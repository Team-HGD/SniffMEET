//
//  RemoteDBManagerMock.swift
//  SniffMeet
//
//  Created by 윤지성 on 1/22/25.
//
import Foundation

final class RemoteDBManagerMock: RemoteDBManageable {
    var data: Data?
    var hasInserted: Bool = false
    var hasUpdated: Bool = false
    var hasDeleted: Bool = false

    init(data: Data?) {
        self.data = data
    }
    
    func fetchData() throws -> any RemoteDBFetchRequestBuildable {
        return RemoteDBRequestBuilderMock(
            requestType: .fetch
        )
    }
    
    func insertData() throws -> any RemoteDBInsertRequestBuildable {
        hasInserted = true
        return RemoteDBRequestBuilderMock(
            requestType: .insert,
            data: data
        )
    }
    
    func updateData() throws -> any RemoteDBUpdateRequestBuildable {
        hasUpdated = true
        return RemoteDBRequestBuilderMock(
            requestType: .update,
            data: data
        )
    }
    
    func deleteData() async throws -> any RemoteDBDeleteRequestBuildable {
        hasDeleted = true
        return RemoteDBRequestBuilderMock(
            requestType: .delete
        )
    }

    func rpc() throws -> any RemoteDBRPCRequestBuildable {
        return RemoteDBRequestBuilderMock(
            requestType: .rpc,
            data: data
        )
    }
}
