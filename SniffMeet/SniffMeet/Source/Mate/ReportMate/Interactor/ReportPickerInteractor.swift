//
//  ReportPickerInteractor.swift
//  SniffMeet
//
//  Created by 배현진 on 2/6/25.
//

protocol ReportPickerInteractable: AnyObject {
    var presenter: (any ReportPickerInteractorOutput)? { get set }
}

final class ReportPickerInteractor: ReportPickerInteractable {
    weak var presenter: (any ReportPickerInteractorOutput)?
}
