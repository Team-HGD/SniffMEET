//
//  FindMateUseCase.swift
//  SniffMeet
//
//  Created by Kelly Chui on 1/14/25.
//
import Combine
import Foundation
import MultipeerConnectivity
import NearbyInteraction

protocol NearByProfileDropUseCase {
    var profilePublisher: CurrentValueSubject<DogDTO?, Never>  { get set }
    var isNIConnected: CurrentValueSubject<Bool, Never> { get set }
    var transmissionFlag: Set<String> { get set }
    var isTransitioned: Bool { get set }
    var triedBefore: Bool { get set }

    func execute()
    func loadProfileData()
    func reset(mpcManager: MPCManager, nimanager: NIManager)
    func isTimeOut() -> Bool
}

final class NearByProfileDropUseCaseImpl: NSObject, NearByProfileDropUseCase {
    var profilePublisher: CurrentValueSubject<DogDTO?, Never> = CurrentValueSubject(nil)
    var startDate: Date?
    var isNIConnected: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    var transmissionFlag: Set<String>
    var isTransitioned: Bool = false
    var triedBefore: Bool = false

    let dataManager: DataLoadable
    private var niManager: NIManager
    private var mpcManager: MPCManager
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    private var profileData: Data? = nil
    private var receivedFlagData: Data? = nil

    private var recentInvalidMPCSession: MCSession?
    private var recentInvalidNISession: NISession?

    init(dataManager: DataLoadable, niManager: NIManager, mpcManager: MPCManager) {
        self.dataManager = dataManager
        self.niManager = niManager
        self.mpcManager = mpcManager
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        transmissionFlag = []

        super.init()
        niManager.niSession?.delegate = self
        mpcManager.session.delegate = self
        encodeFlagData()
        loadProfileData()
    }
    
    func reset(mpcManager: MPCManager, nimanager: NIManager) {
        isNIConnected.value = false
        profilePublisher.value = nil
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
            receivedFlagData = try encoder.encode(MPCProfileDropDTO(
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
        startDate = Date()
    }
    
    func loadProfileData() {
        do {
            let dog = try dataManager.loadData(
                forKey: Environment.UserDefaultsKey.dogInfo,
                type: UserInfo.self)
            let userID = try SupabaseSessionManager.shared.userID.get()
            let imageURL = try? dataManager.loadData(
                forKey: Environment.UserDefaultsKey.profileImage,
                type: String.self
            )

            let dogProfile = DogDTO(id: userID,
                name: dog.name,
                keywords: dog.keywords,
                profileImage: imageURL
            )
            let profileDropDTO = MPCProfileDropDTO(
                token: nil,
                profile: dogProfile,
                transitionMessage: nil
            )
            profileData = try encoder.encode(profileDropDTO)
        } catch {
            SNMLogger.error("loadData error : \(error)")
        }
    }
    func isTimeOut() -> Bool{
        guard let startDate else { return false }
        return startDate.secondsDifferenceFromNow() >= 60
    }
}
// MARK: - MCSessionDelegate
extension NearByProfileDropUseCaseImpl: MCSessionDelegate {
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
                    let data = try encoder.encode(
                        MPCProfileDropDTO(
                            token: token,
                            profile: nil,
                            transitionMessage: nil)
                    )
                    await mpcManager.send(data: data)
                } catch {
                    SNMLogger.error(error.localizedDescription)
                }
            }
        default:
            break
        }
    }

    // 수신
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard session !== recentInvalidMPCSession else { return }

        Task { [weak self] in
            do {
                let receivedData = try self?.decoder.decode(MPCProfileDropDTO.self, from: data)
                if let token = receivedData?.token,
                   let niConnected = self?.niManager.handleReceivedDiscoveryToken(token) {
                    self?.isNIConnected.send(niConnected)
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

// MARK: - TryProfileDropUseCaseImpl+NISessionDelegate

extension NearByProfileDropUseCaseImpl: NISessionDelegate {
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

extension NearByProfileDropUseCaseImpl {
    private enum Context {
        static let minDistance: Float = 0.09
        static let maxDistance: Float = 0.15
        static let minDirection: simd_float3 = simd_float3(-0.6, -0.3, -1.0)
        static let maxDirection: simd_float3 = simd_float3(1.2, 0.6, -2.0)
        static let received: String = "received"
        static let peerReceived: String = "나 받았어"
    }
}
