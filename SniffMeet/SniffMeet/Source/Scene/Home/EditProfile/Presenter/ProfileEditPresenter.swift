//
//  ProfileEditPresenter.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/28/24.
//

import Combine
import UIKit

protocol ProfileEditPresentable: AnyObject {
    var userInfo: ProfileInfo { get set }
    var view: (any ProfileEditViewable)? { get set }
    var router: (any ProfileEditRoutable)? { get set }
    var interactor: (any ProfileEditInteractable)? { get set }
    var output: any ProfileEditPresenterOutput { get }
    
    func viewDidLoad()
    func didTapCompleteButton(
        nameText: String?,
        ageText: String?,
        sizeText: String?,
        keywords: [Keyword]?,
        profileImage: UIImage?
    )
}

final class ProfileEditPresenter: ProfileEditPresentable {
    var userInfo: ProfileInfo
    weak var view: (any ProfileEditViewable)?
    var router: (any ProfileEditRoutable)?
    var interactor: (any ProfileEditInteractable)?
    let output: any ProfileEditPresenterOutput
    
    init(
        userInfo: ProfileInfo,
        view: (any ProfileEditViewable)? = nil,
        router: (any ProfileEditRoutable)? = nil,
        interactor: ProfileEditInteractor? = nil,
        output: ProfileEditPresenterOutput = DefaultProfileEditPresenterOutput(
            profileInfo: PassthroughSubject<ProfileInfo, Never>(),
            profileImage: PassthroughSubject<Data?, Never>()
        )
    ) {
        self.userInfo = userInfo
        self.view = view
        self.router = router
        self.interactor = interactor
        self.output = output
    }
    
    func viewDidLoad() {
        if let (profileInfo, profileImageData) = interactor?.requestProfile() {
            didFetchProfile(info: profileInfo, imageData: profileImageData)
        }
    }
    func didTapCompleteButton(
        nameText: String?,
        ageText: String?,
        sizeText: String?,
        keywords: [Keyword]?,
        profileImage: UIImage?
    ) {
        guard let nameText,
              let ageText,
              let age = UInt8(ageText),
              let sizeText,
              let size = Size(rawValue: sizeText),
              let keywords else {
            return
        }
        Task {
            do {
                try await interactor?.editUserInfo(
                    name: nameText,
                    age: age,
                    size: size.rawValue,
                    keywords: keywords.map { $0.rawValue },
                    imageData: profileImage?.jpegData(compressionQuality: 0.7)
                )
            } catch {
                SNMLogger.error(error.localizedDescription)
            }
        }
    }
}

// MARK: - ProfileEditPresenter+ProfileEditInteractorOutput

protocol ProfileEditInteractorOutput: AnyObject {
    func didFetchProfile(info: ProfileInfo, imageData: Data?)
    func didSaveUserInfo()
    func didFailToSaveUserInfo()
}

extension ProfileEditPresenter: ProfileEditInteractorOutput {
    func didFetchProfile(info: ProfileInfo, imageData: Data?) {
        output.profileInfo.send(userInfo)
        output.profileImage.send(imageData)
    }
    func didSaveUserInfo() {
        guard let view else { return }
        view.didSuccessEditProfile()
        router?.presentMainScreen(from: view)
    }
    func didFailToSaveUserInfo() {
        view?.didFailEditProfile()
    }
}

// MARK: - ProfileEditPresenterOutput

protocol ProfileEditPresenterOutput {
    var profileInfo: PassthroughSubject<ProfileInfo, Never> { get }
    var profileImage: PassthroughSubject<Data?, Never> { get }
}

struct DefaultProfileEditPresenterOutput: ProfileEditPresenterOutput {
    var profileInfo: PassthroughSubject<ProfileInfo, Never>
    var profileImage: PassthroughSubject<Data?, Never>
}
