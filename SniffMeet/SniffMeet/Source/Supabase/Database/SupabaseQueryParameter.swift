//
//  SupabaseQueryOperator.swift
//  SniffMeet
//
//  Created by Kelly Chui on 2/5/25.
//

// https://postgrest.org/en/stable/references/api/tables_views.html#operators

import Foundation

enum SupabaseQueryParameter {
    case equal(String, SupabaseQueryRepresentable)
    case notEqual(String, SupabaseQueryRepresentable)
    case isNull(String, Bool)
    case isTrue(String, Bool)
    case custom(String, SupabaseQueryRepresentable)
    
    var key: String {
        switch self {
        case .equal(let key, _):
            return key
        case .notEqual(let key, _):
            return key
        case .isNull(let key, _):
            return key
        case .isTrue(let key, _):
            return key
        case .custom(let key, _):
            return key
        }
    }
    
    var value: String {
        switch self {
        case .equal(_, let value):
            return "eq." + value.queryValue
        case .notEqual(_, let value):
            return "neq." + value.queryValue
        case .isNull(_, let isNull):
            return isNull ? "is.null" : "not.is.null"
        case .isTrue(_, let isTrue):
            return isTrue ? "is.true" : "is.false"
        case .custom(_, let value):
            return value.queryValue
        }
    }
}

protocol SupabaseQueryRepresentable {
    var queryValue: String { get }
}

extension String: SupabaseQueryRepresentable {
    public var queryValue: String { self }
}

extension Int: SupabaseQueryRepresentable {
    public var queryValue: String { "\(self)" }
}

extension Double: SupabaseQueryRepresentable {
    public var queryValue: String { "\(self)" }
}

extension Bool: SupabaseQueryRepresentable {
    public var queryValue: String { "\(self)" }
}

extension UUID: SupabaseQueryRepresentable {
    public var queryValue: String { uuidString }
}
