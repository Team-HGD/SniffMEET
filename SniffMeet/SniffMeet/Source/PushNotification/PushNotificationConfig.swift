//
//  PushNotificationConfig.swift
//  SniffMeet
//
//  Created by 윤지성 on 12/2/24.
//
import Foundation

enum PushNotificationConfig {
    static let baseURL: URL = {
        guard let serverURLString = Bundle.main.object(forInfoDictionaryKey: "NOTIFICATION_SERVER") as? String,
              let serverURL = URL(string: serverURLString.replacingOccurrences(of: "\\", with: "")) else {
            fatalError("invalid server url")
        }
        return serverURL
    }()
}
