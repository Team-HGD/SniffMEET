//
//  DeviceInfoFinder.swift
//  SniffMeet
//
//  Created by 배현진 on 2/12/25.
//
import NearbyInteraction

protocol NIDeviceCheckerProtocol {
    func isNISupported() -> Bool
}

final class NIDeviceChecker: NIDeviceCheckerProtocol {
    func isNISupported() -> Bool {
        if #available(iOS 16.0, *) {
            return NISession.deviceCapabilities.supportsPreciseDistanceMeasurement
        } else {
            return NISession.isSupported
        }
    }
}
