//
//  MovePasswdResponse.swift
//  passwd
//
//  Created by EvanD on 2026/1/6.
//

import Foundation

struct MovePasswdResponse: Codable {
    let success: Bool
    let code: Int
    let msg: String
    let data: String?
    let timestamp: Int64
}