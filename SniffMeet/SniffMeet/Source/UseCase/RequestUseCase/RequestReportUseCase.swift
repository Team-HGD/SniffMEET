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
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let remoteDatabaseManager: RemoteDatabaseManager

    init(session: URLSession = URLSession.shared, remoteDatabaseManager: RemoteDatabaseManager) {
        self.session = session
        self.remoteDatabaseManager = remoteDatabaseManager
    }

    func execute(report: Report) async throws {
        do {
            let requestData = ReportDTO(id: UUID(),
                                        createdAt: Date().convertDateToISO8601String(),
                                        reporterID: report.reporterID,
                                        reportedID: report.reportedID,
                                        reportOption: report.option,
                                        reportMessage: report.message)
            let data = try encoder.encode(requestData)
            try await remoteDatabaseManager.insertData(
                into: Environment.SupabaseTableName.reportlist,
                with: data
            )
        } catch {
            SNMLogger.error("Report list insert error: \(error.localizedDescription)")
        }
    }
}
