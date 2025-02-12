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
    private var tryProfileDropUseCase: any TryProfileDropUseCase
    private var quitProfileDropUseCase: any QuitProfileDropUseCase
    private var cancellables: Set<AnyCancellable> = []
    private let deviceInfoFinder: DeviceInfoFinderProtocol

    init(
        presenter: ProfileDropInteractorOutput? = nil,
        tryProfileDropUseCase: any TryProfileDropUseCase,
        quitProfileDropUseCase: any QuitProfileDropUseCase,
        deviceInfoFinder: DeviceInfoFinderProtocol
    ) {
        self.presenter = presenter
        self.tryProfileDropUseCase = tryProfileDropUseCase
        self.quitProfileDropUseCase = quitProfileDropUseCase
        self.deviceInfoFinder = deviceInfoFinder

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
        let isSupportedNI = deviceInfoFinder.isDeviceSupportedNI()
        SNMLogger.log("isSupportedNI: \(isSupportedNI)")
        if isSupportedNI == false {
            presenter?.updateDeviceInfo()
        }
    }
}
