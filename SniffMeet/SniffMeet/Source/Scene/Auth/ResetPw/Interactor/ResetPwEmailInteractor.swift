//
//  ResetPwEmailInteractor.swift
//  SniffMeet
//
//  Created by 배현진 on 3/2/25.
//

protocol ResetPwEmailInteractable: AnyObject {
    var presenter: ResetPwEmailInteractorOutput? { get set }
}

final class ResetPwEmailInteractor: ResetPwEmailInteractable {
    weak var presenter: (any ResetPwEmailInteractorOutput)?
}
