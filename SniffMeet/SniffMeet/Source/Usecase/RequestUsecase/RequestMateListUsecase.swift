//
//  RequestMateListUsecase.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/24/24.
//

import Foundation

protocol RequestMateListUsecase {
    func execute(page: Int, pageSize: Int) async throws -> [Mate]
}

struct RequestMateListUsecaseImpl: RequestMateListUsecase {
    private let remoteDBManager: any RemoteDBManageable
    let jsonEncoder: JSONEncoder
    let jsonDecoder: JSONDecoder
    
    init(
        remoteDBManager: any RemoteDBManageable,
        jsonEncoder: JSONEncoder = JSONEncoder(),
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.remoteDBManager = remoteDBManager
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    func execute(page: Int, pageSize: Int) async throws -> [Mate] {
        do {
            let tableName = Environment.SupabaseTableName.matelistFunction
            let userID = try SupabaseSessionManager.shared.userID.get()
            let requestData = try jsonEncoder.encode(MateListRequestDTO(userID: userID))
            let data = try await remoteDBManager.rpc()
                .setTable(tableName)
                .setData(requestData)
                .setQuery(.custom("limit", pageSize))
                .setQuery(.custom("offset", pageSize * page))
                .request()
            let mateDTOList = try jsonDecoder.decode([UserInfoDTO].self, from: data)
            return mateDTOList.map {
                Mate(name: $0.dogName,
                     userID: $0.id,
                     keywords: $0.keywords,
                     profileImageURLString: $0.profileImageURL)
            }
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
