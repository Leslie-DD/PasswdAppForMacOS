//
//  LoginInfoCheck.swift
//  passwd
//
//  Created by Leslie D on 2024/2/18.
//

import Foundation

class LoginInfoCheck {
    static let shared = LoginInfoCheck()
    
    func isUsernameValid(username: String?, checkSpace: Bool = true) -> Bool {
        guard username != nil else {
            print("username: \(username ?? "nil") invalid")
            return false
        }
        if (checkSpace) {
            guard !username!.contains(" ") else {
                print("username: \(username ?? "nil") contains empty space")
                return false
            }
        }
        
        print("username.count: \(username!.count)")
        return username!.count <= 16 && username!.count > 0
    }
    
    func isPasswordValid(password: String?) -> Bool {
        guard password != nil else {
            print("password: \(password ?? "nil") invalid")
            return false
        }
        guard !password!.contains(" ") else {
            print("password: \(password ?? "nil") contains empty space")
            return false
        }
        
        print("password.count: \(password!.count)")
        return password!.count <= 16 && password!.count > 0
    }
    
    func isSecretKeyValid(secretKey: String?) -> Bool {
        guard secretKey != nil else {
            print("secretKey: \(secretKey ?? "nil") invalid")
            return false
        }
        guard !secretKey!.contains(" ") else {
            print("secretKey: \(secretKey ?? "nil") contains empty space")
            return false
        }
        
        print("secretKey.count: \(secretKey!.count)")
//        return secretKey!.count > 0
        return true
    }
    
    func isIpAddressValid(ipAddress: String?) -> Bool {
        guard ipAddress != nil else {
            print("ipAddress: \(ipAddress ?? "nil") invalid")
            return false
        }
        let parts = ipAddress!.split(separator: ".")
        guard parts.count == 4 else {
            print("ipAddress: \(ipAddress ?? "nil") count != 4")
            return false
        }
        for part in parts {
            guard let intPart = Int(part), intPart >= 0, intPart <= 255 else {
                print("ipAddress: \(ipAddress ?? "nil") invalid")
                return false
            }
        }
        print("ipAddress: \(ipAddress ?? "nil") valid")
        return true
    }
    
    func isValidIpAddress(ipAddress: String) -> Bool {
        let parts = ipAddress.split(separator: ".")
        guard parts.count <= 4 else { return false }
        for part in parts {
            guard let intPart = Int(part), intPart >= 0, intPart <= 255 else { return false }
        }
        return true
    }
    
    func isValidHost(hostStr: String) -> Bool {
        guard Int(hostStr) != nil else {
            print("hostStr: \(hostStr) invalid")
            return false
        }
        
        print("hostStr: \(hostStr) valid")
        return true
    }
    
    static var currentTimeStamp: Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
