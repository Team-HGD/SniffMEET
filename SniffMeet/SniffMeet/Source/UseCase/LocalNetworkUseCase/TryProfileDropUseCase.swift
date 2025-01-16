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
    var profilePublisher: CurrentValueSubject<DogProfileDTO?, Never>  { get set }
    var isNIConnected: CurrentValueSubject<Bool, Never> { get set }
    var transmissionFlag: Set<String> { get set }
    var isTransistioned: Bool { get set }

    func execute()
    func loadProfileData()
}

final class TryProfileDropUseCaseImpl: NSObject, TryProfileDropUseCase {
    var profilePublisher: CurrentValueSubject<DogProfileDTO?, Never> = CurrentValueSubject(nil)
    var isNIConnected: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    var transmissionFlag: Set<String>
    var isTransistioned: Bool = false
    let lock = NSLock()

    let dataManager: DataLoadable
    let niManager: NIManager
    let mpcManager: MPCManager
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    var profileData: Data? = nil
    var receivedFlagData: Data? = nil
    
    init(
        dataManager: DataLoadable,
        niManager: NIManager,
        mpcManager: MPCManager
    ) {
        self.dataManager = dataManager
        self.niManager = niManager
        self.mpcManager = mpcManager
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        transmissionFlag = []
        
        super.init()
        niManager.niSession?.delegate = self
        niManager.mpcManager.session.delegate = self
        encodeFlagData()
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
        loadProfileData()
        niManager.mpcManager.isAvailableToBeConnected = true
    }
    
    func loadProfileData() {
        do {
            let dog = try dataManager.loadData(forKey: "dogInfo", type: UserInfo.self)
            guard let userID = SessionManager.shared.session?.user?.userID else { return }
            let dogProfileDTO = DogProfileDTO(
                id: userID,
                name: dog.name,
                keywords: dog.keywords,
                profileImage: dog.profileImage
            )
            let dataToSend = MPCProfileDropDTO(token: nil, profile: dogProfileDTO, transitionMessage: nil)
            profileData = try encoder.encode(dataToSend)
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
            Task { @MainActor in
            }
        }
    }

    // 수신
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        SNMLogger.info("didReceive bytes \(data.count) bytes")
        do {
            let receivedData = try decoder.decode(MPCProfileDropDTO.self, from: data)
            if let token = receivedData.token { // 토큰
                let niConnected =  niManager.handleReceivedDiscoveryToken(token)
                isNIConnected.send(niConnected)
            } else if let profile = receivedData.profile { // 프로필 데이터
                Task { @MainActor [weak self] in
                    self?.profilePublisher.send(profile)
                }
                guard let receivedFlagData else { return }
                // 수신 플래그 송신
                mpcManager.send(data: receivedFlagData)
            } else if let message = receivedData.transitionMessage { // 수신 여부 플래그
                SNMLogger.log("flag message: \(message)")
                lock.lock()
                transmissionFlag.insert(message)
                lock.unlock()
            }
            if transmissionFlag.count == 1 && isTransistioned {
                niManager.endSession()
                isTransistioned = false
            }
        } catch {
            SNMLogger.error("Failed to decode received data: \(error)")
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
    // 송신
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject])  {
        guard let nearbyObject = nearbyObjects.first else { return }
        let distance = nearbyObject.distance ?? 0
        let direction = nearbyObject.direction ?? simd_float3(0.1, 0.1, 0.1)

        if distance > Context.minDistance && distance < Context.maxDistance {
            guard let profileData else { return }
            SNMLogger.log("거리와 방향 조건 만족")
            if !transmissionFlag.contains(Context.peerReceived)  {
                // 프로필 데이터 송신
                Task {
                    SNMLogger.log("강아지 프로필 데이터 전송 ")
                    mpcManager.send(data: profileData)
                    try await Task.sleep(nanoseconds: 6000000000)
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
