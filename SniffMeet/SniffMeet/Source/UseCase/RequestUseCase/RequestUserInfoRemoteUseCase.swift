//
//  RequestUserInfoRemoteUseCase.swift
//  SniffMeet
//
//  Created by 배현진 on 11/27/24.
//

import Foundation

protocol RequestUserInfoRemoteUseCase {
    func execute() async throws -> [UserInfoDTO]
}

struct RequestUserInfoRemoteUseCaseImpl: RequestUserInfoRemoteUseCase {
    private let remoteDBManager: any RemoteDBManageable
    private let sessionManager: any SessionManageable
    
    init(remoteDBManager: any RemoteDBManageable, sessionManager: any SessionManageable) {
        self.remoteDBManager = remoteDBManager
        self.sessionManager = sessionManager
    }
    
    func execute() async throws -> [UserInfoDTO] {
        let userID = try sessionManager.userID.get()
        let data = try await remoteDBManager.fetchData()
            .setTable(Environment.SupabaseTableName.userInfo)
            .setQuery(.equal("id", userID))
            .request()
        let decoder = JSONDecoder()
        let info = try decoder.decode([UserInfoDTO].self, from: data)
        return info
    }
}
