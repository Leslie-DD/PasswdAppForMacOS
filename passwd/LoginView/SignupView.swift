//
//  SignupView.swift
//  passwd
//
//  Created by Leslie D on 2024/2/18.
//

import SwiftUI

struct SignupView: View {
    
    @EnvironmentObject var model: DataModel
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var ipAddress: String = "0.0.0.0"
    @State private var host: String = "8080"
    
    @State private var invalidAlert: Bool = false
    @State private var signupSuccessAlert: Bool = false
    @State private var secretKey: String = ""
    
    @State private var signupFailureAlert: Bool = false
    @State private var failureMsg: String = ""
    
    
    var body: some View {
        VStack (spacing: 16) {
            TextField("Username", text: $username)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(TextBorder(editable: true))
            
            SecureField("Password", text: $password)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(TextBorder(editable: true))
                .frame(maxWidth: 230)
            
            HStack {
                TextField("IP Address", text: $ipAddress)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .frame(maxWidth: 150)
                    .onChange(of: ipAddress) { oldValue, newValue in
                        if !LoginInfoCheck.shared.isValidIpAddress(ipAddress: newValue) {
                            ipAddress = ""
                            // Show an error message
                        }
                    }
                    .alert(isPresented: $signupFailureAlert) {
                        Alert(
                            title: Text("Sign up failure"),
                            message: Text("Message: \(failureMsg)"),
                            dismissButton: .default(Text("Got it!"))
                        )
                    }
                
                TextField("Host", text: $host)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .frame(maxWidth: 80)
                    .onChange(of: host) { oldValue, newValue in
                        if !LoginInfoCheck.shared.isValidHost(hostStr: host) {
                            host = ""
                            // Show an error message
                        }
                    }
                    .alert(isPresented: $invalidAlert) {
                        Alert(
                            title: Text("Invalid input"),
                            message: Text("Username or password invalid"),
                            dismissButton: .default(Text("Got it!"))
                        )
                    }
            }
            .frame(maxWidth: 230)
            .background(TextBorder(editable: true))
            
            Button(action: {
                print("Sign up")
                
                if (LoginInfoCheck.shared.isUsernameValid(username: username)
                    && LoginInfoCheck.shared.isPasswordValid(password: password)) {
                    
                    model.loadingAlert = true
                    model.signup(username: username, password: password, ip: ipAddress, host: host) { result in
                        model.loadingAlert = false
                        switch result {
                        case .success(let resultSecretKey):
                            self.secretKey = resultSecretKey
                            self.signupSuccessAlert = true
                        case .failure(let error):
                            switch error {
                            case .requestFailed(let failureMsg) :
                                self.failureMsg = failureMsg
                            case .invalidURL(let failureMsg) :
                                self.failureMsg = failureMsg
                            }
                            signupFailureAlert = true
                        }
                    }
                } else {
                    print("invalid username or password")
                    self.invalidAlert = true
                }
            }) {
                Text("Sign up")
                    .font(.headline)
                    .frame(maxWidth: 230)
                    .frame(height: 40)
            }
            .foregroundColor(.white)
            .background(Color.accentColor)
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .buttonStyle(.plain)
            .alert(isPresented: $signupSuccessAlert) {
                Alert(
                    title: Text("Sign up success"),
                    message: Text("Your secret key is \n\n\(secretKey)\n\n YOU MUST WRITE IT DOWN! And if you forget it, decoding will be wrong!"),
                    dismissButton: .default(Text("Got it!")) {
                        model.currentScreen = .Passwds
                    }
                )
            }

        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button("", systemImage: "chevron.backward") {
                    model.currentScreen = .Login
                }
            }
        }
        .frame(alignment: .leading)
        .frame(maxWidth: 230, maxHeight: .infinity, alignment: .center)
        .padding(.bottom, 40)
        .navigationTitle("Signup")
        
    }
}

#Preview {
    SignupView()
}
