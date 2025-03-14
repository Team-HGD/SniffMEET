//
//  TargetedProfileDropUsecase.swift
//  SniffMeet
//
//  Created by 윤지성 on 2/11/25.
//
import Combine
import Foundation
import MultipeerConnectivity

protocol TargetedProfileDropUsecase {
    var profilePublisher: PassthroughSubject<DogDTO?, Never>  { get set }
    var isConnected: PassthroughSubject<ConnectionState, Never> { get set }
    var transmissionFlag: Set<String> { get set }
    var isTransitioned: Bool { get set }
    var triedBefore: Bool { get set }

    func execute()
    func loadProfileData()
    func reset(mpcManager: MPCManager)
    func mcBrowserViewController() -> MCBrowserViewController
}

final class TargetedProfileDropUsecaseImpl: NSObject, TargetedProfileDropUsecase {
    var profilePublisher: PassthroughSubject<DogDTO?, Never> = PassthroughSubject()
    var isConnected: PassthroughSubject<ConnectionState, Never> = PassthroughSubject()
    private var timeLimitCancellable: AnyCancellable? = nil
    private var sendProfileCancellable: AnyCancellable? = nil 
    var transmissionFlag: Set<String>
    var isTransitioned: Bool = false
    var triedBefore: Bool = false

    private let dataManager: DataLoadable
    private var mpcManager: MPCManager
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    private var profileData: Data? = nil
    private var receivedFlagData: Data? = nil
    private var recentInvalidMPCSession: MCSession?

    init(
        dataManager: DataLoadable,
        mpcManager: MPCManager,
        jsonEncoder: JSONEncoder = JSONEncoder(),
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.dataManager = dataManager
        self.mpcManager = mpcManager
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        transmissionFlag = []

        super.init()
        mpcManager.session.delegate = self
        mpcManager.inviteAutomatically = false
        encodeFlagData()
        loadProfileData()
    }
    
    func reset(mpcManager: MPCManager) {
        transmissionFlag = []
        isTransitioned = false
        triedBefore = false

        recentInvalidMPCSession = self.mpcManager.session
        self.mpcManager = mpcManager
        mpcManager.inviteAutomatically = false
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
    
    func execute()  {
        timeLimitCancellable?.cancel()
        triedBefore = true
        mpcManager.isAvailableToBeConnected.send(true)
        
        timeLimitCancellable = Timer.publish(every: Context.connectionTimeLimit, on: .current, in: .common)
            .autoconnect()
            .sink { _ in
                Task { [weak self] in
                    self?.isConnected.send(.cannotFindPeer)
                    self?.timeLimitCancellable?.cancel()
                }
            }
    }
    
    func loadProfileData() {
        do {
            let dog = try dataManager.loadData(
                forKey: Environment.UserDefaultsKey.dogInfo,
                type: ProfileInfo.self
            )
            guard let userID = try? SupabaseSessionManager.shared.userID.get() else { return }
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
            profileData = try jsonEncoder.encode(profileDropDTO)
        } catch {
            SNMLogger.error("loadData error : \(error)")
        }
    }
    func mcBrowserViewController() -> MCBrowserViewController {
        mpcManager.serviceBrowser
    }
    func bindTimer() {
        timeLimitCancellable?.cancel()
        
        sendProfileCancellable = Timer.publish(every: Context.minimumDuration, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                Task { [weak self] in
                    // connectedPeer가 없거나 수신플래그를 받으면 타이머 종료
                    self?.checkProfileDropEnd()
                    guard let profileData = self?.profileData else { return }
                    await self?.mpcManager.send(data: profileData)
                }
            }
        timeLimitCancellable = Timer.publish(every: Context.connectionTimeLimit, on: .main, in: .common).autoconnect()
            .sink { _ in
                Task { [weak self] in
                    // connectedPeer가 없거나 수신플래그를 받으면 타이머 종료
                    self?.isConnected.send(.failure)
                    self?.timeLimitCancellable?.cancel()
                }
            }
    }
    func checkProfileDropEnd() {
        Task { [weak self] in
            guard await self?.mpcManager.connectedPeerManager.connectedPeer != nil &&
                    self?.transmissionFlag.contains(Context.peerReceived) != true else {
                self?.sendProfileCancellable?.cancel()
                return
            }
        }
        if transmissionFlag.contains(Context.peerReceived) == true
            && isTransitioned == true {
            mpcManager.isAvailableToBeConnected.send(false)
            isConnected.send(.finished)
            mpcManager.session.disconnect()
        }
    }
}
// MARK: - MCSessionDelegate
extension TargetedProfileDropUsecaseImpl: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard session !== recentInvalidMPCSession else { return }
        SNMLogger.info("peer \(peerID) didChangeState: \(state.rawValue)")
        
        switch state {
        case .connected:
            Task { [weak self] in
                SNMLogger.log("successfully connected to MPCSession: \(session.connectedPeers) session \(session)")
                await self?.mpcManager.connectedPeerManager.connect(peer: peerID)
                self?.isConnected.send(.successMPCSession)
                
                guard let profileData = self?.profileData else { return }
                await self?.mpcManager.send(data: profileData)
            }
            bindTimer()
        case .connecting:
            isConnected.send(.connecting)
        case .notConnected:
            sendProfileCancellable?.cancel()
            isConnected.send(.failure)
            Task { [weak self] in
                await self?.mpcManager.connectedPeerManager.disconnect()
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
                let receivedData = try self?.jsonDecoder.decode(MPCProfileDropDTO.self, from: data)
                
                if let profile = receivedData?.profile,
                   let receivedFlagData = self?.receivedFlagData { // 프로필 데이터
                    self?.profilePublisher.send(profile)
                    await self?.mpcManager.send(data: receivedFlagData)
                } else if let message = receivedData?.transitionMessage { // 수신 여부 플래그
                    self?.transmissionFlag.insert(message)
                }
            } catch {
                SNMLogger.error("Failed to decode received data: \(error)")
            }
        }
        checkProfileDropEnd()
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

extension TargetedProfileDropUsecaseImpl {
    private enum Context {
        static let received: String = "received"
        static let peerReceived: String = "나 받았어"
        static let minimumDuration: Double = 1.0
        static let connectionTimeLimit: Double = 30.0
    }
}
