//
//  SupabaseSessionRequest.swift
//  SniffMeet
//
//  Created by Kelly Chui on 2/4/25.
//

import Foundation

enum SupabaseSessionRequest {
    case refreshToken(refreshToken: String)
    case refreshUser(accessToken: String)
}

extension SupabaseSessionRequest: SNMRequestConvertible {
    var endpoint: Endpoint {
        switch self {
        case .refreshToken:
            return Endpoint(
                baseURL: SupabaseConfig.baseURL,
                path: "auth/v1/token",
                method: .post,
                query: [
                    "grant_type": "refresh_token"
                ]
            )
        case .refreshUser:
            return Endpoint(
                baseURL: SupabaseConfig.baseURL,
                path: "auth/v1/user",
                method: .get
            )
        }

    }
    var requestType: SNMRequestType {
        var header = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(SupabaseConfig.apiKey)",
            "apikey": SupabaseConfig.apiKey
        ]
        switch self {
        case .refreshToken(let refreshToken):
            header["Authorization"] = nil
            return SNMRequestType.compositePlain(
                header: header,
                body: Data("{ \"refresh_token\": \"\(refreshToken)\" }".utf8)
            )
        case .refreshUser(let accessToken):
            header["Authorization"] = "Bearer \(accessToken)"
            return SNMRequestType.header(
                with: header
            )
        }
    }
}
