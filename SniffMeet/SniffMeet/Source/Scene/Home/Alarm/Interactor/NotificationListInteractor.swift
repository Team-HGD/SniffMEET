//
//  NotificationListInteractor.swift
//  SniffMeet
//
//  Created by sole on 12/1/24.
//

import Foundation

protocol NotificationListInteractable: AnyObject {
    var presenter: (any NotificationListPresentable)? { get set }
    func fetchNotificationList(page: Int, pageSize: Int) async throws -> [WalkNoti]
    func deleteNotifcation(notificationID: UUID) async throws
    func deleteNotifications(notifications: [UUID]) async throws
}

final class NotificationListInteractor: NotificationListInteractable {
    weak var presenter: (any NotificationListPresentable)?
    private let requestNotiListUsecase: any RequestNotiListUsecase
    private let deleteNotificationUsecase: any DeleteNotificationUsecase

    init(
        presenter: (any NotificationListPresentable)? = nil,
        requestNotiListUsecase: any RequestNotiListUsecase,
        deleteNotificationUsecase: any DeleteNotificationUsecase
    ) {
        self.presenter = presenter
        self.requestNotiListUsecase = requestNotiListUsecase
        self.deleteNotificationUsecase = deleteNotificationUsecase
    }

    func fetchNotificationList(page: Int, pageSize: Int) async throws -> [WalkNoti] {
        try await requestNotiListUsecase.execute(page: page, pageSize: pageSize)
    }
    func deleteNotifcation(notificationID: UUID) async throws {
        try await deleteNotificationUsecase.execute(notificationID: notificationID.uuidString)
    }
    func deleteNotifications(notifications: [UUID]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { [weak self] group in
            for notiID in notifications {
                group.addTask {
                    try await self?.deleteNotifcation(notificationID: notiID)
                }
            }
            try await group.waitForAll()
        }
    }
}
