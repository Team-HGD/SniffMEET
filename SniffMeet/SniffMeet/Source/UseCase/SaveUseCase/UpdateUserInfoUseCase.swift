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
    private let localDBManager: any UserDefaultsManagable
    private let remoteDBManager: any RemoteDBManageable
    private let sessionManager: any SessionManageable
    
    init(
        localDBManager: any UserDefaultsManagable,
        remoteDBManager: any RemoteDBManageable,
        sessionManager: any SessionManageable
    ) {
        self.localDBManager = localDBManager
        self.remoteDBManager = remoteDBManager
        self.sessionManager = sessionManager
    }
    
    func execute(with updatedProperty: [String: Any]) async throws {
        do {
            try updateToLocal(with: updatedProperty)
            try await updateToRemote(with: updatedProperty)
        } catch let error as UserDefaultsError {
            throw SNMError(level: .user, error: error)
        } catch let error as SupabaseSessionError {
            try localDBManager.delete(forKey: Environment.UserDefaultsKey.dogInfo)
            throw SNMError(level: .user, error: error)
        } catch let error as SupabaseDBError {
            try localDBManager.delete(forKey: Environment.UserDefaultsKey.dogInfo)
            throw SNMError(level: .user, error: error)
        }
    }
    
    private func updateToLocal(with updatedProperty: [String: Any]) throws {
        let oldProfileInfo = try localDBManager.get(
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
        try localDBManager.set(value: newProfileInfo, forKey: Environment.UserDefaultsKey.dogInfo)
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
