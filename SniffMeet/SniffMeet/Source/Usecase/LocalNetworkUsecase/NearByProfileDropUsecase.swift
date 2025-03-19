//
//  FindMateUsecase.swift
//  SniffMeet
//
//  Created by Kelly Chui on 1/14/25.
//
import Combine
import Foundation
import MultipeerConnectivity
import NearbyInteraction

protocol NearByProfileDropUsecase {
    var profilePublisher: PassthroughSubject<DogDTO?, Never>  { get set }
    var isConnected: PassthroughSubject<ConnectionState, Never> { get set }
    var transmissionFlag: Set<String> { get set }
    var isTransitioned: Bool { get set }
    var triedBefore: Bool { get set }

    func execute()
    func loadProfileData()
    func reset(mpcManager: MPCManager, nimanager: NIManager)
}

final class NearByProfileDropUsecaseImpl: NSObject, NearByProfileDropUsecase {
    var profilePublisher: PassthroughSubject<DogDTO?, Never> = PassthroughSubject()
    var isConnected: PassthroughSubject<ConnectionState, Never> = PassthroughSubject()
    var cancellable: AnyCancellable? = nil

    var transmissionFlag: Set<String>
    var isTransitioned: Bool = false
    var triedBefore: Bool = false

    let dataManager: DataLoadable
    private var niManager: NIManager
    private var mpcManager: MPCManager
    let jsonEncoder: JSONEncoder
    let jsonDecoder: JSONDecoder
    private var profileData: Data? = nil
    private var receivedFlagData: Data? = nil

    private var recentInvalidMPCSession: MCSession?
    private var recentInvalidNISession: NISession?

    init(
        dataManager: DataLoadable,
        niManager: NIManager,
        mpcManager: MPCManager,
        jsonEncoder: JSONEncoder = JSONEncoder(),
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.dataManager = dataManager
        self.niManager = niManager
        self.mpcManager = mpcManager
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        transmissionFlag = []

        super.init()
        niManager.niSession?.delegate = self
        mpcManager.session.delegate = self
        encodeFlagData()
        loadProfileData()
    }
    
    func reset(mpcManager: MPCManager, nimanager: NIManager) {
        transmissionFlag = []
        isTransitioned = false
        triedBefore = false

        recentInvalidMPCSession = self.mpcManager.session
        recentInvalidNISession = self.niManager.niSession

        self.mpcManager = mpcManager
        self.niManager = nimanager
        self.niManager.niSession?.delegate = self
        self.mpcManager.session.delegate = self
    }
    
    func encodeFlagData() {
        do {
            receivedFlagData = try jsonEncoder.encode(MPCProfileDropDTO(
                token: nil,
                profile: nil,
                transitionMessage: Context.peerReceived))
        } catch {
            SNMLogger.error("Fail to encode transmissionData")
        }
    }
    
    func execute() {
        triedBefore = true
        mpcManager.isAvailableToBeConnected.send(true)
        
        cancellable = Timer.publish(every: Context.connectionTimeLimit, on: .current, in: .common)
            .autoconnect()
            .sink { _ in
                Task { [weak self] in
                    self?.isConnected.send(.cannotFindPeer)
                    self?.cancellable?.cancel()
                }
            }
    }
    
    func loadProfileData() {
        do {
            let dog = try dataManager.loadData(
                forKey: Environment.UserDefaultsKey.profileInfo,
                type: ProfileInfo.self)
            let userID = try SupabaseSessionManager.shared.userID.get()
            let imageName = try? dataManager.loadData(
                forKey: Environment.UserDefaultsKey.profileImageName,
                type: String.self
            )

            let dogProfile = DogDTO(
                id: userID,
                name: dog.name,
                keywords: dog.keywords,
                profileImageName: imageName
            )
            let profileDropDTO = MPCProfileDropDTO(
                token: nil,
                profile: dogProfile,
                transitionMessage: nil
            )
            profileData = try jsonEncoder.encode(profileDropDTO)
        } catch {
            SNMLogger.error("loadData error : \(error)")
        }
    }
    
    func setTimer() {
        cancellable = Timer.publish(every: Context.connectionTimeLimit, on: .current, in: .common)
            .autoconnect()
            .sink { _ in
                Task { [weak self] in // 30초가 지나고 프로필 드랍이 진행되지 않으면 연결 실패 처리
                    self?.isConnected.send(.failure)
                    self?.cancellable?.cancel()
                }
            }
    }
    
    func deleteTimer() {
        cancellable?.cancel()
    }
}
// MARK: - MCSessionDelegate
extension NearByProfileDropUsecaseImpl: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard session !== recentInvalidMPCSession else { return }
        
        SNMLogger.info("peer \(peerID) didChangeState: \(state.rawValue)")
        switch state {
        case .connected:
            Task {
                do {
                    SNMLogger.log("successfully connected to MPCSession: \(session.connectedPeers) session \(session)")
                    await mpcManager.connectedPeerManager.connect(peer: peerID)
                    guard let token = niManager.discoveryToken() else { return }
                    let data = try jsonEncoder.encode(
                        MPCProfileDropDTO(token: token, profile: nil, transitionMessage: nil)
                    )
                    await mpcManager.send(data: data)
                } catch {
                    SNMLogger.error(error.localizedDescription)
                }
            }
            cancellable?.cancel()
            setTimer()
        case .notConnected:
            isConnected.send(.failure)
            deleteTimer()
        default:
            break
        }
    }

    // 수신
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard session !== recentInvalidMPCSession else { return }

        Task { [weak self] in
            do {
                let receivedData = try self?.jsonDecoder.decode(MPCProfileDropDTO.self, from: data)
                if let token = receivedData?.token,
                   let niConnected = self?.niManager.handleReceivedDiscoveryToken(token) {
                    let connectionsState: ConnectionState = niConnected ? .successNISession : .failure
                    self?.isConnected.send(connectionsState)
                } else if let profile = receivedData?.profile,
                          let receivedFlagData = self?.receivedFlagData { // 프로필 데이터
                    self?.profilePublisher.send(profile)
                    await self?.mpcManager.send(data: receivedFlagData)
                } else if let message = receivedData?.transitionMessage { // 수신 여부 플래그
                    self?.transmissionFlag.insert(message)
                }
            } catch {
                SNMLogger.error("Failed to decode received data: \(error)")
            }
            if self?.transmissionFlag.contains(Context.peerReceived) == true
                && self?.isTransitioned == true {
                self?.niManager.endSession()
                self?.mpcManager.isAvailableToBeConnected.send(false)
                self?.deleteTimer()
            }
        }
    }

    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        SNMLogger.error("Receiving streams is not supported")
    }

    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        SNMLogger.error("Receiving resources is not supported")
    }

    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: (any Error)?
    ) {
        SNMLogger.error("Receiving resources is not supported")
    }
}

// MARK: - TryProfileDropUsecaseImpl+NISessionDelegate

extension NearByProfileDropUsecaseImpl: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject])  {
        guard session !== recentInvalidNISession else { return }

        guard let nearbyObject = nearbyObjects.first else { return }
        let distance = nearbyObject.distance ?? 0
        Task { [weak self] in
            guard (distance > Context.minDistance &&
                    distance < Context.maxDistance),
            let profileData = self?.profileData else { return }
            if self?.transmissionFlag.contains(Context.peerReceived) == false {
                await self?.mpcManager.send(data: profileData)
                try await Task.sleep(nanoseconds: 2000000000)
            }
        }
    }

    func sessionWasSuspended(_ session: NISession) {
        SNMLogger.log("NearbyInteraction session suspended.")
    }
    func sessionSuspensionEnded(_ session: NISession) {
        SNMLogger.log("NearbyInteraction session suspension ended.")
    }
    func session(_ session: NISession, didInvalidateWith error: Error) {
        SNMLogger.error("NearbyInteraction session invalidated: \(error)")
    }
    func sessionDidStartRunning(_ session: NISession) {
        SNMLogger.print("NISession did start running: \(session)")
    }
}

extension NearByProfileDropUsecaseImpl {
    private enum Context {
        static let minDistance: Float = 0.09
        static let maxDistance: Float = 0.15
        static let minDirection: simd_float3 = simd_float3(-0.6, -0.3, -1.0)
        static let maxDirection: simd_float3 = simd_float3(1.2, 0.6, -2.0)
        static let connectionTimeLimit: Double = 30.0
        static let received: String = "received"
        static let peerReceived: String = "나 받았어"
    }
}
