//
//  passwdApp.swift
//  passwd
//
//  Created by Leslie D on 2024/2/4.
//

import SwiftUI
import SwiftData


@main
struct passwdApp: App {
    
    @ObservedObject private var model = DataModel()

    var body: some Scene {
        WindowGroup {
            
            ZStack {
                switch model.currentScreen {
                case .Loading:
                    StartupLoadingView()
                        .environmentObject(model)
                case .Login:
                    LoginView()
                        .environmentObject(model)
                case .Signup:
                    SignupView()
                        .environmentObject(model)
                case .Passwds:
                    SideGroupsView()
                        .environmentObject(model)
                case .Settings:
                    LoginView()
                        .environmentObject(model)
                }
                
                if model.loadingAlert {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                        .foregroundColor(.white)
                }
            }
        }
        .modelContainer(for: [UserInfo.self])
    }
}

struct StartupLoadingView: View {
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var model: DataModel

    @Query(sort: \UserInfo.updateTime, order: .reverse) private var userInfoes: [UserInfo]
    
    var body: some View {
        ProgressView()
            .onAppear() {
                model.tryAutoLoginWhenStartup(userInfoes: userInfoes)
            }
    }
}

