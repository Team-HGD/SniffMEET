//
//  AuthManager.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/16/24.
//

import Combine
import Foundation

protocol AuthManager {
    static var shared: AuthManager { get }
    var authStateSubject: PassthroughSubject<AuthState, Never> { get set }
    func signInAnonymously() async throws
    func restoreSession() async throws
    func refreshSession() async throws
    func loadTokens() throws
}

enum AuthState: String, CaseIterable {
    case signInSucced
    case signInFailed
    case signInAnonymously
}

final class SupabaseAuthManager: AuthManager {
    var authStateSubject: PassthroughSubject<AuthState, Never>
    private let networkProvider: SNMNetworkProvider
    private let decoder: JSONDecoder
    private var cancellables: Set<AnyCancellable>
    static let shared: AuthManager = SupabaseAuthManager()
    
    private init() {
        authStateSubject = PassthroughSubject<AuthState, Never>()
        networkProvider = SNMNetworkProvider()
        decoder = JSONDecoder()
        cancellables = Set<AnyCancellable>()
    }
    
    func signInAnonymously() async throws {
        do {
            let response = try await networkProvider.request(
                with: SupabaseAuthRequest.signInAnonymously
            )
            let sessionResponse = try decoder.decode(
                SupabaseSessionResponse.self,
                from: response.data)
            try saveSession(for: SupabaseSession(
                accessToken: sessionResponse.accessToken,
                expiresAt: sessionResponse.expiresAt,
                refreshToken: sessionResponse.refreshToken,
                user: SupabaseUser(from: sessionResponse.user)
            ))
            authStateSubject.send(.signInSucced)
        } catch {
            throw SupabaseAuthError.signInFailed
        }
    }
    
    func restoreSession() async throws {
        try loadTokens()
        try await refreshSession()
    }
    
    func refreshSession() async throws { // 세션 갱신
        do {
            // 세션에서 토큰 가져옴
            guard let refreshToken = SessionManager.shared.session?.refreshToken else {
                throw SupabaseAuthError.sessionNotExist
            }
            // 가져온 토큰으로 갱신 요청
            let response = try await networkProvider.request(
                with: SupabaseAuthRequest.refreshToken(refreshToken: refreshToken)
            )
            let sessionResponse = try decoder.decode(
                SupabaseSessionResponse.self,
                from: response.data
            )
            // 새로 받아온 토큰으로 세션 업데이트
            try saveSession(for: SupabaseSession(
                accessToken: sessionResponse.accessToken,
                expiresAt: sessionResponse.expiresAt,
                refreshToken: sessionResponse.refreshToken,
                user: SupabaseUser(from: sessionResponse.user)
            ))
        } catch {
            throw SupabaseAuthError.refreshSessionFailed
        }
    }
    
    func loadTokens() throws {
        do {
            let accessToken = try KeychainManager.shared.get(forKey: "accessToken")
            let refreshToken = try KeychainManager.shared.get(forKey: "refreshToken")
            let expiresAt = try UserDefaultsManager.shared.get(forKey: "expiresAt", type: Int.self)
            SessionManager.shared.session = SupabaseSession(
                accessToken: accessToken,
                expiresAt: expiresAt,
                refreshToken: refreshToken
            )
        } catch {
            throw SupabaseAuthError.loadSessionFailed
        }
    }
    
    private func saveSession(for session: SupabaseSession?) throws {
        guard let session else { throw SupabaseAuthError.sessionNotExist }
        do {
            try KeychainManager.shared.set(value: session.accessToken, forKey: "accessToken")
            try KeychainManager.shared.set(value: session.refreshToken, forKey: "refreshToken")
            try UserDefaultsManager.shared.set(value: session.expiresAt, forKey: "expiresAt")
            try UserDefaultsManager.shared.set(value: session.user, forKey: Environment.UserDefaultsKey.dogInfo)
            SessionManager.shared.session = session
        } catch {
            throw SupabaseAuthError.sessionNotExist
        }
    }
}

// MARK: - SupabaseAuthError

enum SupabaseAuthError: LocalizedError {
    case signInFailed
    case loadSessionFailed
    case refreshSessionFailed
    case saveSessionFailed
    case sessionNotExist
    case userNotFound
    
    var errorDescription: String? {
        switch self {
        case .signInFailed: "로그인 실패"
        case .loadSessionFailed: "세션 불러오기 실패"
        case .saveSessionFailed: "세션 저장 실패"
        case .refreshSessionFailed: "세션 갱신 실패"
        case .sessionNotExist: "세션 존재하지 않음"
        case .userNotFound: "유저 존재하지 않음"
        }
    }
}
