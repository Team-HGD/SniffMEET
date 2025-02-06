//
//  ReportPickerRouter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/6/25.
//
import UIKit

protocol ReportPickerRoutable: Routable {
    var presenter: (any ReportPickerPresentable)? { get set }
    func dismissPickerView(view: any ReportPickerViewable)
}

protocol ReportPickerBuildable {
    static func createReportPickerModule() -> UIViewController
}

final class ReportPickerRouter: ReportPickerRoutable {
    weak var presenter: (any ReportPickerPresentable)?

    func dismissPickerView(view: any ReportPickerViewable) {
        if let view = view as? UIViewController {
            Task{ @MainActor in
                view.dismiss(animated: true)
            }
        }
    }
}

extension ReportPickerRouter: ReportPickerBuildable {
    static func createReportPickerModule() -> UIViewController {
        let view: ReportPickerViewable & UIViewController = ReportPickerViewController()
        var router: ReportPickerRoutable & ReportPickerBuildable = ReportPickerRouter()
        let presenter: ReportPickerPresentable & ReportPickerInteractorOutput = ReportPickerPresenter()
        let interactor: ReportPickerInteractable = ReportPickerInteractor()

        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        router.presenter = presenter

        return view
    }
}
