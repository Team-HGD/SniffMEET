//
//  ConnectedPeerManager.swift
//  SniffMeet
//
//  Created by sole on 2/6/25.
//

import MultipeerConnectivity

protocol ConnectedPeerManagable {
    var connectedPeer: MCPeerID? { get }
    func connect(peer: MCPeerID) async
    func disconnect() async
}

actor ConnectedPeerManager: @preconcurrency ConnectedPeerManagable {
    var connectedPeer: MCPeerID?

    func connect(peer: MCPeerID) {
        if connectedPeer != nil { return }
        connectedPeer = peer
    }
    func disconnect() {
        connectedPeer = nil
    }
}
