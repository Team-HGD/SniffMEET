//
//  ConnectedPeerManagerSpy.swift
//  SniffMeet
//
//  Created by sole on 2/6/25.
//

import MultipeerConnectivity

actor ConnectedPeerManagerSpy: @preconcurrency ConnectedPeerManagable {
    var previousConnectedPeer: MCPeerID?
    var connectedPeer: MCPeerID?
    var connectedPeerCount: Int = 0
    var connectionTrialCount: Int = 0

    func connect(peer: MCPeerID) async {
        connectionTrialCount += 1
        guard connectedPeer == nil else { return }
        connectedPeerCount += 1
        connectedPeer = peer
    }
    func disconnect() async {
        if connectedPeer != nil {
            previousConnectedPeer = connectedPeer
        }
        connectedPeer = nil
    }
}
