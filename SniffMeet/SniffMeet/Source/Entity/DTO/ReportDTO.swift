//
//  ReportDTO.swift
//  SniffMeet
//
//  Created by 배현진 on 2/7/25.
//

import Foundation

struct ReportDTO: Encodable {
    let id: UUID
    let createdAt: String
    let reporterID: UUID
    let reportedID: UUID
    let reportOption: String
    let reportMessage: String

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case reporterID = "reporter_id"
        case reportedID = "reported_id"
        case reportOption = "report_option"
        case reportMessage = "report_message"
    }
}
