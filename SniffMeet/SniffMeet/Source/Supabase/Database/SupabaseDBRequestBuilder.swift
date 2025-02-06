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

protocol SupabaseDBRequestBuildable {
    func request() async throws -> Data
}

final class SupabaseDBRequestBuilder: SupabaseDBRequestBuildable {
    private let networkProvider: any NetworkProvider
    private let accessToken: String // 만료부터 30초 미리 갱신하기 때문에 중간에 바뀔 일이 없습니다.
    private var task: SupabaseDBTask
    private var table: String?
    private var data: Data?
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

    func setData(_ data: Data) -> Self {
        self.data = data
        return self
    }

    func setQuery(_ parameter: SupabaseQueryParameter) -> Self {
        query = query ?? [:]
        query?[parameter.key] = parameter.value
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
            guard let data = self.data,
                  let table = self.table else { throw SupabaseDBError.insertDataFailed }
            return SupabaseDBRequest.insertData(
                table: table,
                accessToken: accessToken,
                data: data
            )
        case .update:
            guard let data = self.data,
                  let query = self.query,
                  let table = self.table else { throw SupabaseDBError.updateDataFailed }
            return SupabaseDBRequest.updateData(
                table: table,
                accessToken: accessToken,
                data: data,
                query: query
            )
        case .rpc:
            guard let data = self.data,
                  let query = self.query,
                  let table = self.table else { throw SupabaseDBError.rpcFailed }
            return SupabaseDBRequest.rpc(
                table: table,
                accessToken: accessToken,
                data: data,
                query: query
            )
        }
    }
    
    @discardableResult
    func request() async throws -> Data {
        let response = try await networkProvider.request(
            with: try build()
        )
        return response.data
    }
}
