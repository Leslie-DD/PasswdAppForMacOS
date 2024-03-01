//
//  ContentView.swift
//  passwd
//
//  Created by Leslie D on 2024/2/4.
//

import SwiftUI

struct SideGroupsView: View {
    
    @EnvironmentObject var model: DataModel
    
    @State private var newGroupAlert: Bool = false
    @State private var newGroupName: String = ""
    @State private var newGroupComment: String = ""
    
    @State private var refactorGroupAlert: Bool = false
    @State private var refactorGroupId: Int = -1
    @State private var refactorGroupName: String = ""
    @State private var refactorGroupComment: String = ""
    
    @State private var deleteGroupAlert: Bool = false
    @State private var deleteGroupId: Int = -1
    @State private var deleteGroupName: String = ""
    
    @State private var newPasswdAlert: Bool = false
    @State private var newPasswdGroupId: Int = -1
    @State private var newPasswdTitle: String = ""
    @State private var newPasswdUsername: String = ""
    @State private var newPasswdPassword: String = ""
    @State private var newPasswdLink: String = ""
    @State private var newPasswdComment: String = ""
    
    var body: some View {
        NavigationSplitView {
            
            List(selection: $model.currentGroupId) {
                Section {
                    ForEach(model.groups) { group in
                        Text(group.groupName)
                            .tag(group.id)
                            .foregroundStyle(model.currentGroupId == group.id ? Color.primary : .gray)
                            .contextMenu {
                                Button("Refactor") {
                                    refactorGroupId = group.id
                                    refactorGroupName = ""
                                    refactorGroupComment = ""
                                    refactorGroupAlert.toggle()
                                }
                                
                                Button (
                                    action: {
                                        newPasswdGroupId = group.id
                                        newPasswdTitle = ""
                                        newPasswdUsername = ""
                                        newPasswdPassword = ""
                                        newPasswdLink = ""
                                        newPasswdComment = ""
                                        newPasswdAlert.toggle()
                                    },
                                    label: {
                                        Text("Add")
                                    }
                                )
                                
                                Divider()
                                
                                Button (
                                    action: {
                                        deleteGroupId = group.id
                                        deleteGroupName = group.groupName
                                        deleteGroupAlert.toggle()
                                    },
                                    label: {
                                        Text("Delete")
                                            .foregroundColor(.red)
                                    }
                                )
                            }
                            .alert("Refactor Group", isPresented: $refactorGroupAlert) {
                                TextField("Group Name", text: $refactorGroupName)
                                    .background(Color(.customGray))
                                    .cornerRadius(5.0)
                                    .frame(maxWidth: 60)
                                
                                TextField("Group Comment", text: $refactorGroupComment)
                                    .background(Color(.customGray))
                                    .cornerRadius(5.0)
                                    .frame(maxWidth: 60)
                                    
                                Button("Cancel", role: .cancel) {
                                }
                                
                                Button("Refactor") {
                                    if (LoginInfoCheck.shared.isUsernameValid(username: refactorGroupName)) {
                                        model.loadingAlert = true
                                        model.updateGroup(groupId: refactorGroupId, groupName: refactorGroupName, groupComment: refactorGroupComment) { result in
                                            model.loadingAlert = false
                                        }
                                    }
                                }
                            }
                    }
                    .onMove(perform: { source, destination in
                        print("from \(source) to \(destination)")
                    })
                } header: {
                    HStack(spacing: 5) {
                        Text("Groups")
                            .foregroundStyle(Color.primary)
                            .font(.title3)
                            .padding(.vertical, 10)
                            .alert("分组 [\(deleteGroupName)] 下的所有密码都会被删除，确定删除吗?", isPresented: $deleteGroupAlert) {
                                Text("Warning: 分组下的所有密码都会被删除")
                                Button("Cancel", role: .cancel) {
                                }
                                
                                Button("Delete") {
                                    model.loadingAlert = true
                                    model.deleteGroup(groupId: deleteGroupId) { result in
                                        model.loadingAlert = false
                                    }
                                }
                            }
                        Button("", systemImage: "plus") {
                            newGroupAlert.toggle()
                        }.padding(.bottom, 4)
                        .tint(.gray)
                        .buttonStyle(.plain)
                        .alert("Add a group", isPresented: $newGroupAlert) {
                            TextField("Group Name", text: $newGroupName)
                                .background(Color(.customGray))
                                .cornerRadius(5.0)
                                .frame(maxWidth: 60)
                            
                            TextField("Group Comment", text: $newGroupComment)
                                .background(Color(.customGray))
                                .cornerRadius(5.0)
                                .frame(maxWidth: 60)
                                
                            Button("Cancel", role: .cancel) {
                                newGroupName = ""
                                newGroupComment = ""
                            }
                            
                            Button("Add") {
                                if (LoginInfoCheck.shared.isUsernameValid(username: self.newGroupName, checkSpace: false)) {
                                    model.loadingAlert = true
                                    model.newGroup(groupName: self.newGroupName, groupComment: self.newGroupComment) { result in
                                        model.loadingAlert = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .onChange(of: model.currentGroupId) { oldGroupId, newGroupId in
                model.onGroupClick(groupId: newGroupId)
            }

            Button("Log out", systemImage: "rectangle.portrait.and.arrow.forward") {
                model.currentScreen = .Login
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .tint(.gray)
            .buttonStyle(.plain)
            
        } detail: {
            PasswdsView()
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
                        if (LoginInfoCheck.shared.isUsernameValid(username: self.newPasswdTitle, checkSpace: false)) {
                            model.loadingAlert = true
                            let passwd = Passwd(id: -1, userId: model.userId, groupId: self.newPasswdGroupId, title: newPasswdTitle, usernameString: newPasswdUsername, passwordString: newPasswdPassword, link: newPasswdLink, comment: newPasswdComment)
                            
                            model.newPasswd(passwd: passwd) { result in
                                model.loadingAlert = false
                            }
                        }
                    }
                }
        }
        .navigationTitle(model.currentGroup?.groupName ?? "")
    }
}
