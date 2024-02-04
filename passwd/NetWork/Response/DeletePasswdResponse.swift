//
//  DeletePasswdResponse.swift
//  passwd
//
//  Created by Leslie D on 2024/2/20.
//

import Foundation

struct DeletePasswdResponse: Codable {
    let success: Bool
    let code: Int
    let msg: String
    let data: Int? // passwd id
    let timestamp: Int64
}
