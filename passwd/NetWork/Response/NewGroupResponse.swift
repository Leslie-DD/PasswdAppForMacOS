//
//  NewGroupResponse.swift
//  passwd
//
//  Created by Leslie D on 2024/2/19.
//

import Foundation

struct NewGroupResponse: Codable {
    let success: Bool
    let code: Int
    let msg: String
    let data: Int? // 新建 group 的 id
    let timestamp: Int64
}
