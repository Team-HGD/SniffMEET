//
//  ProfileCreateInteractable.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/14/24.
//

import UIKit

protocol ProfileSetInteractable: AnyObject {
    var presenter: (any DogInfoInteractorOutput)? { get set }
    
    func saveProfile(imageData: Data?, withNickname nickname: String)
    func isNicknameTaken(_ nickname: String)
}

final class ProfileSetInteractor: ProfileSetInteractable {
    weak var presenter: (any DogInfoInteractorOutput)?
    private let saveProfileImageUseCase: any SaveProfileImageUseCase
    private let updateUserInfoUseCase: any UpdateUserInfoUseCase
    private let checkNicknameUseCase: any CheckNicknameUseCase
    
    init(
        presenter: (any DogInfoInteractorOutput)? = nil,
        saveProfileImageUseCase: any SaveProfileImageUseCase,
        updateUserInfoUseCase: any UpdateUserInfoUseCase,
        checkNicknameUseCase: any CheckNicknameUseCase
    ) {
        self.presenter = presenter
        self.saveProfileImageUseCase = saveProfileImageUseCase
        self.updateUserInfoUseCase = updateUserInfoUseCase
        self.checkNicknameUseCase = checkNicknameUseCase
    }
    
    func saveProfile(imageData: Data?, withNickname nickname: String) {
        guard let imageData else { return }
        Task {
            let profileImageName = try await saveProfileImageUseCase.execute(imageData: imageData)
            try await updateUserInfoUseCase.execute(
                with: ["nickname": nickname, "profile_image_url": profileImageName]
            )
        }
    }
    
    func isNicknameTaken(_ nickname: String) {
        Task {
            let isDuplicated = try await checkNicknameUseCase.execute(
                nickname: nickname
            )
            presenter?.notifyNicknameDuplication(isDuplicated)
        }
    }
}
