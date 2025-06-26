//
//  ResendEmailUsecase.swift
//  SniffMeet
//
//  Created by sole on 5/10/25.
//

protocol ResendSignUpEmailUsecase {
    /// redirectTo: 인증 메일을 클릭했을 때 리다이렉트되는 URL 주소를 입력합니다.
    /// 입력하지 않은 경우, supabase dashboard에 기입된 주소로 리다이렉트 됩니다.
    func execute(email: String, redirectTo: String?) async throws
}

struct ResendSignUpEmailUsecaseImpl: ResendSignUpEmailUsecase {
    private let authManager: any AuthManageable

    init(authManager: any AuthManageable) {
        self.authManager = authManager
    }

    func execute(email: String, redirectTo: String?) async throws {
        let parameter = ResendEmailParameter(email: email, type: .signUp)
        try await authManager.resendVerificationEmail(parameter: parameter, redirectTo: redirectTo)
    }
}
