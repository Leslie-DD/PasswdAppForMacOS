//
//  AESUtil.swift
//  passwd
//
//  Created by Leslie D on 2024/2/19.
//

import Foundation

class AESUtil {
    
    var aesWrapper: AESWrapper
    
    static var shared = AESUtil()
    
    init() {
        print("aes.initailize")
        aesWrapper = AESWrapper()
        aesWrapper.initialize()
    }
    
    static func updateAES() {
        shared = AESUtil()
    }
    
}
