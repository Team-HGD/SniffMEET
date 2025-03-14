//
//  RequestUserLocationUsecase.swift
//  SniffMeet
//
//  Created by sole on 11/19/24.
//
import Combine
import CoreLocation

protocol UpdateUserLocationUsecase {
    var locationPublisher: AnyPublisher<CLLocation, Never> { get }

    func execute()
    func cancel()
}

final class UpdateUserLocationUsecaseImpl: NSObject, UpdateUserLocationUsecase {
    private let locationManager: CLLocationManager
    private var locationSubject = PassthroughSubject<CLLocation, Never>()

    var locationPublisher: AnyPublisher<CLLocation, Never> {
        locationSubject.eraseToAnyPublisher()
    }

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

    func execute() {
        locationManager.startUpdatingLocation()
    }

    func cancel() {
        locationManager.stopUpdatingLocation()
    }
}

extension UpdateUserLocationUsecaseImpl: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationSubject.send(location)
    }
}
