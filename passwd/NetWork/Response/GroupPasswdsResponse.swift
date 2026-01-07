//
//  GroupPasswdsResponse.swift
//  passwd
//
//  Created by EvanD on 2026/1/7.
//

struct GroupPasswdsResponse: Codable {
    let success: Bool
    let code: Int
    let msg: String
    let data: PasswdsData
    let timestamp: Int64
}

struct PasswdsData: Codable {
    var passwds: [Passwd]
}


