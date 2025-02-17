//
//  ProfileSetupPresenter.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/14/24.
//

import Combine
import Foundation
import UIKit

protocol ProfileCreatePresentable : AnyObject{
    var dogInfo: DogInfo { get set }
    var view: ProfileCreateViewable? { get set }
    var interactor: ProfileCreateInteractable? { get set }
    var router: ProfileCreateRoutable? { get set }
    var output: any ProfileCreatePresenterOutput { get }
    
    func didTapSubmitButton(nickname: String, image: UIImage?)
    func didtextFieldEndEditing(text: String)
}

protocol DogInfoInteractorOutput: AnyObject {
    func didSaveUserInfo()
    func didFailToSaveUserInfo(error: Error)
    func notifyNicknameDuplication(_ isDuplicated: Bool)
}


final class ProfileCreatePresenter: ProfileCreatePresentable {
    weak var view: (any ProfileCreateViewable)?
    var interactor: (any ProfileCreateInteractable)?
    var router: (any ProfileCreateRoutable)?
    let output: any ProfileCreatePresenterOutput
    var dogInfo: DogInfo
    
    init(dogInfo: DogInfo,
         view: (any ProfileCreateViewable)? = nil,
         interactor: (any ProfileCreateInteractable)? = nil,
         router: (any ProfileCreateRoutable)? = nil,
         output: any ProfileCreatePresenterOutput = DefaultProfileCreatePresenterOutput()
    ) {
        self.dogInfo = dogInfo
        self.view = view
        self.interactor = interactor
        self.router = router
        self.output = output
    }

    func didTapSubmitButton(nickname: String, image: UIImage?) {
        let jpgData = interactor?.convertImageToJPGData(image: image)
        let userInfo = UserInfo(
            name: dogInfo.name,
            age: dogInfo.age,
            sex: dogInfo.sex,
            sexUponIntake: dogInfo.sexUponIntake,
            size: dogInfo.size,
            keywords: dogInfo.keywords,
            nickname: nickname,
            profileImage: nil
        )
        // TODO: SubmitButton disable 필요
        interactor?.signInWithProfileData(
            dogInfo: userInfo,
            imageData: jpgData
        )
    }
    
    func didtextFieldEndEditing(text: String) {
        interactor?.isNicknameTaken(text)
    }
}

extension ProfileCreatePresenter: DogInfoInteractorOutput {
    func didSaveUserInfo() {
        // TODO: submit button enable
        guard let view else { return }
        view.didSuccessCreateProfile()
        router?.presentMainScreen(from: view)
    }
    
    func didFailToSaveUserInfo(error: any Error) {
        // TODO: -  alert 올리는데 어떻게 올릴지 정하기
        // TODO: submit button enable
        view?.didFailToCreateProfile()
    }
    
    func notifyNicknameDuplication(_ isDuplicated: Bool) {
        output.isDuplicated.send(isDuplicated)
    }
}

// MARK: - MateListPresenterOutput
protocol ProfileCreatePresenterOutput {
    var isDuplicated: PassthroughSubject<Bool, Never> { get }
}

struct DefaultProfileCreatePresenterOutput: ProfileCreatePresenterOutput {
    var isDuplicated = PassthroughSubject<Bool, Never>()
}
