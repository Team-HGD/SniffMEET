//
//  MPCAdvertiser.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/13/24.
//
import Combine
import MultipeerConnectivity
import os

final class MPCAdvertiser {
    let advertiser: MCNearbyServiceAdvertiser
    let session: MCSession
    let myPeerID: MCPeerID

    static var sharedAdvertiser: MCNearbyServiceAdvertiser?

//    var receivedInvite = PassthroughSubject<Bool, Never>()

    @Published var receivedInviteFrom: MCPeerID?
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?

    init(advertiser: MCNearbyServiceAdvertiser,
         session: MCSession,
         myPeerID: MCPeerID,
         receivedInviteFrom: MCPeerID? = nil,
         invitationHandler: ((Bool, MCSession?) -> Void)? = nil)
    {
        self.advertiser = advertiser
        self.session = session
        self.myPeerID = myPeerID
        self.receivedInviteFrom = receivedInviteFrom
        self.invitationHandler = invitationHandler
    }
    
    convenience init(session: MCSession, myPeerID: MCPeerID, serviceType: String) {
        if let existingAdvertiser = MPCAdvertiser.sharedAdvertiser {
            self.init(advertiser: existingAdvertiser, session: session, myPeerID: myPeerID)
        } else {
            let newAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID,
                                                          discoveryInfo: nil,
                                                          serviceType: serviceType)
            MPCAdvertiser.sharedAdvertiser = newAdvertiser
            self.init(advertiser: newAdvertiser, session: session, myPeerID: myPeerID)
            SNMLogger.log("Created new MCNearbyServiceAdvertiser instance")
        }
    }

    deinit {
        if MPCAdvertiser.sharedAdvertiser === advertiser {
            MPCAdvertiser.sharedAdvertiser = nil
            SNMLogger.log("MPCAdvertiser deinit")
        }
    }

    func startAdvertising() {
        advertiser.startAdvertisingPeer()
        SNMLogger.log("start advertising")
    }
    
    func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
//        receivedInvite.send(false)
        SNMLogger.log("stop advertising")
    }
}
