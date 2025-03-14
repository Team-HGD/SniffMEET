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
    private var nearByProfileDropUsecase: any NearByProfileDropUsecase
    private var targetedProfileDropUsecase: any TargetedProfileDropUsecase
    private var quitProfileDropUsecase: any QuitProfileDropUsecase
    private var cancellables: Set<AnyCancellable> = []
    private let niDeviceChecker: NIDeviceCheckerProtocol

    init(
        presenter: ProfileDropInteractorOutput? = nil,
        nearByProfileDropUsecase: any NearByProfileDropUsecase,
        targetedProfileDropUsecase: any TargetedProfileDropUsecase,
        quitProfileDropUsecase: any QuitProfileDropUsecase,
        niDeviceChecker: NIDeviceCheckerProtocol
    ) {
        self.presenter = presenter
        self.nearByProfileDropUsecase = nearByProfileDropUsecase
        self.targetedProfileDropUsecase = targetedProfileDropUsecase
        self.quitProfileDropUsecase = quitProfileDropUsecase
        self.niDeviceChecker = niDeviceChecker

        bind()
    }

    func tryNearByProfileDrop() {
        if nearByProfileDropUsecase.isTransitioned {
            guard let mpcManager = MPCManager(dataManager: LocalDataManager())
            else { return }
            let niManager = NIManager()
            nearByProfileDropUsecase.reset(mpcManager: mpcManager, nimanager: niManager)
            quitProfileDropUsecase.reset(niManager: niManager)
        }
        nearByProfileDropUsecase.execute()
    }
    func tryTargetedProfileDrop() {
        targetedProfileDropUsecase.execute()
    }
    func mcBrowserViewController() -> AnyObject {
        targetedProfileDropUsecase.mcBrowserViewController()
    }

    func quitProfileDrop() {
        quitProfileDropUsecase.execute()
    }

    func bind() {
        [nearByProfileDropUsecase.isConnected, targetedProfileDropUsecase.isConnected].forEach {
            $0.receive(on: RunLoop.main)
            .sink {[weak self] (state) in
                self?.handleConnectionState(state: state)
                Task { @MainActor [weak self] in
                    self?.presenter?.closeBrowserView()
                }
            }
            .store(in: &cancellables)
        }
        
        [nearByProfileDropUsecase.profilePublisher, targetedProfileDropUsecase.profilePublisher].forEach {
            $0.receive(on: RunLoop.main)
                .sink {[weak self] (profile) in
                    guard let profile else { return }
                    if self?.targetedProfileDropUsecase.isTransitioned == false {
                        self?.presenter?.receiveProfileData(profile)
                        self?.nearByProfileDropUsecase.isTransitioned = true
                    }
                }
                .store(in: &cancellables)
        }
    }

    func checkNISupport() {
        let isSupported = niDeviceChecker.isNISupported()
        if isSupported == false {
            presenter?.updateDeviceInfo()
        }
    }
    
    func handleConnectionState(state: ConnectionState) {
        presenter?.showConnectionState(to: state)
        switch state {
        case .cannotFindPeer, .failure:
            quitProfileDrop()
        default:
            break
        }
    }
}
