//
//  ProfileDropRouter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/11/25.
//

import UIKit

protocol ProfileDropRoutable: AnyObject, Routable {
    var presenter: (any ProfileDropPresentable)? { get set }
    func dismissView(view: any ProfileDropViewable)
}

protocol ProfileDropBuildable {
    static func createProfileDropModule() -> UIViewController
}

final class ProfileDropRouter: ProfileDropRoutable {
    weak var presenter: (any ProfileDropPresentable)?

    func dismissView(view: any ProfileDropViewable) {
        if let view = view as? UIViewController {
            Task { @MainActor in
                dismiss(from: view, animated: true)
            }
        }
    }
}

extension ProfileDropRouter: ProfileDropBuildable {
    static func createProfileDropModule() -> UIViewController {
        let view: ProfileDropViewable & UIViewController = ProfileDropViewController()
        let router: ProfileDropRoutable & ProfileDropBuildable = ProfileDropRouter()
        let presenter: ProfileDropPresentable & ProfileDropInteractorOutput = ProfileDropPresenter()
        let interactor: ProfileDropInteractable = ProfileDropInteractor()

        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        router.presenter = presenter

        return view
    }
}
