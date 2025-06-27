//
//  SupabaseDatabaseManager.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/20/24.
//

import Combine
import Foundation

protocol RemoteDBManageable {
    func fetchData() async throws -> any RemoteDBFetchRequestBuildable
    func insertData() async throws -> any RemoteDBInsertRequestBuildable
    func updateData() async throws -> any RemoteDBUpdateRequestBuildable
    func deleteData() async throws -> any RemoteDBDeleteRequestBuildable
    func rpc() async throws -> any RemoteDBRPCRequestBuildable
}

final class SupabaseDBManager: RemoteDBManageable {
    private let sessionManager: any SessionManageable
    private let networkProvider: any NetworkProvider
    private let jsonDecoder: JSONDecoder
    
    private init() {
        self.sessionManager = SupabaseSessionManager.shared
        self.networkProvider = SNMNetworkProvider()
        self.jsonDecoder = JSONDecoder()
    }
    
    func fetchData() async throws -> any RemoteDBFetchRequestBuildable {
        let accessToken = try sessionManager.accessToken.get()
        try await sessionManager.checkSession()
        return SupabaseDBFetchRequestBuilder(
            networkProvider: networkProvider,
            accessToken: accessToken,
        )
    }
    
    func insertData() async throws -> any RemoteDBInsertRequestBuildable {
        let accessToken = try sessionManager.accessToken.get()
        try await sessionManager.checkSession()
        return SupabaseDBInsertRequestBuilder(
            networkProvider: networkProvider,
            accessToken: accessToken,
        )
    }
    
    func updateData() async throws -> any RemoteDBUpdateRequestBuildable {
        let accessToken = try sessionManager.accessToken.get()
        try await sessionManager.checkSession()
        return SupabaseDBUpdateRequestBuilder(
            networkProvider: networkProvider,
            accessToken: accessToken,
        )
    }

    func deleteData() async throws -> any RemoteDBDeleteRequestBuildable {
        let accessToken = try sessionManager.accessToken.get()
        try await sessionManager.checkSession()
        return SupabaseDBDeleteRequestBuilder(
            networkProvider: networkProvider,
            accessToken: accessToken,
        )
    }

    func rpc() async throws -> any RemoteDBRPCRequestBuildable {
        let accessToken = try sessionManager.accessToken.get()
        try await sessionManager.checkSession()
        return SupabaseDBRPCRequestBuilder(
            networkProvider: networkProvider,
            accessToken: accessToken,
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
    case deleteDataFailed
    case rpcFailed
    case noMoreData
    
    var errorDescription: String? {
        switch self {
        case .fetchDataFailed: "데이터 불러오기 실패"
        case .insertDataFailed: "데이터 삽입 실패"
        case .updateDataFailed: "데이터 업데이트 실패"
        case .rpcFailed: "RPC 호출 실패"
        case .noMoreData: "더 불러올 데이터 없음"
        case .deleteDataFailed: "데이터 삭제 실패"
        }
    }
}
