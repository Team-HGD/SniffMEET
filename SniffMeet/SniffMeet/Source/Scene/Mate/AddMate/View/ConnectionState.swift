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
    case cannotFindPeer

    var description: String {
        switch self {
        case .connecting:
            return "연결 중입니다."
        case .successNISession:
            return "연결 성공, 서로 기기를 위와 같이 움직여보세요."
        case .successMPCSession:
            return "연결 성공, 친구가 프로필을 보내고 있어요."
        case .failure:
            return "연결 실패, 다시 시도해보세요!"
        case .cannotFindPeer:
            return "주위 산책 친구를 찾을 수 없어요. 다시 시도해보세요!"
        }
    }
}
