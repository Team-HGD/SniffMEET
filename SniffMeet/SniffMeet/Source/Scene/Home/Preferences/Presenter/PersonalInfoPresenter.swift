//
//  PersonalInfoPresenter.swift
//  SniffMeet
//
//  Created by 배현진 on 3/23/25.
//

protocol PersonalInfoPresentable: AnyObject {
    var view: (any PersonalInfoViewable)? { get set }
    var interactor: (any PersonalInfoInteractable)? { get set }
    var router: (any PersonalInfoRoutable)? { get set }
    
    func getOptions() -> [PersonalInfoOption]
    func didSelectOption(_ type: PersonalInfoType)
}

protocol PersonalInfoInteractorOutput: AnyObject {
}

final class PersonalInfoPresenter: PersonalInfoPresentable {
    weak var view: (any PersonalInfoViewable)?
    var interactor: (any PersonalInfoInteractable)?
    var router: (any PersonalInfoRoutable)?
    
    private var personalInfoOptions: [PersonalInfoOption] = []
    
    func getOptions() -> [PersonalInfoOption] {
        personalInfoOptions = [
            PersonalInfoOption(title: "비밀번호 변경", type: .changePW),
            PersonalInfoOption(title: "회원 탈퇴", type: .delectAccount)
        ]
        return personalInfoOptions
    }
    
    func didSelectOption(_ type: PersonalInfoType) {
        guard let view else { return }
        switch type {
        case .changePW:
            router?.showChangePWView(view: view)
        case .delectAccount:
        // TODO: - 회원 탈퇴 구현 연결
            SNMLogger.log("회원 탈퇴")
        }
    }
}

extension PersonalInfoPresenter: PersonalInfoInteractorOutput {
}
