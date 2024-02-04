//
//  Group.swift
//  passwd
//
//  Created by Leslie D on 2024/2/6.
//

import Foundation

struct Group: Identifiable, Codable {
    let id: Int
    let userId: Int
    var groupName: String
    var groupComment: String?
}

struct GroupResponse: Codable {
    let success: Bool
    let code: Int
    let msg: String
    let data: [Group]
    let timestamp: Int64
}
