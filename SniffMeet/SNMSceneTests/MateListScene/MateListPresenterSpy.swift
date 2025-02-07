//
//  MateListIteractorSpy.swift
//  SniffMeet
//
//  Created by 윤지성 on 1/22/25.
//
import Foundation

final class MateListPresenterSpy: MateListInteractorOutput {
    var presentMateListsCalled = false
    var receivedMateList: [Mate]?
    var presentProfileImageCalled = false
    var receivedProfileImage: Data?
    var presentProfileDataCalled = false
    var receivedProfileData: DogDTO?
    var presentNIConnectedCalled = false
    var presentNINotConnectedCalled = false
    
    func didFetchMateList(mateList: [Mate]) {
        presentMateListsCalled = true
        receivedMateList = mateList
    }
    
    func didFetchProfileImage(id: UUID, imageData: Data?) {
        presentProfileImageCalled = true
        receivedProfileImage = imageData
    }
    
    func receiveProfileData(_ data: DogDTO) {
        presentProfileDataCalled = true
        receivedProfileData = data
    }
    
    func didConnectNISession() {
        presentNIConnectedCalled = true
    }
    
    func failToConnectNISession() {
        presentNINotConnectedCalled = true
    }

    func didDeleteMate(_ mate: Mate) {
        // didDeleteMate
    }
}
