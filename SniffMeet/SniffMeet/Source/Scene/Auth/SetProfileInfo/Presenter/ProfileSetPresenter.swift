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
    var view: (any ProfileSetViewable)? { get set }
    var interactor: (any ProfileSetInteractable)? { get set }
    var router: (any ProfileSetRoutable)? { get set }
    var output: any ProfileSetPresenterOutput { get }
    
    func didTapSubmitButton(nickname: String, image: UIImage?)
    func didtextFieldEndEditing(text: String)
}

protocol DogInfoInteractorOutput: AnyObject {
    func notifyNicknameDuplication(_ isDuplicated: Bool)
}

final class ProfileSetPresenter: ProfileSetPresentable {
    weak var view: (any ProfileSetViewable)?
    var interactor: (any ProfileSetInteractable)?
    var router: (any ProfileSetRoutable)?
    let output: any ProfileSetPresenterOutput
    
    init(
        view: (any ProfileSetViewable)? = nil,
        interactor: (any ProfileSetInteractable)? = nil,
        router: (any ProfileSetRoutable)? = nil,
        output: any ProfileSetPresenterOutput = DefaultProfileSetPresenterOutput()
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.output = output
    }
    
    func didTapSubmitButton(nickname: String, image: UIImage?) {
        guard let view else { return }
        let imageData = convertImageToJPGData(image: image)
        interactor?.saveProfile(imageData: imageData, withNickname: nickname)
        router?.presentMainScreen(from: view)
    }
    
    func didtextFieldEndEditing(text: String) {
        interactor?.isNicknameTaken(text)
    }
    
    func convertImageToJPGData(image: UIImage?) -> Data? {
        guard let image else { return nil }
        return image.jpegData(compressionQuality: 0.8)
    }
}

extension ProfileSetPresenter: DogInfoInteractorOutput {
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
