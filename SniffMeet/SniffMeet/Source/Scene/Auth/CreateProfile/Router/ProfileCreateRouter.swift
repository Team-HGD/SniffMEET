//
//  Untitled.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/14/24.
//
import UIKit

protocol ProfileCreateRoutable {
    func presentProfileSetView(from view: any ProfileCreateViewable)
}

protocol ProfileCreateBuildable {
    static func createProfileCreateModule() -> UIViewController
}

final class ProfileCreateRouter: ProfileCreateRoutable {
    func presentProfileSetView(from view: any ProfileCreateViewable) {
        Task { @MainActor in
            let profileCreateViewController = ProfileSetRouter.createProfileSetModule()
            if let sourceView = view as? UIViewController {
                sourceView.navigationController?.pushViewController(
                    profileCreateViewController,
                    animated: true
                )
            }
        }
    }
}

extension ProfileCreateRouter: ProfileCreateBuildable {
    static func createProfileCreateModule() -> UIViewController {
        let networkProvider: any NetworkProvider = SNMNetworkProvider()
        let view: any ProfileCreateViewable & UIViewController = ProfileCreateViewController()
        let presenter: any ProfileCreatePresentable & ProfileCreateInteractorOutput = ProfileCreatePresenter()
        let router: any ProfileCreateRoutable & ProfileCreateBuildable = ProfileCreateRouter()
        let interactor: any ProfileCreateInteractable = ProfileCreateInteractor(
            saveUserInfoUseCase: SaveUserInfoUseCaseImpl(
                localDataManager: UserDefaultsManager.shared,
                remoteDBManager: SupabaseDBManager.shared,
                sessionManager: SupabaseSessionManager.shared
            ),
            saveProfileImageUseCase: SaveProfileImageUseCaseImpl(
                remoteImageManager: SupabaseStorageManager(
                    networkProvider: networkProvider,
                    sessionManager: SupabaseSessionManager.shared
                ),
                fileManager: SNMFileManager(fileType: .image),
                localDataManager: UserDefaultsManager.shared,
                imageSampler: ImageSampler()
            ),
            signInUseCase: SignInUseCaseImpl(
                authManager: SupabaseAuthManager(
                    networkProvider: networkProvider,
                    sessionManager: SupabaseSessionManager.shared
                )
            )
        )
        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        return view
    }
}
