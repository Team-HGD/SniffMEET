//
//  ConvertToWalkAPSUsecase.swift
//  SniffMeet
//
//  Created by sole on 11/28/24.
//

import Foundation

protocol ConvertToWalkAPSUsecase {
    func execute(walkAPSUserInfo: [AnyHashable: Any]) -> WalkAPSDTO?
}

struct ConvertToWalkAPSUsecaseImpl: ConvertToWalkAPSUsecase {
    private let jsonDecoder: JSONDecoder

    init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
    }

    func execute(walkAPSUserInfo: [AnyHashable : Any]) -> WalkAPSDTO? {
        try? AnyJSONSerializable(
            value: walkAPSUserInfo,
            jsonDecoder: jsonDecoder
        )?.decode(type: WalkAPSDTO.self)
    }
}
