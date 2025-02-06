//
//  MPConnectionManager.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/13/24.
//

import Combine
import MultipeerConnectivity
import NearbyInteraction
import os

fileprivate extension String {
    static var serviceName = "SniffMeet"
}

final class MPCManager: NSObject {
    var advertiser: MPCAdvertiser
    var browser: MPCBrowser
    var session: MCSession

    private var cancellables = Set<AnyCancellable>()
    var availablePeers = Set<MCPeerID>()
    var connectedPeerManager: ConnectedPeerManagable
    var isAvailableToBeConnected = CurrentValueSubject<Bool, Never>(false)
    
    init(
        advertiser: MPCAdvertiser,
        browser: MPCBrowser,
        session: MCSession,
        connectedPeerManager: ConnectedPeerManagable = ConnectedPeerManager()
    ) {
        self.advertiser = advertiser
        self.browser = browser
        self.session = session
        self.connectedPeerManager = connectedPeerManager
        super.init()

        self.browser.browser.delegate = self
        self.advertiser.advertiser.delegate = self
        self.bind()
    }
    convenience init?(dataManager: DataLoadable) {
        guard let dog = try? dataManager.loadData(
            forKey: Environment.UserDefaultsKey.dogInfo,
            type: UserInfo.self
        ) else { return nil }
        let myName: String = "\(dog.name)의 \(dog.nickname)"
        let peerID = MCPeerID(displayName: myName)
        let serviceType = String.serviceName
        let session = MCSession(peer: peerID)

        self.init(
            advertiser: MPCAdvertiser(
                session: session,
                myPeerID: peerID,
                serviceType: serviceType
            ),
            browser: MPCBrowser(
                session: session,
                myPeerID: peerID,
                serviceType: serviceType
            ),
            session: session
        )
    }
    deinit {
        browser.browser.delegate = nil
        advertiser.advertiser.delegate = nil
        advertiser.stopAdvertising()
        browser.stopBrowsing()
        session.disconnect()
        SNMLogger.print("deinit MPCManager")
    }
    private func bind() {
        isAvailableToBeConnected
            .sink { [weak self] isAvailable in
                if isAvailable {
                    self?.advertiser.startAdvertising()
                    self?.browser.startBrowsing()
                } else {
                    self?.session.disconnect()
                    self?.session.delegate = nil
                    self?.advertiser.stopAdvertising()
                    self?.browser.stopBrowsing()
                    Task {
                        await self?.connectedPeerManager.disconnect()
                    }
                }
            }
            .store(in: &cancellables)
    }
}

extension MPCManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didNotStartAdvertisingPeer error: Error) {
        SNMLogger.info("Advertiser failed to start: \(error)")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void)
    {
        SNMLogger.info("Received invitation from \(peerID)")
        invitationHandler(true, session)
    }
}

extension MPCManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?)
    {
        if let info = info {
            SNMLogger.info("Found peer with info: \(info)")
        }

        // info에 해당되는 peer에 대해서만 availablepeers에 넣을 수 있다
        SNMLogger.info("ServiceBrowser found peer: \(peerID)")
        guard !self.availablePeers.contains(peerID) else { return }
        self.availablePeers.insert(peerID)
        self.browser.invite(peerID: peerID)
        Task { [weak self] in
            try await Task.sleep(nanoseconds: 100_000_000)
            if (self?.session.connectedPeers.contains(peerID) == false) {
                self?.browser.invite(peerID: peerID)
            }
        }
        SNMLogger.info("availablePeers: \(self.availablePeers)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Task {
            if let connectedPeer = await connectedPeerManager.connectedPeer,
               connectedPeer == peerID
            {
                await connectedPeerManager.disconnect()
            }
        }
        guard let index = availablePeers.firstIndex(of: peerID) else { return }
        self.availablePeers.remove(at: index)
    }
}

extension MPCManager {
    /// 연결된 한명의 피어에게만 데이터를 전송합니다.
    func send(data: Data) async {
        guard let connectedPeer = await connectedPeerManager.connectedPeer,
              availablePeers.contains(connectedPeer)
        else {
            await connectedPeerManager.disconnect()
            return
        }
        do {
            try self.session.send(data, toPeers: [connectedPeer], with: .reliable)
        } catch {
            SNMLogger.error("Fail to send data through mpcSession: \(error.localizedDescription)")
        }
    }
}
