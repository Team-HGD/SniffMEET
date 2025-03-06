//
//  File.swift
//  SniffMeet
//
//  Created by Kelly Chui on 2/4/25.
//

protocol SignInUsecase {
    func execute() async throws
}

struct SignInUsecaseImpl: SignInUsecase {
    private let authManager: any AuthManageable
    
    init(authManager: any AuthManageable) {
        self.authManager = authManager
    }
    
    //TODO: 파라미터에 따라서 로그인 방식을 구분할 수 있도록 확장 가능할 것 같습니다.
    func execute() async throws {
        try await authManager.signInAnonymously()
    }
}
