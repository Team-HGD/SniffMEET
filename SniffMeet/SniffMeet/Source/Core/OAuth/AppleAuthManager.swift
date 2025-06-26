//
//  AppleAuthManager.swift
//  SniffMeet
//
//  Created by sole on 5/2/25.
//

import AuthenticationServices

protocol AppleAuthManageable: AnyObject {
    func signIn() async throws -> String
}

final class AppleAuthManager: NSObject, AppleAuthManageable {
    private let provider: ASAuthorizationAppleIDProvider = ASAuthorizationAppleIDProvider()
    private var authorizationController: ASAuthorizationController?
#if DEBUG
    private var continuation: CheckedContinuation<String, Error>?
#else
    private var continuation: UnsafeContinuation<String, Error>?
#endif

    private override init() {
        super.init()
    }

    func signIn() async throws -> String {
        // 중복 로그인 요청 방지 및 continuation misuse/crash 방지
        guard continuation == nil else { throw AppleAuthError.signInFailed }
        let request = provider.createRequest()
        authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController?.delegate = self
        authorizationController?.presentationContextProvider = self
#if DEBUG
        let idToken = try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.continuation = continuation
            self?.authorizationController?.performRequests()
        }
#else
        let idToken = try await withUnsafeThrowingContinuation { [weak self] continuation in
            self?.continuation = continuation
            self?.authorizationController?.performRequests()
        }
#endif
        return idToken
    }

    private func resumeOnce(with result: Result<String, Error>) {
        guard let continuation else { return }
        self.continuation = nil
        switch result {
        case .success(let idToken):
            continuation.resume(returning: idToken)
        case .failure(let error):
            continuation.resume(throwing: error)
        }
    }
}

// MARK: - AppleAuthManager+

extension AppleAuthManager {
    static let shared: AppleAuthManager = AppleAuthManager()
}

extension AppleAuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.keyWindow?.windowScene {
            ASPresentationAnchor(windowScene: windowScene)
        } else {
            ASPresentationAnchor()
        }
    }
}

extension AppleAuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let idTokenData = credential.identityToken,
           let idToken = String(data: idTokenData, encoding: .utf8) else {
            resumeOnce(with: .failure(AppleAuthError.idTokenNotFound))
            return
        }
        resumeOnce(with: .success(idToken))
    }
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: any Error
    ) {
        resumeOnce(with: .failure(AppleAuthError.signInFailed))
    }
}

// MARK: - AppleAuthError

enum AppleAuthError: LocalizedError {
    case idTokenNotFound
    case signInFailed
    case signInAlreadyInProgress

    var localizedDescription: String {
        switch self {
        case .idTokenNotFound: "idToken을 찾을 수 없습니다."
        case .signInFailed: "애플 로그인에 실패했습니다."
        case .signInAlreadyInProgress: "애플 로그인 진행 중입니다."
        }
    }
}
