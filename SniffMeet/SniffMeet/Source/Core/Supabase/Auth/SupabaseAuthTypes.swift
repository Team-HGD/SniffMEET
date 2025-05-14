//
//  AuthTypes.swift
//  SniffMeet
//
//  Created by sole on 5/2/25.
//

struct SupabaseEmailAuthParameter: Encodable {
    let email: String
    let password: String
}

struct OpenIDConnectCredentials: Encodable {
    /// apple, google 등 idToken 제공자
    let provider: Provider
    let idToken: String

    enum Provider: String, Encodable {
        case apple
        case google
    }

    enum CodingKeys: String, CodingKey {
        case provider
        case idToken = "id_token"
    }
}

/// 로그아웃 세션 범위입니다.
enum SignOutScope: String, Encodable {
    /// 모든 세션에서 로그아웃합니다.
    case global
    /// 현재 세션만 로그아웃 합니다.
    case local
    /// 현재 세션 외 다른 모든 세션에서 로그아웃합니다.
    case others
}

struct ResendEmailParameter: Encodable {
    let email: String
    let type: EmailType

    enum EmailType: String, Encodable {
        case signUp = "signup"
        case emailChange = "email_change"
    }
}
