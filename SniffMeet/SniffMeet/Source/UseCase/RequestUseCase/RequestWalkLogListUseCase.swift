//
//  RequestWalkLogListUseCase.swift
//  SniffMeet
//
//  Created by sole on 2/26/25.
//

import Foundation

protocol RequestWalkLogListUseCase {
    func execute() throws -> [WalkLog]
}

struct RequestWalkLogListUseCaseImpl: RequestWalkLogListUseCase {
    private let fileManager: any FileManagable
    private let jsonDecoder: JSONDecoder

    init(
        fileManager: any FileManagable,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.jsonDecoder = jsonDecoder
        self.fileManager = fileManager
    }

    func execute() throws -> [WalkLog] {
        try fileManager.getAll(directoryPath: Environment.FileManagerKey.walkLog)
            .compactMap { try? jsonDecoder.decode(WalkLog.self, from: $0) }
            .sorted{ $0.endDate > $1.endDate } // 최신순 정렬
    }
}
