//
//  SupabaseDBRequestBuilder.swift
//  SniffMeet
//
//  Created by Kelly Chui on 2/6/25.
//

import Foundation

enum SupabaseDBTask {
    case fetch
    case insert
    case update
    case delete
    case rpc
}

protocol RemoteDBRequestBuildable {
    func setTable(_ table: String) -> Self
}

class SupabaseDBRequestBuilder {
    let networkProvider: any NetworkProvider
    let accessToken: String?
    var table: String?

    init(networkProvider: any NetworkProvider, accessToken: String?) {
        self.networkProvider = networkProvider
        self.accessToken = accessToken
    }

    func setTable(_ table: String) -> Self {
        self.table = table
        return self
    }
}
