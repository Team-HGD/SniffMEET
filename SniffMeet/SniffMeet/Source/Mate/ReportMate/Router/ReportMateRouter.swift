//
//  ReportMateRouter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/6/25.
//

import UIKit

protocol ReportMateRoutable: AnyObject, Routable {
    var presenter: (any ReportMatePresentable)? { get set }
    func dismissView(view: any ReportMateViewable)
    func showSelectReportView(reportMateView: any ReportMateViewable,
                              matePresenter: ReportMatePresenter)
}

protocol ReportMateBuildable {
    static func createReportMateModule(profile: Mate) -> UIViewController
}

final class ReportMateRouter: ReportMateRoutable {
    weak var presenter: (any ReportMatePresentable)?

    func dismissView(view: any ReportMateViewable) {
        if let view = view as? UIViewController {
            Task { @MainActor in
                pop(from: view, animated: true)
            }
        }
    }
    func showSelectReportView(reportMateView: any ReportMateViewable, matePresenter: ReportMatePresenter) {
        guard let reportMateView = reportMateView as? UIViewController else { return }
        guard let reportPickerViewController = ReportPickerRouter.createReportPickerModule() as? ReportPickerViewController else { return }
        reportPickerViewController.matePresenter = matePresenter
        reportPickerViewController.modalPresentationStyle = .formSheet

        if #available(iOS 16.0, *) {
            let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("customDetent")) { _ in
                return 150
            }
            if let sheet = reportPickerViewController.sheetPresentationController {
                sheet.detents = [customDetent]
            }
        } else {
            if let sheet = reportPickerViewController.sheetPresentationController {
                sheet.detents = [.medium()]
            }
        }

        present(from: reportMateView, with: reportPickerViewController, animated: true)
    }
}

extension ReportMateRouter: ReportMateBuildable {
    static func createReportMateModule(profile: Mate) -> UIViewController {
        let requestProfileImageUseCase:
        RequestProfileImageUseCase = RequestProfileImageUseCaseImpl(
            remoteImageManager: SupabaseStorageManager(
            networkProvider: SNMNetworkProvider()),
            cacheManager: CacheManager.shared
        )
        let requestReportUseCase: RequestReportUseCase = RequestReportUseCaseImpl(remoteDatabaseManager: SupabaseDatabaseManager.shared)
        let view: ReportMateViewable & UIViewController = ReportMateViewController()
        let router: ReportMateRoutable & ReportMateBuildable = ReportMateRouter()
        let presenter: ReportMatePresentable & ReportMateInteractorOutput = ReportMatePresenter()
        let interactor: ReportMateInteractable = ReportMateInteractor(
            mate: profile,
            requestProfileImageUseCase: requestProfileImageUseCase,
            requestReportUseCase: requestReportUseCase
        )

        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        router.presenter = presenter

        return view
    }
}
