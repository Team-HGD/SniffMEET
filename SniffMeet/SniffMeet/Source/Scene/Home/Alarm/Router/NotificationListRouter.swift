//
//  NotificationListRouter.swift
//  SniffMeet
//
//  Created by sole on 12/1/24.
//

import Combine
import UIKit

protocol NotificationListRoutable: AnyObject, Routable {
    var presenter: (any NotificationListPresentable)? { get set }
    func showWalkNotification(view: any NotificationListViewable, walkNoti: WalkNoti)
    func dismiss(view: any NotificationListViewable)
    func presentDeleteAllAlert(from view: any NotificationListViewable, animated: Bool)
}

final class NotificationListRouter: NSObject, NotificationListRoutable {
    weak var presenter: (any NotificationListPresentable)?

    func showWalkNotification(view: any NotificationListViewable, walkNoti: WalkNoti) {
        guard let view = view as? UIViewController else { return }
        let targetView = routeWalkNotification(walkNoti: walkNoti)
        targetView.modalPresentationStyle = .custom
        targetView.transitioningDelegate = self
        present(
            from: UIViewController.topMostViewController ?? view,
            with: targetView,
            animated: true
        )
    }
    func dismiss(view: any NotificationListViewable) {
        guard let view = view as? UIViewController else { return }
        pop(from: view, animated: true)
    }
    func presentDeleteAllAlert(from view: any NotificationListViewable, animated: Bool) {
        guard let view = view as? UIViewController else { return }
        let deleteAllAlertViewController = UIAlertController(
            title: "알림 삭제",
            message: "알림이 전체 삭제됩니다. 계속 진행할까요?",
            preferredStyle: .alert
        )
        let confirmAction: UIAlertAction = UIAlertAction(
            title: "확인",
            style: .destructive
        ) { [weak self] _ in
            self?.presenter?.didTapDeleteConfirmButton()
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "취소", style: .cancel)
        [confirmAction, cancelAction].forEach {
            deleteAllAlertViewController.addAction($0)
        }
        present(from: view, with: deleteAllAlertViewController, animated: animated)
    }
    private func routeWalkNotification(walkNoti: WalkNoti) -> UIViewController {
        switch walkNoti.category {
        case .walkRequest:
            RespondWalkRouter.createRespondtWalkModule(walkNoti: walkNoti)
        case .walkAccepted, .walkDeclined:
            ProcessedWalkRouter.createProcessedWalkView(noti: walkNoti)
        }
    }
}

// MARK: - NotificationListRouter+UIViewControllerTransitioningDelegate

extension NotificationListRouter: UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        CardPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

// MARK: - NotificationListModuleBuildable

extension NotificationListRouter: NotificationListModuleBuildable {}

protocol NotificationListModuleBuildable {
    static func createNotificationListModule() -> UIViewController
}

extension NotificationListModuleBuildable {
    static func createNotificationListModule() -> UIViewController {
        let view = NotificationListViewController()
        let presenter = NotificationListPresenter(
            output: DefaultNotificationListPresenterOutput(
                notificationList: CurrentValueSubject([])
            )
        )
        let interactor = NotificationListInteractor(
            requestNotiListUseCase: RequestNotiListUseCaseImpl(
                remoteManager: SupabaseDBManager.shared,
                sessionManager: SupabaseSessionManager.shared
            ),
            deleteNotificationUseCase: DeleteNotificationUseCaseImpl(
                remoteDataManager: SupabaseDBManager.shared
            )
        )
        let router = NotificationListRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.presenter = presenter

        return view
    }
}
