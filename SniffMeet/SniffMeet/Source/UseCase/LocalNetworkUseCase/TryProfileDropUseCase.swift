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

protocol TryProfileDropUseCase {
    var profilePublisher: CurrentValueSubject<DogDTO?, Never>  { get set }
    var isNIConnected: CurrentValueSubject<Bool, Never> { get set }
    var transmissionFlag: Set<String> { get set }
    var isTransistioned: Bool { get set }
    var triedBefore: Bool { get set }

    func execute()
    func loadProfileData()
    func reset(mpcManager: MPCManager, nimanager: NIManager)
}

final class TryProfileDropUseCaseImpl: NSObject, TryProfileDropUseCase {
    var profilePublisher: CurrentValueSubject<DogDTO?, Never> = CurrentValueSubject(nil)
    var isNIConnected: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    var transmissionFlag: Set<String>
    var isTransistioned: Bool = false
    var triedBefore: Bool = false
    let lock = NSLock()

    let dataManager: DataLoadable
    private var niManager: NIManager
    private var mpcManager: MPCManager
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    private var profileData: Data? = nil
    private var receivedFlagData: Data? = nil
    
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
    }
    func reset(mpcManager: MPCManager, nimanager: NIManager) {
        isNIConnected.value = false
        profilePublisher.value = nil
        transmissionFlag = []
        isTransistioned = false
        triedBefore = false
        
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
    
    func execute()  {
        triedBefore = true
        loadProfileData()
        mpcManager.isAvailableToBeConnected = true
    }
    
    func loadProfileData() {
        do {
            let dog = try dataManager.loadData(
                forKey: Environment.UserDefaultsKey.dogInfo,
                type: UserInfo.self)
            guard let userID = SessionManager.shared.userID else { return }
            let imageURL = try? dataManager.loadData(
                forKey: Environment.UserDefaultsKey.profileImage,
                type: String.self)
            
            let dogProfile = DogDTO( id: userID,
                name: dog.name,
                keywords: dog.keywords,
                profileImage: imageURL
            )
            let profileDropDTO = MPCProfileDropDTO(token: nil, profile: dogProfile, transitionMessage: nil)
            profileData = try encoder.encode(profileDropDTO)
        } catch {
            SNMLogger.error("loadData error : \(error)")
        }
    }
}
// MARK: - MCSessionDelegate
extension TryProfileDropUseCaseImpl: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        SNMLogger.info("peer \(peerID) didChangeState: \(state.rawValue)")
        switch state {
        case .notConnected:
            Task { @MainActor in
                SNMLogger.log("notConnected to MPCSession: \(session.connectedPeers)")
            }
        case .connected:
            Task { @MainActor in
                SNMLogger.log("successfully connected to MPCSession: \(session.connectedPeers)")
                niManager.sendDiscoveryToken()
                niManager.mpcManager.isAvailableToBeConnected = false
            }
        default:
            niManager.mpcManager.isAvailableToBeConnected = false
        }
    }

    // 수신
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        Task {@MainActor [weak self] in
            SNMLogger.info("didReceive bytes \(data.count) bytes")
            do {
                let receivedData = try self?.decoder.decode(MPCProfileDropDTO.self, from: data)
                if let token = receivedData?.token { // 토큰
                    guard let niConnected = self?.niManager.handleReceivedDiscoveryToken(token) else { return }
                    self?.isNIConnected.send(niConnected)
                } else if let profile = receivedData?.profile { // 프로필 데이터
                    self?.profilePublisher.send(profile)
                    guard let receivedFlagData = self?.receivedFlagData else { return }
                    self?.mpcManager.send(data: receivedFlagData)
                    SNMLogger.log("Receive profile data")
                } else if let message = receivedData?.transitionMessage { // 수신 여부 플래그
                    SNMLogger.log("flag message: \(message)")
                    self?.lock.lock()
                    self?.transmissionFlag.insert(message)
                    self?.lock.unlock()
                }
            } catch {
                SNMLogger.error("Failed to decode received data: \(error)")
            }
            if self?.transmissionFlag.contains(Context.peerReceived) == true && self?.isTransistioned == true {
                self?.niManager.endSession()
                SNMLogger.log("End all session")
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

extension TryProfileDropUseCaseImpl: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject])  {
        guard let nearbyObject = nearbyObjects.first else { return }
        let distance = nearbyObject.distance ?? 0
        Task { [weak self] in
            if distance > Context.minDistance && distance < Context.maxDistance {
                SNMLogger.log("조건 만족")

                guard let profileData = self?.profileData else { return }
                if self?.transmissionFlag.contains(Context.peerReceived) == false {
                    self?.mpcManager.send(data: profileData)
                    SNMLogger.log("프로필 데이터 보낸다.")
                    try await Task.sleep(nanoseconds: 2000000000)
                }
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
}

extension TryProfileDropUseCaseImpl {
    private enum Context {
        static let minDistance: Float = 0.09
        static let maxDistance: Float = 0.15
        static let minDirection: simd_float3 = simd_float3(-0.6, -0.3, -1.0)
        static let maxDirection: simd_float3 = simd_float3(1.2, 0.6, -2.0)
        static let received: String = "received"
        static let peerReceived: String = "나 받았어"
    }
}
