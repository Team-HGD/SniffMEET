//
//  RequestProfileImageUsecase.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/24/24.
//

import Foundation

protocol RequestProfileImageUsecase {
    func execute(fileName: String) async -> Data?
}

struct RequestProfileImageUsecaseImpl: RequestProfileImageUsecase {
    private let remoteImageManager: any RemoteImageManageable
    private let cacheManager: any ImageCacheable

    init(
        remoteImageManager: any RemoteImageManageable,
        cacheManager: any ImageCacheable
    ) {
        self.remoteImageManager = remoteImageManager
        self.cacheManager = cacheManager
    }

    func execute(fileName: String) async -> Data? {
        if let cacheableImage = await cacheManager.image(urlString: fileName) { // 캐시에 있을 때
            do {
                let remoteImage = try await remoteImageManager.download(
                    fileName: fileName,
                    lastModified: cacheableImage.lastModified
                )
                if !remoteImage.isModified { // 변경되지 않음
                    SNMLogger.log("not modified")
                    return cacheableImage.imageData
                } else {
                    await cacheManager.save(urlString: fileName,
                                                 lastModified: remoteImage.lastModified,
                                                 imageData: remoteImage.imageData)
                    return remoteImage.imageData!
                }
            } catch {
                SNMLogger.error("RequestProfileImageUsecaseImpl: \(error.localizedDescription)")
                return nil
            }
        } else { // 캐시에 없을 때
            do {
                let remoteImage = try await remoteImageManager.download(
                    fileName: fileName,
                    lastModified: ""
                )
                await cacheManager.save(urlString: fileName,
                                             lastModified: remoteImage.lastModified,
                                             imageData: remoteImage.imageData)
                return remoteImage.imageData
            } catch {
                SNMLogger.error("RequestProfileImageUsecaseImpl: \(error.localizedDescription)")
                return nil
            }
        }
    }
}
