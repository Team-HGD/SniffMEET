//
//  ConnectionState.swift
//  SniffMeet
//
//  Created by 배현진 on 2/11/25.
//

enum ConnectionState {
    case connecting
    case success
    case failure

    var description: String {
        switch self {
        case .connecting:
            return "연결 중입니다."
        case .success:
            return "연결 성공, 프로필 드랍 시도하세요"
        case .failure:
            return "연결 실패, 다시 시도하세요"
        }
    }
}
