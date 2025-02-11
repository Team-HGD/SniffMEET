//
//  SupabaseRequest.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/18/24.
//

import Foundation

enum SupabaseAuthRequest {
    case signInAnonymously
}

extension SupabaseAuthRequest: SNMRequestConvertible {
    var endpoint: Endpoint {
        switch self {
        case .signInAnonymously:
            return Endpoint(
                baseURL: SupabaseConfig.baseURL,
                path: "auth/v1/signup",
                method: .post
            )
        }
    }
    var requestType: SNMRequestType {
        let header = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(SupabaseConfig.apiKey)",
            "apikey": SupabaseConfig.apiKey
        ]
        switch self {
        case .signInAnonymously:
            return SNMRequestType.compositePlain(
                header: header,
                body: Data("{}".utf8)
            )
        }
    }
}
