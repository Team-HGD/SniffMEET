//
//  PersonalInfoInteractor.swift
//  SniffMeet
//
//  Created by 배현진 on 3/23/25.
//

protocol PersonalInfoInteractable: AnyObject {
    var presenter: PersonalInfoInteractorOutput? { get set }
}

final class PersonalInfoInteractor: PersonalInfoInteractable {
    weak var presenter: (any PersonalInfoInteractorOutput)?
}
