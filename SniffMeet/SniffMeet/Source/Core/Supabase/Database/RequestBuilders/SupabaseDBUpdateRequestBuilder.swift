//
//  SupabaseDBUpdateRequestBuilder.swift
//  SniffMeet
//
//  Created by Kelly Chui on 6/28/25.
//

import Foundation

protocol RemoteDBUpdateRequestBuildable: RemoteDBRequestBuildable & HasQuery & HasData {
    func setQuery(_ parameter: SupabaseQueryParameter) -> Self
    func setData(_ data: Data) -> Self
    @discardableResult func request() async throws -> Data
}

final class SupabaseDBUpdateRequestBuilder: SupabaseDBRequestBuilder, RemoteDBUpdateRequestBuildable {
    var data: Data?
    var query: [String: String] = [:]
    
    func request() async throws -> Data {
        guard let data, let table else { throw SupabaseDBError.updateDataFailed }
        let request = SupabaseDBRequest.updateData(
            table: table,
            accessToken: accessToken,
            data: data,
            query: query
        )
        return try await networkProvider.request(with: request).data
    }
}
