//
//  MateListPresentable.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/21/24.
//
import Combine
import Foundation

protocol MateListInteractable: AnyObject {
    var presenter: (any MateListInteractorOutput)? { get set }

    func requestMateList(page: Int, pageSize: Int) async throws -> [Mate]
    func requestProfileImages(mates: [Mate]) async -> [(mateID: UUID, imageData: Data)]
    func tryProfileDrop()
    func quitProfileDrop()
}

final class MateListInteractor: MateListInteractable {
    weak var presenter: (any MateListInteractorOutput)?
    private let requestMateListUseCase: any RequestMateListUseCase
    private let requestProfileImageUseCase: any RequestProfileImageUseCase
    private var tryProfileDropUseCase: any TryProfileDropUseCase
    private var quitProfileDropUseCase: any QuitProfileDropUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        presenter: (any MateListInteractorOutput)? = nil,
        requestMateListUseCase: any RequestMateListUseCase,
        requestProfileImageUseCase: any RequestProfileImageUseCase,
        tryProfileDropUseCase: any TryProfileDropUseCase,
        quitProfileDropUseCase: any QuitProfileDropUseCase
    ) {
        self.presenter = presenter
        self.requestMateListUseCase = requestMateListUseCase
        self.requestProfileImageUseCase = requestProfileImageUseCase
        self.tryProfileDropUseCase = tryProfileDropUseCase
        self.quitProfileDropUseCase = quitProfileDropUseCase
        
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
                if self?.tryProfileDropUseCase.isTransistioned == false {
                    self?.presenter?.receiveProfileData(profile)
                    self?.tryProfileDropUseCase.isTransistioned = true
                }
            }
            .store(in: &cancellables)
    }
    
    func tryProfileDrop() {
        if tryProfileDropUseCase.isTransistioned {
            let mpcManager = MPCManager()
            let niManager = NIManager(mpcManager: mpcManager)
            tryProfileDropUseCase.reset(mpcManager: mpcManager, nimanager: niManager)
            quitProfileDropUseCase.reset(niManager: niManager)
            tryProfileDropUseCase.isTransistioned = false

        }
        tryProfileDropUseCase.execute()
    }
    
    func quitProfileDrop() {
        quitProfileDropUseCase.execute()
    }
}
