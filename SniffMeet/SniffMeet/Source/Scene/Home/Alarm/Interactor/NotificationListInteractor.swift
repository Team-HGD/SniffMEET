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
    private let requestNotiListUseCase: any RequestNotiListUseCase
    private let deleteNotificationUseCase: any DeleteNotificationUseCase

    init(
        presenter: (any NotificationListPresentable)? = nil,
        requestNotiListUseCase: any RequestNotiListUseCase,
        deleteNotificationUseCase: any DeleteNotificationUseCase
    ) {
        self.presenter = presenter
        self.requestNotiListUseCase = requestNotiListUseCase
        self.deleteNotificationUseCase = deleteNotificationUseCase
    }

    func fetchNotificationList(page: Int, pageSize: Int) async throws -> [WalkNoti] {
        try await requestNotiListUseCase.execute(page: page, pageSize: pageSize)
    }
    func deleteNotifcation(notificationID: UUID) async throws {
        try await deleteNotificationUseCase.execute(notificationID: notificationID.uuidString)
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
