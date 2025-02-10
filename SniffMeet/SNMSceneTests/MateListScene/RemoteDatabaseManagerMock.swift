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
    
    init(data: Data?) {
        self.data = data
    }
    
    func fetchData() throws -> RemoteDBRequestBuildable {
        return DBRequestBuilderMock(
            requestType: .fetch
        )
    }
    
    func insertData() throws -> RemoteDBRequestBuildable {
        hasInserted = true
        return DBRequestBuilderMock(
            requestType: .insert,
            data: data
        )
    }
    
    func updateData() throws -> RemoteDBRequestBuildable {
        hasUpdated = true
        return DBRequestBuilderMock(
            requestType: .update,
            data: data
        )
    }
    
    func rpc() throws -> RemoteDBRequestBuildable {
        return DBRequestBuilderMock(
            requestType: .rpc,
            data: data
        )
    }
}
