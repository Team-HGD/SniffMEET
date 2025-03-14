//
//  SignInInteractor.swift
//  SniffMeet
//
//  Created by 배현진 on 2/26/25.
//

protocol SigninInteractable: AnyObject {
    var presenter: SigninInteractorOutput? { get set }
}

final class SigninInteractor: SigninInteractable {
    weak var presenter: (any SigninInteractorOutput)?
}
