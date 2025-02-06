//
//  UpdateUserInfoUseCase.swift
//  SniffMeet
//
//  Created by 배현진 on 12/1/24.
//

import Foundation

protocol UpdateUserInfoUseCase {
    func execute(info: UserInfoDTO) async
}

struct UpdateUserInfoUseCaseImpl: UpdateUserInfoUseCase {
    private let remoteDBManager: any RemoteDBManageable
    private let sessionManager: any SessionManageable
    
    init(
        remoteDBManager: any RemoteDBManageable,
        sessionManager: any SessionManageable
    ) {
        self.remoteDBManager = remoteDBManager
        self.sessionManager = sessionManager
    }
    
    func execute(info: UserInfoDTO) async {
        do {
            guard let id = sessionManager.userID else {
                throw SupabaseAuthError.userNotFound
            }
            let userData = try JSONEncoder().encode(info)
//            try await remoteDBManager.updateData(
//                in: Environment.SupabaseTableName.userInfo,
//                at: id,
//                with: userData
//            )
            try await remoteDBManager.updateData()
                .setTable(Environment.SupabaseTableName.userInfo)
                .setBody(userData)
                .setQuery(key: "id", value: "eq.\(id)")
                .request()
        } catch {
            SNMLogger.error("\(error.localizedDescription)")
        }
    }
}
