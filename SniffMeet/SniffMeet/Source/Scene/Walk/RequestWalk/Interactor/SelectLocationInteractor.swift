//
//  SelectLocationInteractor.swift
//  SniffMeet
//
//  Created by sole on 11/19/24.
//

protocol SelectLocationInteractable: AnyObject {
    var presenter: SelectLocationInteractorOutput? { get set }

    func requestUserLocationAuth()
    func convertLocationToText(latitude: Double, longtitude: Double)
}

final class SelectLocationInteractor: SelectLocationInteractable {
    weak var presenter: (any SelectLocationInteractorOutput)?
    private let convertLocationToTextUsecase: any ConvertLocationToTextUsecase
    private let requestLocationAuthUsecase: any RequestLocationAuthUsecase

    init(
        presenter: (any SelectLocationInteractorOutput)? = nil,
        convertLocationToTextUsecase: any ConvertLocationToTextUsecase,
        requestLocationAuthUsecase: any RequestLocationAuthUsecase
    ) {
        self.presenter = presenter
        self.convertLocationToTextUsecase = convertLocationToTextUsecase
        self.requestLocationAuthUsecase = requestLocationAuthUsecase
    }

    func requestUserLocationAuth() {
        requestLocationAuthUsecase.execute()
    }
    func convertLocationToText(latitude: Double, longtitude: Double) {
        Task {
            let locationText: String? = await convertLocationToTextUsecase.execute(
                latitude: latitude, longtitude: longtitude
            )
            presenter?.didConvertLocationToText(with: locationText)
        }
    }
}
