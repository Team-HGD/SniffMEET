//
//  CacheManager.swift
//  SniffMeet
//
//  Created by 윤지성 on 12/4/24.
//

import Foundation

protocol ImageCacheable {
    func save(urlString: String, lastModified: String?, imageData: Data?)
    func image(urlString: String) -> CacheableImage?
}

final class ImageNSCacheManager {
    static let shared = ImageNSCacheManager()
    
    private let cache: NSCache<NSString, CacheableImage>
    private let fileManager: any FileManagable
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var usageOrder: [String] = []
    private let cacheLimit: Int = 50

    private var cacheDirectoryPath: URL {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let diskCacheURL = cachesURL.appendingPathComponent("DownloadedCache")
        return diskCacheURL
    }

    private init(
        cache: NSCache<NSString, CacheableImage> = NSCache<NSString, CacheableImage>(),
        fileManager: any FileManagable = SNMFileManager(fileType: .data))
    {
        self.cache = cache
        self.fileManager = fileManager
        cache.totalCostLimit = 5 * 1024 * 1024 // 5MB
    }
    
    func saveMemoryCache(urlString: String, cacheableImage: CacheableImage) {
        cache.setObject(cacheableImage, forKey: urlString as NSString)
    }
    
    func saveDiskCache(urlString: String, cacheableImage: CacheableImage) {
        do {
            let data = try encoder.encode(cacheableImage)
            try fileManager.set(value: data, forKey: urlString)

            // 디스크 캐시에 저장 후 사용 순서 업데이트
            updateDiskUsageOrder(urlString: urlString)
            removeOldestDiskImage()
        } catch {
            SNMLogger.error("CacheManager-saveDiskCache: \(error.localizedDescription) ")
        }
    }
    
    func imageFromMemoryCache(urlString: String) -> CacheableImage? {
        return cache.object(forKey: urlString as NSString)
    }
    
    func imageFromDiskCache(urlString: String) -> CacheableImage? {
        do {
            let data = try fileManager.get(forKey: urlString)
            updateDiskUsageOrder(urlString: urlString)
            return try? decoder.decode(CacheableImage.self, from: data)
        } catch {
            SNMLogger.error("CacheManager-imageFromDiskCache: \(error.localizedDescription) ")
        }
        return nil
    }

    private func updateDiskUsageOrder(urlString: String) {
        if !usageOrder.contains(urlString) {
            usageOrder.append(urlString)
        }

        if let index = usageOrder.firstIndex(of: urlString) {
            usageOrder.remove(at: index)
            usageOrder.append(urlString)
        }
    }

    private func removeOldestDiskImage() {
        SNMLogger.info("usageOrderCount: \(usageOrder.count)")
        while usageOrder.count > cacheLimit {
            guard let oldestKey = usageOrder.first else { return }
            usageOrder.removeFirst()

            try? fileManager.delete(forKey: oldestKey)
        }
    }
}

extension ImageNSCacheManager: ImageCacheable {
    func save(urlString: String, lastModified: String?, imageData: Data?) {
        guard let lastModified,
              let imageData else { return }
        let cacheableImage = CacheableImage(lastModified: lastModified, imageData: imageData)
        
        saveMemoryCache(urlString: urlString, cacheableImage: cacheableImage)
        saveDiskCache(urlString: urlString, cacheableImage: cacheableImage)
    }
    
    func image(urlString: String) -> CacheableImage? {
        if let image = imageFromMemoryCache(urlString: urlString) { // 메모리 캐시 hit
            SNMLogger.info("memory cache hit")
            return image
        }
        if let image = imageFromDiskCache(urlString: urlString) { // 디스크 캐시 hit
            SNMLogger.info("disk cache hit")
            saveMemoryCache(urlString: urlString, cacheableImage: image)
            return image
        }
        // 모두 miss
        return nil
    }
}
