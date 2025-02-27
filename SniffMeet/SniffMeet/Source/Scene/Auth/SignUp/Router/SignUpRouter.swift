//
//  SignUpRouter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/26/25.
//

import UIKit

protocol SignUpRoutable: AnyObject, Routable {
    var presenter: (any SignUpPresentable)? { get set }
}

protocol SignUpModuleBuildable {
    static func create() -> UIViewController
}

final class SignUpRouter: SignUpRoutable {
    weak var presenter: (any SignUpPresentable)?

}

extension SignUpRouter: SignUpModuleBuildable {
    static func create() -> UIViewController {
        let view: SignUpViewable & UIViewController = SignUpViewController()
        let presenter: SignUpPresentable & SignUpInteractorOutput = SignUpPresenter()
        let interactor: SignUpInteractable = SignUpInteractor()
        let router: SignUpRoutable & SignUpModuleBuildable = SignUpRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return view
    }
}
