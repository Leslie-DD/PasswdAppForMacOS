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
    @State private var isExpanded: Bool = false
    @State private var showPassword: Bool = false
    @State private var showSecretKey: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: 16) {
                        // App Icon/Logo placeholder
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.accentColor.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "lock.shield")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.accentColor)
                            )
                        
                        VStack(spacing: 8) {
                            Text("Welcome Back")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Sign in to your password manager")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 36)
                    .padding(.bottom, 24)
                    
                    // Login Form Card
                    VStack(spacing: 24) {
                        // Username Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                            HStack {
                                TextField("Enter your username", text: $model.loginUsername)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 16))
                                    .onChange(of: model.loginUsername) { oldValue, newValue in
                                        // 移除换行符和空格
                                        let filteredValue = newValue.replacingOccurrences(of: "\n", with: "")
                                                                   .replacingOccurrences(of: " ", with: "")
                                        if filteredValue != newValue {
                                            model.loginUsername = filteredValue
                                        }
                                    }
                                
                                if !loginInfoes.isEmpty {
                                    Menu {
                                        ForEach(loginInfoes, id: \.self) { loginInfo in
                                            Button(loginInfo.username) {
                                                model.loginUsername = loginInfo.username
                                                model.loginPassword = loginInfo.password ?? ""
                                                model.loginSecretKey = loginInfo.secretKey ?? ""
                                                model.loginDomain = loginInfo.domain ?? ""
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
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.controlBackgroundColor))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color(.separatorColor), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                            HStack {
                                if showPassword {
                                    TextField("Enter your password", text: $model.loginPassword)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 16))
                                        .onChange(of: model.loginPassword) { oldValue, newValue in
                                            // 移除换行符和空格
                                            let filteredValue = newValue.replacingOccurrences(of: "\n", with: "")
                                                                       .replacingOccurrences(of: " ", with: "")
                                            if filteredValue != newValue {
                                                model.loginPassword = filteredValue
                                            }
                                        }
                                } else {
                                    SecureField("Enter your password", text: $model.loginPassword)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 16))
                                        .onChange(of: model.loginPassword) { oldValue, newValue in
                                            // 移除换行符和空格
                                            let filteredValue = newValue.replacingOccurrences(of: "\n", with: "")
                                                                       .replacingOccurrences(of: " ", with: "")
                                            if filteredValue != newValue {
                                                model.loginPassword = filteredValue
                                            }
                                        }
                                }
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.controlBackgroundColor))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color(.separatorColor), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Secret Key Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Secret Key")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                            HStack {
                                if showSecretKey {
                                    TextField("Enter your secret key", text: $model.loginSecretKey)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 16))
                                        .onChange(of: model.loginSecretKey) { oldValue, newValue in
                                            // 移除换行符和空格
                                            let filteredValue = newValue.replacingOccurrences(of: "\n", with: "")
                                                                       .replacingOccurrences(of: " ", with: "")
                                            if filteredValue != newValue {
                                                model.loginSecretKey = filteredValue
                                            }
                                        }
                                } else {
                                    SecureField("Enter your secret key", text: $model.loginSecretKey)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 16))
                                        .onChange(of: model.loginSecretKey) { oldValue, newValue in
                                            // 移除换行符和空格
                                            let filteredValue = newValue.replacingOccurrences(of: "\n", with: "")
                                                                       .replacingOccurrences(of: " ", with: "")
                                            if filteredValue != newValue {
                                                model.loginSecretKey = filteredValue
                                            }
                                        }
                                }
                                
                                Button(action: {
                                    showSecretKey.toggle()
                                }) {
                                    Image(systemName: showSecretKey ? "eye.slash" : "eye")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.controlBackgroundColor))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color(.separatorColor), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Server Configuration (Expandable)
                        VStack(alignment: .leading, spacing: 12) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isExpanded.toggle()
                                }
                            }) {
                                HStack {
                                    Text("Server Configuration")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .contentShape(Rectangle())
                                }
                            }
                            .buttonStyle(.plain)
                            
                            if isExpanded {
                                VStack(spacing: 12) {
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Domain")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                            HStack {
                                                
                                                Text("https://")
                                                    .textFieldStyle(.plain)
                                                    .font(.system(size: 14))
                                                TextField("www.xxx.yyy/zzz", text: $model.loginDomain)
                                                    .textFieldStyle(.plain)
                                                    .font(.system(size: 14))
                                                    .onChange(of: model.loginDomain) { oldValue, newValue in
                                                        let filteredValue = newValue.replacingOccurrences(of: "\n", with: "")
                                                            .replacingOccurrences(of: " ", with: "")
                                                        if filteredValue != newValue {
                                                            model.loginDomain = filteredValue
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.controlBackgroundColor))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .strokeBorder(Color(.separatorColor), lineWidth: 1)
                                            )
                                    )
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("IP Address")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                            
                                            TextField("0.0.0.0", text: $model.loginIpAddress)
                                                .textFieldStyle(.plain)
                                                .font(.system(size: 14))
                                                .onChange(of: model.loginIpAddress) { oldValue, newValue in
                                                    // 移除换行符和空格
                                                    let filteredValue = newValue.replacingOccurrences(of: "\n", with: "")
                                                                               .replacingOccurrences(of: " ", with: "")
                                                    if filteredValue != newValue {
                                                        model.loginIpAddress = filteredValue
                                                    } else if !InfoChecker.loginInfoCheckerShared.isValidIpAddress(ipAddress: newValue) {
                                                        model.loginIpAddress = ""
                                                    }
                                                }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Port")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                            
                                            TextField("8080", text: $model.loginHost)
                                                .textFieldStyle(.plain)
                                                .font(.system(size: 14))
                                                .onChange(of: model.loginHost) { oldValue, newValue in
                                                    // 移除换行符和空格
                                                    let filteredValue = newValue.replacingOccurrences(of: "\n", with: "")
                                                                               .replacingOccurrences(of: " ", with: "")
                                                    if filteredValue != newValue {
                                                        model.loginHost = filteredValue
                                                    } else if !InfoChecker.loginInfoCheckerShared.isValidHost(hostStr: model.loginHost) {
                                                        model.loginHost = ""
                                                    }
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.controlBackgroundColor))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .strokeBorder(Color(.separatorColor), lineWidth: 1)
                                            )
                                    )
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        
                        // Remember Options
                        VStack(spacing: 12) {
                            HStack {
                                Toggle("remember username", isOn: $model.rememberUsernameStatusOn)
                                    .toggleStyle(.checkbox)
                                    .onChange(of: model.rememberUsernameStatusOn) { oldValue, newValue in
                                        if (!newValue) {
                                            model.rememberUsernameStatusOn = false
                                            model.rememberPasswordStatusOn = false
                                            model.rememberSecretKeyStatusOn = false
                                            model.rememberAddressStatusOn = false
                                        }
                                    }
                                
                                Spacer()
                            }
                            
                            HStack {
                                Toggle("remember password", isOn: $model.rememberPasswordStatusOn)
                                    .toggleStyle(.checkbox)
                                    .onChange(of: model.rememberPasswordStatusOn) { oldValue, newValue in
                                        if (newValue) {
                                            model.rememberUsernameStatusOn = true
                                            model.rememberPasswordStatusOn = true
                                        }
                                    }
                                
                                Spacer()
                            }
                            
                            HStack {
                                Toggle("remember secret key", isOn: $model.rememberSecretKeyStatusOn)
                                    .toggleStyle(.checkbox)
                                    .onChange(of: model.rememberSecretKeyStatusOn) { oldValue, newValue in
                                        if (newValue) {
                                            model.rememberUsernameStatusOn = true
                                            model.rememberSecretKeyStatusOn = true
                                        }
                                    }
                                
                                Spacer()
                            }
                            
                            HStack {
                                Toggle("remember address", isOn: $model.rememberAddressStatusOn)
                                    .toggleStyle(.checkbox)
                                    .onChange(of: model.rememberAddressStatusOn) { oldValue, newValue in
                                        if (newValue) {
                                            model.rememberUsernameStatusOn = true
                                            model.rememberAddressStatusOn = true
                                        }
                                    }
                                
                                Spacer()
                            }
                            
                            HStack {
                                Toggle("auto login", isOn: $rememberAutoLoginStatusOn)
                                    .toggleStyle(.checkbox)
                                    .onChange(of: rememberAutoLoginStatusOn) { oldValue, newValue in
                                        if (newValue) {
                                            model.rememberUsernameStatusOn = true
                                            model.rememberPasswordStatusOn = true
                                            model.rememberSecretKeyStatusOn = true
                                            model.rememberAddressStatusOn = true
                                        }
                                    }
                                
                                Spacer()
                            }
                        }
                        
                        // Login Button
                        Button(action: performLogin) {
                            HStack {
                                if model.loadingAlert {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                
                                Text(model.loadingAlert ? "Signing In..." : "Sign In")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.accentColor)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(model.loadingAlert)
                        
                        // Sign Up Link
                        HStack {
                            Text("Don't have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Button("Sign Up") {
                                model.currentScreen = .Signup
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.accentColor)
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.windowBackgroundColor))
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    )
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.windowBackgroundColor),
                    Color(.windowBackgroundColor).opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .alert("Login Error", isPresented: $loginErrorAlert) {
            Button("OK") { }
        } message: {
            Text(loginErrorMsg)
        }
    }
    
    private func performLogin() {
        if (InfoChecker.loginInfoCheckerShared.isUsernameValid(username: model.loginUsername)
            && InfoChecker.loginInfoCheckerShared.isPasswordValid(password: model.loginPassword)
            && InfoChecker.loginInfoCheckerShared.isSecretKeyValid(secretKey: model.loginSecretKey)
//            && InfoChecker.loginInfoCheckerShared.isIpAddressValid(ipAddress: model.loginIpAddress)
//            && InfoChecker.loginInfoCheckerShared.isValidHost(hostStr: model.loginHost)
        ) {
            
            model.loadingAlert = true
            model.loginByPasswd(
                username: model.loginUsername,
                password: model.loginPassword,
                secretKey: model.loginSecretKey,
                domain: model.loginDomain,
                ip: model.loginIpAddress,
                host: Int(model.loginHost) ?? 8081
            ) { result in
                switch result {
                case .success(_):
                    handleLoginSuccess()
                case .failure(let error):
                    handleLoginFailure(error)
                }
                model.loadingAlert = false
            }
        } else {
            loginErrorMsg = "Please check your input fields"
            loginErrorAlert = true
        }
    }
    
    private func handleLoginSuccess() {
        if (rememberAutoLoginStatusOn) {
            if (currentLoginInfo != nil && currentLoginInfo?.username == model.loginUsername) {
                updateCurrentLoginInfo()
            } else {
                handleNewOrExistingUser(autoLogin: true)
            }
        } else {
            if (!model.rememberUsernameStatusOn) {
                handleNoRememberSettings()
            } else {
                handlePartialRememberSettings()
            }
        }
        model.currentScreen = .Passwds
    }
    
    private func handleLoginFailure(_ error: RequestError) {
        switch error {
        case .requestFailed(let failureMsg):
            loginErrorMsg = failureMsg
        case .invalidURL(let failureMsg):
            loginErrorMsg = failureMsg
        }
        loginErrorAlert = true
    }
    
    private func updateCurrentLoginInfo() {
        currentLoginInfo?.username = model.loginUsername
        currentLoginInfo?.password = model.loginPassword
        currentLoginInfo?.secretKey = model.loginSecretKey
        currentLoginInfo?.domain = model.loginDomain
        currentLoginInfo?.ip = model.loginIpAddress
        currentLoginInfo?.host = Int(model.loginHost) ?? 8081
        currentLoginInfo?.updateTime = InfoChecker.currentTimeStamp
        currentLoginInfo?.autoLogin = true
    }
    
    private func handleNewOrExistingUser(autoLogin: Bool) {
        let alreadyInDbUserInfo = loginInfoes.filter {
            model.loginUsername == $0.username
        }.first
        
        if (alreadyInDbUserInfo == nil) {
            let loginUserInfo = UserInfo(
                username: model.loginUsername,
                password: model.loginPassword,
                secretKey: model.loginSecretKey,
                domain: model.loginDomain,
                ip: model.loginIpAddress,
                host: Int(model.loginHost) ?? 8081,
                autoLogin: autoLogin
            )
            context.insert(loginUserInfo)
        } else {
            alreadyInDbUserInfo?.username = model.loginUsername
            alreadyInDbUserInfo?.password = model.loginPassword
            alreadyInDbUserInfo?.secretKey = model.loginSecretKey
            alreadyInDbUserInfo?.domain = model.loginDomain
            alreadyInDbUserInfo?.ip = model.loginIpAddress
            alreadyInDbUserInfo?.host = Int(model.loginHost) ?? 8081
            alreadyInDbUserInfo?.updateTime = InfoChecker.currentTimeStamp
            alreadyInDbUserInfo?.autoLogin = autoLogin
        }
    }
    
    private func handleNoRememberSettings() {
        if (currentLoginInfo != nil && currentLoginInfo?.username == model.loginUsername) {
            context.delete(currentLoginInfo!)
        } else {
            let alreadyInDbUserInfo = loginInfoes.filter {
                model.loginUsername == $0.username
            }.first
            if (alreadyInDbUserInfo != nil) {
                context.delete(currentLoginInfo!)
            }
        }
    }
    
    private func handlePartialRememberSettings() {
        let theUserInfo: UserInfo? = loginInfoes.filter {
            model.loginUsername == $0.username
        }.first
        
        if (theUserInfo != nil) {
            let theUserInfoNotNil = theUserInfo!
            theUserInfoNotNil.password = model.rememberPasswordStatusOn ? model.loginPassword : ""
            theUserInfoNotNil.secretKey = model.rememberSecretKeyStatusOn ? model.loginSecretKey : ""
            theUserInfoNotNil.domain = model.rememberAddressStatusOn ? model.loginDomain : ""
            theUserInfoNotNil.ip = model.rememberAddressStatusOn ? model.loginIpAddress : "0.0.0.0"
            theUserInfoNotNil.host = model.rememberAddressStatusOn ? Int(model.loginHost) ?? 8080 : 8080
            theUserInfoNotNil.autoLogin = false
            theUserInfoNotNil.updateTime = InfoChecker.currentTimeStamp
        } else {
            let theUserInfoNotNil = UserInfo(username: model.loginUsername)
            theUserInfoNotNil.password = model.rememberPasswordStatusOn ? model.loginPassword : ""
            theUserInfoNotNil.secretKey = model.rememberSecretKeyStatusOn ? model.loginSecretKey : ""
            theUserInfoNotNil.domain = model.rememberAddressStatusOn ? model.loginDomain : ""
            theUserInfoNotNil.ip = model.rememberAddressStatusOn ? model.loginIpAddress : "0.0.0.0"
            theUserInfoNotNil.host = model.rememberAddressStatusOn ? Int(model.loginHost) ?? 8080 : 8080
            theUserInfoNotNil.autoLogin = false
            theUserInfoNotNil.updateTime = InfoChecker.currentTimeStamp
            
            context.delete(theUserInfoNotNil)
            context.insert(theUserInfoNotNil)
        }
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
