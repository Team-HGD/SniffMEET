//
//  MPCAdvertiser.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/13/24.
//
import MultipeerConnectivity
import os

final class MPCAdvertiser {
    let advertiser: MCNearbyServiceAdvertiser
    let session: MCSession
    let myPeerID: MCPeerID
    
    init(advertiser: MCNearbyServiceAdvertiser,
         session: MCSession,
         myPeerID: MCPeerID)
    {
        self.advertiser = advertiser
        self.session = session
        self.myPeerID = myPeerID
    }
    
    convenience init(session: MCSession, myPeerID: MCPeerID, serviceType: String) {
        let newAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID,
                                                      discoveryInfo: nil,
                                                      serviceType: serviceType)
        self.init(advertiser: newAdvertiser, session: session, myPeerID: myPeerID)
        SNMLogger.log("Created new MCNearbyServiceAdvertiser instance")
    }
    func startAdvertising() {
        advertiser.startAdvertisingPeer()
        SNMLogger.log("start advertising")
    }
    
    func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
        SNMLogger.log("stop advertising")
    }
}
