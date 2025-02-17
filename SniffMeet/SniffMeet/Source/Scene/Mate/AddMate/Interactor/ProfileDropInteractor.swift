//
//  ProfileDropInteractor.swift
//  SniffMeet
//
//  Created by 배현진 on 2/11/25.
//
import Combine
import Foundation

protocol ProfileDropInteractable: AnyObject {
    var presenter: (any ProfileDropInteractorOutput)? { get set }

    func tryProfileDrop()
    func quitProfileDrop()
    func checkNISupport()
}

final class ProfileDropInteractor: ProfileDropInteractable {
    weak var presenter: (any ProfileDropInteractorOutput)?
    private var tryProfileDropUseCase: any NearByProfileDropUseCase
    private var quitProfileDropUseCase: any QuitProfileDropUseCase
    private var cancellables: Set<AnyCancellable> = []
    private let niDeviceChecker: NIDeviceCheckerProtocol

    init(
        presenter: ProfileDropInteractorOutput? = nil,
        tryProfileDropUseCase: any NearByProfileDropUseCase,
        quitProfileDropUseCase: any QuitProfileDropUseCase,
        niDeviceChecker: NIDeviceCheckerProtocol
    ) {
        self.presenter = presenter
        self.tryProfileDropUseCase = tryProfileDropUseCase
        self.quitProfileDropUseCase = quitProfileDropUseCase
        self.niDeviceChecker = niDeviceChecker

        bind()
    }

    func tryProfileDrop() {
        if tryProfileDropUseCase.isTransitioned {
            guard let mpcManager = MPCManager(dataManager: LocalDataManager())
            else { return }
            let niManager = NIManager()
            tryProfileDropUseCase.reset(mpcManager: mpcManager, nimanager: niManager)
            quitProfileDropUseCase.reset(niManager: niManager)
        }
        tryProfileDropUseCase.execute()
    }

    func quitProfileDrop() {
        quitProfileDropUseCase.execute()
    }

    func bind() {
        tryProfileDropUseCase.isNIConnected
            .receive(on: RunLoop.main)
            .sink { [weak self] isPaired in
                if isPaired {
                    self?.presenter?.didConnectNISession()
                } else {
                    self?.presenter?.failToConnectNISession()
                }
            }
            .store(in: &cancellables)

        tryProfileDropUseCase.profilePublisher
            .receive(on: RunLoop.main)
            .sink {[weak self] (profile) in
                guard let profile else { return }
                if self?.tryProfileDropUseCase.isTransitioned == false {
                    self?.presenter?.receiveProfileData(profile)
                    self?.tryProfileDropUseCase.isTransitioned = true
                }
            }
            .store(in: &cancellables)
    }

    func checkNISupport() {
        let isSupported = niDeviceChecker.isNISupported()
        if isSupported == false {
            presenter?.updateDeviceInfo()
        }
    }
}
