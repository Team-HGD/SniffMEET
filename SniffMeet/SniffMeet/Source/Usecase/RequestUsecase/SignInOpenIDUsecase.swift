//
//  SignInOpenIDUsecase.swift
//  SniffMeet
//
//  Created by sole on 5/10/25.
//

protocol SignInOpenIDUsecase {
    func execute(provider: OpenIDProvider, idToken: String) async throws
}

final class SignInOpenIDUsecaseImpl: SignInOpenIDUsecase {
    private let authManager: any AuthManageable

    init(authManager: any AuthManageable) {
        self.authManager = authManager
    }

    func execute(provider: OpenIDProvider, idToken: String) async throws {
        guard let openIDProvider = OpenIDConnectCredentials.Provider(
            rawValue: provider.rawValue
        ) else {
            throw SupabaseAuthError.signInFailed
        }
        try await authManager.signIn(idToken: idToken, provider: openIDProvider)
    }
}
