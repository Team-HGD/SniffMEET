//
//  ProfileInputPresenter.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/14/24.
//

import Foundation

protocol ProfileCreatePresentable: AnyObject {
    var view: (any ProfileCreateViewable)? { get set }
    var router: (any ProfileCreateRoutable)? { get set }
    var interactor: (any ProfileCreateInteractable)? { get set }
    func didTabSubmitButton(
        nameText: String?,
        ageText: String?,
        sexText: String,
        sexUponIntake: Bool,
        sizeText: String,
        keywords: [Keyword]
    )
}

protocol ProfileCreateInteractorOutput: AnyObject {
    func didSaveUserInfo()
    func didFailToSaveUserInfo(error: Error)
}

final class ProfileCreatePresenter: ProfileCreatePresentable {
    weak var view: (any ProfileCreateViewable)?
    var interactor: (any ProfileCreateInteractable)?
    var router: (any ProfileCreateRoutable)?
    let output: any ProfileCreatePresenterOutput
    
    init(view: (any ProfileCreateViewable)? = nil,
         interactor: (any ProfileCreateInteractable)? = nil,
         router: (any ProfileCreateRoutable)? = nil,
         output: any ProfileCreatePresenterOutput = DefaultProfileCreatePresenterOutput()
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.output = output
    }
    
    func didTabSubmitButton(
        nameText: String?,
        ageText: String?,
        sexText: String,
        sexUponIntake: Bool,
        sizeText: String,
        keywords: [Keyword]
    ) {
        guard let name = nameText,
              let ageText,
              let age = UInt8(ageText),
              let sex = Sex(rawValue: sexText),
              let size = Size(rawValue: sizeText) else {
            // TODO: 로컬 머지 이후 에러 핸들링
            return
        }
        let userInfo = ProfileInfo(
            name: name,
            age: age,
            sex: sex,
            sexUponIntake: sexUponIntake,
            size: size,
            keywords: keywords,
            nickname: UUID().uuidString
        )
        interactor?.signUp(with: userInfo)
    }
}

extension ProfileCreatePresenter: ProfileCreateInteractorOutput {
    func didSaveUserInfo() {
        guard let view else { return }
        view.didSuccessCreateProfile()
        router?.presentProfileSetView(from: view)
    }
    
    func didFailToSaveUserInfo(error: any Error) {
        view?.didFailToCreateProfile()
    }
}

// MARK: - ProfileCreatePresenterOutput
protocol ProfileCreatePresenterOutput {
    
}

struct DefaultProfileCreatePresenterOutput: ProfileCreatePresenterOutput {
    
}
