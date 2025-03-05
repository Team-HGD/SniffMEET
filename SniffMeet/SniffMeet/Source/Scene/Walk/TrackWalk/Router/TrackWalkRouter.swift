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
    func presentFailedToSaveTrackingAlert(from view: any TrackWalkViewable)
}

final class TrackWalkRouter: TrackWalkRoutable {
    weak var presenter: (any TrackWalkPresentable)?
    
    func pop(from view: any TrackWalkViewable) {
        guard let view = view as? UIViewController else { return }
        Task { @MainActor in
            pop(from: view, animated: true)
        }
    }
    func presentFailedToSaveTrackingAlert(from view: any TrackWalkViewable) {
        guard let view = view as? UIViewController else { return }
        let failedAlertViewController = UIAlertController(
            title: "산책 기록 저장 실패",
            message: "산책 기록을 저장하는데 실패했습니다. 다시 시도해주세요.",
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(title: "확인", style: .default)
        failedAlertViewController.addAction(confirmAction)
        Task { @MainActor [weak self] in
            self?.present(from: view, with: failedAlertViewController, animated: true)
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
            updateUserLocationUseCase: updateUserLocationUseCase,
            saveWalkLogUsecase: SaveWalkLogUseCaseImpl(fileManager: SNMFileManager(fileType: .data))
        )
        let router: TrackWalkRoutable & TrackWalkModuleBuildable = TrackWalkRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return view
    }
}

