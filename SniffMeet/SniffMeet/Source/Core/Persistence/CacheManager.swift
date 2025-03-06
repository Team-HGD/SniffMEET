//
//  CacheManager.swift
//  SniffMeet
//
//  Created by 윤지성 on 12/4/24.
//

import Foundation
import OrderedCollections

protocol ImageCacheable {
    func save(urlString: String, lastModified: String?, imageData: Data?) async
    func image(urlString: String) async -> CacheableImage?
}

actor DiskCacheManager {
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    private var fileUsageHistory: OrderedSet<String> = []
    private let cacheLimit: Int = 50
    private let cacheDirectoryPath: URL

    init(cacheDirectoryPath: URL) {
        self.cacheDirectoryPath = cacheDirectoryPath
        if let content = try? FileManager
            .default
            .contentsOfDirectory(atPath: cacheDirectoryPath.path) {
            fileUsageHistory.append(contentsOf: content)
        }
    }

    func saveToDisk(urlString: String, cacheableImage: CacheableImage) async throws {
        let data = try jsonEncoder.encode(cacheableImage)

        if !FileManager.default.fileExists(atPath: cacheDirectoryPath.path) {
            try FileManager
                .default
                .createDirectory(at: cacheDirectoryPath, withIntermediateDirectories: true, attributes: nil)
        }
        try data.write(to: cacheDirectoryPath.appendingPathComponent(urlString))
        await updateDiskUsageOrder(urlString: urlString)
        await removeOldestDiskImage()
        SNMLogger.info("Disk cache usages: \(fileUsageHistory)")
    }

    func loadFromDisk(urlString: String) async throws -> CacheableImage? {
        let filePath = cacheDirectoryPath.appendingPathComponent(urlString)
        guard FileManager
            .default
            .fileExists(atPath: filePath.path) else { return nil }

        let data = try Data(contentsOf: filePath)
        await updateDiskUsageOrder(urlString: urlString)
        return try jsonDecoder.decode(CacheableImage.self, from: data)
    }

    private func updateDiskUsageOrder(urlString: String) async {
        fileUsageHistory.remove(urlString)
        fileUsageHistory.append(urlString)
    }

    private func removeOldestDiskImage() async {
        while fileUsageHistory.count > cacheLimit {
            guard let oldestKey = fileUsageHistory.first else { return }
            fileUsageHistory.removeFirst()

            let filePath = cacheDirectoryPath.appendingPathComponent(oldestKey)
            do {
                try FileManager.default.removeItem(at: filePath)
                SNMLogger.info("Removed disk image: \(oldestKey)")
            } catch {
                SNMLogger.error("Failed to remove disk image: \(oldestKey): \(error)")
            }
        }
    }
}

extension CacheManager {
    static let shared = CacheManager()
}

final class CacheManager {
    private let cache: NSCache<NSString, CacheableImage>
    private let diskCacheManager: DiskCacheManager

    private init(
        cache: NSCache<NSString, CacheableImage> = NSCache<NSString, CacheableImage>()
    ) {
        self.cache = cache
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let diskCacheURL = cachesURL.appendingPathComponent("DownloadedCache")
        self.diskCacheManager = DiskCacheManager(cacheDirectoryPath: diskCacheURL)

        cache.totalCostLimit = 5 * 1024 * 1024 // 5MB
    }
    
    func saveMemoryCache(urlString: String, cacheableImage: CacheableImage) {
        cache.setObject(cacheableImage, forKey: urlString as NSString)
    }
    
    func saveDiskCache(urlString: String, cacheableImage: CacheableImage) async {
        do {
            try await diskCacheManager.saveToDisk(urlString: urlString, cacheableImage: cacheableImage)
        } catch {
            SNMLogger.error("CacheManager-saveDiskCache: \(error.localizedDescription) ")
        }
    }
    
    func imageFromMemoryCache(urlString: String) -> CacheableImage? {
        return cache.object(forKey: urlString as NSString)
    }
    
    func imageFromDiskCache(urlString: String) async -> CacheableImage? {
        do {
            return try await diskCacheManager.loadFromDisk(urlString: urlString)
        } catch {
            SNMLogger.error("CacheManager-imageFromDiskCache: \(error.localizedDescription) ")
            return nil
        }
    }
}

extension CacheManager: ImageCacheable {
    func save(urlString: String, lastModified: String?, imageData: Data?) async {
        guard let lastModified,
              let imageData else { return }
        let cacheableImage = CacheableImage(lastModified: lastModified, imageData: imageData)
        
        saveMemoryCache(urlString: urlString, cacheableImage: cacheableImage)
        await saveDiskCache(urlString: urlString, cacheableImage: cacheableImage)
    }
    
    func image(urlString: String) async -> CacheableImage? {
        if let image = imageFromMemoryCache(urlString: urlString) { // 메모리 캐시 hit
            SNMLogger.info("memory cache hit")
            return image
        }
        if let image = await imageFromDiskCache(urlString: urlString) { // 디스크 캐시 hit
            SNMLogger.info("disk cache hit")
            saveMemoryCache(urlString: urlString, cacheableImage: image)
            return image
        }
        // 모두 miss
        return nil
    }
}
