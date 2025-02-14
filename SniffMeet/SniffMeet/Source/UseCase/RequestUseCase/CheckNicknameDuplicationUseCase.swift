//
//  RequestCheckDuplicateNicknameUseCase.swift
//  SniffMeet
//
//  Created by Kelly Chui on 2/13/25.
//

import Foundation

protocol CheckNicknameDuplicationUseCase {
    func execute(nickname: String) async throws -> Bool
}

final class CheckNicknameDuplicationUseCaseImpl: CheckNicknameDuplicationUseCase {
    private let remoteDBManager: any RemoteDBManageable
    private let decoder: JSONDecoder
    
    init(remoteDBManager: any RemoteDBManageable, sessionManager: any SessionManageable) {
        self.remoteDBManager = remoteDBManager
        decoder = JSONDecoder()
    }
    
    func execute(nickname: String) async throws -> Bool {
        let body = try JSONSerialization.data(withJSONObject: ["input_name": nickname])
        let response = try await remoteDBManager.anonRPC()
            .setTable(Environment.SupabaseTableName.checkDuplicateNicknameFunction)
            .setData(body)
            .request()
        let isDuplicate = try decoder.decode(Bool.self, from: response)
        return isDuplicate
    }
}
