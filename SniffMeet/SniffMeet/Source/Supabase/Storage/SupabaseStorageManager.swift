//
//  SupabaseStorageManager.swift
//  SniffMeet
//
//  Created by sole on 11/24/24.
//

import Foundation

struct RemoteImage {
    let isModified: Bool
    let imageData: Data?
    let lastModified: String?
}

protocol RemoteImageManagable {
    func upload(imageData: Data, fileName: String, mimeType: MimeType) async throws
//    func download(fileName: String) async throws -> Data
    func download(fileName: String, lastModified: String) async throws -> RemoteImage
}

struct SupabaseStorageManager: RemoteImageManagable {
    private let networkProvider: SNMNetworkProvider

    init(networkProvider: SNMNetworkProvider) {
        self.networkProvider = networkProvider
    }
    func upload(
        imageData: Data,
        fileName: String,
        mimeType: MimeType = .image
    ) async throws {
        do {
            if try SessionManager.shared.checkSessionExpiration() {
                try await SessionManager.shared.refreshSession()
            }
            guard let session = SessionManager.shared.session else {
                throw SupabaseSessionError.sessionNotExist
            }
            _ = try await networkProvider.request(
                with: SupabaseStorageRequest.upload(
                    accessToken: session.accessToken,
                    image: imageData,
                    fileName: fileName,
                    mimeType: mimeType
                )
            )
        } catch {
            throw SupabaseStorageError.uploadFailed
        }
    }
    func download(fileName: String, lastModified: String) async throws -> RemoteImage {
        do {
            let response: SNMNetworkResponse = try await networkProvider.request(
                with: SupabaseStorageRequest.download(fileName: fileName,
                                                           lastModified: lastModified)
            )
            let recentLastModified = response.header?["Last-Modified"] as? String
            let imageResponse = RemoteImage(isModified: response.statusCode != .notModified,
                                            imageData: response.data,
                                            lastModified: recentLastModified ?? "" )
            return imageResponse
        } catch {
            throw SupabaseStorageError.downloadFailed
        }
    }
}

// MARK: - SupabaseStorageError

enum SupabaseStorageError: LocalizedError {
    case uploadFailed
    case downloadFailed
    
    var errorDescription: String? {
        switch self {
        case .uploadFailed: "업로드 실패"
        case .downloadFailed: "다운로드 실패"
        }
    }
}
