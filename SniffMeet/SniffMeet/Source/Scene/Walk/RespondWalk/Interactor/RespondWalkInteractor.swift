//
//  RespondWalkInteractor.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/20/24.
//
import CoreLocation
import Foundation

protocol RespondWalkInteractable: AnyObject {
    var presenter: RespondWalkInteractorOutput? { get set }
    var requestUserInfoUsecase: RequestMateInfoUsecase { get }
    var respondWalkRequestUsecase: RespondWalkRequestUsecase { get }
    var calculateTimeLimitUsecase: CalculateTimeLimitUsecase { get }
    var convertLocationToTextUsecase: ConvertLocationToTextUsecase { get }
    var requestProfileImageUsecase: RequestProfileImageUsecase { get }
    var loadUserUsecase: LoadUserInfoUsecase { get }
    
    func fetchSenderInfo(userId: UUID)
    func respondWalkRequest(isAccepted: Bool, receivedNoti: WalkNoti)
    func calculateTimeLimit(requestTime: Date)
    func convertLocationToText(latitude: Double, longtitude: Double) async
    func fetchProfileImage(urlString: String)
}

final class RespondWalkInteractor: RespondWalkInteractable {
    weak var presenter: (any RespondWalkInteractorOutput)?
    var requestUserInfoUsecase: RequestMateInfoUsecase
    var respondWalkRequestUsecase: RespondWalkRequestUsecase
    var calculateTimeLimitUsecase: CalculateTimeLimitUsecase
    var convertLocationToTextUsecase: ConvertLocationToTextUsecase
    var requestProfileImageUsecase: RequestProfileImageUsecase
    let loadUserUsecase: LoadUserInfoUsecase
    
    init(presenter: (any RespondWalkInteractorOutput)? = nil,
         requestUserInfoUsecase: RequestMateInfoUsecase,
         respondUsecase: RespondWalkRequestUsecase,
         calculateTimeLimitUsecase: CalculateTimeLimitUsecase,
         convertLocationToTextUsecase: ConvertLocationToTextUsecase,
         requestProfileImageUsecase: RequestProfileImageUsecase,
         loadUserUsecase: LoadUserInfoUsecase
    )
    {
        self.presenter = presenter
        self.requestUserInfoUsecase = requestUserInfoUsecase
        self.respondWalkRequestUsecase = respondUsecase
        self.calculateTimeLimitUsecase = calculateTimeLimitUsecase
        self.convertLocationToTextUsecase = convertLocationToTextUsecase
        self.requestProfileImageUsecase = requestProfileImageUsecase
        self.loadUserUsecase = loadUserUsecase
    }
    
    func fetchSenderInfo(userId: UUID) {
        Task {
            do {
                guard let senderInfo = try await requestUserInfoUsecase.execute(
                    mateID: userId
                ) else {
                    presenter?.didFailToFetchWalkRequest(
                        error: SupabaseAuthError.userNotFound
                    )
                    return
                }
                presenter?.didFetchUserInfo(senderInfo: senderInfo)
                guard let profileImageURL = senderInfo.profileImageURL else { return }
                fetchProfileImage(urlString: profileImageURL)
            } catch {
                presenter?.didFailToFetchWalkRequest(error: error)
            }
        }
    }
    
    func respondWalkRequest(isAccepted: Bool, receivedNoti: WalkNoti) {
        let walkNotiCategory: WalkNotiCategory = isAccepted ? .walkAccepted : .walkDeclined
        Task {
            do {
                guard let date = receivedNoti.createdAt?.convertDateToISO8601String() else {
                    // TODO: 에러 핸들링 필요
                    return
                }
                let userID = try SupabaseSessionManager.shared.userID.get()
                let userInfo = try loadUserUsecase.execute()
                let walkNoti = WalkNotiDTO(
                    id: UUID(),
                    createdAt: date,
                    message: receivedNoti.message,
                    latitude: receivedNoti.latitude,
                    longtitude: receivedNoti.longtitude,
                    senderId: userID,
                    receiverId: receivedNoti.senderId,
                    senderName: userInfo.name,
                    category: walkNotiCategory
                )
                try await respondWalkRequestUsecase.execute(requestID: receivedNoti.id, walkNoti: walkNoti)
            }
            catch {
                presenter?.didFailToSendWalkRequest(error: error)
            }
        }
        presenter?.didSendWalkRespond()
    }
    func calculateTimeLimit(requestTime: Date) {
        let timeDifference = calculateTimeLimitUsecase.execute(requestTime: requestTime)
        presenter?.didCalculateTimeLimit(secondDifference: timeDifference)
    }
    func convertLocationToText(latitude: Double, longtitude: Double) async {
        Task {
            let locationText: String? = await convertLocationToTextUsecase.execute(
                latitude: latitude, longtitude: longtitude
            )
            presenter?.didConvertLocationToText(with: locationText)
        }
    }
    func fetchProfileImage(urlString: String) {
        Task { [weak self] in
            let imageData = try await self?.requestProfileImageUsecase.execute(fileName: urlString)
            self?.presenter?.didFetchProfileImage(with: imageData)
        }
    }
}
