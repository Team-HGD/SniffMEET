//
//  NotificationListPresenter.swift
//  SniffMeet
//
//  Created by sole on 12/1/24.
//

import Combine

protocol NotificationListPresentable: AnyObject {
    var view: (any NotificationListViewable)? { get set }
    var interactor: (any NotificationListInteractable)? { get set }
    var router: (any NotificationListRoutable)? { get set }

    var output: any NotificationListPresenterOutput { get }
    func viewDidLoad()
    func didTapNotificationCell(index: Int)
    func didDeleteNotificationCell(index: Int)
    func didTapTrashcanButton()
    func didTapDeleteConfirmButton()
    func didTapDismissButton()
    func didScrollToBottom()
}

final class NotificationListPresenter: NotificationListPresentable {
    weak var view: (any NotificationListViewable)?
    var interactor: (any NotificationListInteractable)?
    var router: (any NotificationListRoutable)?
    var output: any NotificationListPresenterOutput

    private var isFetching: Bool = false
    private var isReachedBottom: Bool = false
    private var currentPage: Int = 0
    private let pageSize: Int = 20
    private var fetchErrorHandler: SNMErrorHandler
    private var deleteErrorHandler: SNMErrorHandler

    init(
        view: (any NotificationListViewable)? = nil,
        interactor: (any NotificationListInteractable)? = nil,
        router: (any NotificationListRoutable)? = nil,
        output: any NotificationListPresenterOutput,
        fetchErrorHandler: SNMErrorHandler = SNMErrorHandler(),
        deleteErrorHandler: SNMErrorHandler = SNMErrorHandler()
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.output = output
        self.fetchErrorHandler = fetchErrorHandler
        self.deleteErrorHandler = deleteErrorHandler
        configureErrorHandlers()
    }

    func viewDidLoad() {
        fetchNotificationList()
    }
    func didTapNotificationCell(index: Int) {
        guard let view else { return }
        router?.showWalkNotification(view: view, walkNoti: output.notificationList.value[index])
    }
    func didDeleteNotificationCell(index: Int) {
        var notiList = output.notificationList.value
        let deleteNoti: WalkNoti = notiList[index]
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.interactor?.deleteNotifcation(
                    notificationID: deleteNoti.id
                )
            } catch let error as SNMError {
                fetchErrorHandler.handle(error)
            } catch {
                fetchErrorHandler.handle(
                    SNMError(level: .logOnly, error: error)
                )
            }
        }
        notiList.remove(at: index)
        output.notificationList.send(notiList)
    }
    func didTapTrashcanButton() {
        guard let view else { return }
        router?.presentDeleteAllAlert(from: view, animated: true)
    }
    func didTapDeleteConfirmButton() {
        let notifications = output.notificationList.value.map{ $0.id }
        Task { [weak self] in
            self?.view?.didStartDeleteNotifications()
            defer {
                self?.view?.didEndDeleteNotifications()
            }

            do {
                try await self?.interactor?.deleteNotifications(notifications: notifications)
            } catch let error as SNMError {
                self?.deleteErrorHandler.handle(error)
            } catch {
                self?.deleteErrorHandler.handle(
                    SNMError(level: .logOnly, error: error)
                )
            }
        }
        output.notificationList.send([])
    }
    func didTapDismissButton() {
        guard let view else { return }
        router?.dismiss(view: view)
    }
    func didScrollToBottom() {
        guard !isReachedBottom, !isFetching else { return }
        isFetching = true
        currentPage += 1
        fetchNotificationList()
    }
    private func fetchNotificationList() {
        Task { [weak self] in
            guard let self else { return }
            do {
                guard let notiList = try await self.interactor?.fetchNotificationList(
                    page: self.currentPage,
                    pageSize: self.pageSize
                ) else { return }
                self.didFetchNotificationList(with: notiList)
            } catch let error as SNMError {
                fetchErrorHandler.handle(error)
            } catch {
                fetchErrorHandler.handle(
                    SNMError(level: .logOnly, error: error)
                )
            }
        }
    }
    private func didFetchNotificationList(with notificationList: [WalkNoti]) {
        output.notificationList.send(output.notificationList.value + notificationList)
        isFetching = false
    }
    private func didReachEndOfNotificationList() {
        isReachedBottom = true
    }
    private func configureErrorHandlers() {
        fetchErrorHandler.configure { [weak self] level in
            switch level {
            case .notifyUser:
                self?.didReachEndOfNotificationList()
            default:
                break
            }
        }
    }
}

// MARK: - NotificationListPresenterOutput

protocol NotificationListPresenterOutput {
    var notificationList: CurrentValueSubject<[WalkNoti], Never> { get }
}

struct DefaultNotificationListPresenterOutput: NotificationListPresenterOutput {
    var notificationList: CurrentValueSubject<[WalkNoti], Never>
}
