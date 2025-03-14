//
//  DogDTO.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/14/24.
//
import Foundation

struct UserInfo {
    let name: String
    let age: UInt8
    let sex: Sex
    let sexUponIntake: Bool
    let size: Size
    let keywords: [Keyword]
}

struct ProfileInfo: Codable {
    let name: String
    let age: UInt8
    let sex: Sex
    let sexUponIntake: Bool
    let size: Size
    let keywords: [Keyword]
    let nickname: String
    var profileImageName: String?
}

extension ProfileInfo {
    static let example = ProfileInfo(
        name: "후추",
        age: 6,
        sex: .female,
        sexUponIntake: true,
        size: .medium,
        keywords: [.shy],
        nickname: "pear",
        profileImageName: nil
    )
}

extension UserInfo {
    static let example = UserInfo(
        name: "후추",
        age: 6,
        sex: .female,
        sexUponIntake: true,
        size: .medium,
        keywords: [.shy]
    )
}
