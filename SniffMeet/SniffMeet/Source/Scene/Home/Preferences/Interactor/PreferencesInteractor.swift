//
//  SettingInteractor.swift
//  SniffMeet
//
//  Created by 배현진 on 3/19/25.
//

protocol PreferencesInteractable: AnyObject {
    var presenter: PreferencesInteractorOutput? { get set }
}

final class PreferencesInteractor: PreferencesInteractable {
    weak var presenter: (any PreferencesInteractorOutput)?
}
