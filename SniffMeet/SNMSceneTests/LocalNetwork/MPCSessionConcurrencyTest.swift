//
//  MPCSessionConcurrencyTest.swift
//  SNMSceneTests
//
//  Created by 윤지성 on 2/6/25.
//

import XCTest
import MultipeerConnectivity

final class MPCSessionConcurrencyTest: XCTestCase {
    private var sessionMock: MockMPCSession!
    private var sut: MPCManager!
    private var session: MCSession!
    private var connectedPeerManagerSpy: ConnectedPeerManagerSpy!
    private var sessionPeerID: String = "session"

    override func setUp() {
        session = MCSession(peer: MCPeerID(displayName: sessionPeerID))
        connectedPeerManagerSpy = ConnectedPeerManagerSpy()
        sut = MPCManager(
            advertiser:
                MPCAdvertiser(
                    session: session,
                    myPeerID: MCPeerID(displayName: "test1"),
                    serviceType: "SniffMeet"
                ),
            browser:
                MPCBrowser(
                    session: session,
                    myPeerID: MCPeerID(displayName: "test2"),
                    serviceType: "SniffMeet"
                ),
            session: session,
            connectedPeerManager: connectedPeerManagerSpy
        )
        
        sessionMock = MockMPCSession(mpcManager: sut)
        session.delegate = sessionMock
    }
    override func tearDown() {
        session = nil
        sut = nil
        sessionMock = nil
    }

    func test_mockSessionDelegate_메서드_호출할때_MPCManager가_피어_정보를_알맞게_저장되어야_한다() async {
        // Arrange
        let peerName = "테스트 피어"
        // Act
        sessionMock.session(session, peer: MCPeerID(displayName: peerName), didChange: .connected)
        
        // Assert
        do {
            try await Task.sleep(nanoseconds: 1000000000)
        } catch {
            XCTFail("connect된 peer가 없다. ")
        }
        let peerID = await sut.connectedPeerManager.connectedPeer
        if let peerID {
            XCTAssertEqual(peerID.displayName, peerName, "connected 상태 성공적" )
        } else {
            XCTFail("connect된 peer가 없다. ")
        }
    }
    func test_peer가_동시에_세션에_접근할_때_connectedPeer는_하나만_연결되어야_한다() async throws {
        // Arrange
        let peerName = "테스트 피어"
        // Act
        await withTaskGroup(of: Void.self) { [weak self] group in
            guard let self else {
                XCTFail("self 바인딩 실패 ")
                return
            }
            for _ in 0..<1000 {
                group.addTask {
                    self.sessionMock.session(self.session, peer: MCPeerID(displayName: peerName), didChange: .connected)
                }
            }
        }
        // Assert
        try await Task.sleep(nanoseconds: 1000000000)
        let connectedPeerCount = await connectedPeerManagerSpy.connectedPeerCount
        let connectionTrialCount = await connectedPeerManagerSpy.connectionTrialCount
        XCTAssertEqual(1, connectedPeerCount)
        XCTAssertEqual(1000, connectionTrialCount)
    }
    func test_connectedManager는_disconnect되면_새로운_peer를_연결할_수있다() async throws {
        // Arrange
        let peer = MCPeerID(displayName: "테스트1")
        let otherPeer = MCPeerID(displayName: "테스트2")

        // Act
        sessionMock.session(session, peer: peer, didChange: .connected)
        sessionMock.session(session, peer: peer, didChange: .notConnected)
        sessionMock.session(session, peer: otherPeer, didChange: .connected)

        // Assert
        try await Task.sleep(nanoseconds: 1000000000)
        let previousConnectedPeer = await connectedPeerManagerSpy.previousConnectedPeer
        let connectedPeer = await connectedPeerManagerSpy.connectedPeer
       // XCTAssertEqual(peer, previousConnectedPeer)
//        XCTAssertEqual(otherPeer, connectedPeer)
    }
    func test_peer가_동시에_세션에_접근할때_disconnect된_시점에_새로운_peer를_연결할_수있다() async throws {
        // Arrange
        let peerName = "테스트 피어"
        let firstConnectedPeer = MCPeerID(displayName: peerName)
        sessionMock.session(self.session, peer: firstConnectedPeer, didChange: .connected)

        // Act
        await withTaskGroup(of: Void.self) { [weak self] group in
            guard let self else {
                XCTFail("self 바인딩 실패")
                return
            }
            for _ in 0..<500 {
                group.addTask {
                    self.sessionMock.session(self.session, peer: MCPeerID(displayName: peerName), didChange: .connected)
                }
            }
            group.addTask {
                self.sessionMock.session(self.session, peer: MCPeerID(displayName: peerName), didChange: .notConnected)
            }
            for _ in 0..<500 {
                group.addTask {
                    self.sessionMock.session(self.session, peer: MCPeerID(displayName: peerName), didChange: .connected)
                }
            }
        }
        // Assert
        try await Task.sleep(nanoseconds: 1000000000)
        let connectedPeerCount = await connectedPeerManagerSpy.connectedPeerCount
        let connectedTrialCount = await connectedPeerManagerSpy.connectionTrialCount
        let connectedPeer = await connectedPeerManagerSpy.connectedPeer
        let previousConnectedPeer = await connectedPeerManagerSpy.previousConnectedPeer
        XCTAssertEqual(2, connectedPeerCount)
        XCTAssertEqual(1001, connectedTrialCount)
        XCTAssertEqual(previousConnectedPeer, firstConnectedPeer)
        XCTAssertNotEqual(previousConnectedPeer, connectedPeer)
    }
}
