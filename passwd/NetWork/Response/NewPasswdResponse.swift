//
//  NewPasswdResponse.swift
//  passwd
//
//  Created by Leslie D on 2024/2/20.
//

import Foundation

struct NewPasswdResponse: Codable {
    let success: Bool
    let code: Int
    let msg: String
    let data: Int? // 没什么具体含义，可以忽略。根据 success 判断是否成功
    let timestamp: Int64
}
