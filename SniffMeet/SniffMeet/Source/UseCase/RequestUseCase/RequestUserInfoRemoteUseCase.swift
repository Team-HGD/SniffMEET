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
    
    init(remoteDBManager: any RemoteDBManageable) {
        self.remoteDBManager = remoteDBManager
    }
    
    func execute() async throws -> [UserInfoDTO] {
        guard let userID = SessionManager.shared.userID else {
            throw SupabaseSessionError.sessionNotExist
        }
        let data = try await remoteDBManager.fetchData(
            from: Environment.SupabaseTableName.userInfo,
            query: ["id": "eq.\(userID)"])
        let decoder = JSONDecoder()
        let info = try decoder.decode([UserInfoDTO].self, from: data)
        return info
    }
}
