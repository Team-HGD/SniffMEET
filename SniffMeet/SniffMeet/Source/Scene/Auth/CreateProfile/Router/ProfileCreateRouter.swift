//
//  ProfileCreateRouter.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/14/24.
//
import UIKit

protocol ProfileCreateRoutable {
    func presentMainScreen(from view: ProfileCreateViewable)
}

protocol ProfileCreateBuildable {
    static func createProfileCreateModule(dogDetailInfo: DogInfo) -> UIViewController
}

final class ProfileCreateRouter: ProfileCreateRoutable {
    func presentMainScreen(from view: any ProfileCreateViewable) {
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

extension ProfileCreateRouter: ProfileCreateBuildable {
    static func createProfileCreateModule(dogDetailInfo: DogInfo) -> UIViewController {
        let networkProvider = SNMNetworkProvider()
        let saveUserInfoUseCase: SaveUserInfoUseCase = SaveUserInfoUseCaseImpl(
            localDataManager: LocalDataManager(),
            imageManager: SNMFileManager(fileType: .image)
        )
        let saveProfileImageUseCase: SaveProfileImageUseCase = SaveProfileImageUseCaseImpl(
            remoteImageManager: SupabaseStorageManager(
                networkProvider: networkProvider,
                sessionManager: SupabaseSessionManager.shared
            ),
            userDefaultsManager: UserDefaultsManager.shared,
            imageSampler: ImageSampler()
        )
        let createAccountUseCase: CreateAccountUseCase = CreateAccountUseCaseImpl(
            remoteDBManager: SupabaseDBManager.shared
        )
        let signInUseCase: SignInUseCase = SignInUseCaseImpl(
            authManager: SupabaseAuthManager(
                networkProvider: networkProvider,
                sessionManager: SupabaseSessionManager.shared,
                decoder: JSONDecoder()
            )
        )
        let checkNicknameDuplicationUseCase: CheckNicknameDuplicationUseCase = CheckNicknameDuplicationUseCaseImpl(
            remoteDBManager: SupabaseDBManager.shared,
            sessionManager: SupabaseSessionManager.shared
        )

        let view: ProfileCreateViewable & UIViewController = ProfileCreateViewController()
        let presenter: ProfileCreatePresentable & DogInfoInteractorOutput
        = ProfileCreatePresenter(dogInfo: dogDetailInfo)
        let interactor: ProfileCreateInteractable =
        ProfileCreateInteractor(
            saveUserInfoUseCase: saveUserInfoUseCase,
            saveProfileImageUseCase: saveProfileImageUseCase,
            saveUserInfoRemoteUseCase: createAccountUseCase,
            signInUseCase: signInUseCase,
            checkNicknameDuplicationUseCase: checkNicknameDuplicationUseCase
        )
        let router: ProfileCreateRoutable & ProfileCreateBuildable = ProfileCreateRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        return view
    }
    
}
