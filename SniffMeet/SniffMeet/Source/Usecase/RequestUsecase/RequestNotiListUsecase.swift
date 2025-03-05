//
//  RequestNotiListUsecase.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/30/24.
//
import Foundation

protocol RequestNotiListUsecase {
    func execute(page: Int, pageSize: Int) async throws -> [WalkNoti]
}

struct RequestNotiListUsecaseImpl: RequestNotiListUsecase {
    private let remoteManager: any RemoteDBManageable
    private let sessionManager: any SessionManageable
    let jsonEncoder: JSONEncoder
    let jsonDecoder: JSONDecoder
    
    init(
        remoteManager: any RemoteDBManageable,
        sessionManager: any SessionManageable,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) {
        self.remoteManager = remoteManager
        self.sessionManager = sessionManager
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
    }
    
    func execute(page: Int = 0, pageSize: Int = 100) async throws -> [WalkNoti] {
        let tableName = Environment.SupabaseTableName.notificationListFunction

        do {
            let userID = try sessionManager.userID.get()
            let requestData = try jsonEncoder.encode(WalkNotiListRequestDTO(userID: userID))
            let data = try await remoteManager.rpc()
                .setTable(tableName)
                .setData(requestData)
                .setQuery(.custom("limit", pageSize))
                .setQuery(.custom("offset", pageSize * page))
                .request()
            let walkDTOList = try jsonDecoder.decode([WalkNotiDTO].self, from: data)
            
            return walkDTOList.map { $0.toEntity() }
        } catch let error as SupabaseSessionError {
            throw SNMError(level: .notExistSession, error: error)
        } catch let error as SupabaseDBError where error == .noMoreData {
            throw SNMError(level: .notifyUser, error: error)
        } catch let error as SupabaseDBError {
            throw SNMError(level: .retryable, error: error)
        } catch {
            throw SNMError(level: .logOnly, error: error)
        }
    }
}
