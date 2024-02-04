//
//  LoginView.swift
//  passwd
//
//  Created by Leslie D on 2024/2/7.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var model: DataModel
    
    @Query(sort: \UserInfo.updateTime, order: .reverse, animation: .snappy) private var loginInfoes: [UserInfo]
    
    @State private var currentLoginInfo: UserInfo?
    
    @State private var rememberAutoLoginStatusOn: Bool = false
    
    @State private var loginErrorAlert: Bool = false
    @State private var loginErrorMsg: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .padding(.vertical)
            VStack {
                HStack {
                    TextField("Username", text: $model.loginUsername)
                        .background(Color(.customGray))
                        .cornerRadius(5.0)
                    
                    Menu {
                        ForEach(loginInfoes, id: \.self){ loginInfo in
                            Button(loginInfo.username) {
                                model.loginUsername = loginInfo.username
                                model.loginPassword = loginInfo.password ?? ""
                                model.loginSecretKey = loginInfo.secretKey ?? ""
                                model.loginIpAddress = loginInfo.ip ?? "0.0.0.0"
                                model.loginHost = String(loginInfo.host ?? 8080)
                                
                                model.rememberUsernameStatusOn = true
                                model.rememberPasswordStatusOn = !model.loginPassword.isEmpty
                                model.rememberSecretKeyStatusOn = !model.loginSecretKey.isEmpty
                                model.rememberAddressStatusOn = !model.loginIpAddress.isEmpty && !model.loginHost.isEmpty
                                self.rememberAutoLoginStatusOn = loginInfo.autoLogin
                                
                                self.currentLoginInfo = loginInfo
                            }
                        }
                    } label: {
                    }
                    .frame(width: 30)
                }
                
                VStack {
                    Toggle("remember username", isOn: $model.rememberUsernameStatusOn)
                        .frame(alignment: .leading)
                        .onChange(of: model.rememberUsernameStatusOn) { oldValue, newValue in
                            if (!newValue) {
                                model.rememberUsernameStatusOn = false
                                model.rememberPasswordStatusOn = false
                                model.rememberSecretKeyStatusOn = false
                                model.rememberAddressStatusOn = false
                            }
                        }
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                SecureField("Password", text: $model.loginPassword)
                    .background(Color(.customGray))
                    .cornerRadius(5.0)
                    .frame(maxWidth: 200)
                VStack {
                    Toggle("remember password", isOn: $model.rememberPasswordStatusOn)
                        .frame(alignment: .leading)
                        .onChange(of: model.rememberPasswordStatusOn) { oldValue, newValue in
                            if (newValue) {
                                model.rememberUsernameStatusOn = true
                                model.rememberPasswordStatusOn = true
                            }
                        }
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                SecureField("Secret Key", text: $model.loginSecretKey)
                    .background(Color(.customGray))
                    .cornerRadius(5.0)
                    .frame(maxWidth: 200)
                VStack {
                    Toggle("remember secret key", isOn: $model.rememberSecretKeyStatusOn)
                        .frame(alignment: .leading)
                        .onChange(of: model.rememberSecretKeyStatusOn) { oldValue, newValue in
                            if (newValue) {
                                model.rememberUsernameStatusOn = true
                                model.rememberSecretKeyStatusOn = true
                            }
                        }
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    TextField("IP Address", text: $model.loginIpAddress)
                        .background(Color(.customGray))
                        .cornerRadius(5.0)
                        .frame(maxWidth: 150)
                        .onChange(of: model.loginIpAddress) { oldValue, newValue in
                            if !LoginInfoCheck.shared.isValidIpAddress(ipAddress: newValue) {
                                model.loginIpAddress = ""
                                // Show an error message
                            }
                        }
                    
                    TextField("Host", text: $model.loginHost)
                        .background(Color(.customGray))
                        .cornerRadius(5.0)
                        .frame(maxWidth: 60)
                        .onChange(of: model.loginHost) { oldValue, newValue in
                            if !LoginInfoCheck.shared.isValidHost(hostStr: model.loginHost) {
                                model.loginHost = ""
                                // Show an error message
                            }
                        }
                }
                .frame(maxWidth: 200)
                
                VStack {
                    Toggle("remember address", isOn: $model.rememberAddressStatusOn)
                        .frame(alignment: .leading)
                        .onChange(of: model.rememberAddressStatusOn) { oldValue, newValue in
                            if (newValue) {
                                model.rememberUsernameStatusOn = true
                                model.rememberAddressStatusOn = true
                            }
                        }
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    if (LoginInfoCheck.shared.isUsernameValid(username: model.loginUsername)
                        && LoginInfoCheck.shared.isPasswordValid(password: model.loginPassword)
                        && LoginInfoCheck.shared.isSecretKeyValid(secretKey: model.loginSecretKey)
                        && LoginInfoCheck.shared.isIpAddressValid(ipAddress: model.loginIpAddress)
                        && LoginInfoCheck.shared.isValidHost(hostStr: model.loginHost)) {
                        
                        model.loadingAlert = true
                        model.loginByPasswd(
                            username: model.loginUsername,
                            password: model.loginPassword,
                            secretKey: model.loginSecretKey,
                            ip: model.loginIpAddress,
                            host: Int(model.loginHost) ?? 8081
                        ) { result in
                            switch result {
                            case .success(_):
                                if (rememberAutoLoginStatusOn) {
                                    if (currentLoginInfo != nil && currentLoginInfo?.username == model.loginUsername) {
                                        print("login 1")
                                        currentLoginInfo?.username = model.loginUsername
                                        currentLoginInfo?.password = model.loginPassword
                                        currentLoginInfo?.secretKey = model.loginSecretKey
                                        currentLoginInfo?.ip = model.loginIpAddress
                                        currentLoginInfo?.host = Int(model.loginHost) ?? 8081
                                        currentLoginInfo?.updateTime = LoginInfoCheck.currentTimeStamp
                                        currentLoginInfo?.autoLogin = true
                                    } else {
                                        let alreadyInDbUserInfo = loginInfoes.filter {
                                            model.loginUsername == $0.username
                                        }.first
                                        if (alreadyInDbUserInfo == nil) {
                                            print("login 2")
                                            let loginUserInfo = UserInfo(username: model.loginUsername, password: model.loginPassword, secretKey: model.loginSecretKey, ip: model.loginIpAddress, host: Int(model.loginHost) ?? 8081, autoLogin: rememberAutoLoginStatusOn)
                                            context.insert(loginUserInfo)
                                        } else {
                                            print("login 3")
                                            alreadyInDbUserInfo?.username = model.loginUsername
                                            alreadyInDbUserInfo?.password = model.loginPassword
                                            alreadyInDbUserInfo?.secretKey = model.loginSecretKey
                                            alreadyInDbUserInfo?.ip = model.loginIpAddress
                                            alreadyInDbUserInfo?.host = Int(model.loginHost) ?? 8081
                                            alreadyInDbUserInfo?.updateTime = LoginInfoCheck.currentTimeStamp
                                            alreadyInDbUserInfo?.autoLogin = true
                                        }
                                    }
                                } else {
                                    if (!model.rememberUsernameStatusOn) {    // 说明要不自动登录，也不保存任何信息
                                        if (currentLoginInfo != nil && currentLoginInfo?.username == model.loginUsername) {
                                            print("login 4")
                                            context.delete(currentLoginInfo!)
                                        } else {
                                            let alreadyInDbUserInfo = loginInfoes.filter {
                                                model.loginUsername == $0.username
                                            }.first
                                            if (alreadyInDbUserInfo != nil) {
                                                context.delete(currentLoginInfo!)
                                            }
                                        }
                                    } else {
                                        // 说明要不自动登录，但要保存 Username 和其他一些信息
                                        let theUserInfo: UserInfo? = loginInfoes.filter {
                                            model.loginUsername == $0.username
                                        }.first
                                        
                                        if (theUserInfo != nil) {
                                            print("save Username and others 0")
                                            let theUserInfoNotNil = theUserInfo!
                                            
                                            theUserInfoNotNil.password = model.rememberPasswordStatusOn ? model.loginPassword : ""
                                            theUserInfoNotNil.secretKey = model.rememberSecretKeyStatusOn ? model.loginSecretKey : ""
                                            theUserInfoNotNil.ip = model.rememberAddressStatusOn ? model.loginIpAddress : "0.0.0.0"
                                            theUserInfoNotNil.host = model.rememberAddressStatusOn ? Int(model.loginHost) ?? 8080 : 8080
                                            theUserInfoNotNil.autoLogin = false
                                            theUserInfoNotNil.updateTime = LoginInfoCheck.currentTimeStamp
                                        } else {
                                            print("save Username and others 1")
                                            let theUserInfoNotNil = UserInfo(username: model.loginUsername)
                                            
                                            theUserInfoNotNil.password = model.rememberPasswordStatusOn ? model.loginPassword : ""
                                            theUserInfoNotNil.secretKey = model.rememberSecretKeyStatusOn ? model.loginSecretKey : ""
                                            theUserInfoNotNil.ip = model.rememberAddressStatusOn ? model.loginIpAddress : "0.0.0.0"
                                            theUserInfoNotNil.host = model.rememberAddressStatusOn ? Int(model.loginHost) ?? 8080 : 8080
                                            
                                            theUserInfoNotNil.autoLogin = false
                                            theUserInfoNotNil.updateTime = LoginInfoCheck.currentTimeStamp
                                            
                                            context.delete(theUserInfoNotNil)
                                            context.insert(theUserInfoNotNil)
                                        }
                                    }
                                }
                                model.currentScreen = .Passwds
                            case .failure(let error):
                                switch error {
                                case .requestFailed(let failureMsg) :
                                    loginErrorMsg = failureMsg
                                case .invalidURL(let failureMsg) :
                                    loginErrorMsg = failureMsg
                                }
                                loginErrorAlert = true
                            }
                            model.loadingAlert = false
                        }
                        
                    } else {
                        loginErrorMsg = "invalid input"
                        loginErrorAlert = true
                    }
                }) {
                    Text("Login")
                        .font(.headline)
                        .frame(maxWidth: 200)
                        .frame(height: 40)
                }
                .foregroundColor(.white)
                .background(Color.accentColor)
                .contentShape(RoundedRectangle(cornerRadius: 10))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .buttonStyle(.plain)
                .padding(.top)
                
                HStack {
                    Toggle("auto login", isOn: $rememberAutoLoginStatusOn)
                        .frame(alignment: .leading)
                        .onChange(of: rememberAutoLoginStatusOn) { oldValue, newValue in
                            if (newValue) {
                                model.rememberUsernameStatusOn = true
                                model.rememberPasswordStatusOn = true
                                model.rememberSecretKeyStatusOn = true
                                model.rememberAddressStatusOn = true
                            }
                        }
                    
                    Spacer()
                    
                    Button("Sign up") {
                        print("sign up")
                        model.currentScreen = .Signup
                    }
                    .foregroundColor(.accentColor)
                    .buttonStyle(.plain)
                    .alert(isPresented: $loginErrorAlert) {
                        Alert(
                            title: Text("Error"),
                            message: Text("Message: \(loginErrorMsg)"),
                            dismissButton: .default(Text("Got it!"))
                        )
                    }
                    
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: 200, maxHeight: .infinity, alignment: .center)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: 200, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 100)
    }
}

struct CustomTextField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14))
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.blue, lineWidth: 1))
    }
}

#Preview {
    LoginView()
}
