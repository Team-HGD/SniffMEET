//
//  MockMPCSession.swift
//  SniffMeet
//
//  Created by 윤지성 on 2/6/25.
//
import MultipeerConnectivity

final class MockMPCSession: NSObject, MCSessionDelegate {
    var connectedState: ConnectedState
    var mpcManager: MPCManager
    
    init(
        connectedState: ConnectedState = .notConnected,
         mpcManager: MPCManager
    ) {
        self.connectedState = connectedState
        self.mpcManager = mpcManager
    }
    
    enum ConnectedState {
        case connecting
        case connected
        case notConnected
    }
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            connectedState = .connected
            Task {
                await mpcManager.connectedPeerManager.connect(peer: peerID)
            }
        case .connecting:
            connectedState = .connecting
        case .notConnected:
            connectedState = .notConnected
        @unknown default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceive method call")
    }
    
    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        print("didReceive stream: InputStream call")
    }

    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        print("didStartReceivingResourceWithName method call")
    }

    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: (any Error)?
    ) {
        print("didFinishReceivingResourceWithName method call")
    }
}
