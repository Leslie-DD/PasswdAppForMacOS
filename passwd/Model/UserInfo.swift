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
    var domain: String?
    var ip: String?
    var host: Int?
    var updateTime: Int64
    var autoLogin: Bool
    
    init(username: String) {
        self.username = username
        self.password = nil
        self.secretKey = nil
        self.domain = nil
        self.ip = nil
        self.host = nil
        self.updateTime = InfoChecker.currentTimeStamp
        self.autoLogin = false
    }
    
    init(username: String, password: String?) {
        self.username = username
        self.password = password
        self.secretKey = nil
        self.domain = nil
        self.ip = nil
        self.host = nil
        self.updateTime = InfoChecker.currentTimeStamp
        self.autoLogin = false
    }
    
    init(username: String, password: String?, secretKey: String?) {
        self.username = username
        self.password = password
        self.secretKey = secretKey
        self.domain = nil
        self.ip = nil
        self.host = nil
        self.updateTime = InfoChecker.currentTimeStamp
        self.autoLogin = false
    }
    
    init(username: String, password: String?, secretKey: String?, ip: String?, host: Int?) {
        self.username = username
        self.password = password
        self.secretKey = secretKey
        self.domain = nil
        self.ip = ip
        self.host = host
        self.updateTime = InfoChecker.currentTimeStamp
        self.autoLogin = false
    }
    
    init(username: String, password: String?, secretKey: String?, ip: String?, host: Int?, autoLogin: Bool) {
        self.username = username
        self.password = password
        self.secretKey = secretKey
        self.domain = nil
        self.ip = ip
        self.host = host
        self.updateTime = InfoChecker.currentTimeStamp
        self.autoLogin = true
    }
    
    init(username: String, password: String?, secretKey: String?, domain: String?, ip: String?, host: Int?) {
        self.username = username
        self.password = password
        self.secretKey = secretKey
        self.domain = domain
        self.ip = ip
        self.host = host
        self.updateTime = InfoChecker.currentTimeStamp
        self.autoLogin = false
    }
    
    init(username: String, password: String?, secretKey: String?, domain: String?, ip: String?, host: Int?, autoLogin: Bool) {
        self.username = username
        self.password = password
        self.secretKey = secretKey
        self.domain = domain
        self.ip = ip
        self.host = host
        self.updateTime = InfoChecker.currentTimeStamp
        self.autoLogin = true
    }
    
    init(username: String, password: String?, secretKey: String?, domain: String?) {
        self.username = username
        self.password = password
        self.secretKey = secretKey
        self.domain = domain
        self.ip = nil
        self.host = nil
        self.updateTime = InfoChecker.currentTimeStamp
        self.autoLogin = false
    }
    
    init(username: String, password: String?, secretKey: String?, domain: String?, autoLogin: Bool) {
        self.username = username
        self.password = password
        self.secretKey = secretKey
        self.domain = domain
        self.ip = nil
        self.host = nil
        self.updateTime = InfoChecker.currentTimeStamp
        self.autoLogin = true
    }
    
}
