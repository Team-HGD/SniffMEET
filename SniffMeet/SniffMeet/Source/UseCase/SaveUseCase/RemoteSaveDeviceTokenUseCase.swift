//
//  RemoteSaveDeviceTokenUseCase.swift
//  SniffMeet
//
//  Created by sole on 11/27/24.
//

import Foundation

protocol RemoteSaveDeviceTokenUseCase {
    func execute() async throws
}

struct RemoteSaveDeviceTokenUseCaseImpl: RemoteSaveDeviceTokenUseCase {
    private let jsonEncoder: JSONEncoder
    private let keychainManager: any TokenManagable
    private let remoteDBManager: any RemoteDBManageable
    private let sessionManager: any SessionManageable

    init(
        jsonEncoder: JSONEncoder,
        keychainManager: any TokenManagable,
        remoteDBManager: any RemoteDBManageable,
        sessionManager: any SessionManageable
    ) {
        self.jsonEncoder = jsonEncoder
        self.keychainManager = keychainManager
        self.remoteDBManager = remoteDBManager
        self.sessionManager = sessionManager
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
        } catch let error as SupabaseAuthError {
            throw SNMError(level: .user, error: error)
        } catch let error as SupabaseSessionError {
            throw SNMError(level: .user, error: error)
        } catch let error as SupabaseDBError {
            throw SNMError(level: .user, error: error)
        } catch {
            throw SNMError(level: .developer, error: error)
        }
    }
}
