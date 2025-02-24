//
//  Untitled.swift
//  SniffMeet
//
//  Created by 윤지성 on 2/18/25.
//
import CoreLocation
import UIKit

protocol TrackWalkRoutable: AnyObject, Routable {
    var presenter: (any TrackWalkPresentable)? { get set }
    
    func pop(from view: TrackWalkViewable)
}

final class TrackWalkRouter: TrackWalkRoutable {
    weak var presenter: (any TrackWalkPresentable)?
    
    func pop(from view: TrackWalkViewable) {
        Task { @MainActor in
            pop(from: view as! UIViewController, animated: true)
        }
    }
}

protocol TrackWalkModuleBuildable {
    static func create() -> UIViewController
}

extension TrackWalkRouter: TrackWalkModuleBuildable {
    static func create() -> UIViewController {
        let updateTimeUseCase: UpdateTimeUseCase = UpdateTimeUseCaseImpl()
        let updateUserStepUseCase: UpdateUserStepUseCase = UpdateUserStepUseCaseImpl()
        let updateUserLocationUseCase: UpdateUserLocationUseCase = UpdateUserLocationUseCaseImpl(
            locationManager: CLLocationManager())
        let view: TrackWalkViewable & UIViewController = TrackWalkViewController()
        let presenter: TrackWalkPresentable & TrackWalkInteractorOutput = TrackWalkViewPresenter()
        let interactor: TrackWalkInteractable = TrackWalkInteractor(
            updateTimeUseCase: updateTimeUseCase,
            updateUserStepUseCase: updateUserStepUseCase,
            updateUserLocationUseCase: updateUserLocationUseCase)
        let router: TrackWalkRoutable & TrackWalkModuleBuildable = TrackWalkRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return view
    }
}

