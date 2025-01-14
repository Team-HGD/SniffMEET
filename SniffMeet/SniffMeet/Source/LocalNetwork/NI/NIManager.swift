//
//  NIManager.swift
//  SniffMeet
//
//  Created by 배현진 on 11/14/24.
//

import Combine
import MultipeerConnectivity
import NearbyInteraction

final class NIManager: NSObject {
    var niSession: NISession?
    private var cancellables = Set<AnyCancellable>()

    @Published var niPaired: Bool = false
    var mpcManager: MPCManager
    var isViewTransitioning = PassthroughSubject<Bool, Never>()
    var viewTransitionInfo = Set<String>()

    init(mpcManager: MPCManager) {
        self.mpcManager = mpcManager
        super.init()

        setupNISession()
        setupBindings()
    }

    private func setupNISession() {
        niSession = NISession()
    }

    private func setupBindings() {
        // MPC 연결 완료 시 discoveryToken을 주고받기
        mpcManager.$paired
            .receive(on: RunLoop.main)
            .sink { [weak self] isPaired in
                if isPaired {
                    self?.sendDiscoveryToken()
                }
            }
            .store(in: &cancellables)

        // MPC로 discoveryToken 수신 시 NI 세션 업데이트
        mpcManager.receivedTokenPublisher
            .sink { [weak self] token in
                self?.handleReceivedDiscoveryToken(token)
            }
            .store(in: &cancellables)

        mpcManager.receivedViewTransitionPublisher
            .sink { [weak self] isViewTransitioning in
                self?.viewTransitionInfo.insert(isViewTransitioning) // receive 메세지가 들어옴
                SNMLogger.info("viewTrnasitionInfo: \(self?.viewTransitionInfo ?? [])")
                
                if self?.viewTransitionInfo.count == 2 {
                    self?.endSession()
                }
            }
            .store(in: &cancellables)
    }

    // discoveryToken 전송
    private func sendDiscoveryToken() {
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
    private func handleReceivedDiscoveryToken(_ data: Data) {
        do {
            guard let token = try NSKeyedUnarchiver.unarchivedObject(
                ofClass: NIDiscoveryToken.self,
                from: data
            ) else {
                SNMLogger.log("Invalid discovery token received.")
                return
            }

            let config = NINearbyPeerConfiguration(peerToken: token)
            niSession?.run(config)
            niPaired = true
            SNMLogger.log("NearbyInteraction session started with received discovery token.")
        } catch {
            SNMLogger.error("Failed to decode discovery token: \(error)")
        }
    }

    func endSession() {
        SNMLogger.log("NI 세션 종료")
        niSession?.invalidate()
        mpcManager.session.disconnect()
        mpcManager.isAvailableToBeConnected = false
        SNMLogger.log("MPC 세션 종료")
        niPaired = false
    }
}
