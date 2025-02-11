//
//  DeleteMateUseCase.swift
//  SniffMeet
//
//  Created by 배현진 on 2/5/25.
//

import Foundation

protocol DeleteMateUseCase {
    func execute(mate: Mate) async throws
}

final class DeleteMateUseCaseImpl: DeleteMateUseCase {
    private let networkProvider: any NetworkProvider
    private let remoteDBManager: any RemoteDBManageable
    private let sessionManager: any SessionManageable
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        networkProvider: any NetworkProvider,
        remoteDBManager: any RemoteDBManageable,
        sessionManager: any SessionManageable
    ) {
        self.networkProvider = networkProvider
        self.remoteDBManager = remoteDBManager
        self.sessionManager = sessionManager
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

            let mateListDTO = try decoder.decode([MateListDTO].self, from: userMateListData)
            guard let mateList = mateListDTO.first else {
                throw SupabaseDBError.fetchDataFailed
            }

            var matesToUUID = mateList.mates
            matesToUUID.removeAll { $0 == mateID }
            SNMLogger.log("mates: \(matesToUUID)")

            let updatedData = try encoder.encode(MateListInsertDTO(id: userID, mates: matesToUUID))
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
        } catch let error as SupabaseDBError where error == .fetchDataFailed || error == .updateDataFailed{
            throw SNMError(level: .user, error: error)
        } catch let error as SupabaseAuthError {
            throw SNMError(level: .user, error: error)
        } catch {
            throw SNMError(level: .developer, error: error)
        }
    }
}
