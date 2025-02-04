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
    
    init(browser: MCNearbyServiceBrowser,
         session: MCSession,
         myPeerId: MCPeerID)
    {
        self.browser = browser
        self.session = session
        self.myPeerId = myPeerId
    }
    convenience init(session: MCSession, myPeerID: MCPeerID, serviceType: String) {
        let newBrowser = MCNearbyServiceBrowser(peer: myPeerID,
                                                serviceType: serviceType)
        self.init(browser: newBrowser, session: session, myPeerId: myPeerID)
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
