//
//  DataStoragable.swift
//  SniffMeet
//
//  Created by 윤지성 on 1/9/25.
//
import Foundation

protocol DataStorageManagable {
    associatedtype StoredType: Codable
    func get(forKey key: String) throws -> StoredType
    func set(value: StoredType, forKey key: String) throws
    func delete(forKey key: String) throws
}

enum FileType {
    case data
    case image
}

protocol FileManagable: DataStorageManagable where StoredType == Data {
    var fileType: FileType { get } // managing할 파일의 타입을 지정합니다.
}

protocol TokenManagable: DataStorageManagable where StoredType == String {}
