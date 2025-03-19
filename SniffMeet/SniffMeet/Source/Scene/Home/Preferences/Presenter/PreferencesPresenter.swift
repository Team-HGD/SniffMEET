//
//  SettingPresenter.swift
//  SniffMeet
//
//  Created by 배현진 on 3/19/25.
//

protocol PreferencesPresentable: AnyObject {
    var view: (any PreferencesViewable)? { get set }
    var interactor: (any PreferencesInteractable)? { get set }
    var router: (any PreferencesRoutable)? { get set }
}

protocol PreferencesInteractorOutput: AnyObject {
}

final class PreferencesPresenter: PreferencesPresentable {
    weak var view: (any PreferencesViewable)?
    var interactor: (any PreferencesInteractable)?
    var router: (any PreferencesRoutable)?
}

extension PreferencesPresenter: PreferencesInteractorOutput {
}
