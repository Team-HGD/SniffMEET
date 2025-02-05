//
//  remoteDBManagerMock.swift
//  SniffMeet
//
//  Created by 윤지성 on 1/22/25.
//
import Foundation

final class remoteDBManagerMock: RemoteDBManager {
    var fetchData: Data?
    var hasInserted: Bool = false
    var hasUpdated: Bool = false
    var hasUpdatedWithId: Bool = false
    var fetchListData: Data?
    
    init(fetchData: Data?, fetchListData: Data?) {
        self.fetchData = fetchData
        self.fetchListData = fetchListData
    }
    
    func fetchData(from table: String, query: [String : String]) async throws -> Data {
        guard let fetchData else { throw SNMNetworkError.failedStatusCode(reason: .notFound)}
        return fetchData
    }
    
    func insertData(into table: String, with data: Data) async throws {
        hasInserted = true
    }
    
    func updateData(into table: String, with data: Data) async throws {
        hasUpdated = true
    }
    
    func updateData(into table: String, at id: UUID, with data: Data) async throws {
        self.hasUpdated = true
    }
    
    func fetchList(into table: String = "", with data: Data, page: Int, pageSize: Int = 0 ) async throws -> Data {
        guard let fetchListData else { throw SNMNetworkError.failedStatusCode(reason: .notFound)}
        return fetchListData
    }
}
