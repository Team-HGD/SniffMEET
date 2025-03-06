//
//  FetchWalkStepUsecase.swift
//  SniffMeet
//
//  Created by 배현진 on 2/18/25.
//
import Combine
import CoreMotion

protocol UpdateUserStepUsecase {
    var stepCountPublisher: AnyPublisher<Int, Never> { get }

    func execute()
    func cancel()
}

final class UpdateUserStepUsecaseImpl: UpdateUserStepUsecase {
    private let pedometer = CMPedometer()
    private var pedometerIsUpdating: Bool = false
    private let stepCountSubject = PassthroughSubject<Int, Never>()

    var stepCountPublisher: AnyPublisher<Int, Never> {
        stepCountSubject.eraseToAnyPublisher()
    }

    func execute() {
        if pedometerIsUpdating {
            cancel()
            pedometerIsUpdating = false
        }

        guard CMPedometer.isStepCountingAvailable() else { return }

        pedometerIsUpdating = true
        pedometer.startUpdates(from: Date()) { [weak self] data, error in
        //TODO: - 에러 구체화 필요
            guard error == nil, let data = data else { return }
            self?.stepCountSubject.send(data.numberOfSteps.intValue)
        }
    }

    func cancel() {
        pedometer.stopUpdates()
    }
}
