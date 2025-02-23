//
//  TargetedProfileDropUseCase.swift
//  SniffMeet
//
//  Created by 윤지성 on 2/11/25.
//
import Combine
import Foundation
import MultipeerConnectivity

protocol TargetedProfileDropUseCase {
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

final class TargetedProfileDropUseCaseImpl: NSObject, TargetedProfileDropUseCase {
    var profilePublisher: PassthroughSubject<DogDTO?, Never> = PassthroughSubject()
    var isConnected: PassthroughSubject<ConnectionState, Never> = PassthroughSubject()
    private var cancellable: AnyCancellable? = nil

    var transmissionFlag: Set<String>
    var isTransitioned: Bool = false
    var triedBefore: Bool = false

    let dataManager: DataLoadable
    private var mpcManager: MPCManager
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    private var profileData: Data? = nil
    private var receivedFlagData: Data? = nil
    private var recentInvalidMPCSession: MCSession?

    init(dataManager: DataLoadable, mpcManager: MPCManager) {
        self.dataManager = dataManager
        self.mpcManager = mpcManager
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
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
            receivedFlagData = try encoder.encode(MPCProfileDropDTO(
                token: nil,
                profile: nil,
                transitionMessage: Context.peerReceived))
        } catch {
            SNMLogger.error("Fail to encode transmissionData")
        }
    }
    
    func execute()  {
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
                forKey: Environment.UserDefaultsKey.dogInfo,
                type: UserInfo.self
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
            profileData = try encoder.encode(profileDropDTO)
        } catch {
            SNMLogger.error("loadData error : \(error)")
        }
    }
    func mcBrowserViewController() -> MCBrowserViewController {
        mpcManager.serviceBrowser
    }
}
// MARK: - MCSessionDelegate
extension TargetedProfileDropUseCaseImpl: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard session !== recentInvalidMPCSession else { return }
        SNMLogger.info("peer \(peerID) didChangeState: \(state.rawValue)")
        
        switch state {
        case .connected:
            Task { [weak self] in
                SNMLogger.log("successfully connected to MPCSession: \(session.connectedPeers) session \(session)")
                await self?.mpcManager.connectedPeerManager.connect(peer: peerID)
                self?.isConnected.send(.successMPCSession)
            }
            cancellable?.cancel()
            cancellable = Timer.publish(every: Context.profileSendDuration, on: .current, in: .common)
                .autoconnect()
                .sink { _ in
                    Task { [weak self] in
                        // connectedPeer가 없거나 수신플래그를 받으면 타이머 종료
                        guard await self?.mpcManager.connectedPeerManager.connectedPeer != nil
                                && self?.transmissionFlag.contains(Context.peerReceived) != true else { self?.cancellable?.cancel(); return }
                        
                        guard let profileData = self?.profileData else { return }
                        await self?.mpcManager.send(data: profileData)
                    }
                }
        case .connecting:
            isConnected.send(.connecting)
        case .notConnected:
            cancellable?.cancel()
            isConnected.send(.failure)
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
            if self?.transmissionFlag.contains(Context.peerReceived) == true
                && self?.isTransitioned == true {
                self?.mpcManager.isAvailableToBeConnected.send(false)
                session.disconnect()
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

extension TargetedProfileDropUseCaseImpl {
    private enum Context {
        static let received: String = "received"
        static let peerReceived: String = "나 받았어"
        static let profileSendDuration: Double = 2.0
        static let connectionTimeLimit: Double = 30.0
    }
}
