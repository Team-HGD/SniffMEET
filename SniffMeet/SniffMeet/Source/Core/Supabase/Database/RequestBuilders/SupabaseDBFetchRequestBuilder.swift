//
//  SupabaseDBFetchRequestBuilder.swift
//  SniffMeet
//
//  Created by Kelly Chui on 6/28/25.
//

import Foundation

protocol RemoteDBFetchRequestBuildable: RemoteDBRequestBuildable & HasQuery {
    func setQuery(_ parameter: SupabaseQueryParameter) -> Self
    func request() async throws -> Data
}

final class SupabaseDBFetchRequestBuilder: SupabaseDBRequestBuilder, RemoteDBFetchRequestBuildable {
    var query: [String: String] = [:]
    
    func request() async throws -> Data {
        guard let table else { throw SupabaseDBError.fetchDataFailed }
        let request = SupabaseDBRequest.fetchData(
            table: table,
            accessToken: accessToken,
            query: query
        )
        return try await networkProvider.request(with: request).data
    }
}
