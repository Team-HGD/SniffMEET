//
//  ProfileCreateInteractable.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/14/24.
//

import UIKit

protocol ProfileCreateInteractable: AnyObject {
    var presenter: (any ProfileCreateInteractorOutput)? { get set }
    var saveUserInfoUsecase: any SaveUserInfoUsecase { get set }
    var saveProfileImageUsecase: any SaveProfileImageUsecase { get }
    
    func signUp(with userInfo: ProfileInfo)
}

final class ProfileCreateInteractor: ProfileCreateInteractable {
    weak var presenter: (any ProfileCreateInteractorOutput)?
    var saveUserInfoUsecase: any SaveUserInfoUsecase
    var saveProfileImageUsecase: any SaveProfileImageUsecase
    var signInUsecase: any SignInUsecase
    
    init(
        presenter: (any ProfileCreateInteractorOutput)? = nil,
        saveUserInfoUsecase: any SaveUserInfoUsecase,
        saveProfileImageUsecase: any SaveProfileImageUsecase,
        signInUsecase: any SignInUsecase
    ) {
        self.presenter = presenter
        self.saveUserInfoUsecase = saveUserInfoUsecase
        self.saveProfileImageUsecase = saveProfileImageUsecase
        self.signInUsecase = signInUsecase
    }
    
    func signUp(with userInfo: ProfileInfo) {
        Task {
            do {
                try await signInUsecase.execute()
                try await saveUserInfoUsecase.execute(userInfo: userInfo)
                presenter?.didSaveUserInfo()
            } catch {
                presenter?.didFailToSaveUserInfo(error: error)
            }
        }
    }
}
