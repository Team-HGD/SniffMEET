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
        let updateUserInfoUseCase: UpdateUserInfoUseCase = UpdateUserInfoUseCaseImpl(
            localDBManager: UserDefaultsManager.shared,
            remoteDBManager: SupabaseDBManager.shared,
            sessionManager: SupabaseSessionManager.shared
        )
        let saveProfileImageUseCase: SaveProfileImageUseCase = SaveProfileImageUseCaseImpl(
            remoteImageManager: SupabaseStorageManager(
                networkProvider: SNMNetworkProvider(),
                sessionManager: SupabaseSessionManager.shared
            ),
            userDefaultsManager: UserDefaultsManager.shared,
            fileManager: SNMFileManager(fileType: .image),
            imageSampler: ImageSampler()
        )
        let view: ProfileEditViewable & UIViewController = ProfileEditViewController()
        let router: ProfileEditRoutable & ProfileEditBuildable = ProfileEditRouter()
        let interactor: ProfileEditInteractable = ProfileEditInteractor(
            updateUserInfoUseCase: updateUserInfoUseCase,
            saveProfileImageUseCase: saveProfileImageUseCase,
            loadUserInfoUseCase: LoadUserProfileUseCaseImpl(
                dataLoadable: LocalDataManager(),
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
