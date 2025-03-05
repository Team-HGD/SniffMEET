//
//  CheckNicknameUseCase.swift
//  SniffMeet
//
//  Created by Kelly Chui on 2/13/25.
//

import Foundation

protocol CheckNicknameUseCase {
    func execute(nickname: String) async throws -> Bool
}

final class CheckNicknameUseCaseImpl: CheckNicknameUseCase {
    private let remoteDBManager: any RemoteDBManageable
    private let jsonDecoder: JSONDecoder
    
    init(remoteDBManager: any RemoteDBManageable, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.remoteDBManager = remoteDBManager
        self.jsonDecoder = jsonDecoder
    }
    
    func execute(nickname: String) async throws -> Bool {
        do {
            let body = try JSONSerialization.data(withJSONObject: ["input_name": nickname])
            let response = try await remoteDBManager.rpc()
                .setTable(Environment.SupabaseTableName.checkDuplicateNicknameFunction)
                .setData(body)
                .request()
            let isDuplicate = try jsonDecoder.decode(Bool.self, from: response)
            return isDuplicate
        } catch let error as SupabaseDBError {
            throw SNMError(level: .retryable, error: error)
        } catch {
            throw SNMError(level: .logOnly, error: error)
        }
    }
}
