//
//  SupabaseDBTests.swift
//  SupabaseTests
//
//  Created by Kelly Chui on 6/28/25.
//

import Foundation
import XCTest

final class SupabaseDBRequestBuilderTests: XCTestCase {
    
    func testFetchRequestBuilder_setsQueryCorrectly() async throws {
        let mockNetwork = MockNetworkProvider()
        let builder = SupabaseDBFetchRequestBuilder(
            networkProvider: mockNetwork,
            accessToken: "token"
        )

        _ = try await builder
            .setTable("users")
            .setQuery(SupabaseQueryParameter.equal("id", 1))
            .request()

        XCTAssertEqual(mockNetwork.lastRequest?.endpoint.path, "rest/v1/users")
        XCTAssertEqual(mockNetwork.lastRequest?.endpoint.query, ["id": "eq1"])
    }

    func testInsertRequestBuilder_setsDataCorrectly() async throws {
        let mockNetwork = MockNetworkProvider()
        let builder = SupabaseDBInsertRequestBuilder(
            networkProvider: mockNetwork,
            accessToken: "token"
        )

        let data = try JSONEncoder().encode(["name": "Hello World!"])
        _ = try await builder
            .setTable("users")
            .setData(data)
            .request()
        guard case .compositePlain(_, let body) = mockNetwork.lastRequest?.requestType else {
            XCTFail("바디 바인딩 실패")
            return
        }
        XCTAssertEqual(mockNetwork.lastRequest?.endpoint.path, "rest/v1/users")
        XCTAssertEqual(body, data)
    }

    func testDeleteRequestBuilder_setsQueryCorrectly() async throws {
        let mockNetwork = MockNetworkProvider()
        let builder = SupabaseDBDeleteRequestBuilder(
            networkProvider: mockNetwork,
            accessToken: "token"
        )

        _ = try await builder
            .setTable("users")
            .setQuery(SupabaseQueryParameter.equal("id", 1))
            .request()

        XCTAssertEqual(mockNetwork.lastRequest?.endpoint.path, "rest/v1/users")
        XCTAssertEqual(mockNetwork.lastRequest?.endpoint.query, ["id": "eq1"])
    }

    func testUpdateRequestBuilder_setsQueryAndDataCorrectly() async throws {
        let mockNetwork = MockNetworkProvider()
        let builder = SupabaseDBUpdateRequestBuilder(
            networkProvider: mockNetwork,
            accessToken: "token"
        )

        let data = try JSONEncoder().encode(["name": "Kelly"])
        _ = try await builder.setTable("users")
            .setQuery(SupabaseQueryParameter.equal("id", 1))
            .setData(data)
            .request()
        
        guard case .compositePlain(_, let body) = mockNetwork.lastRequest?.requestType else {
            XCTFail("바디 바인딩 실패")
            return
        }
        
        XCTAssertEqual(mockNetwork.lastRequest?.endpoint.path, "rest/v1/users")
        XCTAssertEqual(body, data)
        XCTAssertEqual(mockNetwork.lastRequest?.endpoint.query, ["id": "eq1"])
    }

    func testRPCRequestBuilder_setsAllCorrectly() async throws {
        let mockNetwork = MockNetworkProvider()
        let builder = SupabaseDBRPCRequestBuilder(
            networkProvider: mockNetwork,
            accessToken: "token"
        )

        let data = try JSONEncoder().encode(["arg": 42])
        _ = try await builder
            .setTable("rpc")
            .setQuery(SupabaseQueryParameter.custom("rpc", "World"))
            .setData(data)
            .request()
        
        guard case .compositePlain(let _, let body) = mockNetwork.lastRequest?.requestType else {
            XCTFail("바디 바인딩 실패")
            return
        }

        XCTAssertEqual(mockNetwork.lastRequest?.endpoint.path, "rest/v1/rpc")
        XCTAssertEqual(body, data)
        XCTAssertEqual(mockNetwork.lastRequest?.endpoint.query, ["rpc": "World"])
    }
}
