//
//  ProfileSetupPresenter.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/14/24.
//

import Combine
import Foundation
import UIKit

protocol ProfileSetPresentable : AnyObject {
    var dogInfo: DogInfo { get set }
    var view: (any ProfileSetViewable)? { get set }
    var interactor: (any ProfileSetInteractable)? { get set }
    var router: (any ProfileSetRoutable)? { get set }
    var output: any ProfileSetPresenterOutput { get }
    
    func didTapSubmitButton(nickname: String, image: UIImage?)
    func didtextFieldEndEditing(text: String)
}

protocol DogInfoInteractorOutput: AnyObject {
    func didSaveUserInfo()
    func didFailToSaveUserInfo(error: Error)
    func notifyNicknameDuplication(_ isDuplicated: Bool)
}

final class ProfileSetPresenter: ProfileSetPresentable {
    weak var view: (any ProfileSetViewable)?
    var interactor: (any ProfileSetInteractable)?
    var router: (any ProfileSetRoutable)?
    let output: any ProfileSetPresenterOutput
    var dogInfo: DogInfo
    
    init(dogInfo: DogInfo,
         view: (any ProfileSetViewable)? = nil,
         interactor: (any ProfileSetInteractable)? = nil,
         router: (any ProfileSetRoutable)? = nil,
         output: any ProfileSetPresenterOutput = DefaultProfileSetPresenterOutput()
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

extension ProfileSetPresenter: DogInfoInteractorOutput {
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
protocol ProfileSetPresenterOutput {
    var isDuplicated: PassthroughSubject<Bool, Never> { get }
}

struct DefaultProfileSetPresenterOutput: ProfileSetPresenterOutput {
    var isDuplicated = PassthroughSubject<Bool, Never>()
}
