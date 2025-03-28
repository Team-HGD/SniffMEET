//
//  Untitled.swift
//  SniffMeet
//
//  Created by 윤지성 on 2/18/25.
//
import Combine
import CoreLocation
import Foundation

protocol TrackWalkInteractable: AnyObject {
    var presenter: TrackWalkInteractorOutput? { get set }

    func startTracking()
    func stopTracking(snapshotImageData: Data?) -> WalkLog?
    func saveWalkLog(walkLog: WalkLog) throws
}

final class TrackWalkInteractor: TrackWalkInteractable {
    weak var presenter: (any TrackWalkInteractorOutput)?
    private let updateTimeUsecase: any UpdateTimeUsecase
    private let updateUserStepUsecase: any UpdateUserStepUsecase
    private let updateUserLocationUsecase: any UpdateUserLocationUsecase
    private let saveWalkLogUsecase: any SaveWalkLogUsecase

    private var startDate: Date?
    private var endDate: Date?
    private var time: TimeInterval = 0.0
    private var stepCount: Int = 0
    private var totalDistance: Double = 0.0
    private var locations: [CLLocation] = []
    private var walkRoute = WalkRoute(points: [])
    private var cancellables = Set<AnyCancellable>()

    init(
        updateTimeUsecase: any UpdateTimeUsecase,
        updateUserStepUsecase: any UpdateUserStepUsecase,
        updateUserLocationUsecase: any UpdateUserLocationUsecase,
        saveWalkLogUsecase: any SaveWalkLogUsecase
    ){
        self.updateTimeUsecase = updateTimeUsecase
        self.updateUserStepUsecase = updateUserStepUsecase
        self.updateUserLocationUsecase = updateUserLocationUsecase
        self.saveWalkLogUsecase = saveWalkLogUsecase
    }

    func startTracking() {
        startDate = Date()

        updateTimeUsecase.execute()
        updateUserStepUsecase.execute()
        updateUserLocationUsecase.execute()

        binding()
    }

    private func binding() {
        updateTimeUsecase.elapsedTimePublisher
            .sink { [weak self] elapsedTime in
                guard let self = self else { return }
                self.time = elapsedTime
                self.updateWalkRecord()
                SNMLogger.log("경과 시간: \(self.time) seconds")
            }
            .store(in: &cancellables)
        updateUserStepUsecase.stepCountPublisher
            .sink { [weak self] step in
                guard let self = self else { return }
                self.stepCount = step
                SNMLogger.log("걸음 수: \(self.stepCount) steps")
            }
            .store(in: &cancellables)
        updateUserLocationUsecase.locationPublisher
            .sink { [weak self] location in
                guard let self = self else { return }
                self.calculateDistance(location)
            }
            .store(in: &cancellables)
    }

    private func updateWalkRecord() {
        let record = WalkRecord(
            stepCount: stepCount,
            totalDistance: totalDistance,
            time: time
        )
        presenter?.updateWalkRecord(record)
    }

    private func calculateDistance(_ location: CLLocation) {
        locations.append(location)

        if locations.count > 1 {
            let lastLocation = self.locations[locations.count - 2]
            let coordinate = location.coordinate
            let distance = location.distance(from: lastLocation)
            totalDistance += distance
            walkRoute.append(coordinate)
            presenter?.updateLocation(with: walkRoute)
        }
        SNMLogger.log("이동 거리: \(totalDistance) meters")
    }

    func stopTracking(snapshotImageData: Data?) -> WalkLog? {
        endDate = Date()
        updateTimeUsecase.cancel()
        updateUserStepUsecase.cancel()
        updateUserLocationUsecase.cancel()

        guard let startDate = startDate, let endDate = endDate else { return nil }

        return WalkLog(
            step: stepCount,
            distance: totalDistance,
            startDate: startDate,
            endDate: endDate,
            imageData: snapshotImageData
        )
    }

    func saveWalkLog(walkLog: WalkLog) throws {
        try saveWalkLogUsecase.execute(walkLog: walkLog)
    }
}
