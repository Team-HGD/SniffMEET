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
    private let saveProfileImageUsecase: any SaveProfileImageUsecase
    private let updateUserInfoUsecase: any UpdateUserInfoUsecase
    private let checkNicknameUsecase: any CheckNicknameUsecase
    
    init(
        presenter: (any DogInfoInteractorOutput)? = nil,
        saveProfileImageUsecase: any SaveProfileImageUsecase,
        updateUserInfoUsecase: any UpdateUserInfoUsecase,
        checkNicknameUsecase: any CheckNicknameUsecase
    ) {
        self.presenter = presenter
        self.saveProfileImageUsecase = saveProfileImageUsecase
        self.updateUserInfoUsecase = updateUserInfoUsecase
        self.checkNicknameUsecase = checkNicknameUsecase
    }
    
    func saveProfile(imageData: Data?, withNickname nickname: String) {
        guard let imageData else { return }
        Task {
            let profileImageName = try await saveProfileImageUsecase.execute(imageData: imageData)
            try await updateUserInfoUsecase.execute(
                with: ["nickname": nickname, "profile_image_url": profileImageName]
            )
        }
    }
    
    func isNicknameTaken(_ nickname: String) {
        Task {
            let isDuplicated = try await checkNicknameUsecase.execute(
                nickname: nickname
            )
            presenter?.notifyNicknameDuplication(isDuplicated)
        }
    }
}
