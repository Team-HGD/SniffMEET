//
//  RequestNotificationAuthUsecase.swift
//  SniffMeet
//
//  Created by sole on 11/28/24.
//

import UserNotifications

protocol RequestNotificationAuthUsecase {
    func execute() async throws -> Bool
}

struct RequestNotificationAuthUsecaseImpl: RequestNotificationAuthUsecase {
    private let userNotificationCenter: UNUserNotificationCenter

    init(userNotificationCenter: UNUserNotificationCenter = .current()) {
        self.userNotificationCenter = userNotificationCenter
    }

    func execute() async throws -> Bool {
        try await userNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
    }
}
