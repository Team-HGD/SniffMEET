//
//  SaveInfoUseCase.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/14/24.
//
import Foundation

protocol SaveUserInfoUseCase {
    func execute(userInfo: ProfileInfo) async throws
}

struct SaveUserInfoUseCaseImpl: SaveUserInfoUseCase {
    private let localDataManager: any UserDefaultsManagable
    private let remoteDBManager: any RemoteDBManageable
    private let sessionManager: any SessionManageable
    private let jsonEncoder: JSONEncoder
    
    init(
        localDataManager: any UserDefaultsManagable,
        remoteDBManager: any RemoteDBManageable,
        sessionManager: any SessionManageable,
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) {
        self.remoteDBManager = remoteDBManager
        self.localDataManager = localDataManager
        self.sessionManager = sessionManager
        self.jsonEncoder = jsonEncoder
    }
    
    func execute(userInfo: ProfileInfo) async throws {
        do {
            try saveToLocal(userInfo: userInfo)
            let userID = try sessionManager.userID.get()
            let dto = UserInfoDTO(
                id: userID,
                dogName: userInfo.name,
                age: userInfo.age,
                sex: userInfo.sex,
                sexUponIntake: userInfo.sexUponIntake,
                size: userInfo.size,
                keywords: userInfo.keywords,
                nickname: userInfo.nickname,
                profileImageURL: nil
            )
            try await saveToRemote(dto: dto)
        } catch let error as UserDefaultsError {
            throw SNMError(level: .logOnly, error: error)
        } catch let error as SupabaseSessionError {
            try localDataManager.delete(forKey: Environment.UserDefaultsKey.dogInfo)
            throw SNMError(level: .notExistSession, error: error)
        } catch let error as SupabaseDBError {
            try localDataManager.delete(forKey: Environment.UserDefaultsKey.dogInfo)
            throw SNMError(level: .retryable, error: error)
        }
    }
    private func saveToLocal(userInfo: ProfileInfo) throws {
        try localDataManager.set(value: userInfo, forKey: Environment.UserDefaultsKey.dogInfo)
    }
    private func saveToRemote(dto: UserInfoDTO) async throws {
        let userData = try jsonEncoder.encode(dto)
        try await remoteDBManager.insertData()
            .setTable(Environment.SupabaseTableName.userInfo)
            .setData(userData)
            .request()
        let mateListData = try jsonEncoder.encode(MateListInsertDTO(id: dto.id, mates: nil))
        try await remoteDBManager.insertData()
            .setTable(Environment.SupabaseTableName.matelist)
            .setData(mateListData)
            .request()
        let notiListData = try jsonEncoder.encode(WalkNotiListInsertDTO(id: dto.id))
        try await remoteDBManager.insertData()
            .setTable(Environment.SupabaseTableName.notificationList)
            .setData(notiListData)
            .request()
    }
}
