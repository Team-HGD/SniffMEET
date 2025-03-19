//
//  WalkLogUsecaseTests.swift
//  SNMSceneTests
//
//  Created by sole on 2/26/25.
//

import XCTest

final class WalkLogUsecaseTests: XCTestCase {
    private var fileManager: SNMFileManager!
    private var saveWalkLogUsecase: (any SaveWalkLogUsecase)!
    private var requestWalkLogListUsecase: (any RequestWalkLogListUsecase)!
    private var testWalkLogs: [WalkLog] = [
        WalkLog(
            step: 100,
            distance: 200,
            startDate: Date(),
            endDate: Date().addingTimeInterval(300),
            imageData: nil
        ),
        WalkLog(
            step: 100,
            distance: 200,
            startDate: Date(),
            endDate: Date().addingTimeInterval(100),
            imageData: nil
        ),
        WalkLog(
            step: 100,
            distance: 200,
            startDate: Date(),
            endDate: Date().addingTimeInterval(200),
            imageData: nil
        )
    ]

    override func setUp() {
        fileManager = SNMFileManager(fileType: .data)
        saveWalkLogUsecase = SaveWalkLogUsecaseImpl(
            jsonEncoder: JSONEncoder(),
            fileManager: fileManager
        )
        requestWalkLogListUsecase = RequestWalkLogListUsecaseImpl(fileManager: fileManager)
    }

    override func tearDown() {
        try? fileManager.deleteAll(directoryPath: Environment.FileManagerKey.walkLog)
    }

    func test_walkLog_저장에_성공한다() throws {
        // Arrange
        let endDate = Date()
        let walkLog: WalkLog = WalkLog(
            step: 10,
            distance: 0,
            startDate: Date(),
            endDate: endDate,
            imageData: nil
        )
        // Act
        try saveWalkLogUsecase.execute(walkLog: walkLog)
        // Assert
        let isExist = fileManager.fileExists(
            forKey: Environment.FileManagerKey.walkLog,
            isDirectory: true
        )
        XCTAssertTrue(isExist)
    }
    func test_산책로그의_파일명을_endDate로_저장한다() throws {
        // Arrange
        let endDate = Date()
        let walkLog: WalkLog = WalkLog(
            step: 10,
            distance: 0,
            startDate: Date(),
            endDate: endDate,
            imageData: nil
        )
        // Act
        try saveWalkLogUsecase.execute(walkLog: walkLog)
        // Assert
        let endDateString = endDate.convertDateToISO8601String()
        let isExist = fileManager.fileExists(
            forKey: "\(Environment.FileManagerKey.walkLog)/\(endDateString)"
        )
        XCTAssert(isExist)
    }
    func test_walkLog_폴더에_있는_모든_산책로그를_불러온다() throws {
        // Arrange
        try testWalkLogs
            .forEach{ try saveWalkLogUsecase.execute(walkLog: $0) }
        // Act
        let walkLogs = try requestWalkLogListUsecase.execute()
        // Assert
        XCTAssertEqual(walkLogs.count, testWalkLogs.count)
    }
    func test_walkLog를_불러올때_산책종료시간_최신순으로_불러온다() throws {
        // Arrange
        try testWalkLogs
            .forEach{ try saveWalkLogUsecase.execute(walkLog: $0) }
        // Act
        let walkLogs = try requestWalkLogListUsecase.execute()
        // Assert
        let comparsion = testWalkLogs.sorted { $0.endDate > $1.endDate }
        XCTAssertEqual(walkLogs, comparsion)
    }
}
