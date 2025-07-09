//
//  SupabaseDBRPCRequestBuilder.swift
//  SniffMeet
//
//  Created by Kelly Chui on 6/28/25.
//

import Foundation

protocol RemoteDBRPCRequestBuildable: RemoteDBRequestBuildable & HasQuery & HasData {
    func setQuery(_ parameter: SupabaseQueryParameter) -> Self
    func setData(_ data: Data) -> Self
    func request() async throws -> Data
}

final class SupabaseDBRPCRequestBuilder: SupabaseDBRequestBuilder, RemoteDBRPCRequestBuildable {
    var data: Data?
    var query: [String: String] = [:]

    func request() async throws -> Data {
        guard let data, let table else { throw SupabaseDBError.rpcFailed }
        let request = SupabaseDBRequest.rpc(
            table: table,
            accessToken: accessToken,
            data: data,
            query: query
        )
        return try await networkProvider.request(with: request).data
    }
}
