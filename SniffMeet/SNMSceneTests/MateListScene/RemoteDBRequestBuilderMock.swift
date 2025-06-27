//
//  DBRequestBuilderMock.swift
//  SNMSceneTests
//
//  Created by Kelly Chui on 2/7/25.
//

import Foundation

typealias MockDBRequestBuildable = RemoteDBRequestBuildable
& RemoteDBInsertRequestBuildable
& RemoteDBUpdateRequestBuildable
& RemoteDBDeleteRequestBuildable
& RemoteDBFetchRequestBuildable
& RemoteDBRPCRequestBuildable

class RemoteDBRequestBuilderMock: MockDBRequestBuildable {
    private var requestType: SupabaseDBTask
    var data: Data?
    var query: [String: String]
    
    init(requestType: SupabaseDBTask, data: Data? = nil) {
        self.requestType = requestType
        self.data = data
        self.query = [:]
    }
    
    func setTable(_ table: String) -> Self {
        self
    }
    
    func setData(_ data: Data) -> Self {
        self
    }
    
    func setQuery(_ parameter: SupabaseQueryParameter) -> Self {
        self
    }
    
    func request() async throws -> Data {
        guard let data else { throw SNMNetworkError.failedStatusCode(reason: .notFound)}
        return data
    }
}


