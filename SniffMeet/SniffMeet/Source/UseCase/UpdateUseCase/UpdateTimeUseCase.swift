//
//  WalkTrackingUseCase.swift
//  SniffMeet
//
//  Created by 배현진 on 2/18/25.
//
import Foundation

protocol UpdateTimeUseCase {
    func startTimer(update: @escaping (TimeInterval) -> Void)
    func stopTimer()
}

final class UpdateTimeUseCaseImpl: UpdateTimeUseCase {
    private var timer: Timer?
    private var startTime: Date?

    func startTimer(update: @escaping (TimeInterval) -> Void) {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let startTime = self?.startTime else { return }
            let elapsedTime = Date().timeIntervalSince(startTime)
            update(elapsedTime)
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stopTimer()
    }
}
