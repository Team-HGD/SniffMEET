//
//  Extension + Array.swift
//  SniffMeet
//
//  Created by sole on 1/22/25.
//

extension Array {
    /// 지정된 size로 배열을 자릅니다.
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
