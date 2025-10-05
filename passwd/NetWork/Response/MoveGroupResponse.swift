//
//  MoveGroupResponse.swift
//  passwd
//
//  Created by EvanD on 2025/9/29.
//

import Foundation

struct MoveGroupResponse: Codable {
    let success: Bool
    let code: Int
    let msg: String
    let data: String?
    let timestamp: Int64
}
