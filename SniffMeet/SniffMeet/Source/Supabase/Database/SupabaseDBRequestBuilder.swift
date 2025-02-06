//
//  SupabaseDBRequestBuilder.swift
//  SniffMeet
//
//  Created by Kelly Chui on 2/6/25.
//

import Foundation

enum SupabaseDBTask {
    case fetch
    case insert
    case update
    case rpc
}

final class SupabaseDBRequestBuilder {
    private let networkProvider: any NetworkProvider
    private let accessToken: String // 만료부터 30초 미리 갱신하기 때문에 중간에 바뀔 일이 없습니다.
    private var task: SupabaseDBTask
    private var table: String?
    private var headers: [String: String] = [:]
    private var body: Data?
    private var query: [String: String]?
    
    init(networkProvider: any NetworkProvider, accessToken: String, task: SupabaseDBTask) {
        self.networkProvider = networkProvider
        self.accessToken = accessToken
        self.task = task
    }
    
    func setTable(_ table: String) -> Self {
        self.table = table
        return self
    }
    
    func setHeaders(_ token: String) -> Self {
        self.headers["Authorization"] = "Bearer \(token)"
        return self
    }

    func setBody(_ body: Data) -> Self {
        self.body = body
        return self
    }

    func setQuery(key: String, value: String) -> Self {
        if query == nil { query = [:] }
        query?[key] = value
        return self
    }

    private func build() async throws -> SupabaseDBRequest {
        switch task {
        case .fetch:
            guard let table = self.table else { throw SupabaseDBError.insertDataFailed }
            return SupabaseDBRequest.fetchData(
                table: table,
                accessToken: accessToken,
                query: self.query ?? [:]
            )
        case .insert:
            guard let body = self.body,
                  let table = self.table else { throw SupabaseDBError.insertDataFailed }
            return SupabaseDBRequest.insertData(
                table: table,
                accessToken: accessToken,
                data: body
            )
        case .update:
            guard let body = self.body,
                  let query = self.query,
                  let table = self.table else { throw SupabaseDBError.updateDataFailed }
            return SupabaseDBRequest.updateData(
                table: table,
                accessToken: accessToken,
                data: body,
                query: query
            )
        case .rpc:
            guard let body = self.body,
                  let query = self.query,
                  let table = self.table else { throw SupabaseDBError.rpcFailed }
            return SupabaseDBRequest.rpc(
                table: table,
                accessToken: accessToken,
                data: body,
                query: query
            )
        }
    }
    
    @discardableResult
    func request() async throws -> Data {
        let response = try await networkProvider.request(
            with: try build()
        )
        SNMLogger.info("요청!")
        return response.data
    }
}
