//
//  MPCBroswer.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/13/24.
//
import MultipeerConnectivity
import os

final class MPCBrowser {
    let browser: MCNearbyServiceBrowser
    let session: MCSession
    let myPeerId: MCPeerID

    static var sharedBrowser: MCNearbyServiceBrowser?


    init(browser: MCNearbyServiceBrowser,
         session: MCSession,
         myPeerId: MCPeerID)
    {
        self.browser = browser
        self.session = session
        self.myPeerId = myPeerId

    }
    
    convenience init(session: MCSession, myPeerID: MCPeerID, serviceType: String) {
        if let existingBrowser = MPCBrowser.sharedBrowser {
            self.init(browser: existingBrowser, session: session, myPeerId: myPeerID)
        } else {
            let newBrowser = MCNearbyServiceBrowser(peer: myPeerID,
                                                    serviceType: serviceType)
            MPCBrowser.sharedBrowser = newBrowser
            self.init(browser: newBrowser, session: session, myPeerId: myPeerID)
        }
    }

    deinit {
        if MPCBrowser.sharedBrowser === browser {
            MPCBrowser.sharedBrowser = nil
            SNMLogger.log("MPCBrowser deinit")
        }
    }

    func startBrowsing() {
        browser.startBrowsingForPeers()
        SNMLogger.log("start Browsing")

    }
    
    func stopBrowsing() {
        browser.stopBrowsingForPeers()
        SNMLogger.log("stop Browsing")
    }

    func invite(peerID: MCPeerID) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        SNMLogger.log("invitePeer peerID")
    }
    
    func invite(peerID: MCPeerID, tokenData: Data) {
        browser.invitePeer(peerID, to: session, withContext: tokenData, timeout: 30)
        SNMLogger.log("invitePeer tokenData")
    }
}
