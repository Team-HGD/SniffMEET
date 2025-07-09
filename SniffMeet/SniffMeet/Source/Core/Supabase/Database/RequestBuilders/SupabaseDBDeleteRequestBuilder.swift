//
//  SupabaseDBDeleteRequestBuilder.swift
//  SniffMeet
//
//  Created by Kelly Chui on 6/28/25.
//

import Foundation

protocol RemoteDBDeleteRequestBuildable: RemoteDBRequestBuildable & HasQuery {
    func setQuery(_ parameter: SupabaseQueryParameter) -> Self
    @discardableResult func request() async throws -> Data
}

final class SupabaseDBDeleteRequestBuilder: SupabaseDBRequestBuilder, RemoteDBDeleteRequestBuildable {
    var query: [String: String] = [:]
    
    func request() async throws -> Data {
        guard let table else { throw SupabaseDBError.deleteDataFailed }
        let request = SupabaseDBRequest.deleteData(
            table: table,
            accessToken: accessToken,
            query: query
        )
        return try await networkProvider.request(with: request).data
    }
}
