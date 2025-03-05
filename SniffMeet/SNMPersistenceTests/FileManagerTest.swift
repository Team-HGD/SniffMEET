//
//  FileManagerTest.swift
//  SNMPersistenceTests
//
//  Created by 윤지성 on 11/25/24.
//

import XCTest

final class FileManagerTest: XCTestCase {
    private var imageFileManagersut: SNMFileManager!
    private var dataFileManagerSut: SNMFileManager!

    private let testKey = "profileTest"
    private var isSaved = false
    private let testDirectoryPath: String = "test"
    private let testDirectoryPaths: [String] = [
        "test/\(UUID().uuidString)",
        "test/\(UUID().uuidString)",
        "test/\(UUID().uuidString)"
    ]

    override func setUp()  {
        imageFileManagersut = SNMFileManager(fileType: .image)
        dataFileManagerSut = SNMFileManager(fileType: .data)
    }

    override func tearDownWithError() throws {
        try? imageFileManagersut.delete(forKey: testKey)
        try? dataFileManagerSut.deleteAll(directoryPath: testDirectoryPath)
        try? imageFileManagersut.deleteAll(directoryPath: testDirectoryPath)
    }

    func test_set에서_key에_설정한_폴더가_없으면_폴더를_생성한다() throws {
        // Arrange
        XCTAssertFalse(
            dataFileManagerSut.fileExists(forKey: testDirectoryPath, isDirectory: true)
        )
        let encodedData = try JSONEncoder().encode([1, 2, 3])
        // Act
        try dataFileManagerSut.set(value: encodedData, forKey: testDirectoryPaths[0])
        // Assert
        XCTAssertTrue(
            dataFileManagerSut.fileExists(forKey: testDirectoryPath, isDirectory: true)
        )
    }

    func test_delete에서_삭제할_값이_없으면_에러를_반환한다() throws {
        XCTAssertThrowsError(try imageFileManagersut.delete(forKey: testKey)) { error in
            guard let error = error as? FileManagerError else {
                XCTFail("error is not FileManagerError")
                return
            }
            XCTAssertEqual(error, FileManagerError.deleteError)
        }
    }

    func test_이미지를_저장하고_가져올_수_있다() throws {
        // Arrange
        let image: UIImage = .app

        // Act
        XCTAssertFalse(imageFileManagersut.fileExists(forKey: testKey))
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try imageFileManagersut.set(value: imageData, forKey: testKey)
        }
        _ = try imageFileManagersut.get(forKey: testKey)
        isSaved = true
        // Assert
        XCTAssertTrue(imageFileManagersut.fileExists(forKey: testKey))
    }

    func test_이미_이미지가_저장된파일에_이미지를_덮어쓸_수_있다() throws {
        // Arrange
        let firstImage: UIImage = .app
        let secondImage: UIImage = .imagePlaceholder

        // Act
        try imageFileManagersut.set(value: firstImage.pngData()!, forKey: testKey)
        let firstSavedImageData = try imageFileManagersut.get(forKey: testKey)

        try imageFileManagersut.set(value: secondImage.pngData()!, forKey: testKey)
        let secondSavedImageData = try imageFileManagersut.get(forKey: testKey)
        isSaved = true

        //Assert
        let comparison1 = firstImage.pngData()?.count ?? 0 > secondImage.pngData()?.count ?? 0
        let comparison2 = firstSavedImageData.count > secondSavedImageData.count

        XCTAssertTrue(imageFileManagersut.fileExists(forKey: testKey))
        XCTAssertEqual(comparison1, comparison2)
    }

    func test_데이터가_삭제될_수_있다() throws {
        // Arrange
        let firstImage: UIImage = .app

        // Act
        try imageFileManagersut.set(value: firstImage.pngData()!, forKey: testKey)
        let beforeSavedImage = try imageFileManagersut.get(forKey: testKey)

        try imageFileManagersut.delete(forKey: testKey)

        //Assert
        XCTAssertThrowsError(try imageFileManagersut.delete(forKey: testKey)) { error in
            XCTAssert(error is FileManagerError)
            XCTAssertEqual(error as! FileManagerError, FileManagerError.deleteError)
        }
    }

    func test_fileExists에서_파일이_존재하는_경로에는_true를_반환한다() throws {
        // Arrange
        let encodedData = try JSONEncoder().encode([1, 2, 3])
        try dataFileManagerSut.set(value: encodedData, forKey: testDirectoryPaths[0])
        // Act
        let isExist = dataFileManagerSut.fileExists(forKey: testDirectoryPaths[0])
        // Assert
        XCTAssertTrue(isExist)
    }
    func test_fileExists에서_파일이_존재하지_않는_경로에는_false를_반환한다() throws {
        // Arrange
        // Act
        let isExist = dataFileManagerSut.fileExists(forKey: testDirectoryPaths[0])
        // Assert
        XCTAssertFalse(isExist)
    }
    func test_fileExists에서_디렉토리가_존재하는_경로에는_true를_반환한다() throws {
        // Arrange
        let encodedData = try JSONEncoder().encode([1, 2, 3])
        try dataFileManagerSut.set(value: encodedData, forKey: testDirectoryPaths[0])
        // Act
        let isExist = dataFileManagerSut.fileExists(forKey: testDirectoryPath, isDirectory: true)
        // Assert
        XCTAssertTrue(isExist)
    }
    func test_fileExists에서_디렉토리가_존재하지_않는_경로에는_false를_반환한다() throws {
        // Arrange
        // Act
        let isExist = dataFileManagerSut.fileExists(
            forKey: testDirectoryPath,
            isDirectory: true
        )
        // Assert
        XCTAssertFalse(isExist)
    }
    func test_fileExists에서_이미지파일경로를_입력하고_isDirectory를_true로_설정하면_false를_반환한다() throws {
        // Arrange
        let image: UIImage = .app
        try imageFileManagersut.set(value: image.pngData()!, forKey: testDirectoryPaths[0])
        // Act
        let isExist = imageFileManagersut.fileExists(
            forKey: testDirectoryPaths[0],
            isDirectory: true
        )
        // Assert
        XCTAssertFalse(isExist)
    }
    func test_fileExists에서_데이터파일경로를_입력하고_isDirectory를_true로_설정하면_false를_반환한다() throws {
        // Arrange
        let encodedData = try JSONEncoder().encode([1, 2, 3])
        try imageFileManagersut.set(value: encodedData, forKey: testDirectoryPaths[0])
        // Act
        let isExist = imageFileManagersut.fileExists(
            forKey: testDirectoryPaths[0],
            isDirectory: true
        )
        // Assert
        XCTAssertFalse(isExist)
    }

    func test_getAll에서_디렉토리에_저장한_데이터를_모두_불러온다() throws {
        // Arrange
        let encodedData = try JSONEncoder().encode([1, 2, 3])
        try testDirectoryPaths.forEach {
            try dataFileManagerSut.set(value: encodedData, forKey: $0)
        }
        // Act
        let loadedDatas = try dataFileManagerSut.getAll(directoryPath: "test")
        let decodedData = loadedDatas
            .compactMap{ try? JSONDecoder().decode([Int].self, from: $0) }
        // Assert
        XCTAssertEqual(loadedDatas.count, 3)
        XCTAssertEqual(decodedData.count, 3)
    }

    func test_getAll에서_디렉토리에_저장한_이미지를_모두_불러온다() throws {
        // Arrange
        let image: UIImage = .app
        try testDirectoryPaths.forEach {
            try imageFileManagersut.set(value: image.pngData()!, forKey: $0)
        }
        // Act
        let loadedDatas = try imageFileManagersut.getAll(directoryPath: "test")
        let decodedData = loadedDatas
            .compactMap{ UIImage(data: $0) }
        // Assert
        XCTAssertEqual(loadedDatas.count, 3)
        XCTAssertEqual(decodedData.count, 3)
    }

    func test_getAll에서_directoryPath가_아니면_invaildPath_에러를_반환한다() throws {
        // Arrange
        let invalidPath: String = "test/test.txt"
        // Act
        // Assert
        XCTAssertThrowsError(try imageFileManagersut.getAll(directoryPath: invalidPath)) { error in
            XCTAssert(error is FileManagerError)
            XCTAssertEqual(error as! FileManagerError, FileManagerError.invalidPath)
        }
    }

    func test_deleteAll에서_폴더에_파일이_있는_경우_파일과_디렉토리를_삭제한다() throws {
        // Arrange
        let encodedData = try JSONEncoder().encode([1, 2, 3])
        try dataFileManagerSut.set(value: encodedData, forKey: testDirectoryPaths[0])
        // Act
        try dataFileManagerSut.deleteAll(directoryPath: testDirectoryPath)
        // Assert
        XCTAssertFalse(dataFileManagerSut.fileExists(forKey: testDirectoryPaths[0]))
        XCTAssertFalse(dataFileManagerSut.fileExists(forKey: testDirectoryPath))
    }

    func test_deleteAll에서_폴더에_파일이_없는_경우_디렉토리를_삭제한다() throws {
        // Arrange
        let encodedData = try JSONEncoder().encode([1, 2, 3])
        try dataFileManagerSut.set(value: encodedData, forKey: testDirectoryPaths[0])
        try dataFileManagerSut.delete(forKey: testDirectoryPaths[0])
        // Act
        try dataFileManagerSut.deleteAll(directoryPath: testDirectoryPath)
        // Assert
        let isExist = dataFileManagerSut.fileExists(forKey: testDirectoryPath, isDirectory: true)
        XCTAssertFalse(isExist)
    }
}
