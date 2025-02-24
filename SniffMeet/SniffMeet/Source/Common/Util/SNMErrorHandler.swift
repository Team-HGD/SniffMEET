//
//  SNMErrorHandler.swift
//  SniffMeet
//
//  Created by sole on 2/20/25.
//

import UIKit

protocol ErrorHandler {
    func handle(_ error: any Error)
}

struct SNMErrorHandler: ErrorHandler {
    private var sessionErrorHandler: any ErrorHandler
    private var customErrorHandler: any ErrorHandler

    init(
        sessionErrorHandler: any ErrorHandler = SupabaseSessionErrorHandler(),
        customErrorHandler: any ErrorHandler = CustomErrorHandler()
    ) {
        self.sessionErrorHandler = sessionErrorHandler
        self.customErrorHandler = customErrorHandler
    }
    /// 로그 출력이 default입니다.
    func handle(_ error: any Error) {
        guard let error = error as? SNMError else {
            SNMLogger.error("Not SNMError:", error.localizedDescription)
            return
        }
        switch error.level {
        case .notExistSession:
            sessionErrorHandler.handle(error.error)
        case .fatal, .notifyUser, .retryable, .logOnly:
            customErrorHandler.handle(error)
        }

#if !DEBUG
            SNMLogger.firebaseLog(
                file: error.context.file,
                function: error.context.function,
                error.errorDescription ?? error.localizedDescription
            )
#endif
        SNMLogger.error(
            file: error.context.file,
            function: error.context.function,
            error.errorDescription ?? error.localizedDescription
        )
    }
    mutating func configure(handler: @escaping (SNMError.Level) -> Void) {
        var newCustomErrorHandler = CustomErrorHandler()
        let wrappedHandler: (any Error) -> Void = { error in
            guard let error = error as? SNMError else { return }
            handler(error.level)
        }
        newCustomErrorHandler.configure(handler: wrappedHandler)
        customErrorHandler = newCustomErrorHandler
    }
}

// MARK: - Concret Error Handler

struct CustomErrorHandler: ErrorHandler {
    private var customHandler: ((any Error) -> Void)?

    func handle(_ error: any Error) {
        customHandler?(error)
    }
    mutating func configure(handler: @escaping (any Error) -> Void) {
        self.customHandler = handler
    }
}

struct SupabaseSessionErrorHandler: ErrorHandler {
    func handle(_ error: any Error) {
        guard let error = error as? SupabaseSessionError else {
            SNMLogger.error(error.localizedDescription)
            return
        }
        switch error {
        case .sessionNotExist:
            NotificationCenter.default.post(
                name: Environment.NotificationCenterName.sessionExpired,
                object: self
            )
        case .loadSessionFailed, .refreshSessionFailed, .saveSessionFailed:
            break
        }
    }
}
