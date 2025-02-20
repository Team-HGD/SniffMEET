//
//  FetchWalkStepUseCase.swift
//  SniffMeet
//
//  Created by 배현진 on 2/18/25.
//
import CoreMotion

protocol UpdateUserStepUseCase {
    func startUpdateStepCount(update: @escaping (Int) -> Void)
    func stopUpdateStepCount()
}

final class UpdateUserStepUseCaseImpl: UpdateUserStepUseCase {
    private let pedometer = CMPedometer()
    private var pedometerIsUpdating: Bool = false

    func startUpdateStepCount(update: @escaping (Int) -> Void) {
        if pedometerIsUpdating {
            stopUpdateStepCount()
            pedometerIsUpdating = false
        }

        guard CMPedometer.isStepCountingAvailable() else { return }

        pedometerIsUpdating = true
        pedometer.startUpdates(from: Date()) { data, error in
            guard error == nil, let data = data else { return }
            update(data.numberOfSteps.intValue)
        }
    }

    func stopUpdateStepCount() {
        pedometer.stopUpdates()
    }
}
