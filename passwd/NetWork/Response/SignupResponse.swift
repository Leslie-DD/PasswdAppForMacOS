//
//  SignupResponse.swift
//  passwd
//
//  Created by Leslie D on 2024/2/19.
//

import Foundation

struct SignupData: Codable {
    let userId: Int
    let token: String
    let secretKey: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case token
        case secretKey = "secret_key"
    }
}

struct SignupResponse: Codable {
    let success: Bool
    let code: Int
    let msg: String
    let data: SignupData?
    let timestamp: Int64
}
