//
//  SigninRouter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/26/25.
//

import UIKit

protocol SigninRoutable: AnyObject, Routable {
    var presenter: (any SigninPresentable)? { get set }
}

protocol SigninModuleBuildable {
    static func create() -> UIViewController
}

final class SigninRouter: SigninRoutable {
    weak var presenter: (any SigninPresentable)?

}

extension SigninRouter: SigninModuleBuildable {
    static func create() -> UIViewController {
        let view: SigninViewable & UIViewController = SigninViewController()
        let presenter: SigninPresentable & SigninInteractorOutput = SigninPresenter()
        let interactor: SigninInteractable = SigninInteractor()
        let router: SigninRoutable & SigninModuleBuildable = SigninRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return view
    }
}
