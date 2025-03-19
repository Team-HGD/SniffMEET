//
//  Usecase.swift
//  SniffMeet
//
//  Created by 윤지성 on 1/22/25.
//
import Combine
import Foundation
import UIKit

struct RequestMateListUsecaseMock: RequestMateListUsecase {
    var remoteDBManager: any RemoteDBManageable
    var mateList: [UserInfoDTO]
    
    init(mateList: [UserInfoDTO]) {
        remoteDBManager = RemoteDBManagerMock(data: nil)
        self.mateList = mateList
    }
    
    func execute(page: Int, pageSize: Int) async throws -> [Mate] {
        mateList.map{
            Mate(
                name: $0.dogName,
                userID: $0.id,
                keywords: $0.keywords,
                profileImageName: $0.profileImageName
            )
        }
    }
}

struct RequestProfileImageUsecaseMock: RequestProfileImageUsecase {
    func execute(fileName: String) async -> Data? {
        UIImage.checkmark.pngData()
    }
}

final class NearByProfileDropUsecaseMock: NearByProfileDropUsecase {
    var isConnected: PassthroughSubject<ConnectionState, Never> = PassthroughSubject()
    
    var profilePublisher: PassthroughSubject<DogDTO?, Never> = PassthroughSubject()
    var transmissionFlag: Set<String> = []
    var isTransitioned: Bool = false
    var triedBefore: Bool = false
    
    init() {
        
    }
    
    func execute() {
    }
    
    func loadProfileData() {
    }
    
    func reset(mpcManager: MPCManager, nimanager: NIManager) {
    }
}

struct QuitProfileDropUsecaseMock: QuitProfileDropUsecase {
    func execute() {
    }
    
    mutating func reset(niManager: NIManager) {
    }
}

struct DeleteMateUsecaseMock: DeleteMateUsecase {
    func execute(mate: Mate) async throws {
    }
}
