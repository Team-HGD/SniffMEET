//
//  WalkLogListRouter.swift
//  SniffMeet
//
//  Created by sole on 2/27/25.
//

import UIKit

protocol WalkLogListRoutable: AnyObject, Routable {
    func showTrackWalkView(view: any WalkLogListViewable)
}

protocol WalkLogListModuleBuildable {
    static func buildWalkLogListModule() -> UIViewController
}

final class WalkLogListRouter: WalkLogListRoutable {
    func showTrackWalkView(view: any WalkLogListViewable) {
        guard let view = view as? UIViewController else { return }
        push(from: view, to: TrackWalkRouter.create(), animated: true)
    }
}

extension WalkLogListRouter: WalkLogListModuleBuildable {
    static func buildWalkLogListModule() -> UIViewController {
        let view = WalkLogListViewController()
        let presenter = WalkLogListPresenter()
        let interactor = WalkLogListInteractor(
            loadUserInfoUsecase: LoadUserInfoUsecaseImpl(
                dataLoadable: LocalDataManager()
            ),
            loadUserProfileImageUsecase: LoadUserProfileImageImpl(
                imageManageable: SNMFileManager(fileType: .image)
            ),
            requestWalkLogListUsecase: RequestWalkLogListUsecaseImpl(
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
