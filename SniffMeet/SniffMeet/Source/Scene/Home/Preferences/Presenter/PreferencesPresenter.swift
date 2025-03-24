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
    
    func getOptions() -> [PreferencesOption]
    func didSelectOption(_ type: PreferencesType)
}

protocol PreferencesInteractorOutput: AnyObject {
}

final class PreferencesPresenter: PreferencesPresentable {
    weak var view: (any PreferencesViewable)?
    var interactor: (any PreferencesInteractable)?
    var router: (any PreferencesRoutable)?
    
    private var preferencesOptions: [PreferencesOption] = []
    
    func getOptions() -> [PreferencesOption] {
        preferencesOptions = [
            PreferencesOption(title: "개인정보 수정", type: .personalInfo),
            PreferencesOption(title: "알림 설정", type: .notificationSetting),
            PreferencesOption(title: "개인정보 이용 약관", type: .termsOfUse),
            PreferencesOption(title: "로그아웃", type: .logout)
        ]
        return preferencesOptions
    }
    
    func didSelectOption(_ type: PreferencesType) {
        guard let view else { return }
        switch type {
        case .personalInfo:
            router?.showPersonalInfoView(view: view)
        case .notificationSetting:
            router?.showNotificationSettingView()
        case .termsOfUse:
            router?.showTermsOfUseView()
        case .logout:
        // TODO: - 로그아웃 동작 연결
            SNMLogger.log("로그아웃")
        }
    }
}

extension PreferencesPresenter: PreferencesInteractorOutput {
}
