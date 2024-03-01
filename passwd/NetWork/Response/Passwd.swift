//
//  Passwd.swift
//  passwd
//
//  Created by Leslie D on 2024/2/5.
//

import Foundation

struct UpdateTime: Codable {
    let date: Int
    let day: Int
    let hours: Int
    let minutes: Int
    let month: Int
    let nanos: Int
    let seconds: Int
    let time: Int
    let timezoneOffset: Int
    let year: Int
}

struct Passwd: Identifiable, Codable {
    
    init(title: String) {
        self.id = -1
        self.userId = -1
        self.groupId = -1
        self.title = title
        self.usernameString = "nil"
        self.passwordString = "nil"
        self.link = "nil"
        self.comment = "nil"
        self.updateTime = nil
        self.updateTimeExpose = -1
    }
    
    init(id:Int, userId: Int, groupId: Int, title: String, usernameString: String, passwordString: String, link: String, comment: String) {
        self.id = id
        self.userId = userId
        self.groupId = groupId
        self.title = title
        self.usernameString = usernameString
        self.passwordString = passwordString
        self.link = link
        self.comment = comment
        self.updateTime = nil
        self.updateTimeExpose = -1
    }
    
    let comment: String
    let groupId: Int
    let id: Int
    let link: String
    var passwordString: String
    var title: String
    let updateTime: UpdateTime?
    let updateTimeExpose: Int
    let userId: Int
    var usernameString: String
}

struct PasswdData: Codable {
    let userId: Int
    let username: String
    let token: String
    var passwds: [Passwd]
    
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username
        case token
        case passwds
    }
}

struct PasswdResponse: Codable {
    let success: Bool
    let code: Int
    let msg: String
    var data: PasswdData
    let timestamp: Int
}
