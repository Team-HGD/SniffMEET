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
    private let jsonDecoder: JSONDecoder
    
    init(
        remoteDBManager: any RemoteDBManageable,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.remoteDBManager = remoteDBManager
        self.jsonDecoder = jsonDecoder
    }
    
    func execute(mateID: UUID) async throws -> UserInfoDTO? {
        let mateInfoData = try await remoteDBManager.fetchData()
            .setTable(Environment.SupabaseTableName.userInfo)
            .setQuery(.equal("id", mateID.uuidString))
            .request()
        let mateInfo = try jsonDecoder.decode([UserInfoDTO].self, from: mateInfoData)
        return mateInfo.first
    }
}
