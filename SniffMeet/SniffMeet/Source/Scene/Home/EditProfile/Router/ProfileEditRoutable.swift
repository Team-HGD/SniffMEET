//
//  ProfileEditRoutable.swift
//  SniffMeet
//
//  Created by Kelly Chui on 12/1/24.
//

import UIKit

protocol ProfileEditRoutable: Routable {
    func presentMainScreen(from view: ProfileEditViewable)
}

protocol ProfileEditBuildable {
    static func createProfileEditModule(userInfo: ProfileInfo) -> UIViewController
}

final class ProfileEditRouter: ProfileEditRoutable {
    func presentMainScreen(from view: any ProfileEditViewable) {
        Task { @MainActor in
            pop(from: view as! UIViewController, animated: true)
        }
    }
}

extension ProfileEditRouter: ProfileEditBuildable {
    static func createProfileEditModule(userInfo: ProfileInfo) -> UIViewController {
        let updateUserInfoUsecase: UpdateUserInfoUsecase = UpdateUserInfoUsecaseImpl(
            localDataManager: UserDefaultsManager.shared,
            remoteDBManager: SupabaseDBManager.shared,
            sessionManager: SupabaseSessionManager.shared
        )
        let saveProfileImageUsecase: SaveProfileImageUsecase = SaveProfileImageUsecaseImpl(
            remoteImageManager: SupabaseStorageManager(
                networkProvider: SNMNetworkProvider(),
                sessionManager: SupabaseSessionManager.shared
            ),
            fileManager: SNMFileManager(fileType: .image),
            localDataManager: UserDefaultsManager.shared,
            imageSampler: ImageSampler()
        )
        let view: ProfileEditViewable & UIViewController = ProfileEditViewController()
        let router: ProfileEditRoutable & ProfileEditBuildable = ProfileEditRouter()
        let interactor: ProfileEditInteractable = ProfileEditInteractor(
            updateUserInfoUsecase: updateUserInfoUsecase,
            saveProfileImageUsecase: saveProfileImageUsecase,
            loadUserInfoUsecase: LoadUserInfoUsecaseImpl(dataLoadable: LocalDataManager()),
            loadUserProfileImageUsecase: LoadUserProfileImageImpl(
                imageManageable: SNMFileManager(fileType: .image)
            )
        )
        let presenter: ProfileEditPresentable & ProfileEditInteractorOutput =
        ProfileEditPresenter(userInfo: userInfo)

        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter

        return view
    }
}
