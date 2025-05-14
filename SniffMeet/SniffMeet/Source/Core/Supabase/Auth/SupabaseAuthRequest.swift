//
//  SupabaseRequest.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/18/24.
//

import Foundation

enum SupabaseAuthRequest {
    case signInAnonymously
    case signInWithEmail(parameter: SupabaseEmailAuthParameter)
    case signInWithIDToken(credentials: OpenIDConnectCredentials)
    case signUpWithEmail(parameter: SupabaseEmailAuthParameter, redirectTo: String?)
    case signOut(accessToken: String, scope: SignOutScope)
    case resendEmail(parameter: ResendEmailParameter, redirectTo: String?)
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
        case .signUpWithEmail(_, let redirectTo):
            return Endpoint(
                baseURL: SupabaseConfig.baseURL,
                path: "auth/v1/signup",
                method: .post,
                query: redirectTo == nil ? [:] : ["redirect_to": redirectTo!]
            )
        case .signInWithEmail:
            return Endpoint(
                baseURL: SupabaseConfig.baseURL,
                path: "auth/v1/token",
                method: .post,
                query: ["grant_type": "password"]
            )
        case .signInWithIDToken:
            return Endpoint(
                baseURL: SupabaseConfig.baseURL,
                path: "auth/v1/token",
                method: .post,
                query: ["grant_type": "id_token"]
            )
        case .signOut(_, let scope):
            return Endpoint(
                baseURL: SupabaseConfig.baseURL,
                path: "auth/v1/logout",
                method: .post,
                query: ["scope": scope.rawValue]
            )
        case .resendEmail(_, let redirectTo):
            return Endpoint(
                baseURL: SupabaseConfig.baseURL,
                path: "auth/v1/resend",
                method: .post,
                query: redirectTo == nil ? [:] : ["redirect_to": redirectTo!]
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
        case .signUpWithEmail(let parameter, _):
            return SNMRequestType.compositeJSONEncodable(
                header: header,
                body: parameter
            )
        case .signInWithEmail(let parameter):
            return SNMRequestType.compositeJSONEncodable(
                header: header,
                body: parameter
            )
        case .signInWithIDToken(let credentials):
            return SNMRequestType.compositeJSONEncodable(
                header: header,
                body: credentials
            )
        case .signOut(let accessToken, _):
            return SNMRequestType.header(
                with: [
                    "Content-Type": "application/json",
                    "Authorization": "Bearer \(accessToken)",
                    "apikey": SupabaseConfig.apiKey
                ]
            )
        case .resendEmail(let parameter, _):
            return SNMRequestType.compositeJSONEncodable(
                header: header,
                body: parameter
            )
        }
    }
}
