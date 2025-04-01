//
//  SettingRouter.swift
//  SniffMeet
//
//  Created by 배현진 on 3/19/25.
//

import UIKit

protocol PreferencesRoutable: AnyObject, Routable {
    var presenter: (any PreferencesPresentable)? { get set }
    
    func showPersonalInfoView(view: any PreferencesViewable)
    func showNotificationSettingView()
    func showTermsOfUseView()
}

protocol PreferencesModuleBuildable {
    static func createPreferencesModule() -> UIViewController
}

final class PreferencesRouter: PreferencesRoutable {
    weak var presenter: (any PreferencesPresentable)?

    func showPersonalInfoView(view: any PreferencesViewable) {
        guard let view = view as? UIViewController else { return }
        let personalInfoView = PersonalInfoRouter.createPersonalInfoModule()
        push(from: view, to: personalInfoView, animated: true)
    }
    func showNotificationSettingView() {
    }
    
    func showTermsOfUseView() {
    }
}

extension PreferencesRouter: PreferencesModuleBuildable {
    static func createPreferencesModule() -> UIViewController {
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
