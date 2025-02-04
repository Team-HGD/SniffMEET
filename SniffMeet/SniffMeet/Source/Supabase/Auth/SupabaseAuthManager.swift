//
//  AuthManager.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/16/24.
//

import Combine
import Foundation

protocol AuthManageable {
    func signInAnonymously() async throws
}

final class SupabaseAuthManager: AuthManageable {
    private let networkProvider: any NetworkProvider
    private let decoder: JSONDecoder
    
    init(
        networkProvider: any NetworkProvider,
        decoder: JSONDecoder
    ) {
        self.networkProvider = networkProvider
        self.decoder = decoder
    }
    
    func signInAnonymously() async throws {
        do {
            let response = try await networkProvider.request(
                with: SupabaseAuthRequest.signInAnonymously
            )
            let sessionResponse = try decoder.decode(
                SupabaseSessionResponse.self,
                from: response.data
            )
            let session = SupabaseSession(
                accessToken: sessionResponse.accessToken,
                expiresAt: sessionResponse.expiresAt,
                refreshToken: sessionResponse.refreshToken,
                user: SupabaseUser(from: sessionResponse.user)
            )
            try SessionManager.shared.saveSession(for: session)
            
        } catch {
            throw SupabaseAuthError.signInFailed
        }
    }
}

// MARK: - SupabaseAuthError

enum SupabaseAuthError: LocalizedError {
    case signInFailed
    case userNotFound
    
    var errorDescription: String? {
        switch self {
        case .signInFailed: "로그인 실패"
        case .userNotFound: "유저 존재하지 않음"
        }
    }
}
