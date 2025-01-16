//
//  NIManager.swift
//  SniffMeet
//
//  Created by 배현진 on 11/14/24.
//

import Combine
import NearbyInteraction

final class NIManager: NSObject {
    var niSession: NISession?
    private var cancellables = Set<AnyCancellable>()
    var mpcManager: MPCManager

    init(mpcManager: MPCManager) {
        self.mpcManager = mpcManager
        super.init()
        setupNISession()
    }

    func setupNISession() {
        niSession = NISession()
    }

    func sendDiscoveryToken() {
        guard let niSession = niSession, let discoveryToken = niSession.discoveryToken else {
            SNMLogger.log("Discovery token is not available.")
            return
        }
        do {
            let tokenData = try NSKeyedArchiver.archivedData(
                withRootObject: discoveryToken,
                requiringSecureCoding: true
            )
            mpcManager.sendToken(discoveryToken: tokenData)
            SNMLogger.log("Discovery token sent to peer.")
        } catch {
            SNMLogger.error("Failed to encode discovery token: \(error)")
        }
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
        SNMLogger.log("NI 세션 종료")
        niSession?.invalidate()
        mpcManager.session.disconnect()
        mpcManager.isAvailableToBeConnected = false
        SNMLogger.log("MPC 세션 종료")
    }
}
