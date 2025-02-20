//
//  WalkLog.swift
//  SniffMeet
//
//  Created by sole on 11/24/24.
//

import Foundation

struct WalkLog {
    let step: Int
    let distance: Double
    let startDate: Date
    let endDate: Date
    let image: Data?

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
}

struct WalkRecord {
    let stepCount: Int
    let distance: Double
    let formattedTime: String

    init(stepCount: Int, totalDistance: Double, time: TimeInterval) {
        self.stepCount = stepCount
        self.distance = round(totalDistance * 100) / 100
        self.formattedTime = WalkRecord.formatTime(time)
    }

    private static func formatTime(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        return formatter.string(from: timeInterval) ?? "00:00:00"
    }
}
