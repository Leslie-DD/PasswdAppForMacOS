//
//  RequestHelper.swift
//  passwd
//
//  Created by Leslie D on 2024/2/19.
//

import Foundation

class RequestHelper {
    
    static var token: String = ""
    static var userId: Int = -1
    static var secretKey: String = ""
    
    static func signup(params: [String: String], completion: @escaping (Result<SignupResponse, RequestError>) -> Void) {
        postRequest(params: params, uri: Constants.signup) { (result: Result<SignupResponse, RequestError>) in
            completion(result)
        }
    }
    
    static func loginByPasswd(params: [String: String], completion: @escaping (Result<PasswdResponse, RequestError>) -> Void) {
        postRequest(params: params, uri: Constants.loginByPasswordUrl) { (loginResult: Result<PasswdResponse, RequestError>) in
            switch loginResult {
            case .success(var passwdResponse) :
                let secretKey: String = params["secretKey"]!
                
                var decodedPasswds: [Passwd] = []
                for var passwd in passwdResponse.data.passwds {
                    passwd.title = AESUtil.shared.aesWrapper.decrypt2(withSecretKey: secretKey, cipherText: passwd.title) ?? "error"
                    if (!passwd.passwordString.isEmpty) {
                        passwd.passwordString = AESUtil.shared.aesWrapper.decrypt2(withSecretKey: secretKey, cipherText: passwd.passwordString) ?? "error"
                    }
                    if (!passwd.usernameString.isEmpty) {
                        passwd.usernameString = AESUtil.shared.aesWrapper.decrypt2(withSecretKey: secretKey, cipherText: passwd.usernameString) ?? "error"
                    }
                    decodedPasswds.append(passwd)
                }
                passwdResponse.data.passwds = decodedPasswds
                self.token = passwdResponse.data.token
                self.userId = passwdResponse.data.userId
                self.secretKey = secretKey
                completion(.success(passwdResponse))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func fetchGroups(completion: @escaping (Result<GroupResponse, RequestError>) -> Void) {
        postRequest(token: self.token, params: ["user_id": String(userId)], uri: Constants.groups) { (result: Result<GroupResponse, RequestError>) in
            completion(result)
        }
    }
    
    // Result<Int, RequestError>) Int 值是新建 group 成功的 group_id
    static func newGroup(params: [String: String], completion: @escaping (Result<Int, RequestError>) -> Void) {
        postRequest(token: self.token, params: params, uri: Constants.newGroup) { (result: Result<NewGroupResponse, RequestError>) in
            switch result {
            case .success(let newGroupResponse):
                if (newGroupResponse.success && newGroupResponse.data != nil) {
                    completion(.success(newGroupResponse.data!))
                } else {
                    completion(.failure(.requestFailed(newGroupResponse.msg)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Result<Int, RequestError>) Int 值可以忽略
    static func updateGroup(params: [String: String], completion: @escaping (Result<Int, RequestError>) -> Void) {
        postRequest(token: self.token, params: params, uri: Constants.updateGroup) { (result: Result<UpdateGroupResponse, RequestError>) in
            switch result {
            case .success(let updateGroupResponse):
                if (updateGroupResponse.success && updateGroupResponse.data != nil) {
                    completion(.success(updateGroupResponse.data!))
                } else {
                    completion(.failure(.requestFailed(updateGroupResponse.msg)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Result<Int, RequestError>) Int 值可以忽略
    static func deleteGroup(params: [String: String], completion: @escaping (Result<Int, RequestError>) -> Void) {
        postRequest(token: self.token, params: params, uri: Constants.deleteGroup) { (result: Result<DeleteGroupResponse, RequestError>) in
            switch result {
            case .success(let deleteGroupResponse):
                if (deleteGroupResponse.success && deleteGroupResponse.data != nil) {
                    completion(.success(deleteGroupResponse.data!))
                } else {
                    completion(.failure(.requestFailed(deleteGroupResponse.msg)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func newPasswd(params: [String: String], completion: @escaping (Result<Int, RequestError>) -> Void) {
        postRequest(token: self.token, params: params, uri: Constants.newPasswd) { (result: Result<NewPasswdResponse, RequestError>) in
            switch result {
            case .success(let newPasswdResponse):
                if (newPasswdResponse.success && newPasswdResponse.data != nil) {
                    completion(.success(newPasswdResponse.data!))
                } else {
                    completion(.failure(.requestFailed(newPasswdResponse.msg)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Result<Int, RequestError>) Int 值可以忽略
    static func updatePasswd(params: [String: String], completion: @escaping (Result<Int, RequestError>) -> Void) {
        postRequest(token: self.token, params: params, uri: Constants.updatePasswd) { (result: Result<UpdatePasswdResponse, RequestError>) in
            switch result {
            case .success(let updatePasswdResponse):
                if (updatePasswdResponse.success && updatePasswdResponse.data != nil) {
                    completion(.success(updatePasswdResponse.data!))
                } else {
                    completion(.failure(.requestFailed(updatePasswdResponse.msg)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func deletePasswd(params: [String: String], completion: @escaping (Result<Int, RequestError>) -> Void) {
        postRequest(token: self.token, params: params, uri: Constants.deletePasswd) { (result: Result<DeletePasswdResponse, RequestError>) in
            switch result {
            case .success(let deletePasswdResponse):
                if (deletePasswdResponse.success && deletePasswdResponse.data != nil) {
                    completion(.success(deletePasswdResponse.data!))
                } else {
                    completion(.failure(.requestFailed(deletePasswdResponse.msg)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func postRequest<T: Codable>(token: String? = nil, params: [String: String]? = nil, uri: String, completion: @escaping (Result<T, RequestError>) -> Void) {
        guard let url = URL(string: uri) else {
            print("Invalid URL: \(uri)")
            completion(.failure(.invalidURL("Invalid URL: \(uri)")))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        if (token != nil) {
            urlRequest.setValue(token, forHTTPHeaderField: "access_token")
        }
        
        if (params != nil) {
            if let params = params {
                let encodedParams = params.map { (key, value) in
                    let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    return "\(encodedKey)=\(encodedValue)"
                }
                
                let paramString = encodedParams.joined(separator: "&")
                urlRequest.httpBody = paramString.data(using: .utf8)
            }
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(.failure(.requestFailed("unknown error")))
            } else if let data = data {
                guard let jsonStr = String(data: data, encoding: .utf8) else {
                    print("Error_1: \(data)")
                    completion(.failure(.requestFailed("encoding .utf8 error")))
                    return
                }
                
                print("jsonStr: \(jsonStr)")
                if (jsonStr.isEmpty) {
                    print("No valid response")
                    completion(.failure(.requestFailed("No valid response")))
                    return
                }
                guard let jsonData = jsonStr.data(using: .utf8) else {
                    print("Error_2: \(data)")
                    completion(.failure(.requestFailed(".data encoding .utf8 error")))
                    return
                }
                
                do {
                    let responseObject = try JSONDecoder().decode(T.self, from: jsonData)
                    completion(.success(responseObject))
                } catch {
                    print("Error_4 decoding error: \(error)")
                    completion(.failure(.requestFailed("Error: decoding error")))
                }
            }
        }

        task.resume()
    }
}
