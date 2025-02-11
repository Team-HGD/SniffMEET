//
//  RequestReportUseCase.swift
//  SniffMeet
//
//  Created by 배현진 on 2/7/25.
//

import Foundation

protocol RequestReportUseCase {
    func execute(report: Report) async throws
}

struct RequestReportUseCaseImpl: RequestReportUseCase {
    private let encoder: JSONEncoder
    private let remoteDBManager: any RemoteDBManageable
    
    init(remoteDBManager: any RemoteDBManageable) {
        self.encoder = JSONEncoder()
        self.remoteDBManager = remoteDBManager
    }
    
    func execute(report: Report) async throws {
        do {
            let requestData = ReportDTO(
                id: UUID(),
                createdAt: Date().convertDateToISO8601String(),
                reporterID: report.reporterID,
                reportedID: report.reportedID,
                reportOption: report.option,
                reportMessage: report.message
            )
            let data = try encoder.encode(requestData)
            try await remoteDBManager.insertData()
                .setTable(Environment.SupabaseTableName.reportlist)
                .setData(data)
                .request()
        } catch {
            SNMLogger.error("Report list insert error: \(error.localizedDescription)")
        }
    }
}
