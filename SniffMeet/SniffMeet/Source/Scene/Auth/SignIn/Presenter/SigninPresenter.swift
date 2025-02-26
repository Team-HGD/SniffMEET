//
//  SigninPresenter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/26/25.
//

protocol SigninPresentable: AnyObject {
    var view: (any SigninViewable)? { get set }
    var interactor: (any SigninInteractable)? { get set }
    var router: (any SigninRoutable)? { get set }
}

protocol SigninInteractorOutput: AnyObject {

}

final class SigninPresenter: SigninPresentable {
    weak var view: (any SigninViewable)?
    var interactor: (any SigninInteractable)?
    var router: (any SigninRoutable)?

    func someMethod() {

    }
}

extension SigninPresenter: SigninInteractorOutput {

}
