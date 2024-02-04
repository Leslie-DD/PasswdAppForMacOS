//
//  Constants.swift
//  passwd
//
//  Created by Leslie D on 2024/2/5.
//

import Foundation

class Constants {
    
    static var ip_host = ""
    
    static var baseUrl: String {
        ip_host + "/Passwd/"
    }
    
    static var loginByPasswordUrl : String {
        baseUrl + "passwd/loginByPassword.do?"
    }
    
    static var groups : String {
        baseUrl + "passwd/groups.do?"
    }
    
    static var signup : String {
        baseUrl + "passwd/register.do?"
    }
    
    static var newGroup: String {
        baseUrl + "passwd/newGroup.do?"
    }
    
    static var updateGroup: String {
        baseUrl + "passwd/updateGroup.do?"
    }
    
    static var deleteGroup: String {
        baseUrl + "passwd/deleteGroupById.do?"
    }
    
    static var newPasswd: String {
        baseUrl + "passwd/newPasswd.do?"
    }
    
    static var updatePasswd: String {
        baseUrl + "passwd/updatePasswd.do?"
    }
    
    static var deletePasswd: String {
        baseUrl + "passwd/deletePasswdById.do?"
    }
    
    static func initIpHost(ipHost: String) {
        ip_host = "http://" + ipHost
    }
}
