//
//  RequestUserInfoRemoteUsecase.swift
//  SniffMeet
//
//  Created by 배현진 on 11/27/24.
//

import Foundation

protocol RequestUserInfoRemoteUsecase {
    func execute() async throws -> [UserInfoDTO]
}

struct RequestUserInfoRemoteUsecaseImpl: RequestUserInfoRemoteUsecase {
    private let remoteDBManager: any RemoteDBManageable
    private let sessionManager: any SessionManageable
    private let jsonDecoder: JSONDecoder
    
    init(remoteDBManager: any RemoteDBManageable,
         sessionManager: any SessionManageable,
         jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.remoteDBManager = remoteDBManager
        self.sessionManager = sessionManager
        self.jsonDecoder = jsonDecoder
    }
    
    func execute() async throws -> [UserInfoDTO] {
        let userID = try sessionManager.userID.get()
        let data = try await remoteDBManager.fetchData()
            .setTable(Environment.SupabaseTableName.userInfo)
            .setQuery(.equal("id", userID))
            .request()
        let info = try jsonDecoder.decode([UserInfoDTO].self, from: data)
        return info
    }
}
