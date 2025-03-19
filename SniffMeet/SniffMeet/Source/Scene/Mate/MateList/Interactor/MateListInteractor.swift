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
    func deleteMate(mate: Mate) async throws
}

final class MateListInteractor: MateListInteractable {
    weak var presenter: (any MateListInteractorOutput)?
    private let requestMateListUsecase: any RequestMateListUsecase
    private let requestProfileImageUsecase: any RequestProfileImageUsecase
    private var deleteMateUsecase: any DeleteMateUsecase
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        presenter: (any MateListInteractorOutput)? = nil,
        requestMateListUsecase: any RequestMateListUsecase,
        requestProfileImageUsecase: any RequestProfileImageUsecase,
        deleteMateUsecase: any DeleteMateUsecase
    ) {
        self.presenter = presenter
        self.requestMateListUsecase = requestMateListUsecase
        self.requestProfileImageUsecase = requestProfileImageUsecase
        self.deleteMateUsecase = deleteMateUsecase
    }

    func requestMateList(page: Int, pageSize: Int) async throws -> [Mate] {
        let mateList = try await requestMateListUsecase.execute(
            page: page,
            pageSize: pageSize
        )
        return mateList
    }

    func requestProfileImages(mates: [Mate]) async -> [(mateID: UUID, imageData: Data)] {
        var result: [(UUID, Data)] = []

        await withTaskGroup(of: (UUID, Data?).self) { [weak self] group in
            for mate in mates {
                guard let profileImageName = mate.profileImageName else { continue }
                group.addTask {
                    let imageData = await self?.requestProfileImageUsecase.execute(
                        fileName: "thumbnail_\(profileImageName)"
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
        try await deleteMateUsecase.execute(mate: mate)
        presenter?.didDeleteMate(mate)
    }
    
}
