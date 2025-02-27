//
//  WalkLogListRouter.swift
//  SniffMeet
//
//  Created by sole on 2/27/25.
//

import UIKit

protocol WalkLogListRoutable: AnyObject, Routable {

}

protocol WalkLogListModuleBuildable {
    static func buildWalkLogListModule() -> UIViewController
}

final class WalkLogListRouter: WalkLogListRoutable {

}

extension WalkLogListRouter: WalkLogListModuleBuildable {
    static func buildWalkLogListModule() -> UIViewController {
        let view = WalkLogListViewController()
        let presenter = WalkLogListPresenter()
        let interactor = WalkLogListInteractor(
            loadUserInfoUsecase: LoadUserInfoUseCaseImpl(
                dataLoadable: LocalDataManager(),
                imageManageable: SNMFileManager(fileType: .image)
            ),
            requestWalkLogListUsecase: RequestWalkLogListUseCaseImpl(
                fileManager: SNMFileManager(fileType: .data)
            )
        )
        let router = WalkLogListRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return view
    }
}
