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
    private let remoteDatabaseManager: RemoteDatabaseManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(remoteDatabaseManager: any RemoteDatabaseManager) {
        self.remoteDatabaseManager = remoteDatabaseManager
    }

    func execute(mate: Mate) async throws {
        do {
            guard let userID = SessionManager.shared.session?.user?.userID else {
                throw SNMError(level: .user, error: SupabaseAuthError.sessionNotExist)
            }
            let mateID = mate.userID
            let tableName = Environment.SupabaseTableName.matelist

            let userMateListData = try await remoteDatabaseManager.fetchData(
                from: tableName,
                query: ["id": "eq.\(userID)"]
            )

            let mateListDTO = try decoder.decode([MateListDTO].self, from: userMateListData)
            guard let mateList = mateListDTO.first else {
                throw SupabaseDBError.fetchDataFailed
            }

            var matesToUUID = mateList.mates
            matesToUUID.removeAll { $0 == mateID }
            SNMLogger.log("mates: \(matesToUUID)")

            let updatedData = try encoder.encode(MateListInsertDTO(id: userID, mates: matesToUUID))
            try await remoteDatabaseManager.updateData(into: tableName, at: userID, with: updatedData)
        } catch let error as SupabaseDBError where error == .fetchDataFailed || error == .updateDataFailed{
            throw SNMError(level: .user, error: error)
        } catch let error as SupabaseAuthError {
            throw SNMError(level: .user, error: error)
        } catch {
            throw SNMError(level: .developer, error: error)
        }
    }
}
