//
//  SideGroupsView.swift
//  passwd
//
//  Created by Leslie D on 2024/2/4.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var model: DataModel
    
    @State private var newPasswdAlert: Bool = false
    @State private var newPasswdGroupId: Int = -1
    @State private var newPasswdTitle: String = ""
    @State private var newPasswdUsername: String = ""
    @State private var newPasswdPassword: String = ""
    @State private var newPasswdLink: String = ""
    @State private var newPasswdComment: String = ""
    
    @State private var usernameLimitAlert: Bool = false
    @State private var isSearching: Bool = false
    
    var body: some View {
        NavigationSplitView {
            SideBarView()
        } content: {
            PasswdsView()
                .searchable(text: $model.searchText, isPresented: $isSearching, prompt: Text("(Command + F) Search"))
                .navigationSplitViewColumnWidth(min:100, ideal: 200, max: 300)
        } detail: {
            DetailView()
                .navigationSplitViewColumnWidth(min:200, ideal: 400)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            Button("") {
                isSearching = true
            }
            .keyboardShortcut("f", modifiers: .command).hidden()
        )
        .alert("Add a Passwd", isPresented: $newPasswdAlert) {
            TextField("title", text: $newPasswdTitle)
                .background(Color(.customGray))
                .cornerRadius(5.0)
                .frame(maxWidth: 60)
            
            TextField("Username", text: $newPasswdUsername)
                .background(Color(.customGray))
                .cornerRadius(5.0)
                .frame(maxWidth: 60)
            
            TextField("Password", text: $newPasswdPassword)
                .background(Color(.customGray))
                .cornerRadius(5.0)
                .frame(maxWidth: 60)
            
            TextField("Link", text: $newPasswdLink)
                .background(Color(.customGray))
                .cornerRadius(5.0)
                .frame(maxWidth: 60)
            
            TextField("Comment", text: $newPasswdComment)
                .background(Color(.customGray))
                .cornerRadius(5.0)
                .frame(maxWidth: 60)
            
            Button("Cancel", role: .cancel) {
            }
            
            Button("Add") {
                if (InfoChecker.passwdInfoCheckerShared.isUsernameValid(username: self.newPasswdTitle, checkSpace: false)) {
                    model.loadingAlert = true
                    let passwd = Passwd(id: -1, userId: model.userId, groupId: self.newPasswdGroupId, title: newPasswdTitle, usernameString: newPasswdUsername, passwordString: newPasswdPassword, link: newPasswdLink, comment: newPasswdComment)
                    
                    model.newPasswd(passwd: passwd) { result in
                        model.loadingAlert = false
                    }
                } else {
                    usernameLimitAlert.toggle()
                }
            }
        }
        .alert("Username not valid", isPresented: $usernameLimitAlert) {
            Text("Username 不能为空并且长度不能超过 64")
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("addNewPasswd"))) { notification in
            if let groupId = notification.object as? Int {
                newPasswdGroupId = groupId
                newPasswdTitle = ""
                newPasswdUsername = ""
                newPasswdPassword = ""
                newPasswdLink = ""
                newPasswdComment = ""
                newPasswdAlert.toggle()
            }
        }
    }
}



