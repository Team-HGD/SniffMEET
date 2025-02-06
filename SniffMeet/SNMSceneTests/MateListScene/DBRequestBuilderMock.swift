//
//  DBRequestBuilderMock.swift
//  SNMSceneTests
//
//  Created by Kelly Chui on 2/7/25.
//

import Foundation

final class DBRequestBuilderMock: RemoteDBRequestBuildable {
    private var requestType: SupabaseDBTask
    private var data: Data?
    
    init(requestType: SupabaseDBTask, data: Data? = nil) {
        self.requestType = requestType
        self.data = data
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
