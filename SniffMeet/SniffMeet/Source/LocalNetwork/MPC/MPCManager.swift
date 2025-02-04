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

extension String {
    static var serviceName = "SniffMeet"
}

final class MPCManager: NSObject {
    let advertiser: MPCAdvertiser
    let browser: MPCBrowser
    let session: MCSession
    let mypeerID: MCPeerID
    private let encoder: JSONEncoder

    var availablePeers = Set<MCPeerID>()
    var connectedPeerManager: ConnectedPeerManager
    private var cancellables = Set<AnyCancellable>()
    var receivedTokenPublisher = PassthroughSubject<Data, Never>()
    var receivedDataPublisher = PassthroughSubject<DogProfileDTO, Never>()
    var receivedViewTransitionPublisher = PassthroughSubject<String, Never>()
    var isAvailableToBeConnected = CurrentValueSubject<Bool, Never>(false)

    init(advertiser: MPCAdvertiser, browser: MPCBrowser, session: MCSession, mypeerID: MCPeerID) {
        self.advertiser = advertiser
        self.browser = browser
        self.session = session
        self.mypeerID = mypeerID
        encoder = JSONEncoder()
        connectedPeerManager = ConnectedPeerManager()
        super.init()

        self.browser.browser.delegate = self
        self.advertiser.advertiser.delegate = self
        self.bind()
    }
    
    convenience init(nickName: String) {
        let yourName = nickName
        let peerID = MCPeerID(displayName: yourName)
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
            session: session,
            mypeerID: peerID
        )
    }
    deinit {
        advertiser.stopAdvertising()
        browser.stopBrowsing()
    }

    private func bind() {
        isAvailableToBeConnected
            .sink { [weak self] isAvailable in
                if isAvailable {
                    self?.advertiser.startAdvertising()
                    self?.browser.startBrowsing()
                } else {
                    self?.advertiser.stopAdvertising()
                    self?.browser.stopBrowsing()
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
//        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
//            if (self?.session.connectedPeers.contains(peerID) == false) {
//                self?.browser.invite(peerID: peerID)
//            }
//        }
        SNMLogger.info("availablePeers: \(self.availablePeers)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard let index = availablePeers.firstIndex(of: peerID) else { return }
        self.availablePeers.remove(at: index)
    }
}

extension MPCManager {
    /// 연결된 한명의 피어에게만 데이터를 전송합니다.
    func send(data: Data) async {
        guard let connectedPeer = await connectedPeerManager.connectedPeer else { return }
        do {
            try self.session.send(data, toPeers: [connectedPeer], with: .reliable)
        } catch {
            SNMLogger.error("DogProfileInfo 전송 실패 \(error.localizedDescription)")
        }
    }
}

// connected peer에 대해서만 동시성 문제 발생 예상
actor ConnectedPeerManager {
    var connectedPeer: MCPeerID?
    
    func connect(peer: MCPeerID) {
        if connectedPeer != nil { return }
        connectedPeer = peer
    }
    func disconnect() {
        connectedPeer = nil
    }
}
