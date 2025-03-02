//
//  ResetPwEmailRouter.swift
//  SniffMeet
//
//  Created by 배현진 on 3/2/25.
//

import UIKit

protocol ResetPwEmailRoutable: AnyObject, Routable {
    var presenter: (any ResetPwEmailPresentable)? { get set }
}

protocol ResetPwEmailModuleBuildable {
    static func create() -> UIViewController
}

final class ResetPwEmailRouter: ResetPwEmailRoutable {
    weak var presenter: (any ResetPwEmailPresentable)?

}

extension ResetPwEmailRouter: ResetPwEmailModuleBuildable {
    static func create() -> UIViewController {
        let view: ResetPwEmailViewable & UIViewController = ResetPwEmailViewController()
        let presenter: ResetPwEmailPresentable & ResetPwEmailInteractorOutput = ResetPwEmailPresenter()
        let interactor: ResetPwEmailInteractable = ResetPwEmailInteractor()
        let router: ResetPwEmailRoutable & ResetPwEmailModuleBuildable = ResetPwEmailRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return view
    }
}
