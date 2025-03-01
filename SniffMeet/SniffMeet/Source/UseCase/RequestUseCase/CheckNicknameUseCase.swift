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
    private let decoder: JSONDecoder
    
    init(remoteDBManager: any RemoteDBManageable) {
        self.remoteDBManager = remoteDBManager
        decoder = JSONDecoder()
    }
    
    func execute(nickname: String) async throws -> Bool {
        do {
            let body = try JSONSerialization.data(withJSONObject: ["input_name": nickname])
            let response = try await remoteDBManager.anonRPC()
                .setTable(Environment.SupabaseTableName.checkDuplicateNicknameFunction)
                .setData(body)
                .request()
            let isDuplicate = try decoder.decode(Bool.self, from: response)
            return isDuplicate
        } catch let error as SupabaseDBError {
            throw SNMError(level: .retryable, error: error)
        } catch {
            throw SNMError(level: .logOnly, error: error)
        }
    }
}
