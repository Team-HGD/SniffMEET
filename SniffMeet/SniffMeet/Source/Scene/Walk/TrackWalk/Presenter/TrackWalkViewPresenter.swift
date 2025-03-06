//
//  Untitled.swift
//  SniffMeet
//
//  Created by 윤지성 on 2/18/25.
//
import CoreLocation

protocol TrackWalkPresentable: AnyObject {
    var view: (any TrackWalkViewable)? { get set }
    var interactor: (any TrackWalkInteractable)? { get set }
    var router: (any TrackWalkRoutable)? { get set }

    func startTracking()
    func endTracking(snapshotImageData: Data?)
    func didTapDismissButton()
}
protocol TrackWalkInteractorOutput: AnyObject {
    func updateWalkRecord(_ record: WalkRecord)
    func updateLocation(with walkLocation: WalkRoute)
}

final class TrackWalkViewPresenter: TrackWalkPresentable {
    weak var view: (any TrackWalkViewable)?
    var interactor: (any TrackWalkInteractable)?
    var router: (any TrackWalkRoutable)?
    private var endTrackingErrorHandler: SNMErrorHandler

    init(
        view: (any TrackWalkViewable)? = nil,
        interactor: (any TrackWalkInteractable)? = nil,
        router: (any TrackWalkRoutable)? = nil,
        endTrackingErrorHandler: SNMErrorHandler = SNMErrorHandler()
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.endTrackingErrorHandler = endTrackingErrorHandler
        configureErrorHandlers()
    }

    func startTracking() {
        interactor?.startTracking()
    }
    func endTracking(snapshotImageData: Data?) {
        Task { @MainActor [weak self] in
            guard let walkLog = self?.interactor?.stopTracking(
                snapshotImageData: snapshotImageData
            ) else { return }

            do {
                try self?.interactor?.saveWalkLog(walkLog: walkLog)
                try await self?.view?.showRouteResult(with: snapshotImageData)
                guard let view = self?.view else { return }
                self?.router?.pop(from: view)
            } catch {
                self?.endTrackingErrorHandler.handle(error: error)
            }
        }
    }
    private func configureErrorHandlers() {
        endTrackingErrorHandler.configure { [weak self] level in
            switch level {
            case .notifyUser:
                guard let view = self?.view else { break }
                self?.router?.presentFailedToSaveTrackingAlert(from: view)
            default:
                break
            }
        }
    }
    func didTapDismissButton() {
        guard let view else { return }
        router?.pop(from: view)
    }
}

extension TrackWalkViewPresenter: TrackWalkInteractorOutput {
    func updateWalkRecord(_ record: WalkRecord) {
        view?.updateWalkRecord(record: record)
    }
    func updateLocation(with walkLocation: WalkRoute) {
        Task { @MainActor [weak self]  in
            self?.view?.updateRouteLine(with: walkLocation)
        }
    }
}
