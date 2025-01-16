//
//  SNMLogger.swift
//  SniffMeet
//
//  Created by sole on 11/20/24.
//

import OSLog

enum SNMLogger {
    private static let logger: Logger = Logger(subsystem: "SniffMeet", category: "SNMLogger")
    private static let poster: OSSignposter = OSSignposter(logger: logger)

    /// debug 레벨에서 사용합니다.
    static func print(_ message: String...) {
        logger.debug("⚙️ \(message.joined(separator: " "))")
    }
    static func error(file: String = #file, function: String = #function , _ message: String...) {
        logger.error("🚨 \(file) \(function) \(message.joined(separator: " "))")
    }
    static func info(_ message: String...) {
        logger.info("📄 \(message.joined(separator: " "))")
    }
    static func log(level: OSLogType = .default, _ message: String...) {
        logger.log(level: level, "\(message.joined(separator: " "))")
    }
}

// MARK: - SNMLogger+OSSignPoster

extension SNMLogger {
    /// 주의: 프로세스 bound를 넘어 사용하지 마세요
    static func begin(name: StaticString) -> OSSignpostIntervalState {
        let id = poster.makeSignpostID()
        return poster.beginInterval(name, id: id)
    }
    /// 주의: 프로세스 bound를 넘어 사용하지 마세요
    static func end(name: StaticString, state: OSSignpostIntervalState) {
        poster.endInterval(name, state)
    }
    static func emitEvent(name: StaticString) {
        let id = poster.makeSignpostID()
        poster.emitEvent(name, id: id)
    }
}
