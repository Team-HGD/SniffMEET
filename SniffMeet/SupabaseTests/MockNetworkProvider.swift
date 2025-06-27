//
//  MockNetworkProvider.swift
//  SupabaseTests
//
//  Created by Kelly Chui on 6/28/25.
//

import Foundation

final class MockNetworkProvider: NetworkProvider {
    var mockResponse: SNMNetworkResponse?
    var mockError: Error?
    var lastRequest: (any SNMRequestConvertible)?

    func request(with: any SNMRequestConvertible) async throws -> SNMNetworkResponse {
        self.lastRequest = with
        if let error = mockError {
            throw error
        }
        return mockResponse ?? SNMNetworkResponse(
            statusCode: .okCode,
            data: Data(),
            header: [:]
        )
    }
}
