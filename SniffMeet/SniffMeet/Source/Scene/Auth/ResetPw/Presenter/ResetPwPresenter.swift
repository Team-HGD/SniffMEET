//
//  ResetPwPresenter.swift
//  SniffMeet
//
//  Created by 배현진 on 3/2/25.
//

protocol ResetPwPresentable: AnyObject {
    var view: (any ResetPwViewable)? { get set }
    var interactor: (any ResetPwInteractable)? { get set }
    var router: (any ResetPwRoutable)? { get set }
}

protocol ResetPwInteractorOutput: AnyObject {
}

final class ResetPwPresenter: ResetPwPresentable {
    weak var view: (any ResetPwViewable)?
    var interactor: (any ResetPwInteractable)?
    var router: (any ResetPwRoutable)?
}

extension ResetPwPresenter: ResetPwInteractorOutput {
}
