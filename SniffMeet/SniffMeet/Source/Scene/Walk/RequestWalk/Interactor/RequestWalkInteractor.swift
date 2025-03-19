//
//  RequestWalkInteractor.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/18/24.
//

import Foundation

protocol RequestWalkInteractable: AnyObject {
    var presenter: RequestWalkInteractorOutput? { get set }
    func requestMateInfo()
    func requestProfileImage(imageName: String?)
    func sendWalkRequest(message: String, latitude: Double, longtitude: Double, location: String)
}

final class RequestWalkInteractor: RequestWalkInteractable {
    private(set) var mate: Mate
    weak var presenter: RequestWalkInteractorOutput?
    private let requestWalkUsecase: any RequestWalkUsecase
    // private let requestMateInfoUsecase: any RequestMateInfoUsecase
    private let requestProfileImageUsecase: any RequestProfileImageUsecase
    private let loadUserInfoUsecase: any LoadUserInfoUsecase
    
    init(
        mate: Mate,
        presenter: RequestWalkInteractorOutput? = nil,
        requestWalkUsecase: any RequestWalkUsecase,
        // requestMateInfoUsecase: any RequestMateInfoUsecase,
        requestProfileImageUsecase: any RequestProfileImageUsecase,
        loadUserInfoUsecase: any LoadUserInfoUsecase
    ) {
        self.mate = mate
        self.presenter = presenter
        self.requestWalkUsecase = requestWalkUsecase
        // self.requestMateInfoUsecase = requestMateInfoUsecase
        self.requestProfileImageUsecase = requestProfileImageUsecase
        self.loadUserInfoUsecase = loadUserInfoUsecase
    }
    
    func sendWalkRequest(message: String, latitude: Double, longtitude: Double, location: String) {
        Task {
            do {
                let myInfo = try loadUserInfoUsecase.execute()
                let id = try SupabaseSessionManager.shared.userID.get()
                let walkNoti = WalkNotiDTO(
                    id: UUID(),
                    createdAt: Date().convertDateToISO8601String(),
                    message: message,
                    latitude: latitude,
                    longtitude: longtitude,
                    senderId: id,
                    receiverId: mate.userID,
                    senderName: myInfo.name,
                    category: .walkRequest
                )
                try await requestWalkUsecase.execute(walkNoti: walkNoti)
            } catch {
                // TODO: 이 부분은 Mapper를 통해 정리할 수 있을 것 같습니다.
                SNMLogger.error("RequestWalkInteractor: \(error.localizedDescription)")
            }
        }
        presenter?.didSendWalkRequest()
    }
    
    func requestMateInfo() {
        presenter?.didFetchMateInfo(mateInfo: mate)
    }
    
    func requestProfileImage(imageName: String?) {
        Task { @MainActor in
            let fileName = mate.profileImageName ?? ""
            let imageData = await requestProfileImageUsecase.execute(fileName: fileName)
            presenter?.didFetchProfileImage(imageData: imageData)
        }
    }
}
