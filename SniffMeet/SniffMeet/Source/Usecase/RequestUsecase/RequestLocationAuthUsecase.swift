//
//  RequestLocationAuthUsecase.swift
//  SniffMeet
//
//  Created by sole on 11/19/24.
//

import CoreLocation

protocol RequestLocationAuthUsecase {
    func execute()
}

struct RequestLocationAuthUsecaseImpl: RequestLocationAuthUsecase {
    private let locationManager: CLLocationManager

    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }
    
    func execute() {
        locationManager.requestWhenInUseAuthorization()
    }
}
