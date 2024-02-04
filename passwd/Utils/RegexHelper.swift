//
//  RegexHelper.swift
//  passwd
//
//  Created by Leslie D on 2024/2/6.
//

import Foundation

struct RegexHelper {
    let regex: NSRegularExpression?
    
    init(_ pattern: String) {
        regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
    
    func match(input: String) -> Bool {
        if let matches = regex?.matches(in: input, options: .reportCompletion, range: NSRange(location: 0, length: input.count)) {
            return matches.count > 0
        } else {
            return false
        }
    }
}
