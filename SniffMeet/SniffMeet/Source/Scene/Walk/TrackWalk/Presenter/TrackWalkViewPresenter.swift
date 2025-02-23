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
    func endTracking()
}
protocol TrackWalkInteractorOutput: AnyObject {
    func updateWalkRecord(_ record: WalkRecord)
}

final class TrackWalkViewPresenter: TrackWalkPresentable {
    weak var view: (any TrackWalkViewable)?
    var interactor: (any TrackWalkInteractable)?
    var router: (any TrackWalkRoutable)?
    
    func updateLocation(with walkLocation: WalkRoute) {
        Task { @MainActor [weak self]  in
            self?.view?.updateRouteLine(with: walkLocation)
        }
    }
    func startTracking() {
        interactor?.startTracking()
    }
    func endTracking() {
        // TODO: -  인터랙터에 저장 요청하는 로직
        
    }
}

extension TrackWalkViewPresenter: TrackWalkInteractorOutput {
    func updateWalkRecord(_ record: WalkRecord) {
        view?.updateWalkRecord(record: record)
    }
}
