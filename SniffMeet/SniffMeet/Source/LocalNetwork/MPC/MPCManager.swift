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

final class MPCManager {
    let advertiser: MPCAdvertiser
    let browser: MPCBrowser
    let session: MCSession
    let mypeerID: MCPeerID
    let encoder: JSONEncoder

    private var cancellables = Set<AnyCancellable>()
    @Published var paired: Bool = false

    var receivedTokenPublisher = PassthroughSubject<Data, Never>()
    var receivedDataPublisher = PassthroughSubject<DogProfileDTO, Never>()
    var receivedViewTransitionPublisher = PassthroughSubject<String, Never>()
    var isAvailableToBeConnected: Bool = false {
        didSet {
            if isAvailableToBeConnected {
                advertiser.startAdvertising()
                browser.startBrowsing()
            } else {
                advertiser.stopAdvertising()
                browser.stopBrowsing()
            }

            advertiser.receivedInvite
                .sink { [weak self] bool in
                    SNMLogger.info("receivedInvite : \(bool)")
                    if bool {
                        self?.browser.stopBrowsing()
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    init(advertiser: MPCAdvertiser, browser: MPCBrowser, session: MCSession, mypeerID: MCPeerID) {
        self.advertiser = advertiser
        self.browser = browser
        self.session = session
        self.mypeerID = mypeerID
        encoder = JSONEncoder()
    }
    
    convenience init(yourName: String) {
        let peerID = MCPeerID(displayName: yourName)
        let serviceType = String.serviceName
        let session = MCSession(peer: peerID)

        self.init(advertiser: MPCAdvertiser(session: session,
                                            myPeerID: peerID,
                                            serviceType: serviceType),
                  browser:  MPCBrowser(session: session,
                                       myPeerID: peerID,
                                       serviceType: serviceType),
                  session: session,
                  mypeerID: peerID)
    }
    
    deinit {
        advertiser.stopAdvertising()
        browser.stopBrowsing()
    }

    func sendToken(discoveryToken: Data) {
        guard !session.connectedPeers.isEmpty else { return }

        do {
            let dataToSend = MPCProfileDropDTO(token: discoveryToken, profile: nil, transitionMessage: nil)
            let encodedData = try encoder.encode(dataToSend)
            SNMLogger.info("encodedToken is  \(encodedData)")
            try session.send(encodedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            SNMLogger.error("error sending \(error.localizedDescription)")
        }
    }
    
    func send(data: Data) {
        guard !session.connectedPeers.isEmpty else {
            SNMLogger.log("no one is connected")
            isAvailableToBeConnected = true
            return
        }
        do {
            let decodedData = try JSONDecoder().decode(MPCProfileDropDTO.self, from: data)
            if let flag = decodedData.transitionMessage {
                SNMLogger.log("transitionMessage flag 전송 성공")
            }
            try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            SNMLogger.error("DogProfileInfo 전송 실패 \(error.localizedDescription)")
        }
    }
    func send(viewTransitionInfo: String) {
        guard !session.connectedPeers.isEmpty else { return }

        do {
            let dataToSend = MPCProfileDropDTO(token: nil, profile: nil, transitionMessage: viewTransitionInfo)
            let encodedData = try JSONEncoder().encode(dataToSend)
            SNMLogger.info("encodedToken is  \(encodedData)")
            try session.send(encodedData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            SNMLogger.error("error sending \(error.localizedDescription)")
        }
    }
}
