//
//  Extension + Date.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/26/24.
//
import Foundation

extension Date {
    func secondsDifferenceFromNow() -> Int {
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.second], from: self, to: currentDate)
        
        return components.second ?? 0
    }
    func minutesDifferenceFromNow() -> Int {
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: self, to: currentDate)

        return components.minute ?? 0
    }
    func hoursDifferenceFromNow() -> Int {
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: self, to: currentDate)
        
        return components.hour ?? 0
    }
    func daysDifferenceFromNow() -> Int {
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: currentDate)
        
        return components.day ?? 0
    }
    /// 현재 시간과의 차이를 문자열로 출력합니다.
    /// 가장 큰 단위의 시간으로 출력합니다. (1일 1시간 전이면 1일 전으로 출력)
    func differenceFromNow() -> String {
        let dayDifference = daysDifferenceFromNow()
        let hourDifference = hoursDifferenceFromNow()
        let minuteDifference = minutesDifferenceFromNow()
        let secondDifference = secondsDifferenceFromNow()

        if dayDifference > 0 {
            return "\(dayDifference)일 전"
        } else if hourDifference > 0 {
            return "\(hourDifference)시간 전"
        } else if minuteDifference > 0 {
            return "\(minuteDifference)분 전"
        } else {
            return "\(secondDifference)초 전"
        }
    }
    func convertDateToISO8601String() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // UTC 설정
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 권장 로케일 설정
        return dateFormatter.string(from: self)
    }
}
