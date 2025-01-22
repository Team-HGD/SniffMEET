//
//  SNMSceneTests.swift
//  SNMSceneTests
//
//  Created by 윤지성 on 1/21/25.
//

import XCTest

final class MateListInteractorTests: XCTestCase {
    private var sut: MateListInteractor!
    private var presenterSpy: MateListPresenterSpy!
    private var requestMateListUseCaseMock: RequestMateListUseCase!
    private var requestProfileImageUseCaseMock: RequestProfileImageUseCase!
    private var tryProfileDropUseCaseMock: TryProfileDropUseCase!
    private var quitProfileDropUseCaseMock: QuitProfileDropUseCase!
    private var userInfoDTOList = [
        UserInfoDTO(id: UUID(), dogName: "젤리", age: 1, sex: .female, sexUponIntake: true, size: .small, keywords: [.energetic], nickname: "구아바", profileImageURL: nil),
        UserInfoDTO(id: UUID(), dogName: "딸기", age: 1, sex: .female, sexUponIntake: true, size: .small, keywords: [.energetic], nickname: "생크림", profileImageURL: nil),
        UserInfoDTO(id: UUID(), dogName: "멜론", age: 1, sex: .female, sexUponIntake: true, size: .small, keywords: [.energetic], nickname: "차트", profileImageURL: nil)
    ]

    override func setUp() {
        presenterSpy = MateListPresenterSpy()
        requestMateListUseCaseMock = RequestMateListUseCaseMock(mateList: userInfoDTOList)
        requestProfileImageUseCaseMock = RequestProfileImageUseCaseMock()
        tryProfileDropUseCaseMock = TryProfileDropUseCaseMock()
        quitProfileDropUseCaseMock = QuitProfileDropUseCaseMock()
        sut = MateListInteractor(
            presenter: presenterSpy,
            requestMateListUseCase: requestMateListUseCaseMock,
            requestProfileImageUseCase: requestProfileImageUseCaseMock,
            tryProfileDropUseCase: tryProfileDropUseCaseMock,
            quitProfileDropUseCase: quitProfileDropUseCaseMock
        )
    }

    override func tearDown() {
        presenterSpy = nil
        sut = nil
        requestMateListUseCaseMock = nil
        requestProfileImageUseCaseMock = nil
        tryProfileDropUseCaseMock = nil
        quitProfileDropUseCaseMock = nil
    }
    func test_requestMateList는_presenter에게_올바른_메이트_리스트를_전달한다() async {
        // Arrange
        
        // Act
        // 파라미터로 받은 userID는 Mock객체 동작에 상관없음
        let _ = await sut.requestMateList(userID: UUID())
        
        // Assert
        XCTAssertTrue(presenterSpy.presentMateListsCalled,
                      "presenter에서 메이트리스트를 view에게 전달하는 메서드를 호출한다. " )
        presenterSpy.receivedMateList?.enumerated().forEach { (idx, mate) in
            XCTAssertEqual(mate.userID, userInfoDTOList[idx].id,
                           "presenter가 성공적으로 메이트 리스트 데이터를 받는다. ")
        }
    }
    
    func test_requestProfileImage는_presenter에게_올바른_이미지를_전달한다() async {
        // Arrange
        
        // Act
        // 파라미터로 받은 id와 imageNamge은 Mock객체 동작에 상관없음
        let _ = await sut.requestProfileImage(id: UUID(), imageName: nil)
        
        // Assert
        XCTAssertTrue(presenterSpy.presentProfileImageCalled,
                      "presenter가 이미지를 view에게 전달하는 메서드를 호출한다." )
    }
    
    func test_tryProfileDropUseCase가_profilePublisher를_send_호출시_presenter에_프로필데이터를_전달한다() async throws {
        // Arrange
        let receivedProfile = DogDTO(id: UUID(), name: "lemon", keywords: [.shy], profileImage: nil)
        // Act
        tryProfileDropUseCaseMock.profilePublisher.send(receivedProfile)
        // Assert
        try await Task.sleep(nanoseconds: 1000000000)
        XCTAssertTrue(presenterSpy.presentProfileDataCalled,
                      "presenter가 프로필 드랍 데이터를 처리하는 메서드를 호출한다." )
        if let receivedId = presenterSpy.receivedProfileData?.id {
            XCTAssertEqual(receivedId, receivedProfile.id)
        } else {
            XCTFail("프로필 데이터를 받지 못했다. ")
        }
    }
    func test_tryProfileDropUseCase가_NI세션이_연결되면_presenter에_연결사실을_알린다() async throws {
        // Arrange
        // Act
        tryProfileDropUseCaseMock.isNIConnected.send(true)
        try await Task.sleep(nanoseconds: 1000000000)
        
        // Assert
            XCTAssertTrue(presenterSpy.presentNIConnectedCalled,
                          "presenter가 NI 연결 상태를 처리하는 메서드를 호출한다." )

    }
    func test_tryProfileDropUseCase가_NI세션이_연결이_종료되면_presenter에_연결이_끊긴_사실을_알린다() async throws {
        // Arrange
        let expectation = XCTestExpectation(description: "Presenter processes NI Not Connected")
        // Act
        tryProfileDropUseCaseMock.isNIConnected.send(false)
        try await Task.sleep(nanoseconds: 1000000000)

        // Assert
        XCTAssertTrue(presenterSpy.presentNINotConnectedCalled,
                      "presenter가 NI 연결이 끊긴 상태를 처리하는 메서드를 호출한다." )
    }
}
