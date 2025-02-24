//
//  MateListPresenter.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/21/24.
//

import Combine
import Foundation

protocol MateListPresentable: AnyObject {
    var view: (any MateListViewable)? { get set }
    var router: (any MateListRoutable)? { get set }
    var interactor: (any MateListInteractable)? { get set }
    var output: any MateListPresenterOutput { get }
    
    func viewWillAppear()
    func didTabMateListCell(mate: Mate)
    func didTapAddMateButton()
    func didSwipeToDelete(mate: Mate)
    func didSwipeToReport(mate: Mate)
    func didScrollToBottom()
}

protocol MateListInteractorOutput: AnyObject {
    func didDeleteMate(_ mate: Mate)
}

final class MateListPresenter: MateListPresentable {
    weak var view: (any MateListViewable)?
    var interactor: (any MateListInteractable)?
    var router: (any MateListRoutable)?
    let output: any MateListPresenterOutput

    private var isFetching: Bool = false
    private var isReachedBottom: Bool = false
    private var currentPage: Int = 0
    private let pageSize: Int = 20

    private let queue: TaskSerialQueue = TaskSerialQueue()
    private var fetchErrorHandler: SNMErrorHandler = SNMErrorHandler()

    init(
        view: (any MateListViewable)? = nil,
        output: any MateListPresenterOutput = DefaultMateListPresenterOutput()
    )
    {
        self.view = view
        self.output = output
        configureErrorHandlers()
    }

    func viewWillAppear() {
        guard !isReachedBottom, !isFetching else { return }
        fetchMateList()
        SNMLogger.info("메이트 리스트 호출")
    }

    func didTabMateListCell(mate: Mate) {
        guard let view else { return }
        router?.presentWalkRequestView(mateListView: view, mate: mate)
    }

    func didTapAddMateButton() {
        guard let view else { return }
        router?.showProfileDropView(mateListView: view)
    }

    func didSwipeToDelete(mate: Mate) {
        Task {
            do {
                try await interactor?.deleteMate(mate: mate)
            } catch {
                SNMLogger.error("deleteMate error: \(error)")
            }
        }
    }

    func didSwipeToReport(mate: Mate) {
        guard let view else { return }
        router?.showReportMateView(mateListView: view, data: mate)
    }

    func didScrollToBottom() {
        guard !isReachedBottom, !isFetching else { return }
        isFetching = true
        currentPage += 1
        fetchMateList()
    }

    private func fetchMateList() {
        Task { [weak self] in
            guard let self else { return }
            do {
                guard let mateList = try await self.interactor?.requestMateList(
                    page: self.currentPage,
                    pageSize: self.pageSize
                ) else { return }
                self.didFetchMateList(mateList: mateList)
            } catch {
                fetchErrorHandler.handle(error: error)
            }
        }
    }

    private func didFetchMateList(mateList: [Mate]) {
        output.mates.send(output.mates.value + mateList)
        isFetching = false
        let chunkedSize: Int = 5

        Task { [weak self] in
            // 최대 5개의 이미지 요청만 수행합니다.
            for mates in mateList.chunked(into: chunkedSize) {
                await self?.queue.addTask { [weak self] in
                    if let profileImages = await self?.interactor?.requestProfileImages(
                        mates: mates
                    ) {
                        self?.didFetchProfileImages(
                            profileImages: profileImages
                        )
                    }
                }
            }
        }
    }

    private func didFetchProfileImages(profileImages: [(mateID: UUID, imageData: Data)]) {
        profileImages.forEach {
            self.output.profileImageData.send($0)
        }
    }

    private func didReachEndOfMateList() {
        isReachedBottom = true
    }

    private func configureErrorHandlers() {
        fetchErrorHandler.configure { [weak self] level in
            switch level {
            case .notifyUser:
                self?.didReachEndOfMateList()
            default:
                break
            }
        }
    }
}

extension MateListPresenter: MateListInteractorOutput {
    func didDeleteMate(_ mate: Mate) {
        output.mates.value.removeAll { $0.userID == mate.userID }
    }
}

// MARK: - MateListPresenterOutput
protocol MateListPresenterOutput {
    var mates: CurrentValueSubject<[Mate], Never> { get }
    var profileImageData: PassthroughSubject<(UUID, Data?), Never> { get }
}

struct DefaultMateListPresenterOutput: MateListPresenterOutput {
    var mates = CurrentValueSubject<[Mate], Never>([])
    var profileImageData = PassthroughSubject<(UUID, Data?), Never>()
}
