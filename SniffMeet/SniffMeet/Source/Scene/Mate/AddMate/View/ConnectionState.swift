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
            return "연결 성공, 프로필 드랍 시도하세요"
        case .successMPCSession:
            return "프로필 전송 버튼을 눌러 프로필을 공유해보세요"
        case .failure:
            return "연결 실패, 다시 시도하세요"
        }
    }
}
