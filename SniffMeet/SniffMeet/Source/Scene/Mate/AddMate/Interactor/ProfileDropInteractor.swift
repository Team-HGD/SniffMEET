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

    func tryNearByProfileDrop()
    func tryTargetedProfileDrop()
    func mcBrowserViewController() -> AnyObject
    func quitProfileDrop()
    func checkNISupport()
}

final class ProfileDropInteractor: ProfileDropInteractable {
    weak var presenter: (any ProfileDropInteractorOutput)?
    private var nearByProfileDropUseCase: any NearByProfileDropUseCase
    private var targetedProfileDropUseCase: any TargetedProfileDropUseCase
    private var quitProfileDropUseCase: any QuitProfileDropUseCase
    private var cancellables: Set<AnyCancellable> = []
    private let niDeviceChecker: NIDeviceCheckerProtocol

    init(
        presenter: ProfileDropInteractorOutput? = nil,
        nearByProfileDropUseCase: any NearByProfileDropUseCase,
        targetedProfileDropUseCase: any TargetedProfileDropUseCase,
        quitProfileDropUseCase: any QuitProfileDropUseCase,
        niDeviceChecker: NIDeviceCheckerProtocol
    ) {
        self.presenter = presenter
        self.nearByProfileDropUseCase = nearByProfileDropUseCase
        self.targetedProfileDropUseCase = targetedProfileDropUseCase
        self.quitProfileDropUseCase = quitProfileDropUseCase
        self.niDeviceChecker = niDeviceChecker

        bind()
    }

    func tryNearByProfileDrop() {
        if nearByProfileDropUseCase.isTransitioned {
            guard let mpcManager = MPCManager(dataManager: LocalDataManager())
            else { return }
            let niManager = NIManager()
            nearByProfileDropUseCase.reset(mpcManager: mpcManager, nimanager: niManager)
            quitProfileDropUseCase.reset(niManager: niManager)
        }
        nearByProfileDropUseCase.execute()
    }
    func tryTargetedProfileDrop() {
        targetedProfileDropUseCase.execute()
    }
    func mcBrowserViewController() -> AnyObject {
        targetedProfileDropUseCase.mcBrowserViewController()
    }

    func quitProfileDrop() {
        quitProfileDropUseCase.execute()
    }

    func bind() {
        nearByProfileDropUseCase.isNIConnected
            .receive(on: RunLoop.main)
            .sink { [weak self] isPaired in
                if isPaired {
                    self?.presenter?.didConnectNISession()
                } else {
                    self?.presenter?.failToConnectNISession()
                }
            }
            .store(in: &cancellables)

        nearByProfileDropUseCase.profilePublisher
            .receive(on: RunLoop.main)
            .sink {[weak self] (profile) in
                guard let profile else { return }
                if self?.nearByProfileDropUseCase.isTransitioned == false {
                    self?.presenter?.receiveProfileData(profile)
                    self?.nearByProfileDropUseCase.isTransitioned = true
                }
            }
            .store(in: &cancellables)
        
        targetedProfileDropUseCase.profilePublisher
            .receive(on: RunLoop.main)
            .sink {[weak self] (profile) in
                guard let profile else { return }
                if self?.targetedProfileDropUseCase.isTransitioned == false {
                    self?.presenter?.receiveProfileData(profile)
                    self?.nearByProfileDropUseCase.isTransitioned = true
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
