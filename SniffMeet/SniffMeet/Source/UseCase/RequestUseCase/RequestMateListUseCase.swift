//
//  RequestMateListUseCase.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/24/24.
//

import Foundation

protocol RequestMateListUseCase {
    func execute(page: Int, pageSize: Int) async throws -> [Mate]
}

struct RequestMateListUseCaseImpl: RequestMateListUseCase {
    private let remoteDBManager: any RemoteDBManageable
    let decoder: JSONDecoder
    let encoder: JSONEncoder
    
    init(remoteDBManager: any RemoteDBManageable) {
        self.remoteDBManager = remoteDBManager
        decoder = JSONDecoder()
        encoder = JSONEncoder()
    }
    
    func execute(page: Int, pageSize: Int) async throws -> [Mate] {
        do {
            let tableName = Environment.SupabaseTableName.matelistFunction
            guard let userID = SessionManager.shared.userID else {
                throw SNMError(level: .user, error: SupabaseSessionError.sessionNotExist)
            }
            let requestData = try encoder.encode(MateListRequestDTO(userId: userID))
            let data = try await remoteDBManager.rpc()
                .setTable(tableName)
                .setData(requestData)
                .setQuery(.custom("limit", pageSize))
                .setQuery(.custom("offset", pageSize * page))
                .request()
            let mateDTOList = try decoder.decode([UserInfoDTO].self, from: data)
            return mateDTOList.map {
                Mate(name: $0.dogName,
                     userID: $0.id,
                     keywords: $0.keywords,
                     profileImageURLString: $0.profileImageURL)
            }
        } catch let error as SupabaseDBError where error == .noMoreData {
            throw SNMError(level: .user, error: error)
        } catch let error as SupabaseAuthError {
            throw SNMError(level: .user, error: error)
        } catch {
            throw SNMError(level: .developer, error: error)
        }
    }
}
