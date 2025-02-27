//
//  SignUpPresenter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/26/25.
//

protocol SignUpPresentable: AnyObject {
    var view: (any SignUpViewable)? { get set }
    var interactor: (any SignUpInteractable)? { get set }
    var router: (any SignUpRoutable)? { get set }
}

protocol SignUpInteractorOutput: AnyObject {
}

final class SignUpPresenter: SignUpPresentable {
    weak var view: (any SignUpViewable)?
    var interactor: (any SignUpInteractable)?
    var router: (any SignUpRoutable)?
}

extension SignUpPresenter: SignUpInteractorOutput {
}
