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
        guard fileType == .data else {
            return documentsDir?.appendingPathComponent(fileName)
        }
        return documentsDir?.appendingPathComponent(fileName, conformingTo: .jpeg)
       }
    
    func fileExists(forKey path: String) -> Bool {
        guard let fileURL = fullURL(for: path) else { return false }
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
        try data.write(to: fileURL)
    }
    
    func delete(forKey: String) throws {
        guard let fileURL = fullURL(for: forKey) else {
            throw FileManagerError.directoryNotFound
        }
        try fileManager.removeItem(at: fileURL)
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

    var errorDescription: String? {
        switch self {
        case .directoryNotFound: "디렉터리를 찾을 수 없습니다."
        case .fileNotFound: "파일을 찾을 수 없습니다."
        case .dataConversionError: "이미지 데이터 변환 에러"
        case .decodingError: "디코딩 에러"
        case .noDeleteObject: "삭제할 대상을 찾을 수 없습니다."
        case .writeError: "파일 쓰기 에러"
        case .deleteError: "파일 삭제 에러"
        }
    }
}
