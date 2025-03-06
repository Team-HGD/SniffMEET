//
//  CalculateTimeLimitUsecase.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/26/24.
//
import Foundation

protocol CalculateTimeLimitUsecase {
    func execute(requestTime: Date) -> Int
}

struct CalculateTimeLimitUsecaseImpl: CalculateTimeLimitUsecase {
    func execute(requestTime: Date) -> Int {
        let secondsDifference = requestTime.secondsDifferenceFromNow()
        let minuteSeconds = 60
        
        return minuteSeconds - secondsDifference > 0 ? minuteSeconds - secondsDifference : 0
    }
}
