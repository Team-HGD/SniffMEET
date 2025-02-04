//
//  RequestNotiListUseCase.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/30/24.
//
import Foundation

protocol RequestNotiListUseCase {
    var remoteManager: (any RemoteDatabaseManager) { get }
    func execute(page: Int, pageSize: Int) async throws -> [WalkNoti]
}

struct RequestNotiListUseCaseImpl: RequestNotiListUseCase {
    var remoteManager: (any RemoteDatabaseManager)
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    
    init(remoteManager: any RemoteDatabaseManager) {
        self.remoteManager = remoteManager
        decoder = JSONDecoder()
        encoder = JSONEncoder()
    }
    
    func execute(page: Int = 0, pageSize: Int = 100) async throws -> [WalkNoti] {
        let tableName = Environment.SupabaseTableName.notificationListFunction

        do {
            guard let userID = SessionManager.shared.userID else {
                throw SNMError(level: .user, error: SupabaseSessionError.sessionNotExist)
            }

            let requestData = try encoder.encode(WalkNotiListRequestDTO(userId: userID))
            let data = try await remoteManager.fetchList(
                into: tableName,
                with: requestData,
                page: page,
                pageSize: pageSize
            )
            let walkDTOList = try decoder.decode([WalkNotiDTO].self, from: data)
            
            return walkDTOList.map { $0.toEntity() }
        } catch let error as SupabaseDBError where error == .noMoreData {
            throw SNMError(level: .user, error: error)
        } catch let error as SupabaseAuthError {
            throw SNMError(level: .user, error: error)
        } catch {
            throw SNMError(level: .developer, error: error)
        }
    }
}
