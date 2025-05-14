//
//  GoogleAuthManager.swift
//  SniffMeet
//
//  Created by sole on 5/2/25.
//

import GoogleSignIn

protocol GoogleAuthManageable {
    @MainActor func signIn() async throws -> String
    func signOut()
}

final class GoogleAuthManager: GoogleAuthManageable {
    private init() {}

    @MainActor
    func signIn() async throws -> String {
        guard let rootViewController = UIViewController.topMostViewController else {
            throw GoogleAuthError.viewHierarchyNotFound
        }
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController
            )
            guard let idToken = result.user.idToken?.tokenString else {
                throw GoogleAuthError.idTokenNotFound
            }
            return idToken
        } catch let error as GoogleAuthError {
            throw error
        } catch {
            throw GoogleAuthError.signInFailed
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
}

extension GoogleAuthManager {
    static let shared: GoogleAuthManageable = GoogleAuthManager()
}

enum GoogleAuthError: Error {
    case viewHierarchyNotFound
    case idTokenNotFound
    case signInFailed

    var localizedDescription: String {
        switch self {
        case .viewHierarchyNotFound: "로그인 창을 띄울 뷰 계층을 찾을 수 없습니다."
        case .idTokenNotFound: "idToken을 찾을 수 없습니다."
        case .signInFailed: "구글 로그인에 실패했습니다."
        }
    }
}
