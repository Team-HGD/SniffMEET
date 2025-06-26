//
//  SignUpEmailUsecase.swift
//  SniffMeet
//
//  Created by sole on 5/10/25.
//

protocol SignUpEmailUsecase {
    /// 이메일로 회원가입을 시도합니다. redirectTo는 사용자가 인증 이메일을 탭했을 때 연결되는 링크 주소입니다.
    func execute(email: String, password: String, redirectTo: String?) async throws
}

struct SignUpEmailUsecaseImpl: SignUpEmailUsecase {
    private let authManager: any AuthManageable

    init(authManager: any AuthManageable) {
        self.authManager = authManager
    }

    func execute(email: String, password: String, redirectTo: String?) async throws {
        try await authManager.signUp(
            email: email,
            password: password,
            redirectTo: redirectTo
        )
    }
}
