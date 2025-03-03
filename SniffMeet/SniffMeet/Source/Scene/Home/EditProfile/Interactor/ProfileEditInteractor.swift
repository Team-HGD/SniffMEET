//
//  ProfileEditInteractor.swift
//  SniffMeet
//
//  Created by Kelly Chui on 12/1/24.
//

import Foundation

protocol ProfileEditInteractable: AnyObject {
    var presenter: (any ProfileEditInteractorOutput)? { get set }
    var updateUserInfoUseCase: any UpdateUserInfoUseCase { get set }
    var saveProfileImageUseCase: any SaveProfileImageUseCase { get set }
    
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
    var updateUserInfoUseCase: any UpdateUserInfoUseCase
    var saveProfileImageUseCase: any SaveProfileImageUseCase
    private let loadUserInfoUseCase: any LoadUserInfoUseCase
    private let loadUserProfileImageUseCase: any LoadUserProfileImageUseCase
    
    init(
        presenter: (any ProfileEditInteractorOutput)? = nil,
        updateUserInfoUseCase: any UpdateUserInfoUseCase,
        saveProfileImageUseCase: any SaveProfileImageUseCase,
        loadUserInfoUseCase: any LoadUserInfoUseCase,
        loadUserProfileImageUseCase: any LoadUserProfileImageUseCase
    ) {
        self.presenter = presenter
        self.updateUserInfoUseCase = updateUserInfoUseCase
        self.saveProfileImageUseCase = saveProfileImageUseCase
        self.loadUserInfoUseCase = loadUserInfoUseCase
        self.loadUserProfileImageUseCase = loadUserProfileImageUseCase
    }
    
    func requestProfile() -> (ProfileInfo, Data?) {
        do {
            let profileInfo = try loadUserInfoUseCase.execute()
            let profileImage = try loadUserProfileImageUseCase.execute()
            return (profileInfo, profileImage)
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
        let _ = try await saveProfileImageUseCase.execute(imageData: imageData)
    }
    private func updateUserInfo(
        name: String,
        age: UInt8,
        size: String,
        keywords: [String]
    ) async throws {
        do {
            try await updateUserInfoUseCase.execute(
                with: [
                    "name": name,
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
