//
//  ProfileCreateInteractable.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/14/24.
//

import UIKit

protocol ProfileCreateInteractable: AnyObject {
    var presenter: (any ProfileCreateInteractorOutput)? { get set }
    var saveUserInfoUseCase: any SaveUserInfoUseCase { get set }
    var saveProfileImageUseCase: any SaveProfileImageUseCase { get }
    
    func signUp(with userInfo: ProfileInfo)
}

final class ProfileCreateInteractor: ProfileCreateInteractable {
    weak var presenter: (any ProfileCreateInteractorOutput)?
    var saveUserInfoUseCase: any SaveUserInfoUseCase
    var saveProfileImageUseCase: any SaveProfileImageUseCase
    var signInUseCase: any SignInUseCase
    
    init(
        presenter: (any ProfileCreateInteractorOutput)? = nil,
        saveUserInfoUseCase: any SaveUserInfoUseCase,
        saveProfileImageUseCase: any SaveProfileImageUseCase,
        signInUseCase: any SignInUseCase
    ) {
        self.presenter = presenter
        self.saveUserInfoUseCase = saveUserInfoUseCase
        self.saveProfileImageUseCase = saveProfileImageUseCase
        self.signInUseCase = signInUseCase
    }
    
    func signUp(with userInfo: ProfileInfo) {
        Task {
            do {
                try await signInUseCase.execute()
                try await saveUserInfoUseCase.execute(userInfo: userInfo)
                presenter?.didSaveUserInfo()
            } catch {
                presenter?.didFailToSaveUserInfo(error: error)
            }
        }
    }
}
