//
//  ReportPickerPresenter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/6/25.
//
import Combine

protocol ReportPickerPresentable: AnyObject {
    var view: ReportPickerViewable? { get set }
    var router: (any ReportPickerRoutable)? { get set }
    var interactor: (any ReportPickerInteractable)? { get set }
    var output: any ReportPickerPresenterOutput { get set }
    func didSelectOption(_ option: String)
}

protocol ReportPickerInteractorOutput: AnyObject {
    func didSelectReportData(option: String)
}

protocol ReportPickerPresenterOutput {
    var selectedReportOption: PassthroughSubject<String, Never> { get }
}

struct DefaultReportPickerPresenterOutput: ReportPickerPresenterOutput {
    let selectedReportOption: PassthroughSubject<String, Never>
}

final class ReportPickerPresenter: ReportPickerPresentable {
    weak var view: ReportPickerViewable?
    var router: (any ReportPickerRoutable)?
    var interactor: (any ReportPickerInteractable)?
    var output: any ReportPickerPresenterOutput

    init(
        view: ReportPickerViewable? = nil,
        router: (any ReportPickerRoutable)? = nil,
        interactor: (any ReportPickerInteractable)? = nil,
        output: any ReportPickerPresenterOutput = DefaultReportPickerPresenterOutput(
            selectedReportOption: PassthroughSubject<String, Never>()
        )
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.output = output
    }

    func didSelectOption(_ option: String) {
        didSelectReportData(option: option)
    }
}

extension ReportPickerPresenter: ReportPickerInteractorOutput {
    func didSelectReportData(option: String) {
        output.selectedReportOption.send(option)
        if let view {
            router?.dismissPickerView(view: view)
        }
    }
}
