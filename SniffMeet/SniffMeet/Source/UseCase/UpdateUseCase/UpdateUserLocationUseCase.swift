//
//  RequestUserLocationUseCase.swift
//  SniffMeet
//
//  Created by sole on 11/19/24.
//

import CoreLocation

protocol UpdateUserLocationUseCase {
    func startUpdateLocation(updateHandler: @escaping (CLLocation) -> Void)
    func stopUpdateLocation()
}

final class UpdateUserLocationUseCaseImpl: NSObject, UpdateUserLocationUseCase {
    private let locationManager: CLLocationManager
    private var updateHandler: ((CLLocation) -> Void)?

    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1.0
#if !DEBUG
        locationManager.distanceFilter = 10.0
#endif
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdateLocation(updateHandler: @escaping (CLLocation) -> Void) {
        self.updateHandler = updateHandler
        locationManager.startUpdatingLocation()
    }

    func stopUpdateLocation() {
        updateHandler = nil
        locationManager.stopUpdatingLocation()
    }
}

extension UpdateUserLocationUseCaseImpl: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, let handler = updateHandler else { return }
        handler(location)
    }
}
