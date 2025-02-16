//
//  SNMError.swift
//  SniffMeet
//
//  Created by Kelly Chui on 1/9/25.
//

import Foundation

struct SNMError: LocalizedError {
    enum ErrorLevel: String {
        case user = "유저"
        case developer = "개발자"
    }
    let level: ErrorLevel
    let error: any Error
    
    var errorDescription: String? {
        "\(level.rawValue) 레벨 에러 \(error.localizedDescription) 발생"
    }
}
