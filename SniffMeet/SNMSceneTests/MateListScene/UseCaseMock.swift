//
//  UseCase.swift
//  SniffMeet
//
//  Created by 윤지성 on 1/22/25.
//
import Combine
import Foundation
import UIKit

struct RequestMateListUseCaseMock: RequestMateListUseCase {
    var remoteDBManager: any RemoteDBManageable
    var mateList: [UserInfoDTO]
    
    init(mateList: [UserInfoDTO]) {
        remoteDBManager = RemoteDBManagerMock(data: nil)
        self.mateList = mateList
    }
    
    func execute(page: Int, pageSize: Int) async throws -> [Mate] {
        mateList.map{
            Mate(name: $0.dogName,
                 userID: $0.id,
                 keywords: $0.keywords,
                 profileImageURLString: $0.profileImageURL)
        }
    }
}

struct RequestProfileImageUseCaseMock: RequestProfileImageUseCase {
    func execute(fileName: String) async -> Data? {
        UIImage.checkmark.pngData()
    }
}

final class NearByProfileDropUseCaseMock: NearByProfileDropUseCase {
    var profilePublisher: CurrentValueSubject<DogDTO?, Never> = CurrentValueSubject(nil)
    var isNIConnected: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
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

struct QuitProfileDropUseCaseMock: QuitProfileDropUseCase {
    func execute() {
    }
    
    mutating func reset(niManager: NIManager) {
    }
}

struct DeleteMateUseCaseMock: DeleteMateUseCase {
    func execute(mate: Mate) async throws {
    }
}
