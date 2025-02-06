//
//  RespondWalkRequestUseCase.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/20/24.
//
import Foundation

protocol RespondWalkRequestUseCase {
    func execute(requestID: UUID, walkNoti: WalkNotiDTO) async throws
}

struct RespondWalkRequestUseCaseImpl: RespondWalkRequestUseCase {
    private let remoteDBManager: any RemoteDBManageable
    private let session: URLSession
    private let encoder = JSONEncoder()
    
    init(session: URLSession = URLSession.shared, remoteDBManager: RemoteDBManageable) {
        self.session = session
        self.remoteDBManager = remoteDBManager
    }
    
    func execute(requestID: UUID, walkNoti: WalkNotiDTO) async throws {
        guard let requestData = try? encoder.encode(walkNoti) else { return }
        let request = try PushNotificationRequest.sendWalkRespond(data: requestData).urlRequest()
        let _ = try await session.data(for: request)

        // MARK: - walk-request 테이블 업데이트
        var tableData: WalkRequestUpdateDTO?
        switch walkNoti.category {
        case .walkAccepted:
            tableData = WalkRequestUpdateDTO(state: .accepted)
        case .walkDeclined:
            tableData = WalkRequestUpdateDTO(state: .declined)
        default:
            break
        }
        guard let tableData else { return }
        let data = try JSONEncoder().encode(tableData)
        Task {
            try await remoteDBManager.updateData()
                .setTable(Environment.SupabaseTableName.walkRequest)
                .setData(data)
                .setQuery(.equal("id", requestID))
                .request()
        }
    }
}
