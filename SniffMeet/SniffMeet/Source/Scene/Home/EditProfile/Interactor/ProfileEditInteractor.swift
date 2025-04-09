//
//  ProfileEditInteractor.swift
//  SniffMeet
//
//  Created by Kelly Chui on 12/1/24.
//

import Foundation

protocol ProfileEditInteractable: AnyObject {
    var presenter: (any ProfileEditInteractorOutput)? { get set }
    var updateUserInfoUsecase: any UpdateUserInfoUsecase { get set }
    var saveProfileImageUsecase: any SaveProfileImageUsecase { get set }
    
    func requestProfile() -> (ProfileInfo, Data?)
    func editUserInfo(
        name: String,
        age: UInt8,
        size: String,
        keywords: [String],
        imageData: Data?
    )
}

final class ProfileEditInteractor: ProfileEditInteractable {
    weak var presenter: (any ProfileEditInteractorOutput)?
    var updateUserInfoUsecase: any UpdateUserInfoUsecase
    var saveProfileImageUsecase: any SaveProfileImageUsecase
    private let loadUserInfoUsecase: any LoadUserInfoUsecase
    private let loadUserProfileImageUsecase: any LoadUserProfileImageUsecase
    
    init(
        presenter: (any ProfileEditInteractorOutput)? = nil,
        updateUserInfoUsecase: any UpdateUserInfoUsecase,
        saveProfileImageUsecase: any SaveProfileImageUsecase,
        loadUserInfoUsecase: any LoadUserInfoUsecase,
        loadUserProfileImageUsecase: any LoadUserProfileImageUsecase
    ) {
        self.presenter = presenter
        self.updateUserInfoUsecase = updateUserInfoUsecase
        self.saveProfileImageUsecase = saveProfileImageUsecase
        self.loadUserInfoUsecase = loadUserInfoUsecase
        self.loadUserProfileImageUsecase = loadUserProfileImageUsecase
    }
    
    func requestProfile() -> (ProfileInfo, Data?) {
        do {
            let profileInfo = try loadUserInfoUsecase.execute()
            let profileImageData = try loadUserProfileImageUsecase.execute()
            return (profileInfo, profileImageData)
        } catch {
            // FIXME: 에러 핸들링 필요
            return (ProfileInfo.example, nil)
        }
    }
    func editUserInfo(
        name: String,
        age: UInt8,
        size: String,
        keywords: [String],
        imageData: Data?
    ) {
        Task {
            do {
                try await updateUserInfo(
                    name: name,
                    age: age,
                    size: size,
                    keywords: keywords
                )
                guard let imageData else {
                    presenter?.didSaveUserInfo()
                    return
                }
                try await saveProfile(imageData: imageData)
                presenter?.didSaveUserInfo()
            } catch let error {
                SNMLogger.error(error.localizedDescription)
            }
        }
    }
    private func saveProfile(imageData: Data) async throws {
        let _ = try await saveProfileImageUsecase.execute(imageData: imageData)
    }
    private func updateUserInfo(
        name: String,
        age: UInt8,
        size: String,
        keywords: [String]
    ) async throws {
        do {
            try await updateUserInfoUsecase.execute(
                with: [
                    "dog_name": name,
                    "age": age,
                    "size": size,
                    "keywords": keywords
                ]
            )
        } catch let error {
            SNMLogger.error(error.localizedDescription)
        }
    }
}
