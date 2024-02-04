//
//  LoginInfo.swift
//  passwd
//
//  Created by Leslie D on 2024/2/18.
//

import Foundation
import SwiftData

@Model
class UserInfo {
    @Attribute(.unique) var username: String
    var password: String?
    var secretKey: String?
    var ip: String?
    var host: Int?
    var updateTime: Int64
    var autoLogin: Bool
    
    init(username: String) {
        self.username = username
        self.password = nil
        self.secretKey = nil
        self.ip = nil
        self.host = nil
        self.updateTime = LoginInfoCheck.currentTimeStamp
        self.autoLogin = false
    }
    
    init(username: String, password: String?) {
        self.username = username
        self.password = password
        self.secretKey = nil
        self.ip = nil
        self.host = nil
        self.updateTime = LoginInfoCheck.currentTimeStamp
        self.autoLogin = false
    }
    
    init(username: String, password: String?, secretKey: String?) {
        self.username = username
        self.password = password
        self.secretKey = secretKey
        self.ip = nil
        self.host = nil
        self.updateTime = LoginInfoCheck.currentTimeStamp
        self.autoLogin = false
    }
    
    init(username: String, password: String?, secretKey: String?, ip: String?, host: Int?) {
        self.username = username
        self.password = password
        self.secretKey = secretKey
        self.ip = ip
        self.host = host
        self.updateTime = LoginInfoCheck.currentTimeStamp
        self.autoLogin = false
    }
    
    init(username: String, password: String?, secretKey: String?, ip: String?, host: Int?, autoLogin: Bool) {
        self.username = username
        self.password = password
        self.secretKey = secretKey
        self.ip = ip
        self.host = host
        self.updateTime = LoginInfoCheck.currentTimeStamp
        self.autoLogin = true
    }
    
}
