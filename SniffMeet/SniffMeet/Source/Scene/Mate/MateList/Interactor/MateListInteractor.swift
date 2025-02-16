//
//  MateListPresentable.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/21/24.
//

import Combine
import Foundation
import MultipeerConnectivity

protocol MateListInteractable: AnyObject {
    var presenter: (any MateListInteractorOutput)? { get set }

    func requestMateList(page: Int, pageSize: Int) async throws -> [Mate]
    func requestProfileImages(mates: [Mate]) async -> [(mateID: UUID, imageData: Data)]
    func deleteMate(mate: Mate) async throws
    func tryProfileDrop()
    func quitProfileDrop()
}

final class MateListInteractor: MateListInteractable {
    weak var presenter: (any MateListInteractorOutput)?
    private let requestMateListUseCase: any RequestMateListUseCase
    private let requestProfileImageUseCase: any RequestProfileImageUseCase
    private var tryProfileDropUseCase: any NearByProfileDropUseCase
    private var quitProfileDropUseCase: any QuitProfileDropUseCase
    private var deleteMateUseCase: any DeleteMateUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        presenter: (any MateListInteractorOutput)? = nil,
        requestMateListUseCase: any RequestMateListUseCase,
        requestProfileImageUseCase: any RequestProfileImageUseCase,
        tryProfileDropUseCase: any NearByProfileDropUseCase,
        quitProfileDropUseCase: any QuitProfileDropUseCase,
        deleteMateUseCase: any DeleteMateUseCase
    ) {
        self.presenter = presenter
        self.requestMateListUseCase = requestMateListUseCase
        self.requestProfileImageUseCase = requestProfileImageUseCase
        self.tryProfileDropUseCase = tryProfileDropUseCase
        self.quitProfileDropUseCase = quitProfileDropUseCase
        self.deleteMateUseCase = deleteMateUseCase

        bind()
    }

    func requestMateList(page: Int, pageSize: Int) async throws -> [Mate] {
        let mateList = try await requestMateListUseCase.execute(
            page: page,
            pageSize: pageSize
        )
        return mateList
    }

    func requestProfileImages(mates: [Mate]) async -> [(mateID: UUID, imageData: Data)] {
        var result: [(UUID, Data)] = []

        await withTaskGroup(of: (UUID, Data?).self) { [weak self] group in
            for mate in mates {
                guard let profileImageURLString = mate.profileImageURLString else { continue }
                group.addTask {
                    let imageData = await self?.requestProfileImageUseCase.execute(
                        fileName: "thumbnail_\(profileImageURLString)"
                    )
                    return (mate.userID, imageData)
                }
            }
            for await (mateID, profileImageData) in group {
                guard let profileImageData else { continue }
                result.append((mateID, profileImageData))
            }
        }
        return result
    }

    func deleteMate(mate: Mate) async throws {
        try await deleteMateUseCase.execute(mate: mate)
        presenter?.didDeleteMate(mate)
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
    
    func tryProfileDrop() {
        // 정보 load
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
}
