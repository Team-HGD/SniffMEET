//
//  SupabaseStorageRequest.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/20/24.
//

import Foundation

enum SupabaseDBRequest {
    case fetchData(table: String, accessToken: String, query: [String: String])
    case insertData(table: String, accessToken: String, data: Data)
    case updateData(table: String, accessToken: String, data: Data, query: [String: String])
    case rpc(table: String, accessToken: String, data: Data, query: [String: String])
}

extension SupabaseDBRequest: SNMRequestConvertible {
    var endpoint: Endpoint {
        switch self {
        case .fetchData(let table, _, let query):
            return Endpoint(
                baseURL: SupabaseConfig.baseURL,
                path: "rest/v1/\(table)",
                method: .get,
                query: query
            )
        case .insertData(let table, _, _):
            return Endpoint(
                baseURL: SupabaseConfig.baseURL,
                path: "rest/v1/\(table)",
                method: .post,
                query: nil
            )
        case .updateData(let table, _, _, let query):
            return Endpoint(
                baseURL: SupabaseConfig.baseURL,
                path: "rest/v1/\(table)",
                method: .patch,
                query: query
            )
            
        case .rpc(let table,  _, _, let query):
            return Endpoint(
                baseURL: SupabaseConfig.baseURL,
                path: "rest/v1/\(table)",
                method: .post, // SQL 함수 호출은 POST 요청으로 수행
                query: query
            )
        }
    }
    var requestType: SNMRequestType {
        switch self {
        case .fetchData(_, let accessToken, _):
            return .header(with: createAuthHeader(accessToken: accessToken))
        case .insertData(_, let accessToken, let data),
             .updateData(_, let accessToken, let data, _):
            return .compositePlain(
                header: createAuthHeader(accessToken: accessToken),
                body: data
            )
        case .rpc(_, let accessToken, let data, _):
            return .compositePlain(
                header: createAuthHeader(accessToken: accessToken),
                body: data
            )
        }
    }
}

// MARK: - SupabaseDBRequest+HelperMethods

extension SupabaseDBRequest {
    func createAuthHeader(accessToken: String) -> [String: String] {
        return [
            "Content-Type": "application/json",
            "apikey": SupabaseConfig.apiKey,
            "Authorization": "Bearer \(accessToken)"
        ]
    }
}
