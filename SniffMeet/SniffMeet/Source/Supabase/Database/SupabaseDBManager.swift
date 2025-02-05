//
//  SupabaseDatabaseManager.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/20/24.
//

import Combine
import Foundation

protocol RemoteDBManageable {
    func fetchData(from table: String, query: [String: String]) async throws -> Data
    func insertData(into table: String, with data: Data) async throws
    func updateData(
        in table: String,
        at id: UUID,
        with data: Data
    ) async throws
    func fetchList(
        into table: String,
        with data: Data,
        page: Int,
        pageSize: Int
    ) async throws -> Data
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
    
    func fetchData(from table: String, query: [String: String]) async throws -> Data {
        do {
            if try sessionManager.checkSessionExpiration() {
                try await sessionManager.refreshSession()
            }
            guard let session = sessionManager.session else {
                throw SupabaseSessionError.sessionNotExist
            }
            let response = try await networkProvider.request(
                with: SupabaseDBRequest.fetchData(
                    table: table,
                    accessToken: session.accessToken,
                    query: query
                )
            )
            return response.data
        } catch {
            throw SupabaseDBError.fetchDataFailed
        }
    }
    
    func insertData(into table: String, with data: Data) async throws {
        do {
            if try sessionManager.checkSessionExpiration() {
                try await SessionManager.shared.refreshSession()
            }
            guard let session = sessionManager.session else {
                throw SupabaseSessionError.sessionNotExist
            }
            _ = try await networkProvider.request(
                with: SupabaseDBRequest.insertData(
                    table: table,
                    accessToken: session.accessToken,
                    data: data
                )
            )
        } catch {
            throw SupabaseDBError.insertDataFailed
        }
    }
    
    func updateData(in table: String, at id: UUID, with data: Data) async throws {
        do {
            if try sessionManager.checkSessionExpiration() {
                try await SessionManager.shared.refreshSession()
            }
            guard let session = sessionManager.session else {
                throw SupabaseSessionError.sessionNotExist
            }
            _ = try await networkProvider.request(
                with: SupabaseDBRequest.updateData(
                    table: table,
                    id: id,
                    accessToken: session.accessToken,
                    data: data
                )
            )
        } catch {
            throw SupabaseDBError.updateDataFailed
        }
    }
    
    func fetchList(
        into table: String,
        with data: Data,
        page: Int = 0,
        pageSize: Int = 100
    ) async throws -> Data {
        do {
            if try sessionManager.checkSessionExpiration() {
                try await sessionManager.refreshSession()
            }
            guard let session = sessionManager.session else {
                throw SupabaseSessionError.sessionNotExist
            }
            
            let response = try await networkProvider.request(
                with: SupabaseDBRequest.fetchList(
                    table: table,
                    data: data,
                    accessToken: session.accessToken,
                    page: page,
                    pageSize: pageSize
                )
            )
            if let range = response.header?["content-range"] as? String,
               range == "*/*" {
                throw SupabaseDBError.noMoreData
            }
            return response.data
        } catch let error as SupabaseDBError {
            throw error
        } catch {
            throw SupabaseDBError.fetchDataFailed
        }
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
    case noMoreData
    
    var errorDescription: String? {
        switch self {
        case .fetchDataFailed: "데이터 불러오기 실패"
        case .insertDataFailed: "데이터 삽입 실패"
        case .updateDataFailed: "데이터 업데이트 실패"
        case .noMoreData: "더 불러올 데이터 없음"
        }
    }
}
