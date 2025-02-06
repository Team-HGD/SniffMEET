//
//  RequestMateInfoUseCase.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/28/24.
//

import Foundation

// RequestUserInfoUseCase와 통합이 가능하다고 예상됩니다.
protocol RequestMateInfoUseCase {
    func execute(mateID: UUID) async throws -> UserInfoDTO?
}

struct RequestMateInfoUsecaseImpl: RequestMateInfoUseCase {
    private let remoteDBManager: any RemoteDBManageable
    
    init(remoteDBManager: any RemoteDBManageable) {
        self.remoteDBManager = remoteDBManager
    }
    
    func execute(mateID: UUID) async throws -> UserInfoDTO? {
//        let mateInfoData = try await remoteDBManager.fetchData(
//            from: "user_info",
//            query: ["id": "eq.\(mateID.uuidString)"]
//        )
        let mateInfoData = try await remoteDBManager.fetchData()
            .setTable(Environment.SupabaseTableName.userInfo)
            .setQuery(key: "id", value: "eq.\(mateID.uuidString)")
            .request()
        let mateInfo = try JSONDecoder().decode([UserInfoDTO].self, from: mateInfoData)
        return mateInfo.first
    }
}
