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
    func signIn(idToken: String, provider: OpenIDConnectCredentials.Provider) async throws
    func signIn(email: String, password: String) async throws
    /// redirectTo: 인증 메일을 클릭했을 때 리다이렉트되는 URL 주소를 입력합니다.
    /// 입력하지 않은 경우, supabase dashboard에 기입된 주소로 리다이렉트 됩니다.
    @discardableResult func signUp(
        email: String,
        password: String,
        redirectTo: String?
    ) async throws -> SupabaseUser
    func signOut(scope: SignOutScope) async throws
    /// redirectTo: 인증 메일을 클릭했을 때 리다이렉트되는 URL 주소를 입력합니다.
    /// 입력하지 않은 경우, supabase dashboard에 기입된 주소로 리다이렉트 됩니다.
    func resendVerificationEmail(
        parameter: ResendEmailParameter,
        redirectTo: String?
    ) async throws
}

final class SupabaseAuthManager: AuthManageable {
    private let networkProvider: any NetworkProvider
    private let sessionManager: any SessionManageable
    private let jsonDecoder: JSONDecoder

    init(
        networkProvider: any NetworkProvider,
        sessionManager: any SessionManageable,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.networkProvider = networkProvider
        self.sessionManager = sessionManager
        self.jsonDecoder = jsonDecoder
    }

    func signInAnonymously() async throws {
        do {
            let response = try await networkProvider.request(
                with: SupabaseAuthRequest.signInAnonymously
            )
            let sessionResponse = try jsonDecoder.decode(
                SupabaseSessionResponse.self,
                from: response.data
            )
            let session = SupabaseSession(
                accessToken: sessionResponse.accessToken,
                expiresAt: sessionResponse.expiresAt,
                refreshToken: sessionResponse.refreshToken,
                user: SupabaseUser(from: sessionResponse.user)
            )
            try sessionManager.saveSession(for: session)

        } catch {
            throw SupabaseAuthError.signInFailed
        }
    }

    func signIn(email: String, password: String) async throws {
        let parameter = SupabaseEmailAuthParameter(email: email, password: password)
        do {
            let response = try await networkProvider.request(
                with: SupabaseAuthRequest.signInWithEmail(parameter: parameter)
            )
            try storeSession(from: response)
        } catch {
            throw SupabaseAuthError.signInFailed
        }
    }

    /// idToken으로 회원가입, 로그인을 수행합니다.
    func signIn(idToken: String, provider: OpenIDConnectCredentials.Provider) async throws {
        let credentials = OpenIDConnectCredentials(provider: provider, idToken: idToken)
        do {
            let response = try await networkProvider.request(
                with: SupabaseAuthRequest.signInWithIDToken(credentials: credentials)
            )
            try storeSession(from: response)
        } catch {
            throw SupabaseAuthError.signInFailed
        }
    }

    /// redirectTo: 인증 메일을 클릭했을 때 리다이렉트되는 URL 주소를 입력합니다.
    /// 입력하지 않은 경우, supabase dashboard에 기입된 주소로 리다이렉트 됩니다.
    @discardableResult
    func signUp(
        email: String,
        password: String,
        redirectTo: String? = nil
    ) async throws -> SupabaseUser {
        let parameter = SupabaseEmailAuthParameter(email: email, password: password)
        do {
            let response = try await networkProvider.request(
                with: SupabaseAuthRequest.signUpWithEmail(
                    parameter: parameter,
                    redirectTo: redirectTo
                )
            )
            let userResponse = try jsonDecoder.decode(
                SupabaseUserResponse.self,
                from: response.data
            )
            let user = SupabaseUser(from: userResponse)
            if user.emailVerified == nil { // 이미 Authentication에 등록된 사용자가 signUp 시도
                throw SupabaseAuthError.alreadExistEmail
            }
            return user
        } catch SNMNetworkError.failedStatusCode(let reason) {
            switch reason.rawValue {
            case 422:
                throw SupabaseAuthError.weakPassword
            case 429:
                throw SupabaseAuthError.tooManyEmailRequest
            default:
                throw SupabaseAuthError.signUpFailed
            }
        } catch {
            throw SupabaseAuthError.signUpFailed
        }
    }

    func signOut(scope: SignOutScope = .local) async throws {
        let accessToken = try sessionManager.accessToken.get()
        do {
            _ = try await networkProvider.request(
                with: SupabaseAuthRequest.signOut(
                    accessToken: accessToken,
                    scope: scope
                )
            )
            try sessionManager.deleteSession()
        } catch {
            throw SupabaseAuthError.signInFailed
        }
    }

    /// redirectTo: 인증 메일을 클릭했을 때 리다이렉트되는 URL 주소를 입력합니다.
    /// 입력하지 않은 경우, supabase dashboard에 기입된 주소로 리다이렉트 됩니다.
    func resendVerificationEmail(
        parameter: ResendEmailParameter,
        redirectTo: String? = nil
    ) async throws {
        do {
            _ = try await networkProvider.request(
                with: SupabaseAuthRequest.resendEmail(
                    parameter: parameter,
                    redirectTo: redirectTo
                )
            )
        } catch {
            throw SupabaseAuthError.resendVerificationEmailFailed
        }
    }

    /// 네트워크로 받은 응답을 세션에 반영합니다.
    private func storeSession(from response: SNMNetworkResponse) throws {
        let sessionResponse = try jsonDecoder.decode(
            SupabaseSessionResponse.self,
            from: response.data
        )
        let session = SupabaseSession(
            accessToken: sessionResponse.accessToken,
            expiresAt: sessionResponse.expiresAt,
            refreshToken: sessionResponse.refreshToken,
            user: SupabaseUser(from: sessionResponse.user)
        )
        try sessionManager.saveSession(for: session)
    }
}

// MARK: - SupabaseAuthError

enum SupabaseAuthError: LocalizedError {
    case signInFailed
    case userNotFound
    case signOutFailed
    case signUpFailed
    /// Authentication에 이미 등록 및 인증된 이메일
    case alreadExistEmail
    case resendVerificationEmailFailed
    /// 이메일 인증을 하지 않은 사용자가 연속적으로 signUp을 시도하면, 이메일 전송량 초과
    /// 또는 하루 이메일 전송량 (50건) 초과
    case tooManyEmailRequest
    case weakPassword

    var errorDescription: String? {
        switch self {
        case .signInFailed: "로그인 실패"
        case .userNotFound: "유저 존재하지 않음"
        case .signOutFailed: "로그아웃 실패"
        case .signUpFailed: "회원가입 실패"
        case .alreadExistEmail: "이미 존재하는 유저"
        case .resendVerificationEmailFailed: "인증 이메일 재발송 실패"
        case .tooManyEmailRequest: "이메일 재발송 요청 횟수 초과"
        case .weakPassword: "비밀번호 길이가 너무 짧음"
        }
    }
}
