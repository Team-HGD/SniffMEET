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
    static func createProfileSetModule(dogDetailInfo: DogInfo) -> UIViewController
}

final class ProfileSetRouter: ProfileSetRoutable {
    func presentMainScreen(from view: any ProfileSetViewable) {
        Task { @MainActor in
            if let sceneDelegate = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive })?
                .delegate as? SceneDelegate {
                if let router = sceneDelegate.appRouter {
                    router.moveToHomeScreen()
                }
            }
        }
    }
}

extension ProfileSetRouter: ProfileSetBuildable {
    static func createProfileSetModule(dogDetailInfo: DogInfo) -> UIViewController {
        let networkProvider = SNMNetworkProvider()
        let saveUserInfoUseCase: any SaveUserInfoUseCase = SaveUserInfoUseCaseImpl(
            localDataManager: LocalDataManager(),
            imageManager: SNMFileManager(fileType: .image)
        )
        let saveProfileImageUseCase: any SaveProfileImageUseCase = SaveProfileImageUseCaseImpl(
            remoteImageManager: SupabaseStorageManager(
                networkProvider: networkProvider,
                sessionManager: SupabaseSessionManager.shared
            ),
            userDefaultsManager: UserDefaultsManager.shared,
            imageSampler: ImageSampler()
        )
        let createAccountUseCase: any CreateAccountUseCase = CreateAccountUseCaseImpl(
            remoteDBManager: SupabaseDBManager.shared
        )
        let signInUseCase: any SignInUseCase = SignInUseCaseImpl(
            authManager: SupabaseAuthManager(
                networkProvider: networkProvider,
                sessionManager: SupabaseSessionManager.shared,
                decoder: JSONDecoder()
            )
        )
        let checkNicknameUseCase: any CheckNicknameUseCase = CheckNicknameUseCaseImpl(remoteDBManager: SupabaseDBManager.shared)
        
        let view: any ProfileSetViewable & UIViewController = ProfileSetViewController()
        let presenter: any ProfileSetPresentable & DogInfoInteractorOutput = ProfileSetPresenter(
            dogInfo: dogDetailInfo
        )
        let interactor: any ProfileSetInteractable = ProfileSetInteractor(
            saveUserInfoUseCase: saveUserInfoUseCase,
            saveProfileImageUseCase: saveProfileImageUseCase,
            saveUserInfoRemoteUseCase: createAccountUseCase,
            signInUseCase: signInUseCase,
            checkNicknameUseCase: checkNicknameUseCase
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
