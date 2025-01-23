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
    func didTabAccessoryButton(mate: Mate)
    func showAlertConnected()
    func showAlertDisconnected()
    func didScrollToBottom()
    func startProfileDrop()
}

protocol MateListInteractorOutput: AnyObject {
    func receiveProfileData(_ data: DogDTO)
    func didConnectNISession()
    func failToConnectNISession()
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

    init(
        view: (any MateListViewable)? = nil,
        output: any MateListPresenterOutput = DefaultMateListPresenterOutput()
    )
    {
        self.view = view
        self.output = output
    }

    func viewWillAppear() {
        guard !isReachedBottom, !isFetching else { return }
        fetchMateList()
        SNMLogger.info("메이트 리스트 호출")
    }

    func didTabAccessoryButton(mate: Mate) {
        guard let view else { return }
        router?.presentWalkRequestView(mateListView: view, mate: mate)
    }

    func showAlertConnected() {
        guard let view else { return }
        router?.showAlert(
            mateListView: view,
            title: "Connected",
            message: "성공적으로 연결되었습니다.\n핸드폰끼리 카메라 방향으로 가까이하여 프로필을 교환해보세요."
        )
    }

    func showAlertDisconnected() {
        guard let view else { return }
        router?.showAlert(
            mateListView: view,
            title: "Disconnected",
            message: "메이트 찾기 실패하였습니다.\n 와이파이와 블루투스가 켜져있는 상태인지 확인해주세요."
        )
    }

    func receiveProfileData(_ data: DogDTO) {
        guard let view else { return }
        router?.showMateRequestView(mateListView: view, data: data)
    }

    func startProfileDrop() {
        interactor?.tryProfileDrop()
    }
    func quitProfileDrop() {
        interactor?.quitProfileDrop()
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
            } catch let snmError as SNMError where snmError.level == .user {
                switch snmError.error {
                case let error as SupabaseDBError where error == .noMoreData:
                    self.didReachEndOfMateList()
                case let error as SupabaseAuthError where error == .sessionNotExist:
                    SNMLogger.error("세션이 존재하지 않습니다.")
                    // TODO: 로그인 화면으로 이동
                default:
                    SNMLogger.error(snmError.localizedDescription)
                }
            } catch let snmError as SNMError where snmError.level == .developer {
                SNMLogger.error(snmError.localizedDescription)
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
    private func didFetchProfileImage(mateID: UUID, imageData: Data?) {
        guard let imageData else { return }
        output.profileImageData.send((mateID, imageData))
    }

    private func didReachEndOfMateList() {
        isReachedBottom = true
    }
}

extension MateListPresenter: MateListInteractorOutput {
    func didConnectNISession() {
        //showAlertConnected()
        view?.changeMPCButtonState(to: .success)
    }

    func failToConnectNISession() {
        view?.changeMPCButtonState(to: .normal)
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
