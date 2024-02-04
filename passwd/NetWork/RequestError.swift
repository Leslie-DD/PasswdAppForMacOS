//
//  RequestError.swift
//  passwd
//
//  Created by Leslie D on 2024/2/18.
//

import Foundation

enum RequestError: Error {
    case invalidURL(String)
    case requestFailed(String)
}
