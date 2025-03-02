//
//  ResetPwInteractor.swift
//  SniffMeet
//
//  Created by 배현진 on 3/2/25.
//

protocol ResetPwInteractable: AnyObject {
    var presenter: ResetPwInteractorOutput? { get set }
}

final class ResetPwInteractor: ResetPwInteractable {
    weak var presenter: (any ResetPwInteractorOutput)?
}
