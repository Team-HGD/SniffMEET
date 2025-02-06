//
//  StoreUserInfoRemoteUseCase.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/26/24.
//

import Foundation

protocol CreateAccountUseCase {
    func execute(info: UserInfoDTO) async
}

struct CreateAccountUseCaseImpl: CreateAccountUseCase {
    private let remoteDBManager: any RemoteDBManageable
    
    init(remoteDBManager: any RemoteDBManageable) {
        self.remoteDBManager = remoteDBManager
    }
    
    func execute(info: UserInfoDTO) async {
        let encoder = JSONEncoder()
        do {
            let userData = try encoder.encode(info)
//            try await remoteDBManager.insertData(
//                into: Environment.SupabaseTableName.userInfo,
//                with: userData
//            )
            try await remoteDBManager.insertData()
                .setTable(Environment.SupabaseTableName.userInfo)
                .setBody(userData)
                .request()
            
        } catch {
            SNMLogger.error("\(error.localizedDescription)")
        }
        do {
            let mateListData = try encoder.encode(MateListInsertDTO(id: info.id, mates: nil))
//            try await remoteDBManager.insertData(
//                into: Environment.SupabaseTableName.matelist,
//                with: mateListData
//            )
            try await remoteDBManager.insertData()
                .setTable(Environment.SupabaseTableName.matelist)
                .setBody(mateListData)
                .request()
        } catch {
            SNMLogger.error("mate list insert error: \(error.localizedDescription)")
        }
        do {
            let notiListData = try encoder.encode(WalkNotiListInsertDTO(id: info.id))
//            try await remoteDBManager.insertData(
//                into: Environment.SupabaseTableName.notificationList,
//                with: notiListData
//            )
            try await remoteDBManager.insertData()
                .setTable(Environment.SupabaseTableName.notificationList)
                .setBody(notiListData)
                .request()
        } catch {
            SNMLogger.error("notifiaction list insert error: \(error.localizedDescription)")
        }
    }
}
