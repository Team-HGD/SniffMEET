//
//  SaveProfileImageUsecase.swift
//  SniffMeet
//
//  Created by sole on 11/25/24.
//

import Foundation

protocol SaveProfileImageUsecase {
    func execute(imageData: Data) async throws -> String
}

struct SaveProfileImageUsecaseImpl: SaveProfileImageUsecase {
    private let remoteImageManager: any RemoteImageManageable
    private let fileManager: any FileManagable
    // TODO: DataStorable의 delete 기능 확장이 필요합니다.
    private let localDataManager: any UserDefaultsManagable
    private let imageSampler: any ImageSampleable
    
    init(
        remoteImageManager: any RemoteImageManageable,
        fileManager: any FileManagable,
        localDataManager: any UserDefaultsManagable,
        imageSampler: any ImageSampleable
    ) {
        self.remoteImageManager = remoteImageManager
        self.localDataManager = localDataManager
        self.fileManager = fileManager
        self.imageSampler = imageSampler
    }
    
    func execute(imageData: Data) async throws -> String {
        let fileName: String = UUID().uuidString
        let thumbnailName: String = "thumbnail_\(fileName)"
        do {
            let (profileImageData, thumbnailImageData) = try await downsampleImages(imageData: imageData)
            try saveToLocal(fileName: fileName, imageData: profileImageData)
            try await saveToRemote(
                profileImageData: profileImageData,
                thumbnailImageData: thumbnailImageData,
                fileName: fileName,
                thumbnailName: thumbnailName
            )
        } catch let error as ImageSamplingError {
            throw SNMError(level: .notifyUser, error: error)
        } catch let error as FileManagerError {
            throw SNMError(level: .retryable, error: error)
        } catch let error as SupabaseSessionError {
            throw SNMError(level: .notExistSession, error: error)
        } catch let error as SupabaseStorageError {
            do {
                try fileManager.delete(forKey: fileName)
                try fileManager.delete(forKey: thumbnailName)
                try localDataManager.delete(forKey: fileName)
            } catch {
                throw SNMError(level: .retryable, error: error)
            }
            throw SNMError(level: .retryable, error: error)
        }
        return fileName
    }
    private func downsampleImages(imageData: Data) async throws -> (Data, Data) {
        enum ImageType { case profile, thumbnail }
        return try await withThrowingTaskGroup(of: (imageType: ImageType, data: Data).self) { group in
            var profileImageData: Data?
            var thumbnailImageData: Data?
            group.addTask {
                let data = try await imageSampler.downscaleImage(
                    from: imageData,
                    targetSize: Constants.profileTargetSize,
                    croppingTo: nil
                )
                return (ImageType.profile, data)
            }
            group.addTask {
                let data = try await imageSampler.downscaleImage(
                    from: imageData,
                    targetSize: Constants.thumbnailSize,
                    croppingTo: Constants.thumbnailSize
                )
                return (ImageType.thumbnail, data)
            }
            for try await result in group {
                switch result.imageType {
                case .profile: profileImageData = result.data
                case .thumbnail: thumbnailImageData = result.data
                }
            }
            guard let downsampled = profileImageData,
                  let thumbnail = thumbnailImageData else {
                throw ImageSamplingError.downsamplingFailed
            }
            return (downsampled, thumbnail)
        }
    }
    private func saveToLocal(fileName: String, imageData: Data) throws {
        try localDataManager.set(
            value: fileName,
            forKey: Environment.UserDefaultsKey.profileImageName
        )
        try fileManager.set(
            value: imageData,
            forKey: Environment.FileManagerKey.profileImage
        )
    }
    private func saveToRemote(
        profileImageData: Data,
        thumbnailImageData: Data,
        fileName: String,
        thumbnailName: String
    ) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.remoteImageManager.upload(
                    imageData: profileImageData,
                    fileName: fileName,
                    mimeType: .image
                )
            }
            group.addTask {
                try await self.remoteImageManager.upload(
                    imageData: thumbnailImageData,
                    fileName: thumbnailName,
                    mimeType: .image
                )
            }
            try await group.waitForAll()
        }
    }
}

extension SaveProfileImageUsecaseImpl {
    private enum Constants {
        static let profileTargetSize = CGSize(width: 392, height: 591)
        static let thumbnailSize = CGSize(width: 100, height: 100)
    }
}
