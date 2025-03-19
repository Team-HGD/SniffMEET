//
//  ResetPwRouter.swift
//  SniffMeet
//
//  Created by 배현진 on 3/2/25.
//

import UIKit

protocol ResetPwRoutable: AnyObject, Routable {
    var presenter: (any ResetPwPresentable)? { get set }
}

protocol ResetPwModuleBuildable {
    static func create() -> UIViewController
}

final class ResetPwRouter: ResetPwRoutable {
    weak var presenter: (any ResetPwPresentable)?

}

extension ResetPwRouter: ResetPwModuleBuildable {
    static func create() -> UIViewController {
        let view: ResetPwViewable & UIViewController = ResetPwViewController()
        let presenter: ResetPwPresentable & ResetPwInteractorOutput = ResetPwPresenter()
        let interactor: ResetPwInteractable = ResetPwInteractor()
        let router: ResetPwRoutable & ResetPwModuleBuildable = ResetPwRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return view
    }
}
