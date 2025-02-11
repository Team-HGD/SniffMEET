//
//  SupabaseManager.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/17/24.
//

import Foundation

enum SupabaseConfig {
#if TEST
    static let baseURL: URL = {
        guard let urlString = Bundle(for: SupabaseStorageTests.self).object(forInfoDictionaryKey: "SERVER_URL") as? String,
              let url = URL(string: urlString.replacingOccurrences(of: "\\", with: "")) else {
            fatalError("invalid SERVER_URL")
        }
        return url
    }()
    static let apiKey: String = {
        guard let publicKey = Bundle(for: SupabaseStorageTests.self).object(forInfoDictionaryKey: "PUBLIC_KEY") as? String else {
            fatalError("invalid PUBLIC_KEY")
        }
        return publicKey
    }()
    #else
    static let baseURL: URL = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SERVER_URL") as? String,
              let url = URL(string: urlString.replacingOccurrences(of: "\\", with: "")) else {
            fatalError("invalid SERVER_URL")
        }
        return url
    }()
    static let apiKey: String = {
        guard let publicKey = Bundle.main.object(forInfoDictionaryKey: "PUBLIC_KEY") as? String else {
            fatalError("invalid PUBLIC_KEY")
        }
        return publicKey
    }()
    #endif
    static let bucketName: String = "image"
}
