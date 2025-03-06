//
//  HomeModuleBuilder.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/11/24.
//

import UIKit

enum HomeModuleBuilder {
    static func build() -> UIViewController {
        let view = HomeViewController()
        let router = HomeRouter()
        let interactor = HomeInteractor(
            loadUserInfoUsecase: LoadUserInfoUsecaseImpl(
                dataLoadable: LocalDataManager()
            ),
            loadUserProfileImageUsecase: LoadUserProfileImageImpl(
                imageManageable: SNMFileManager(fileType: .image)
            ),
            checkFirstLaunchUsecase: CheckFirstLaunchUsecaseImpl(
                userDefaultsManager: UserDefaultsManager.shared
            ),
            saveFirstLaunchUsecase: SaveFirstLaunchUsecaseImpl(
                userDefaultsManager: UserDefaultsManager.shared
            ),
            requestNotificationAuthUsecase: RequestNotificationAuthUsecaseImpl(),
            remoteSaveDeviceTokenUsecase: RemoteSaveDeviceTokenUsecaseImpl(
                keychainManager: KeychainManager.shared,
                remoteDBManager: SupabaseDBManager.shared,
                sessionManager: SupabaseSessionManager.shared
            )
        )
        view.presenter = HomePresenter(view: view, router: router, interactor: interactor)
        interactor.presenter = view.presenter
        return view
    }
}
