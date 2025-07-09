//
//  HasQuery.swift
//  SniffMeet
//
//  Created by Kelly Chui on 6/28/25.
//

import Foundation

protocol HasQuery {
    var query: [String: String] { get set }
    func setQuery(_ parameter: SupabaseQueryParameter) -> Self
}
extension HasQuery {
    func setQuery(_ parameter: SupabaseQueryParameter) -> Self {
        var copy = self
        copy.query[parameter.key] = parameter.value
        return copy
    }
}
