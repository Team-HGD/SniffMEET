//
//  ResetPwEmailPresenter.swift
//  SniffMeet
//
//  Created by 배현진 on 3/2/25.
//

protocol ResetPwEmailPresentable: AnyObject {
    var view: (any ResetPwEmailViewable)? { get set }
    var interactor: (any ResetPwEmailInteractable)? { get set }
    var router: (any ResetPwEmailRoutable)? { get set }
}

protocol ResetPwEmailInteractorOutput: AnyObject {
}

final class ResetPwEmailPresenter: ResetPwEmailPresentable {
    weak var view: (any ResetPwEmailViewable)?
    var interactor: (any ResetPwEmailInteractable)?
    var router: (any ResetPwEmailRoutable)?
}

extension ResetPwEmailPresenter: ResetPwEmailInteractorOutput {
}
