//
//  NIManager.swift
//  SniffMeet
//
//  Created by 배현진 on 11/14/24.
//

import Combine
import NearbyInteraction

final class NIManager {
    var niSession: NISession?
    private var cancellables = Set<AnyCancellable>()

    init() {
        niSession = NISession()
    }

    func discoveryToken() -> Data? {
        guard let niSession = niSession, let discoveryToken = niSession.discoveryToken else {
            SNMLogger.log("Discovery token is not available.")
            return nil
        }
        return try? NSKeyedArchiver.archivedData(
            withRootObject: discoveryToken,
            requiringSecureCoding: true
        )
    }

    // discoveryToken 수신 처리
    func handleReceivedDiscoveryToken(_ data: Data) -> Bool {
        do {
            guard let token = try NSKeyedUnarchiver.unarchivedObject(
                ofClass: NIDiscoveryToken.self,
                from: data
            ) else {
                SNMLogger.log("Invalid discovery token received.")
                return false
            }

            let config = NINearbyPeerConfiguration(peerToken: token)
            niSession?.run(config)
            SNMLogger.log("NearbyInteraction session started with received discovery token.")
            return true
        } catch {
            SNMLogger.error("Failed to decode discovery token: \(error)")
            return false
        }
    }

    func endSession() {
        niSession?.invalidate()
    }
}
