//
//  SignInAppleUsecase.swift
//  SniffMeet
//
//  Created by sole on 5/10/25.
//

protocol SignInAppleUsecase {
    /// 성공 시 idToken을 반환합니다.
    func execute() async throws -> String
}

struct SignInAppleUsecaseImpl: SignInAppleUsecase {
    private let appleAuthManager: any AppleAuthManageable

    init(appleAuthManager: any AppleAuthManageable) {
        self.appleAuthManager = appleAuthManager
    }

    func execute() async throws -> String {
        try await appleAuthManager.signIn()
    }
}
