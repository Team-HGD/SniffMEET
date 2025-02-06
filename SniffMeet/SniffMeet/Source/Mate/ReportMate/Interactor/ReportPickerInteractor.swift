//
//  ReportPickerInteractor.swift
//  SniffMeet
//
//  Created by 배현진 on 2/6/25.
//

protocol ReportPickerInteractable: AnyObject {
    var presenter: (any ReportPickerInteractorOutput)? { get set }
    func selectReportOption(_ option: String)
}

final class ReportPickerInteractor: ReportPickerInteractable {
    weak var presenter: (any ReportPickerInteractorOutput)?

    func selectReportOption(_ option: String) {
        presenter?.didSelectReportData(option: option)
    }
}
