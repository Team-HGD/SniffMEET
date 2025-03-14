//
//  SNMFileManager.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/25/24.
//
import Foundation

struct SNMFileManager: FileManagable {
    var fileType: FileType

    private var fileManager: FileManager { FileManager.default }
    private var documentsDir: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    private func fullURL(for fileName: String) -> URL? {
        switch fileType {
        case .data:
            documentsDir?.appendingPathComponent(fileName, conformingTo: .data)
        case .image:
            documentsDir?.appendingPathComponent(fileName, conformingTo: .jpeg)
        }
    }
    private func fullDirectoryURL(for path: String) -> URL? {
        documentsDir?.appendingPathComponent(path)
    }

    func fileExists(forKey path: String, isDirectory: Bool = false) -> Bool {
        guard let fileURL = isDirectory ?
                fullDirectoryURL(for: path) : fullURL(for: path) else { return false }
        if #available(iOS 16.0, *) {
            return fileManager.fileExists(atPath: fileURL.path())
        } else {
            return fileManager.fileExists(atPath: fileURL.path)
        }
    }

    /// key 값은 Environment.FileManagerKey를 이용하시면 됩니다.
    func get(forKey: String) throws -> Data {
        guard let fileURL = fullURL(for: forKey) else {
            throw FileManagerError.directoryNotFound
        }

        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw FileManagerError.fileNotFound
        }
        return try Data(contentsOf: fileURL)
    }

    func set(value data: Data, forKey: String) throws {
        guard let fileURL = fullURL(for: forKey) else {
            throw FileManagerError.directoryNotFound
        }
        try createDirectoryIfNeeded(url: fileURL)
        do {
            try data.write(to: fileURL)
        } catch {
            throw FileManagerError.writeError
        }
    }

    private func createDirectoryIfNeeded(url: URL) throws {
        var directoryURL: URL = url
        directoryURL.deleteLastPathComponent()
        try fileManager.createDirectory(
            atPath: directoryURL.path,
            withIntermediateDirectories: true
        )
    }

    func delete(forKey: String) throws {
        guard let fileURL = fullURL(for: forKey) else {
            throw FileManagerError.directoryNotFound
        }
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            throw FileManagerError.deleteError
        }
    }
    
    func getAll(directoryPath: String) throws -> [Data] {
        guard let fileURL = fullDirectoryURL(for: directoryPath) else {
            throw FileManagerError.directoryNotFound
        }
        guard fileURL.pathExtension.isEmpty else {
            throw FileManagerError.invalidPath
        }
        let contentsURLs = try fileManager.contentsOfDirectory(
            at: fileURL,
            includingPropertiesForKeys: nil
        )
        return contentsURLs.compactMap { try? Data(contentsOf: $0) }
    }

    func deleteAll(directoryPath: String) throws {
        guard let fileURL = fullDirectoryURL(for: directoryPath) else {
            throw FileManagerError.directoryNotFound
        }
        guard fileURL.pathExtension.isEmpty else {
            throw FileManagerError.invalidPath
        }
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            throw FileManagerError.deleteError
        }
    }
}

enum FileManagerError: LocalizedError {
    case directoryNotFound
    case fileNotFound
    case dataConversionError
    case decodingError
    case noDeleteObject
    case writeError
    case deleteError
    case invalidPath

    var errorDescription: String? {
        switch self {
        case .directoryNotFound: "디렉터리를 찾을 수 없습니다."
        case .fileNotFound: "파일을 찾을 수 없습니다."
        case .dataConversionError: "이미지 데이터 변환 에러"
        case .decodingError: "디코딩 에러"
        case .noDeleteObject: "삭제할 대상을 찾을 수 없습니다."
        case .writeError: "파일 쓰기 에러"
        case .deleteError: "파일 삭제 에러"
        case .invalidPath: "유효하지 않은 경로"
        }
    }
}
