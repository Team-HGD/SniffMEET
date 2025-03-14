//
//  DeleteMateUsecase.swift
//  SniffMeet
//
//  Created by 배현진 on 2/5/25.
//

import Foundation

protocol DeleteMateUsecase {
    func execute(mate: Mate) async throws
}

final class DeleteMateUsecaseImpl: DeleteMateUsecase {
    private let networkProvider: any NetworkProvider
    private let remoteDBManager: any RemoteDBManageable
    private let sessionManager: any SessionManageable
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    init(
        networkProvider: any NetworkProvider,
        remoteDBManager: any RemoteDBManageable,
        sessionManager: any SessionManageable,
        jsonEncoder: JSONEncoder = JSONEncoder(),
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.networkProvider = networkProvider
        self.remoteDBManager = remoteDBManager
        self.sessionManager = sessionManager
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    func execute(mate: Mate) async throws {
        do {
            let userID = try sessionManager.userID.get()
            let mateID = mate.userID
            let tableName = Environment.SupabaseTableName.matelist

            let userMateListData = try await remoteDBManager.fetchData()
                .setTable(tableName)
                .setQuery(.equal("id", userID))
                .request()

            let mateListDTO = try jsonDecoder.decode([MateListDTO].self, from: userMateListData)
            guard let mateList = mateListDTO.first else {
                throw SupabaseDBError.fetchDataFailed
            }

            var matesToUUID = mateList.mates
            matesToUUID.removeAll { $0 == mateID }
            SNMLogger.log("mates: \(matesToUUID)")

            let updatedData = try jsonEncoder.encode(MateListInsertDTO(id: userID, mates: matesToUUID))
            try await remoteDBManager.updateData()
                .setTable(tableName)
                .setData(updatedData)
                .setQuery(.equal("id", userID))
                .request()

            _ = try await networkProvider.request(
                with: PushNotificationRequest.sendDeleteMate(
                    senderID: userID.uuidString,
                    receiverID: mateID.uuidString
                )
            )
        } catch let error as SupabaseSessionError {
            throw SNMError(level: .notExistSession, error: error)
        } catch let error as SupabaseDBError {
            throw SNMError(level: .retryable, error: error)
        } catch {
            throw SNMError(level: .logOnly, error: error)
        }
    }
}
