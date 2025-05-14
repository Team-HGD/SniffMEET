//
//  SignInEmailUsecase.swift
//  SniffMeet
//
//  Created by sole on 5/14/25.
//

protocol SignInEmailUsecase {
    func execute(email: String, password: String) async throws
}

struct SignInEmailUsecaseImpl: SignInEmailUsecase {
    private let authManager: any AuthManageable

    init(authManager: any AuthManageable) {
        self.authManager = authManager
    }

    func execute(email: String, password: String) async throws {
        try await authManager.signIn(email: email, password: password)
    }
}
