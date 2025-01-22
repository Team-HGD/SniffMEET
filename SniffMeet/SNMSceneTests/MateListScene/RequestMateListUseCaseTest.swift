//
//  RequestMateListUseCaseTest.swift
//  SNMSceneTests
//
//  Created by 윤지성 on 1/22/25.
//

import XCTest

final class RequestMateListUseCaseTest: XCTestCase {
    private var sut: RequestMateListUseCaseImpl!
    private var remoteDatabaseManagerMock: RemoteDatabaseManager!
    private var userInfoDTOList = [
        UserInfoDTO(id: UUID(), dogName: "젤리", age: 1, sex: .female, sexUponIntake: true, size: .small, keywords: [.energetic], nickname: "구아바", profileImageURL: nil),
        UserInfoDTO(id: UUID(), dogName: "딸기", age: 1, sex: .female, sexUponIntake: true, size: .small, keywords: [.energetic], nickname: "생크림", profileImageURL: nil),
        UserInfoDTO(id: UUID(), dogName: "멜론", age: 1, sex: .female, sexUponIntake: true, size: .small, keywords: [.energetic], nickname: "차트", profileImageURL: nil)
    ]

    override func tearDown()  {
        sut = nil
        remoteDatabaseManagerMock = nil
    }
    
    func test_remoteDataBaseMagerFetchList결과를_받아서_MateList를_반환에_성공한다() async throws {
        // Arrange
        let fetchListData = try JSONEncoder().encode(userInfoDTOList)
        remoteDatabaseManagerMock = RemoteDatabaseManagerMock(fetchData: nil, fetchListData: fetchListData)
        sut = RequestMateListUseCaseImpl(remoteDatabaseManager: remoteDatabaseManagerMock)
        
        // Act
        let mates = await sut.execute()
        
        // Assert
        mates.enumerated().forEach { (idx, mate) in
            XCTAssertEqual(mate.userID, userInfoDTOList[idx].id, "유즈케이스가 올바른 mateList를 전달받는다.")
        }
    }
}
