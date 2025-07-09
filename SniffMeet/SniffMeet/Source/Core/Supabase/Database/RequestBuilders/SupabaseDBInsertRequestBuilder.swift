//
//  SupabaseDBInsertRequestBuilder.swift
//  SniffMeet
//
//  Created by Kelly Chui on 6/28/25.
//

import Foundation

protocol RemoteDBInsertRequestBuildable: RemoteDBRequestBuildable & HasData {
    func setData(_ data: Data) -> Self
    @discardableResult func request() async throws -> Data
}

final class SupabaseDBInsertRequestBuilder: SupabaseDBRequestBuilder, RemoteDBInsertRequestBuildable {
    var data: Data?
    
    func request() async throws -> Data {
        guard let data, let table else { throw SupabaseDBError.insertDataFailed }
        let request = SupabaseDBRequest.insertData(
            table: table,
            accessToken: accessToken,
            data: data
        )
        return try await networkProvider.request(with: request).data
    }
}
