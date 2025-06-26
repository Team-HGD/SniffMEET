//
//  SignInGoogleUsecase.swift
//  SniffMeet
//
//  Created by sole on 5/10/25.
//

protocol SignInGoogleUsecase {
    /// 성공 시 idToken을 반환합니다.
    func execute() async throws -> String
}

struct SignInGoogleUsecaseImpl: SignInGoogleUsecase {
    private let googleAuthManager: any GoogleAuthManageable

    init(googleAuthManager: any GoogleAuthManageable) {
        self.googleAuthManager = googleAuthManager
    }

    func execute() async throws -> String {
        try await googleAuthManager.signIn()
    }
}
