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
    var profilePublisher: CurrentValueSubject<DogDTO?, Never>  { get set }
    var transmissionFlag: Set<String> { get set }
    var isTransitioned: Bool { get set }
    var triedBefore: Bool { get set }

    func execute()
    func loadProfileData()
    func reset(mpcManager: MPCManager)
}

final class TargetedProfileDropUseCaseImpl: NSObject, TargetedProfileDropUseCase {
    var profilePublisher: CurrentValueSubject<DogDTO?, Never> = CurrentValueSubject(nil)
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
        profilePublisher.value = nil
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
    }
    
    func loadProfileData() {
        do {
            let dog = try dataManager.loadData(
                forKey: Environment.UserDefaultsKey.dogInfo,
                type: UserInfo.self
            )
            guard let userID = SessionManager.shared.session?.user?.userID else { return }
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
                
                guard let profileData = self?.profileData else { return }
                if self?.transmissionFlag.contains(Context.peerReceived) == false {
                    await self?.mpcManager.send(data: profileData)
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
    }
}
