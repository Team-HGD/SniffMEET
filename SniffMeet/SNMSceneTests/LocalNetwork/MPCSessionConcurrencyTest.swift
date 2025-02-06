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
    private var sessionPeerID: String = "session"

    override func setUp() {
        session = MCSession(peer: MCPeerID(displayName: sessionPeerID))
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
            session: session
        )
        
        sessionMock = MockMPCSession(mpcManager: sut)
        session.delegate = sessionMock
    }

    override func tearDown() {
        session = nil
        sut = nil
        sessionMock = nil
    }

    func test_mockSessionDelegate메서드호출할때_MPCManager가_피어정보를_알맞게_저장하는가() async {
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

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
