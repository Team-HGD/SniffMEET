//
//  ConnectionState.swift
//  SniffMeet
//
//  Created by 배현진 on 2/11/25.
//

enum ConnectionState {
    case connecting
    case successNISession
    case successMPCSession
    case failure

    var description: String {
        switch self {
        case .connecting:
            return "연결 중입니다."
        case .successNISession:
            return "연결 성공, 서로 기기를 위와 같이 움직여보세요."
        case .successMPCSession:
            return "연결 성공, 친구가 프로필을 보내고 있어요."
        case .failure:
            return "연결 실패, 다시 시도하세요"
        }
    }
}
