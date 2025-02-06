//
//  SupabaseDatabaseManager.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/20/24.
//

import Combine
import Foundation

protocol RemoteDBManageable {
    func fetchData() throws -> SupabaseDBRequestBuilder
    func insertData() throws -> SupabaseDBRequestBuilder
    func updateData() throws -> SupabaseDBRequestBuilder
    func rpc() throws -> SupabaseDBRequestBuilder
}

final class SupabaseDBManager: RemoteDBManageable {
    private let sessionManager: any SessionManageable
    private let networkProvider: any NetworkProvider
    private let decoder: JSONDecoder
    
    private init() {
        self.sessionManager = SessionManager.shared
        self.networkProvider = SNMNetworkProvider()
        self.decoder = JSONDecoder()
    }
    
    func fetchData() throws -> SupabaseDBRequestBuilder {
        guard let accessToken = sessionManager.session?.accessToken else {
            throw SupabaseSessionError.sessionNotExist
        }
        return SupabaseDBRequestBuilder(
            networkProvider: networkProvider,
            accessToken: accessToken,
            task: .fetch
        )
    }
    
    func insertData() throws -> SupabaseDBRequestBuilder {
        guard let accessToken = sessionManager.session?.accessToken else {
            throw SupabaseSessionError.sessionNotExist
        }
        return SupabaseDBRequestBuilder(
            networkProvider: networkProvider,
            accessToken: accessToken,
            task: .insert
        )
    }
    
    func updateData() throws -> SupabaseDBRequestBuilder {
        guard let accessToken = sessionManager.session?.accessToken else {
            throw SupabaseSessionError.sessionNotExist
        }
        return SupabaseDBRequestBuilder(
            networkProvider: networkProvider,
            accessToken: accessToken,
            task: .update
        )
    }
    
    func rpc() throws -> SupabaseDBRequestBuilder {
        guard let accessToken = sessionManager.session?.accessToken else {
            throw SupabaseSessionError.sessionNotExist
        }
        return SupabaseDBRequestBuilder(
            networkProvider: networkProvider,
            accessToken: accessToken,
            task: .rpc
        )
    }
}

// MARK: - SupabaseDBManager+singleton instance

extension SupabaseDBManager {
    static let shared: RemoteDBManageable = SupabaseDBManager()
}

// MARK: - SupabaseDBError

enum SupabaseDBError: LocalizedError {
    case fetchDataFailed
    case insertDataFailed
    case updateDataFailed
    case rpcFailed
    case noMoreData
    
    var errorDescription: String? {
        switch self {
        case .fetchDataFailed: "데이터 불러오기 실패"
        case .insertDataFailed: "데이터 삽입 실패"
        case .updateDataFailed: "데이터 업데이트 실패"
        case .rpcFailed: "RPC 호출 실패"
        case .noMoreData: "더 불러올 데이터 없음"
        }
    }
}
