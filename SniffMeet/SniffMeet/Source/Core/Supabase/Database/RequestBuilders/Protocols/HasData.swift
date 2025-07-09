//
//  HasData.swift
//  SniffMeet
//
//  Created by Kelly Chui on 6/28/25.
//

import Foundation

protocol HasData {
    var data: Data? { get set }
    func setData(_ data: Data) -> Self
}
extension HasData {
    func setData(_ data: Data) -> Self {
        var copy = self
        copy.data = data
        return copy
    }
}
