//
//  SaveProfileImageUseCase.swift
//  SniffMeet
//
//  Created by sole on 11/25/24.
//

import Foundation

protocol SaveProfileImageUseCase {
    /// fileName을 반환합니다.
    func execute(imageData: Data) async throws -> String
}

struct SaveProfileImageUseCaseImpl: SaveProfileImageUseCase {
    private let remoteImageManager: any RemoteImageManageable
    private let userDefaultsManager: any UserDefaultsManagable
    private let imageSampler: any ImageSampleable
    init(
        remoteImageManager: any RemoteImageManageable,
        userDefaultsManager: any UserDefaultsManagable,
        imageSampler: any ImageSampleable
    ) {
        self.remoteImageManager = remoteImageManager
        self.userDefaultsManager = userDefaultsManager
        self.imageSampler = imageSampler
    }

    func execute(imageData: Data) async throws -> String {
        let fileName: String = UUID().uuidString
        let thumbnailName: String = "thumbnail_\(fileName)"
        async let downsampledData = imageSampler.downscaleImage(
            from: imageData,
            targetSize: Constants.profileTargetSize,
            croppingTo: nil
        )
        async let thumbnailData = imageSampler.downscaleImage(
            from: imageData,
            targetSize: Constants.thumbnailSize,
            croppingTo: Constants.thumbnailSize
        )
        let downsampledImageData = try await downsampledData
        let thumbnailImageData = try await thumbnailData
        
        async let uploadDownsampled: () = remoteImageManager.upload(
            imageData: downsampledImageData,
            fileName: fileName,
            mimeType: .image
        )
        async let uploadThumbnail: () = remoteImageManager.upload(
            imageData: thumbnailImageData,
            fileName: thumbnailName,
            mimeType: .image
        )
        
        try await uploadDownsampled
        try await uploadThumbnail
        try userDefaultsManager.set(
            value: fileName,
            forKey: Environment.UserDefaultsKey.profileImage
        )
        return fileName
    }
}

extension SaveProfileImageUseCaseImpl {
    private enum Constants {
        static let profileTargetSize = CGSize(width: 392, height: 591)
        static let thumbnailSize = CGSize(width: 100, height: 100)
    }
}
