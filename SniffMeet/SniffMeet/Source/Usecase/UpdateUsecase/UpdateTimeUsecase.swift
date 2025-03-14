//
//  WalkTrackingUsecase.swift
//  SniffMeet
//
//  Created by 배현진 on 2/18/25.
//
import Combine
import Foundation

protocol UpdateTimeUsecase {
    var elapsedTimePublisher: AnyPublisher<TimeInterval, Never> { get }

    func execute()
    func cancel()
}

final class UpdateTimeUsecaseImpl: UpdateTimeUsecase {
    private var timer: Timer?
    private var startTime: Date?
    private var elapsedTimeSubject = PassthroughSubject<TimeInterval, Never>()

    var elapsedTimePublisher: AnyPublisher<TimeInterval, Never> {
        elapsedTimeSubject.eraseToAnyPublisher()
    }

    func execute() {
        startTime = Date()
        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            guard let startTime = self?.startTime else { return }
            let elapsedTime = Date().timeIntervalSince(startTime)
            self?.elapsedTimeSubject.send(elapsedTime)
        }
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        cancel()
    }
}
