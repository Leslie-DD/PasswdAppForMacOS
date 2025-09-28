//
//  SideBarView.swift
//  passwd
//
//  Created by EvanD on 2025/9/28.
//


import SwiftUI

struct SideBarView: View {
    
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
    
    var body: some View {
        List(selection: $model.currentGroupId) {
            Section {
                ForEach(model.groups) { group in
                    GroupItemView(
                        group: group,
                        refactorGroupId: $refactorGroupId,
                        refactorGroupName: $refactorGroupName,
                        refactorGroupComment: $refactorGroupComment,
                        refactorGroupAlert: $refactorGroupAlert,
                        deleteGroupId: $deleteGroupId,
                        deleteGroupName: $deleteGroupName,
                        deleteGroupAlert: $deleteGroupAlert
                    )
                }
                .onMove(perform: { source, destination in
                    print("from \(source) to \(destination)")
                })
            } header: {
                HStack(spacing: 5) {
                    Text("Groups")
                        .foregroundStyle(Color.gray)
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
                            if (InfoChecker.loginInfoCheckerShared.isUsernameValid(username: self.newGroupName, checkSpace: false)) {
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
        
        Button(action: {
            model.currentScreen = .Login
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.forward")
                    .foregroundColor(.accentColor)
                Text("Log out")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .tint(.accentColor)
        .buttonStyle(.plain)
    }
}

// MARK: - GroupItemView
struct GroupItemView: View {
    let group: Group
    @EnvironmentObject var model: DataModel
    
    @Binding var refactorGroupId: Int
    @Binding var refactorGroupName: String
    @Binding var refactorGroupComment: String
    @Binding var refactorGroupAlert: Bool
    
    @Binding var deleteGroupId: Int
    @Binding var deleteGroupName: String
    @Binding var deleteGroupAlert: Bool
    
    var body: some View {
        Text(group.groupName)
            .tag(group.id)
            .contextMenu {
                Button("Refactor") {
                    refactorGroupId = group.id
                    refactorGroupName = ""
                    refactorGroupComment = ""
                    refactorGroupAlert.toggle()
                }
                
                Button (
                    action: {
                        // 这里需要通知父视图添加密码
                        NotificationCenter.default.post(name: Notification.Name("addNewPasswd"), object: group.id)
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
                    if (InfoChecker.loginInfoCheckerShared.isUsernameValid(username: refactorGroupName)) {
                        model.loadingAlert = true
                        model.updateGroup(groupId: refactorGroupId, groupName: refactorGroupName, groupComment: refactorGroupComment) { result in
                            model.loadingAlert = false
                        }
                    }
                }
            }
    }
}

