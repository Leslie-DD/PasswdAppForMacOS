//
//  DataModel.swift
//  passwd
//
//  Created by Leslie D on 2024/2/5.
//

import Foundation
import Combine
import SwiftUI
import SwiftData

class DataModel: ObservableObject {
    
    private var secretKey: String?
    private var token: String?
    var userId: Int = -1
    
    var groupsPasswdsMap: [Int: [Passwd]] = [:]
    
    @Published var groups: [Group] = []
    @Published var currentGroup: Group?
    @Published var currentGroupId: Int = -1
    @Published var currentPasswds: [Passwd] = []
    @Published var currentPasswd: Passwd?
    @Published var currentPasswdId: Int = -1
    
    @Published var title: String = ""
    @Published var usernameString: String = ""
    @Published var passwordString: String = ""
    @Published var link: String = ""
    @Published var comment: String = ""
    
    var passwdsMap: [Int: Passwd] = [:]
    var groupsMap: [Int: Group] =  [:]
    
    
    @Published var searchText: String = ""
    var textDidChange: AnyCancellable? = nil
    
    @Published var currentScreen: ScreenType = .Loading
    
    @Published var loadingAlert = false
    
    
    @Published var loginUsername: String = ""
    @Published var loginPassword: String = ""
    @Published var loginSecretKey: String = ""
    @Published var loginDomain: String = ""
    @Published var loginIpAddress: String = "0.0.0.0"
    @Published var loginHost: String = "8080"
    
    @Published var rememberUsernameStatusOn: Bool = false
    @Published var rememberPasswordStatusOn: Bool = false
    @Published var rememberSecretKeyStatusOn: Bool = false
    @Published var rememberAddressStatusOn: Bool = false
    
        
    func clearData() {
        self.passwdsMap = [:]
        self.groupsPasswdsMap = [:]
        self.groups = []
        self.currentGroup = nil
        self.currentGroupId = -1
        self.currentPasswds = []
        self.title = ""
        self.usernameString = ""
        self.passwordString = ""
        self.link = ""
        self.comment = ""
        self.groupsMap = [:]
        
        AESUtil.updateAES()
    }
    
    init() {
        var lastSearchStr: String = ""
        textDidChange = $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { str in
                if (str.isEmpty) {
                    if (!lastSearchStr.isEmpty) {
                        DispatchQueue.main.async {
                            self.currentPasswds = []
                            self.updateCurrentPasswd(passwd: nil)
                        }
                        lastSearchStr = ""
                        return
                    } else {
                        return
                    }
                } else {
                    if (!lastSearchStr.isEmpty && lastSearchStr == str) {
                        print("lastSearchStr == str, won't update")
                        return
                    }
                }
                
                var searchResult: [Passwd] = []
                
                print("sink: \(str)")
            
                let pattern = "^.*(?i)\(str).*"
                let matcher = RegexHelper(pattern)

                for passwdKeyValue in self.passwdsMap {
                    let passwd = passwdKeyValue.value
                    
                    let title = passwd.title
                    if matcher.match(input: title) {
                        searchResult.append(passwd)
                        continue
                    }
                    
                    let usernameString = passwd.usernameString
                    if matcher.match(input: usernameString) {
                        searchResult.append(passwd)
                        continue
                    }
                }
                
                lastSearchStr = str
                DispatchQueue.main.async {
                    self.currentGroup = nil
                    self.currentPasswds = self.sortedPasswds(searchResult)
                    self.updateCurrentPasswd(passwd: self.currentPasswds.first)
                }
            }
    }
    
    func signup(username: String, password: String, domain: String, ip: String, host: String, completion: @escaping (Result<String, RequestError>) -> Void) {
        print("signup")
        clearData()
        Constants.initRequestAddress(domain: domain, ipHost: ip + ":\(host)")
        
        RequestHelper.signup(params: ["username": username, "password": password]) { result in
            switch result {
            case .success(let signupResponse):
                guard signupResponse.data != nil else {
                    print("Error_No_SignupData")
                    completion(.failure(.requestFailed(signupResponse.msg)))
                    return
                }
                
                DispatchQueue.main.async {
                    self.secretKey = signupResponse.data?.secretKey
                    self.token = signupResponse.data?.token
                    self.userId = signupResponse.data?.userId ?? -1
                    completion(.success(signupResponse.data?.secretKey ?? ""))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loginByPasswd(username: String, password: String, secretKey: String, domain: String, ip: String, host: Int, completion: @escaping (Result<String, RequestError>) -> Void) {
        print("loginByPasswd")
        clearData()
        Constants.initRequestAddress(domain: domain, ipHost: ip + ":\(host)")
 
        let parameters = ["username": username, "password": password, "secretKey": secretKey]
        
        RequestHelper.loginByPasswd(params: parameters) { loginResult in
            switch loginResult {
            case .success(let passwdResponse):
                let decodedPasswds = passwdResponse.data.passwds
                for passwd in decodedPasswds {
                    self.passwdsMap[passwd.id] = passwd
                }
                
                self.secretKey = secretKey
                self.token = passwdResponse.data.token
                self.userId = passwdResponse.data.userId
                
                self.fetchGroups(userId: self.userId, token: self.token) { result in
                    print("login result: \(result)")
                    completion(result)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchGroups(userId: Int, token: String?, completion: @escaping (Result<String, RequestError>) -> Void) {
        print("fetchGroups")
        for passwd in self.passwdsMap {
            self.groupsPasswdsMap[passwd.value.groupId] = nil
        }
        RequestHelper.fetchGroups { result in
            switch result {
            case .success(let groupResponse):
                var groups: [Group] = []
                var groupsMap: [Int: Group] = [:]
                
                for passwd in self.passwdsMap {
                    if (self.groupsPasswdsMap[passwd.value.groupId] == nil) {
                        self.groupsPasswdsMap[passwd.value.groupId] = []
                    }
                    self.groupsPasswdsMap[passwd.value.groupId]?.append(passwd.value)
                }
                
                for passwds in self.groupsPasswdsMap {
                    var tempPasswds: [Passwd] = []
                    passwds.value.forEach { p in
                        tempPasswds.append(p)
                    }
                    tempPasswds.sort { $0.title.localizedCompare($1.title) == .orderedAscending }
                    self.groupsPasswdsMap[passwds.key] = tempPasswds
                }
                
                for group in groupResponse.data {
                    groups.append(group)
                    groupsMap[group.id] = group
                    if (self.groupsPasswdsMap[group.id] == nil) {
                        self.groupsPasswdsMap[group.id] = []
                    }
                }
                
                // 使用sortOrder排序，如果sortOrder为nil则按名称排序
                groups.sort { group1, group2 in
                    if let sortOrder1 = group1.sortOrder, let sortOrder2 = group2.sortOrder {
                        return sortOrder1 < sortOrder2
                    } else if group1.sortOrder != nil {
                        return true
                    } else if group2.sortOrder != nil {
                        return false
                    } else {
                        return group1.groupName.localizedCompare(group2.groupName) == .orderedAscending
                    }
                }
                                
                DispatchQueue.main.async {
                    self.groups = groups
                    self.groupsMap = groupsMap
                    
                    if let currentGroup = self.currentGroup,
                       groups.contains(where: { $0.id == currentGroup.id }) {
                        if let updatedGroup = groups.first(where: { $0.id == currentGroup.id }) {
                            self.currentGroup = updatedGroup
                        }
                    } else if !groups.isEmpty {
                        self.currentGroup = groups.first
                    } else {
                        self.currentGroup = nil
                    }
                    
                    self.currentGroupId = self.currentGroup?.id ?? -1
                    if (self.currentGroup != nil) {
                        self.currentPasswds = self.sortedPasswds(self.groupsPasswdsMap[self.currentGroup?.id ?? -1] ?? [])
                    } else {
                        self.currentPasswds = []
                    }
                    if (self.currentPasswds.isEmpty) {
                        self.updateCurrentPasswd(passwd: nil)
                    } else {
                        self.updateCurrentPasswd(passwd: self.currentPasswds.first)
                    }
                    
                    completion(.success("success!"))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func newGroup(groupName: String, groupComment: String, completion: @escaping (Result<Group, RequestError>) -> Void) {
        RequestHelper.newGroup(params: ["user_id": String(self.userId), "group_name": groupName, "group_comment": groupComment]) { result in
            switch result {
            case .success(let groupId):
                DispatchQueue.main.async {
                    let newGroup = Group(id: groupId, userId: self.userId, groupName: groupName, groupComment: "", sortOrder: nil)
                    self.groups.append(newGroup)
                    self.groupsMap[newGroup.id] = newGroup
                    self.onGroupClick(groupId: newGroup.id)
                    completion(.success(newGroup))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateGroup(groupId: Int, groupName: String, groupComment: String, completion: @escaping (Result<Group, RequestError>) -> Void) {
        print("updateGroup, groupId: \(groupId)")
        RequestHelper.updateGroup(params: ["user_id": String(self.userId), "id": String(groupId), "group_name": groupName, "group_comment": groupComment]) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    var updateGroup = self.groupsMap[groupId]
                    if (updateGroup == nil) {
                        print("There's no such group(\(groupId)) in local.")
                        completion(.failure(.requestFailed("There's no such group(\(groupId) in local.")))
                    } else {
                        updateGroup?.groupName = groupName
                        updateGroup?.groupComment = groupComment
                        self.groupsMap[groupId] = updateGroup
                        
                        var targetIndex = -1
                        for index in self.groups.indices {
                            if (self.groups[index].id == updateGroup!.id) {
                                targetIndex = index
                                break
                            }
                        }
                        if (targetIndex != -1) {
                            self.groups[targetIndex] = updateGroup!
                        }
                        
                        if (self.currentGroup?.id == updateGroup!.id) {
                            self.onGroupClick(groupId: updateGroup!.id)
                        }
                        
                        completion(.success(updateGroup!))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteGroup(groupId: Int, completion: @escaping (Result<Group, RequestError>) -> Void) {
        print("deleteGroup, groupId: \(groupId)")
        RequestHelper.deleteGroup(params: ["user_id": String(self.userId), "group_id": String(groupId)]) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    let deleteGroup = self.groupsMap[groupId]
                    if (deleteGroup == nil) {
                        print("There's no such group(\(groupId)) in local.")
                        completion(.failure(.requestFailed("There's no such group(\(groupId) in local.")))
                    } else {
                        self.groupsMap[groupId] = nil
                        
                        var targetIndex = -1
                        for index in self.groups.indices {
                            if (self.groups[index].id == deleteGroup!.id) {
                                targetIndex = index
                                break
                            }
                        }
                        if (targetIndex != -1) {
                            self.groups.remove(at: targetIndex)
                        }
                        
                        if (self.currentGroup?.id == deleteGroup!.id) {
                            self.currentGroup = nil
                            self.currentGroupId = -1
                        }
                        completion(.success(deleteGroup!))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func moveGroup(groupId: Int, afterGroupId: Int?, completion: @escaping (Result<String, RequestError>) -> Void) {
        var params: [String: String] = [
            "group_id": String(groupId),
            "user_id": String(self.userId)
        ]
        
        if let afterGroupId = afterGroupId {
            if afterGroupId == -1 {
                // 移动到末尾
                params["after_group_id"] = "last"
            } else {
                params["after_group_id"] = String(afterGroupId)
            }
        }
        
        RequestHelper.moveGroup(params: params) { result in
            switch result {
            case .success(_):
                // 移动成功后重新获取groups列表以更新排序
                self.fetchGroups(userId: self.userId, token: RequestHelper.token) { fetchResult in
                    switch fetchResult {
                    case .success(_):
                        completion(.success("Group移动成功"))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func newPasswd(passwd: Passwd, completion: @escaping (Result<Passwd, RequestError>) -> Void) {
        print("newPasswd, passwdId: \(passwd.id), title: \(passwd.title), usernameString: \(passwd.usernameString), passwordString: \(passwd.passwordString)")
        
        let params = [
            "user_id": String(self.userId),
            "group_id": String(passwd.groupId),
            "title": AESUtil.shared.aesWrapper.encrypt(withSecretKey: secretKey, plainText: passwd.title) ?? "",
            "username_string": AESUtil.shared.aesWrapper.encrypt(withSecretKey: secretKey, plainText: passwd.usernameString) ?? "",
            "password_string": AESUtil.shared.aesWrapper.encrypt(withSecretKey: secretKey, plainText: passwd.passwordString) ?? "",
            "link": passwd.link,
            "comment": passwd.comment,
            "secret_key": self.secretKey ?? ""
        ]
        
        print("newPasswd: \(params)")
        RequestHelper.newPasswd(params: params) { result in
            switch result {
            case .success(let passwdId):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    let newPasswd = Passwd(id: passwdId, userId: self.userId, groupId: passwd.groupId, title: passwd.title, usernameString: passwd.usernameString, passwordString: passwd.passwordString, link: passwd.link, comment: passwd.comment)
                    
                    self.passwdsMap[passwdId] = newPasswd
                    
                    var groupPasswds: [Passwd]? = self.groupsPasswdsMap[passwd.groupId]
                    if (groupPasswds == nil) {
                        groupPasswds = []
                        groupPasswds?.append(newPasswd)
                        self.groupsPasswdsMap[passwd.groupId] = groupPasswds
                        self.onGroupClick(groupId: newPasswd.groupId)
                    } else {
                        groupPasswds?.append(newPasswd)
                        self.groupsPasswdsMap[newPasswd.groupId] = groupPasswds!
                        self.onGroupClick(groupId: newPasswd.groupId)
                        self.onPasswdClick(passwdId: passwdId)
                    }
                    
                    completion(.success(newPasswd))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updatePasswd(passwd: Passwd, completion: @escaping (Result<Passwd, RequestError>) -> Void) {
        print("updatePasswd, passwdId: \(passwd.id), title: \(passwd.title), usernameString: \(passwd.usernameString), passwordString: \(passwd.passwordString)")
        
//        let originTitle = AESUtil.shared.aesWrapper.encrypt(withSecretKey: secretKey, plainText: passwd.title) ?? ""
//        let encodeTitle = originTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let params = [
            "user_id": String(self.userId),
            "id": String(passwd.id),
            "title": AESUtil.shared.aesWrapper.encrypt(withSecretKey: secretKey, plainText: passwd.title) ?? "",
            "username_string": AESUtil.shared.aesWrapper.encrypt(withSecretKey: secretKey, plainText: passwd.usernameString) ?? "",
            "password_string": AESUtil.shared.aesWrapper.encrypt(withSecretKey: secretKey, plainText: passwd.passwordString) ?? "",
            "link": passwd.link, 
            "comment": passwd.comment,
            "secret_key": self.secretKey ?? ""
        ]
        
        print("updatePasswd: \(params)")
        RequestHelper.updatePasswd(params: params) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.passwdsMap[passwd.id] = passwd
                    
                    var groupPasswds = self.groupsPasswdsMap[passwd.groupId]
                    if (groupPasswds == nil) {
                        completion(.failure(.requestFailed("groupPasswds")))
                        return
                    }
                    
                    var targetIndex = -1
                    for index in groupPasswds!.indices {
                        if (groupPasswds![index].id == passwd.id) {
                            targetIndex = index
                            break
                        }
                    }
                    if (targetIndex != -1) {
                        groupPasswds?[targetIndex] = passwd
                    }
                    
                    self.groupsPasswdsMap[passwd.groupId] = groupPasswds
                    self.currentPasswds = groupPasswds!
                    
                    completion(.success(passwd))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deletePasswd(passwd: Passwd, completion: @escaping (Result<Passwd, RequestError>) -> Void) {
        print("deletePasswd. passwdId: \(passwd.id), title: \(passwd.title)")
        let params = ["user_id": String(self.userId), "id": String(passwd.id)]
        
        RequestHelper.deletePasswd(params: params) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.passwdsMap[passwd.id] = nil
                    
                    var groupPasswds: [Passwd]? = self.groupsPasswdsMap[passwd.groupId]
                    if (groupPasswds == nil) {
                        completion(.failure(.requestFailed("No such groupPasswds, group id: \(passwd.groupId)")))
                    } else {
                        var targetIndex = -1
                        for index in groupPasswds!.indices {
                            if (groupPasswds![index].id == passwd.id) {
                                targetIndex = index
                                break
                            }
                        }
                        if (targetIndex != -1) {
                            groupPasswds?.remove(at: targetIndex)
                            self.groupsPasswdsMap[passwd.groupId] = groupPasswds!
                        }
                        self.currentPasswds = self.sortedPasswds(self.groupsPasswdsMap[passwd.groupId] ?? [])
                        self.updateCurrentPasswd(passwd: nil)
                    }
                    
                    completion(.success(passwd))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func movePasswd(passwdId: Int, afterPasswdId: Int?, completion: @escaping (Result<String, RequestError>) -> Void) {
        var params: [String: String] = [
            "passwd_id": String(passwdId),
            "user_id": String(self.userId),
            "group_id": String(self.currentGroupId)
        ]
        print("movePasswd. passwdId: \(passwdId), groupId: \(self.currentGroupId), afterPasswdId: \(String(describing: afterPasswdId))")
        
        if let afterPasswdId = afterPasswdId {
            if afterPasswdId == -1 {
                // 移动到末尾
                params["after_passwd_id"] = "last"
            } else {
                params["after_passwd_id"] = String(afterPasswdId)
            }
        }
        
        RequestHelper.movePasswd(params: params) { result in
            switch result {
            case .success(_):
                print("Passwd移动成功，刷新当前group的passwd列表...")
                
                // 使用新的 groupPasswds 接口刷新当前 group 的 passwd 列表
                self.refreshGroupPasswds(groupId: self.currentGroupId) { refreshResult in
                    switch refreshResult {
                    case .success(_):
                        completion(.success("Passwd移动成功"))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func refreshGroupPasswds(groupId: Int, completion: @escaping (Result<String, RequestError>) -> Void) {
        let params = [
            "user_id": String(self.userId),
            "group_id": String(groupId)
        ]
        
        RequestHelper.fetchGroupPasswds(params: params) { result in
            switch result {
            case .success(let passwds):
                DispatchQueue.main.async {
                    let sortedPasswds = self.sortedPasswds(passwds)
                    for passwd in sortedPasswds {
                        self.passwdsMap[passwd.id] = passwd
                    }
                    
                    self.groupsPasswdsMap[groupId] = sortedPasswds
                    self.currentPasswds = sortedPasswds
                    
                    if let currentPasswd = self.currentPasswd,
                       sortedPasswds.contains(where: { $0.id == currentPasswd.id }) {
                        if let updatedPasswd = sortedPasswds.first(where: { $0.id == currentPasswd.id }) {
                            self.updateCurrentPasswd(passwd: updatedPasswd)
                        }
                    } else if !sortedPasswds.isEmpty {
                        self.updateCurrentPasswd(passwd: sortedPasswds.first)
                    } else {
                        self.updateCurrentPasswd(passwd: nil)
                    }
                    
                    completion(.success("刷新成功"))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func onPasswdClick(passwdId: Int) {
        guard let passwd = self.passwdsMap[passwdId] else {
            print("onPasswdClick self.passwdsMap has not passwdId [\(passwdId)]")
            return
        }
        onPasswdClick(passwd: passwd)
    }
    
    func onPasswdClick(passwd: Passwd) {
        print("onPasswdClick: \(passwd)")
        updateCurrentPasswd(passwd: passwd)
    }
    
    func onGroupClick(groupId: Int) {
        let group = groupsMap[groupId]
        if (group != nil) {
            onGroupClick(group: group!)
        }

    }
    
    func onGroupClick(group: Group) {
        self.currentGroup = group
        self.currentGroupId = group.id
        self.currentPasswds = sortedPasswds(groupsPasswdsMap[group.id] ?? [])
        if (self.currentPasswds.isEmpty) {
            updateCurrentPasswd(passwd: nil)
        } else {
            if (self.currentPasswd?.groupId == group.id) {
                print("no need to update the selected currentPasswd")
                return
            }
            updateCurrentPasswd(passwd: self.currentPasswds.first)
        }
    }
    
    // 按 sortOrder 升序排列密码列表的辅助方法
    private func sortedPasswds(_ passwds: [Passwd]) -> [Passwd] {
        return passwds.sorted { passwd1, passwd2 in
            let order1 = passwd1.sortOrder ?? Int.max
            let order2 = passwd2.sortOrder ?? Int.max
            return order1 < order2
        }
    }
    
    func updateCurrentPasswd(passwd: Passwd?) {
        self.currentPasswd = passwd
        self.currentPasswdId = passwd == nil ? -1 : passwd!.id
        if (passwd == nil) {
            self.title = ""
            self.usernameString = ""
            self.passwordString = ""
            self.link = ""
            self.comment = ""
        } else {
            self.title = passwd?.title ?? ""
            self.usernameString = passwd?.usernameString ?? ""
            self.passwordString = passwd?.passwordString ?? ""
            self.link = passwd?.link ?? ""
            self.comment = passwd?.comment ?? ""
        }
    }
    
    func tryAutoLoginWhenStartup(userInfoes: [UserInfo]) {
        guard let lastAutoLoginUserInfo = userInfoes.first else {
            print("lastAutoLoginUserInfo is nil")
            self.updateLoginViewStatus(userInfo: nil)
            return
        }
        
        if (!lastAutoLoginUserInfo.autoLogin) {
            print("lastAutoLoginUserInfo auto login is false")
            self.updateLoginViewStatus(userInfo: lastAutoLoginUserInfo)
            return
        }
        
        print("lastAutoLoginUserInfo is \(lastAutoLoginUserInfo)")
        self.loginByPasswd(
            username: lastAutoLoginUserInfo.username,
            password: lastAutoLoginUserInfo.password ?? "",
            secretKey: lastAutoLoginUserInfo.secretKey ?? "",
            domain: lastAutoLoginUserInfo.domain ?? "",
            ip: lastAutoLoginUserInfo.ip ?? "0.0.0.0",
            host: lastAutoLoginUserInfo.host ?? 8080
        ) { result in
            switch result {
            case .success(_):
                self.currentScreen = .Passwds
            case .failure(_):
                print("lastAutoLoginUserInfo is nil")
                self.updateLoginViewStatus(userInfo: nil)
            }
        }
    }
    
    func updateLoginViewStatus(userInfo: UserInfo?) {
        self.loginUsername = userInfo?.username ?? ""
        self.loginPassword = userInfo?.password ?? ""
        self.loginSecretKey = userInfo?.secretKey ?? ""
        self.loginIpAddress = userInfo?.ip ?? "0.0.0.0"
        self.loginHost = String(userInfo?.host ?? 8080)
        
        self.rememberUsernameStatusOn = !self.loginUsername.isEmpty
        self.rememberPasswordStatusOn = !self.loginPassword.isEmpty
        self.rememberSecretKeyStatusOn = !self.loginSecretKey.isEmpty
        self.rememberAddressStatusOn = !self.loginIpAddress.isEmpty && !self.loginHost.isEmpty || !self.loginDomain.isEmpty
        
        
        self.currentScreen = .Login
    }
    
    // MARK: - Export
    
    /// 导出所有密码和分组数据为 JSON 格式
    func exportAllPasswords() -> Data? {
        var groupExports: [ExportData.GroupExport] = []
        for group in groups {
            let passwds = sortedPasswds(groupsPasswdsMap[group.id] ?? [])
            groupExports.append(ExportData.GroupExport(group: group, passwds: passwds))
        }
        let exportData = ExportData(groups: groupExports)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            return try encoder.encode(exportData)
        } catch {
            print("导出 JSON 编码失败: \(error)")
            return nil
        }
    }
}

// MARK: - Export Data Structure
struct ExportData: Codable {
    struct GroupExport: Codable {
        let id: Int
        let userId: Int
        var groupName: String
        var groupComment: String?
        let sortOrder: Int64?
        let passwds: [Passwd]
        
        init(group: Group, passwds: [Passwd]) {
            self.id = group.id
            self.userId = group.userId
            self.groupName = group.groupName
            self.groupComment = group.groupComment
            self.sortOrder = group.sortOrder
            self.passwds = passwds
        }
    }
    let groups: [GroupExport]
}
