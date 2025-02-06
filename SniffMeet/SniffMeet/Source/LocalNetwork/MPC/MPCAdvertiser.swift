//
//  MPCAdvertiser.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/13/24.
//
import MultipeerConnectivity
import os

final class MPCAdvertiser {
    var advertiser: MCNearbyServiceAdvertiser
    let session: MCSession
    var myPeerID: MCPeerID
    let serviceType: String

    init(advertiser: MCNearbyServiceAdvertiser,
         session: MCSession,
         myPeerID: MCPeerID,
         serviceType: String)
    {
        self.advertiser = advertiser
        self.session = session
        self.myPeerID = myPeerID
        self.serviceType = serviceType
    }
    
    convenience init(session: MCSession, myPeerID: MCPeerID, serviceType: String) {
        let newAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID,
                                                      discoveryInfo: nil,
                                                      serviceType: serviceType)
        self.init(
            advertiser: newAdvertiser,
            session: session,
            myPeerID: myPeerID,
            serviceType: serviceType
        )
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
