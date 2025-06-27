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
        case let .equal(key, _):
        case let .notEqual(key, _):
        case let .isNull(key, _):
        case let .isTrue(key, _):
        case let .custom(key, _):
            return key
        }
    }
    var value: String {
        switch self {
        case .equal(_, let value):
            return SupabaseOperator.eq.rawValue + value.queryValue
        case .notEqual(_, let value):
            return SupabaseOperator.neq.rawValue + value.queryValue
        case .isNull(_, let isNull):
            return (isNull ? SupabaseOperator.isNull : SupabaseOperator.notIsNull).rawValue
        case .isTrue(_, let isTrue):
            return (isTrue ? SupabaseOperator.isTrue : SupabaseOperator.isFalse).rawValue
        case .custom(_, let value):
            return value.queryValue
        }
    }
}

// MARK: - SupabaseOperator

extension SupabaseQueryParameter {
    private enum SupabaseOperator: String {
        case eq = "eq"
        case neq = "neq"
        case isNull = "is.null"
        case notIsNull = "not.is.null"
        case isTrue = "is.true"
        case isFalse = "is.false"
    }
}

// MARK: - SupabaseQueryRepresentable Protocol

protocol SupabaseQueryRepresentable {
    var queryValue: String { get }
}

// MARK: - SupabaseQueryRepresentable Protocol Conformance

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
