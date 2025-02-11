//
//  ProfileCreateInteractable.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/14/24.
//

import UIKit

protocol ProfileCreateInteractable: AnyObject {
    var presenter: DogInfoInteractorOutput? { get set }
    var saveUserInfoUseCase: SaveUserInfoUseCase { get set }
    var saveProfileImageUseCase: SaveProfileImageUseCase { get }
    
    func signInWithProfileData(dogInfo: UserInfo, imageData: Data?)
    func convertImageToPNGData(image: UIImage?) -> Data?
    func convertImageToJPGData(image: UIImage?) -> Data?
}

final class ProfileCreateInteractor: ProfileCreateInteractable {
    weak var presenter: DogInfoInteractorOutput?
    var saveUserInfoUseCase: SaveUserInfoUseCase
    var saveProfileImageUseCase: SaveProfileImageUseCase
    var saveUserInfoRemoteUseCase: CreateAccountUseCase
    var signInUseCase: SignInUseCase
    
    init(
        presenter: DogInfoInteractorOutput? = nil,
        saveUserInfoUseCase: SaveUserInfoUseCase,
        saveProfileImageUseCase: SaveProfileImageUseCase,
        saveUserInfoRemoteUseCase: CreateAccountUseCase,
        signInUseCase: SignInUseCase
    ) {
        self.presenter = presenter
        self.saveUserInfoUseCase = saveUserInfoUseCase
        self.saveProfileImageUseCase = saveProfileImageUseCase
        self.saveUserInfoRemoteUseCase = saveUserInfoRemoteUseCase
        self.signInUseCase = signInUseCase
    }
    
    func signInWithProfileData(dogInfo: UserInfo, imageData: Data?) {
        Task {
            do {
                try await signInUseCase.execute()
                let fileName = try await saveUserInfoAndProfileImage(dogInfo: dogInfo, imageData: imageData)
                try await saveUserInfoToRemote(dogInfo: dogInfo, profileImageFileName: fileName)
                presenter?.didSaveUserInfo()
            } catch {
                presenter?.didFailToSaveUserInfo(error: error)
            }
        }
    }
    
    private func saveUserInfoAndProfileImage(dogInfo: UserInfo, imageData: Data?) async throws -> String? {
        return try await withThrowingTaskGroup(of: String?.self) { [weak self] group in
            group.addTask {
                try self?.saveUserInfoUseCase.execute(
                    dog: UserInfo(
                        name: dogInfo.name,
                        age: dogInfo.age,
                        sex: dogInfo.sex,
                        sexUponIntake: dogInfo.sexUponIntake,
                        size: dogInfo.size,
                        keywords: dogInfo.keywords,
                        nickname: dogInfo.nickname,
                        profileImage: imageData
                    )
                )
                return nil
            }
            if let imageData {
                group.addTask {
                    return try await self?.saveProfileImageUseCase.execute(imageData: imageData)
                }
            }
            var savedFileName: String? = nil
            for try await result in group {
                if let name = result {
                    savedFileName = name
                }
            }
            return savedFileName
        }
    }
    
    private func saveUserInfoToRemote(dogInfo: UserInfo, profileImageFileName: String?) async throws {
        guard let userID = try? SupabaseSessionManager.shared.userID.get() else {
            throw SupabaseSessionError.sessionNotExist
        }
        let userInfoDTO = UserInfoDTO(
            id: userID,
            dogName: dogInfo.name,
            age: dogInfo.age,
            sex: dogInfo.sex,
            sexUponIntake: dogInfo.sexUponIntake,
            size: dogInfo.size,
            keywords: dogInfo.keywords,
            nickname: dogInfo.nickname,
            profileImageURL: profileImageFileName
        )
        await saveUserInfoRemoteUseCase.execute(info: userInfoDTO)
    }
    
    func convertImageToPNGData(image: UIImage?) -> Data? {
        guard let image else { return nil }
        return image.pngData()
    }
    
    func convertImageToJPGData(image: UIImage?) -> Data? {
        guard let image else { return nil }
        return image.jpegData(compressionQuality: 0.8)
    }
}
