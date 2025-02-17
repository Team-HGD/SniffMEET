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
    
    func fetchData() throws -> RemoteDBRequestBuildable {
        return RemoteDBRequestBuilderMock(
            requestType: .fetch
        )
    }
    
    func insertData() throws -> RemoteDBRequestBuildable {
        hasInserted = true
        return RemoteDBRequestBuilderMock(
            requestType: .insert,
            data: data
        )
    }
    
    func updateData() throws -> RemoteDBRequestBuildable {
        hasUpdated = true
        return RemoteDBRequestBuilderMock(
            requestType: .update,
            data: data
        )
    }
    
    func deleteData() async throws -> any RemoteDBRequestBuildable {
        hasDeleted = true
        return RemoteDBRequestBuilderMock(
            requestType: .delete
        )
    }

    func rpc() throws -> RemoteDBRequestBuildable {
        return RemoteDBRequestBuilderMock(
            requestType: .rpc,
            data: data
        )
    }
}
