//
//  ProfileCreateRouter.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/14/24.
//
import UIKit

protocol ProfileSetRoutable {
    func presentMainScreen(from view: any ProfileSetViewable)
}

protocol ProfileSetBuildable {
    static func createProfileSetModule() -> UIViewController
}

final class ProfileSetRouter: ProfileSetRoutable {
    func presentMainScreen(from view: any ProfileSetViewable) {
        Task { @MainActor in
            if let sceneDelegate = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive })?
                .delegate as? SceneDelegate {
                if let router = sceneDelegate.appRouter {
                    router.displayHomeView()
                }
            }
        }
    }
}

extension ProfileSetRouter: ProfileSetBuildable {
    static func createProfileSetModule() -> UIViewController {
        let networkProvider = SNMNetworkProvider()
        let saveProfileImageUsecase: any SaveProfileImageUsecase = SaveProfileImageUsecaseImpl(
            remoteImageManager: SupabaseStorageManager(
                networkProvider: networkProvider,
                sessionManager: SupabaseSessionManager.shared
            ),
            fileManager: SNMFileManager(fileType: .image),
            localDataManager: UserDefaultsManager.shared,
            imageSampler: ImageSampler()
        )
        let checkNicknameUsecase: any CheckNicknameUsecase = CheckNicknameUsecaseImpl(
            remoteDBManager: SupabaseDBManager.shared
        )
        let updateUserInfoUsecase: any UpdateUserInfoUsecase = UpdateUserInfoUsecaseImpl(
            localDataManager: UserDefaultsManager.shared,
            remoteDBManager: SupabaseDBManager.shared,
            sessionManager: SupabaseSessionManager.shared
        )
        
        let view: any ProfileSetViewable & UIViewController = ProfileSetViewController()
        let presenter: any ProfileSetPresentable & DogInfoInteractorOutput = ProfileSetPresenter()
        let interactor: any ProfileSetInteractable = ProfileSetInteractor(
            saveProfileImageUsecase: saveProfileImageUsecase,
            updateUserInfoUsecase: updateUserInfoUsecase,
            checkNicknameUsecase: checkNicknameUsecase
        )
        let router: any ProfileSetRoutable & ProfileSetBuildable = ProfileSetRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        return view
    }
    
}
