//
//  PersonalInfoRouter.swift
//  SniffMeet
//
//  Created by 배현진 on 3/23/25.
//

import UIKit

protocol PersonalInfoRoutable: AnyObject, Routable {
    var presenter: (any PersonalInfoPresentable)? { get set }
    
    func showChangePWView(view: any PersonalInfoViewable)
}

protocol PersonalInfoModuleBuildable {
    static func create() -> UIViewController
}

final class PersonalInfoRouter: PersonalInfoRoutable {
    weak var presenter: (any PersonalInfoPresentable)?

    func showChangePWView(view: any PersonalInfoViewable) {
        guard let view = view as? UIViewController else { return }
        let changePWView = ResetPwRouter.create()
        push(from: view, to: changePWView, animated: true)
    }
}

extension PersonalInfoRouter: PersonalInfoModuleBuildable {
    static func create() -> UIViewController {
        let view: PersonalInfoViewable & UIViewController = PersonalInfoViewController()
        let presenter: PersonalInfoPresentable & PersonalInfoInteractorOutput = PersonalInfoPresenter()
        let interactor: PersonalInfoInteractable = PersonalInfoInteractor()
        let router: PersonalInfoRoutable & PersonalInfoModuleBuildable = PersonalInfoRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return view
    }
}
