//
//  ReportMateRouter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/6/25.
//

import UIKit

protocol ReportMateRoutable: Routable {
    var presenter: (any ReportMatePresentable)? { get set }
}

protocol ReportMateBuildable {
    static func createReportMateModule(profile: Mate) -> UIViewController
}

final class ReportMateRouter: ReportMateRoutable {
    weak var presenter: (any ReportMatePresentable)?
}

extension ReportMateRouter: ReportMateBuildable {
    static func createReportMateModule(profile: Mate) -> UIViewController {
        let requestProfileImageUseCase:
        RequestProfileImageUseCase = RequestProfileImageUseCaseImpl(
            remoteImageManager: SupabaseStorageManager(
            networkProvider: SNMNetworkProvider()),
            cacheManager: CacheManager.shared
        )
        let view: ReportMateViewable & UIViewController = ReportMateViewController()
        var router: ReportMateRoutable & ReportMateBuildable = ReportMateRouter()
        let presenter: ReportMatePresentable & ReportMateInteractorOutput = ReportMatePresenter()
        let interactor: ReportMateInteractable = ReportMateInteractor(
            mate: profile,
            requestProfileImageUseCase: requestProfileImageUseCase
        )
        SNMLogger.log("profile: \(profile)")
        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        router.presenter = presenter

        return view
    }
}
