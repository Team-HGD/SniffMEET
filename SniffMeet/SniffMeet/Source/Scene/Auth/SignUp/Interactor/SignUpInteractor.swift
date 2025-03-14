//
//  SignUpInteractor.swift
//  SniffMeet
//
//  Created by 배현진 on 2/26/25.
//

protocol SignUpInteractable: AnyObject {
    var presenter: SignUpInteractorOutput? { get set }
}

final class SignUpInteractor: SignUpInteractable {
    weak var presenter: (any SignUpInteractorOutput)?
}
