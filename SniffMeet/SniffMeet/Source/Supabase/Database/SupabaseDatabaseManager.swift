//
//  SupabaseDatabaseManager.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/20/24.
//

import Combine
import Foundation

protocol RemoteDatabaseManager {
    func fetchData(from table: String, query: [String: String]) async throws -> Data
    func insertData(into table: String, with data: Data) async throws
    func updateData(into table: String, with data: Data) async throws
    func updateData(into table: String, at id: UUID, with data: Data) async throws 
    func fetchList(
        into table: String,
        with data: Data,
        page: Int,
        pageSize: Int
    ) async throws -> Data
    func deleteMateData(from table: String, userID: UUID, mateID: UUID) async throws
}

final class SupabaseDatabaseManager: RemoteDatabaseManager {
    static let shared: RemoteDatabaseManager = SupabaseDatabaseManager()
    private let networkProvider: SNMNetworkProvider
    private let decoder: JSONDecoder

    private init() {
        networkProvider = SNMNetworkProvider()
        decoder = JSONDecoder()
    }

    func fetchData(from table: String, query: [String: String]) async throws -> Data {
        do {
            if SessionManager.shared.isExpired {
                try await SupabaseAuthManager.shared.refreshSession()
            }
            guard let session = SessionManager.shared.session else {
                throw SupabaseAuthError.sessionNotExist
            }
            let response = try await networkProvider.request(
                with: SupabaseDatabaseRequest.fetchData(
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
            if SessionManager.shared.isExpired {
                try await SupabaseAuthManager.shared.refreshSession()
            }
            guard let session = SessionManager.shared.session else {
                throw SupabaseAuthError.sessionNotExist
            }
            _ = try await networkProvider.request(
                with: SupabaseDatabaseRequest.insertData(
                    table: table,
                    accessToken: session.accessToken,
                    data: data
                )
            )
        } catch {
            throw SupabaseDBError.insertDataFailed
        }
    }

    func updateData(into table: String, with data: Data) async throws {
        do {
            if SessionManager.shared.isExpired {
                try await SupabaseAuthManager.shared.refreshSession()
            }
            guard let session = SessionManager.shared.session else {
                throw SupabaseAuthError.sessionNotExist
            }
            guard let userID = SessionManager.shared.session?.user?.userID else { return }
            
            _ = try await networkProvider.request(
                with: SupabaseDatabaseRequest.updateData(
                    table: table,
                    id: userID,
                    accessToken: session.accessToken,
                    data: data
                )
            )
        } catch {
            throw SupabaseDBError.updateDataFailed
        }
    }
    
    func updateData(into table: String, at id: UUID, with data: Data) async throws {
        do {
            if SessionManager.shared.isExpired {
                try await SupabaseAuthManager.shared.refreshSession()
            }
            guard let session = SessionManager.shared.session else {
                throw SupabaseAuthError.sessionNotExist
            }
            _ = try await networkProvider.request(
                with: SupabaseDatabaseRequest.updateData(
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
            if SessionManager.shared.isExpired {
                try await SupabaseAuthManager.shared.refreshSession()
            }
            guard let session = SessionManager.shared.session else {
                throw SupabaseAuthError.sessionNotExist
            }

            let response = try await networkProvider.request(
                with: SupabaseDatabaseRequest.fetchList(
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

    func deleteMateData(from table: String, userID: UUID, mateID: UUID) async throws {
        do {
            if SessionManager.shared.isExpired {
                try await SupabaseAuthManager.shared.refreshSession()
            }
            guard let session = SessionManager.shared.session else {
                throw SupabaseAuthError.sessionNotExist
            }

            let userMateListData = try await fetchData(
                from: table,
                query: ["id": "eq.\(userID)"]
            )
            guard let jsonString = String(data: userMateListData, encoding: .utf8),
                  let jsonData = jsonString.data(using: .utf8),
                  let userMateListArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
                  let userMateListJSON = userMateListArray.first,
                  let mates = userMateListJSON["mates"] as? [String] else {
                throw SupabaseDBError.fetchDataFailed
            }

            var matesToUUID = mates.compactMap { UUID(uuidString: $0) }
            matesToUUID.removeAll { $0 == mateID }
            SNMLogger.log("mates: \(matesToUUID)")

            let updatedData = try JSONSerialization.data(withJSONObject: ["mates": matesToUUID.map { $0.uuidString }])

            _ = try await networkProvider.request(
                with: SupabaseDatabaseRequest.updateData(
                    table: table,
                    id: userID,
                    accessToken: session.accessToken,
                    data: updatedData
                )
            )
        } catch {
            throw SupabaseDBError.deleteDataFailed
        }
    }
}

// MARK: - SupabaseDBError

enum SupabaseDBError: LocalizedError {
    case fetchDataFailed
    case insertDataFailed
    case updateDataFailed
    case noMoreData
    case deleteDataFailed

    var errorDescription: String? {
        switch self {
        case .fetchDataFailed: "데이터 불러오기 실패"
        case .insertDataFailed: "데이터 삽입 실패"
        case .updateDataFailed: "데이터 업데이트 실패"
        case .noMoreData: "더 불러올 데이터 없음"
        case .deleteDataFailed: "데이터 삭제 실패"
        }
    }
}
