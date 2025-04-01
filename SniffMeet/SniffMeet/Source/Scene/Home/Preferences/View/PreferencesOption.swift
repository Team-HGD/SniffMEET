//
//  PreferencesOption.swift
//  SniffMeet
//
//  Created by 배현진 on 3/21/25.
//

struct PreferencesOption {
    let title: String
    let type: PreferencesType
}

struct PersonalInfoOption {
    let title: String
    let type: PersonalInfoType
}

enum PreferencesType {
    case personalInfo
    case notificationSetting
    case termsOfUse
    case logout
}

enum PersonalInfoType {
    case changePW
    case delectAccount
}
