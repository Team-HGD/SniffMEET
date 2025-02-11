//
//  Report.swift
//  SniffMeet
//
//  Created by 배현진 on 2/7/25.
//

import Foundation

struct Report: Codable {
    let reporterID: UUID
    let reportedID: UUID
    let option: String
    let message: String
}
