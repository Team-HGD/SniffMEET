//
//  SettingRouter.swift
//  SniffMeet
//
//  Created by 배현진 on 3/19/25.
//

import UIKit

protocol PreferencesRoutable: AnyObject, Routable {
    var presenter: (any PreferencesPresentable)? { get set }
    
    func showPersonalInfoView()
    func showNotificationSettingView()
    func showTermsOfUseView()
    func logoutView()
}

protocol PreferencesModuleBuildable {
    static func create() -> UIViewController
}

final class PreferencesRouter: PreferencesRoutable {
    weak var presenter: (any PreferencesPresentable)?

    func showPersonalInfoView() {
    }
    
    func showNotificationSettingView() {
    }
    
    func showTermsOfUseView() {
    }
    
    func logoutView() {
    }
}

extension PreferencesRouter: PreferencesModuleBuildable {
    static func create() -> UIViewController {
        let view: PreferencesViewable & UIViewController = PreferencesViewController()
        let presenter: PreferencesPresentable & PreferencesInteractorOutput = PreferencesPresenter()
        let interactor: PreferencesInteractable = PreferencesInteractor()
        let router: PreferencesRoutable & PreferencesModuleBuildable = PreferencesRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return view
    }
}
