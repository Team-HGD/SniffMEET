//
//  SNMError.swift
//  SniffMeet
//
//  Created by Kelly Chui on 1/9/25.
//

import Foundation

struct SNMError: LocalizedError {
    let level: Level
    let error: any Error
    let context: Context

    init(
        level: Level,
        error: any Error,
        file: String = #file,
        function: String = #function
    ) {
        self.level = level
        self.error = error
        self.context = Context(file: file, function: function)
    }

    var errorDescription: String? {
        "\(level.rawValue) - \(error.localizedDescription)"
    }

    enum Level: String {
        /// 치명적인 오류
        case fatal
        /// 세션이 존재하지 않음
        case notExistSession
        /// 유저에게 알림
        case notifyUser
        /// 다시 시도할 수 있음
        case retryable
        /// 로그만 남김
        case logOnly
    }

    struct Context {
        let file: String
        let function: String
    }
}
