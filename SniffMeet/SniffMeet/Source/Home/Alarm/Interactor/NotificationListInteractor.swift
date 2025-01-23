//
//  NotificationListInteractor.swift
//  SniffMeet
//
//  Created by sole on 12/1/24.
//

protocol NotificationListInteractable: AnyObject {
    var presenter: (any NotificationListPresentable)? { get set }
    func fetchNotificationList(page: Int, pageSize: Int) async throws -> [WalkNoti]
}

final class NotificationListInteractor: NotificationListInteractable {
    weak var presenter: (any NotificationListPresentable)?
    private let requestNotiListUseCase: (any RequestNotiListUseCase)

    init(
        presenter: (any NotificationListPresentable)? = nil,
        requestNotiListUseCase: any RequestNotiListUseCase
    ) {
        self.presenter = presenter
        self.requestNotiListUseCase = requestNotiListUseCase
    }

    func fetchNotificationList(page: Int, pageSize: Int) async throws -> [WalkNoti] {
        try await requestNotiListUseCase.execute(page: page, pageSize: pageSize)
    }
}
