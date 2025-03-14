//
//  RemoteSaveDeviceTokenUsecase.swift
//  SniffMeet
//
//  Created by sole on 11/27/24.
//

import Foundation

protocol RemoteSaveDeviceTokenUsecase {
    func execute() async throws
}

struct RemoteSaveDeviceTokenUsecaseImpl: RemoteSaveDeviceTokenUsecase {
    private let keychainManager: any TokenManagable
    private let remoteDBManager: any RemoteDBManageable
    private let sessionManager: any SessionManageable
    private let jsonEncoder: JSONEncoder

    init(
        keychainManager: any TokenManagable,
        remoteDBManager: any RemoteDBManageable,
        sessionManager: any SessionManageable,
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) {
        self.remoteDBManager = remoteDBManager
        self.sessionManager = sessionManager
        self.keychainManager = keychainManager
        self.jsonEncoder = jsonEncoder
    }

    func execute() async throws {
        do {
            let id = try sessionManager.userID.get()
            let deviceToken = try keychainManager.get(forKey: Environment.KeychainKey.deviceToken)
            let deviceTokenDTO = SaveDeviceTokenDTO(deviceToken: deviceToken)
            let deviceTokenData = try jsonEncoder.encode(deviceTokenDTO)
            try await remoteDBManager.updateData()
                .setTable(Environment.SupabaseTableName.userInfo)
                .setData(deviceTokenData)
                .setQuery(.equal("id", id))
                .request()
        } catch let error as SupabaseSessionError {
            throw SNMError(level: .notExistSession, error: error)
        } catch let error as SupabaseDBError {
            throw SNMError(level: .retryable, error: error)
        } catch {
            throw SNMError(level: .logOnly, error: error)
        }
    }
}
