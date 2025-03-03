//
//  UpdateUserInfoUseCase.swift
//  SniffMeet
//
//  Created by 배현진 on 12/1/24.
//

import Foundation

protocol UpdateUserInfoUseCase {
    func execute(with updatedProperty: [String: Any]) async throws
}

struct UpdateUserInfoUseCaseImpl: UpdateUserInfoUseCase {
    private let localDataManager: any UserDefaultsManagable
    private let remoteDBManager: any RemoteDBManageable
    private let sessionManager: any SessionManageable
    
    init(
        localDataManager: any UserDefaultsManagable,
        remoteDBManager: any RemoteDBManageable,
        sessionManager: any SessionManageable
    ) {
        self.localDataManager = localDataManager
        self.remoteDBManager = remoteDBManager
        self.sessionManager = sessionManager
    }
    
    func execute(with updatedProperty: [String: Any]) async throws {
        do {
            try updateToLocal(with: updatedProperty)
            try await updateToRemote(with: updatedProperty)
        } catch let error as UserDefaultsError {
            throw SNMError(level: .retryable, error: error)
        } catch let error as SupabaseSessionError {
            try localDataManager.delete(forKey: Environment.UserDefaultsKey.dogInfo)
            throw SNMError(level: .notExistSession, error: error)
        } catch let error as SupabaseDBError {
            try localDataManager.delete(forKey: Environment.UserDefaultsKey.dogInfo)
            throw SNMError(level: .retryable, error: error)
        }
    }
    
    private func updateToLocal(with updatedProperty: [String: Any]) throws {
        let oldProfileInfo = try localDataManager.get(
            forKey: Environment.UserDefaultsKey.dogInfo,
            type: ProfileInfo.self
        )
        let newProfileInfo = ProfileInfo(
            name: updatedProperty["name"] as? String ?? oldProfileInfo.name,
            age: updatedProperty["age"] as? UInt8 ?? oldProfileInfo.age,
            sex: oldProfileInfo.sex,
            sexUponIntake: updatedProperty["sexUponIntake"] as? Bool ?? oldProfileInfo.sexUponIntake,
            size: (updatedProperty["size"] as? String).flatMap { sizeString in
                Size(rawValue: sizeString)
            } ?? oldProfileInfo.size,
            keywords: (updatedProperty["keywords"] as? [String])?.compactMap { keywordString in
                Keyword(rawValue: keywordString)
            } ?? oldProfileInfo.keywords,
            nickname: updatedProperty["nickname"] as? String ?? oldProfileInfo.nickname,
            profileImageName: oldProfileInfo.profileImageName
        )
        try localDataManager.set(value: newProfileInfo, forKey: Environment.UserDefaultsKey.dogInfo)
    }
    private func updateToRemote(with updatedProperty: [String: Any]) async throws {
        let userID = try sessionManager.userID.get()
        let data = try JSONSerialization.data(withJSONObject: updatedProperty, options: [])
        try await remoteDBManager.updateData()
            .setTable(Environment.SupabaseTableName.userInfo)
            .setData(data)
            .setQuery(.equal("id", userID))
            .request()
    }
}
