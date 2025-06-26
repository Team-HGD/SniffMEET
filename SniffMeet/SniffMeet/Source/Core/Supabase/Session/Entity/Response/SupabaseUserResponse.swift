//
//  SupabaseUserResponse.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/19/24.
//

import Foundation

struct SupabaseUserResponse: Decodable {
    var id: UUID
    let identities: [SupabaseUserIdentity]
}

struct SupabaseUserIdentity: Decodable {
    let identityData: IdentityData

    enum CodingKeys: String, CodingKey {
        case identityData = "identity_data"
    }

    struct IdentityData: Decodable {
        let emailVerified: Bool

        enum CodingKeys: String, CodingKey {
            case emailVerified = "email_verified"
        }
    }
}
