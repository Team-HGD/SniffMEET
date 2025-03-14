//
//  SaveWalkLogUsecase.swift
//  SniffMeet
//
//  Created by sole on 2/26/25.
//

import Foundation

protocol SaveWalkLogUsecase {
    func execute(walkLog: WalkLog) throws
}

struct SaveWalkLogUsecaseImpl: SaveWalkLogUsecase {
    private let jsonEncoder: JSONEncoder
    private let fileManager: any FileManagable

    init(
        jsonEncoder: JSONEncoder = JSONEncoder(),
        fileManager: any FileManagable
    ) {
        self.jsonEncoder = jsonEncoder
        self.fileManager = fileManager
    }

    func execute(walkLog: WalkLog) throws {
        let timestamp = walkLog.endDate.convertDateToISO8601String() // 저장한 시각
        do {
            let walkLogData = try jsonEncoder.encode(walkLog)
            try fileManager.set(
                value: walkLogData,
                forKey: "\(Environment.FileManagerKey.walkLog)/\(timestamp)"
            )
        } catch {
            throw SNMError(level: .notifyUser, error: error)
        }
    }
}
