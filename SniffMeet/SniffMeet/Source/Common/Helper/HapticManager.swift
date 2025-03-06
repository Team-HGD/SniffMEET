//
//  HapticManager.swift
//  SniffMeet
//
//  Created by 배현진 on 3/5/25.
//

import UIKit
import CoreHaptics

public class HapticManager {
    public static let instance = HapticManager()

    private var engine: CHHapticEngine?
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        notificationGenerator.prepare()
        resetEngine()
    }

    public func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
    }

    public func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    func playHaptic(type: HapticType) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let pattern = try CHHapticPattern(events: type.hapticEvents, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("\(error.localizedDescription).")
        }
    }
}

public enum HapticType {
    case shortsHaptic
    case longHaptic

    var hapticEvents: [CHHapticEvent] {
        switch self {
        case .shortsHaptic:
            [
                CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0.3, duration: 0.2),
                CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0.6, duration: 0.6)
            ]
        case .longHaptic:
            [CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0.1, duration: 3)]
        }
    }
}

private extension HapticManager {
    func resetEngine() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            setStopHandler()
            setResetHandler()
        } catch {
            SNMLogger.error("reset 실패")
        }

    }

    func setStopHandler() {
        engine?.stoppedHandler = { reason in
            SNMLogger.error("엔진이 멈춤 \(reason)")
        }
    }

    func setResetHandler() {
        engine?.resetHandler = { [weak self] in
            do {
                try self?.engine?.start()
            } catch {
                SNMLogger.error("restart 실패 \(error)")
            }
        }
    }
}
