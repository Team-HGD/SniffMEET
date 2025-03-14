//
//  MateListRouter.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/21/24.
//

import UIKit

protocol MateListRoutable: Routable {
    var presenter: (any MateListPresentable)? { get }
    func presentWalkRequestView(mateListView: any MateListViewable, mate: Mate)
    func showAlert(mateListView: any MateListViewable, title: String, message: String)
    func showReportMateView(mateListView: any MateListViewable, data: Mate)
    func showProfileDropView(mateListView: any MateListViewable)
}

protocol MateListBuildable {
    static func createMateListModule() -> UIViewController
}

final class MateListRouter: MateListRoutable {
    weak var presenter: (any MateListPresentable)?
    func presentWalkRequestView(mateListView: MateListViewable, mate: Mate) {
        guard let mateListView = mateListView as? MateListViewController else { return }
        let requestWalkView = RequestWalkRouter.createRequestWalkModule(mate: mate)
        requestWalkView.modalPresentationStyle = .custom
        requestWalkView.transitioningDelegate = mateListView
        mateListView.present(requestWalkView, animated: true)
    }
    func showAlert(
        mateListView: any MateListViewable,
        title: String,
        message: String
    ) {
        guard let mateListView = mateListView as? UIViewController else { return }
        if let presentedVC = mateListView.presentedViewController as? UIAlertController {
            presentedVC.dismiss(animated: false)
        }

        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        mateListView.present(alertVC, animated: true, completion: nil)
    }
    func showReportMateView(mateListView: any MateListViewable, data: Mate) {
        guard let mateListView = mateListView as? UIViewController else { return }
        let reportMateViewController = ReportMateRouter.createReportMateModule(profile: data)
        pushNoBottomBar(from: mateListView, to: reportMateViewController, animated: true)
    }
    func showProfileDropView(mateListView: any MateListViewable) {
        guard let mateListView = mateListView as? UIViewController else { return }
        let profileDropViewController = ProfileDropRouter.createProfileDropModule()
        pushNoBottomBar(from: mateListView, to: profileDropViewController, animated: true)
    }
}

extension MateListRouter: MateListBuildable {
    static func createMateListModule() -> UIViewController {
        let networkProvider: SNMNetworkProvider = SNMNetworkProvider()
        let requestMateListUsecase: RequestMateListUsecase = RequestMateListUsecaseImpl(
            remoteDBManager: SupabaseDBManager.shared)
        let requestProfileImageUsecase: RequestProfileImageUsecase = RequestProfileImageUsecaseImpl(
            remoteImageManager: SupabaseStorageManager(
                networkProvider: networkProvider,
                sessionManager: SupabaseSessionManager.shared
            ),
            cacheManager: CacheManager.shared
        )
        let deleteMateUsecase: DeleteMateUsecase = DeleteMateUsecaseImpl(
            networkProvider: networkProvider,
            remoteDBManager: SupabaseDBManager.shared,
            sessionManager: SupabaseSessionManager.shared
        )

        let view: MateListViewable & UIViewController = MateListViewController()
        let presenter: MateListPresentable & MateListInteractorOutput = MateListPresenter()
        let interactor: MateListInteractable = MateListInteractor(
            requestMateListUsecase: requestMateListUsecase,
            requestProfileImageUsecase: requestProfileImageUsecase,
            deleteMateUsecase: deleteMateUsecase
        )

        let router: MateListRoutable & MateListBuildable = MateListRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter

        return view
    }
}
