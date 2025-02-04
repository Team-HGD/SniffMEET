//
//  SessionManager.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/19/24.
//

import Combine
import Foundation

protocol SessionManageable {
    var session: SupabaseSession? { get }
    var userID: UUID? { get }
    func restoreSession() async throws
    func refreshSession() async throws
    func saveSession(for session: SupabaseSession?) throws
    func checkSessionExpiration() throws -> Bool
}

final class SessionManager: SessionManageable {
    private let networkProvider: SNMNetworkProvider
    private let decoder: JSONDecoder
    var session: SupabaseSession?
    var userID: UUID? { session?.user?.userID }
    
    private init() {
        networkProvider = SNMNetworkProvider()
        decoder = JSONDecoder()
    }
    
    func restoreSession() async throws {
        try loadTokens()
        try await refreshSession()
    }
    
    func refreshSession() async throws {
        do {
            guard let refreshToken = session?.refreshToken else {
                throw SupabaseSessionError.sessionNotExist
            }
            let response = try await networkProvider.request(
                with: SupabaseSessionRequest.refreshToken(refreshToken: refreshToken)
            )
            let sessionResponse = try decoder.decode(
                SupabaseSessionResponse.self,
                from: response.data
            )
            try saveSession(
                for: SupabaseSession(
                    accessToken: sessionResponse.accessToken,
                    expiresAt: sessionResponse.expiresAt,
                    refreshToken: sessionResponse.refreshToken,
                    user: SupabaseUser(from: sessionResponse.user)
                )
            )
        } catch {
            throw SupabaseSessionError.refreshSessionFailed
        }
    }
    
    func saveSession(for session: SupabaseSession?) throws {
        guard let session else { throw SupabaseSessionError.sessionNotExist }
        do {
            try KeychainManager.shared.set(value: session.accessToken, forKey: "accessToken")
            try KeychainManager.shared.set(value: session.refreshToken, forKey: "refreshToken")
            try UserDefaultsManager.shared.set(value: session.expiresAt, forKey: "expiresAt")
            try UserDefaultsManager.shared.set(value: session.user, forKey: Environment.UserDefaultsKey.sessionUserInfo)
            self.session = session
        } catch {
            throw SupabaseSessionError.sessionNotExist
        }
    }
    
    func checkSessionExpiration() throws -> Bool {
        guard let session else {
            throw SupabaseSessionError.sessionNotExist
        }
        return Date(timeIntervalSince1970: TimeInterval(session.expiresAt + 30)) < Date()
    }
    
    private func loadTokens() throws {
        do {
            let accessToken = try KeychainManager.shared.get(forKey: "accessToken")
            let refreshToken = try KeychainManager.shared.get(forKey: "refreshToken")
            let expiresAt = try UserDefaultsManager.shared.get(forKey: "expiresAt", type: Int.self)
            self.session = SupabaseSession(
                accessToken: accessToken,
                expiresAt: expiresAt,
                refreshToken: refreshToken
            )
        } catch {
            throw SupabaseSessionError.loadSessionFailed
        }
    }
}

// MARK: - SessionManager+Singleton instance

extension SessionManager {
    static let shared = SessionManager()
}

// MARK: - SupabaseSessionError

enum SupabaseSessionError: LocalizedError {
    case loadSessionFailed
    case refreshSessionFailed
    case saveSessionFailed
    case sessionNotExist
    
    var errorDescription: String? {
        switch self {
        case .loadSessionFailed: "세션 불러오기 실패"
        case .saveSessionFailed: "세션 저장 실패"
        case .refreshSessionFailed: "세션 갱신 실패"
        case .sessionNotExist: "세션 존재하지 않음"
        }
    }
}
