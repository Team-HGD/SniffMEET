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
    private let requestMateListUseCase: any RequestMateListUseCase
    private let requestProfileImageUseCase: any RequestProfileImageUseCase
    private var deleteMateUseCase: any DeleteMateUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        presenter: (any MateListInteractorOutput)? = nil,
        requestMateListUseCase: any RequestMateListUseCase,
        requestProfileImageUseCase: any RequestProfileImageUseCase,
        deleteMateUseCase: any DeleteMateUseCase
    ) {
        self.presenter = presenter
        self.requestMateListUseCase = requestMateListUseCase
        self.requestProfileImageUseCase = requestProfileImageUseCase
        self.deleteMateUseCase = deleteMateUseCase
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
    
}
