//
//  DeleteNotificationUsecase.swift
//  SniffMeet
//
//  Created by sole on 2/14/25.
//

protocol DeleteNotificationUsecase {
    func execute(notificationID: String) async throws
}

struct DeleteNotificationUsecaseImpl: DeleteNotificationUsecase {
    private let remoteDataManager: any RemoteDBManageable

    init(remoteDataManager: any RemoteDBManageable) {
        self.remoteDataManager = remoteDataManager
    }

    func execute(notificationID: String) async throws {
        do {
            try await remoteDataManager
                .deleteData()
                .setTable(Environment.SupabaseTableName.notification)
                .setQuery(.equal("id", notificationID))
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
