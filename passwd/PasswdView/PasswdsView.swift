//
//  ContentView.swift
//  passwd
//
//  Created by EvanD on 2025/9/28.
//


import SwiftUI

struct PasswdsView: View {
    
    @EnvironmentObject var model: DataModel
    
    @State private var confirmDeletePasswdAlert = false
    @State private var deletePasswd: Passwd? = nil
    
    var body: some View {
        List(selection: $model.currentPasswdId) {
            ForEach(model.currentPasswds) { passwd in
                Text("\(passwd.title)")
                    .tag(passwd.id)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .contextMenu {
                        Button (
                            action: {
                                print("ready to delete \(passwd.title)")
                                deletePasswd = passwd
                                confirmDeletePasswdAlert.toggle()
                            },
                            label: {
                                Text("Delete")
                                    .foregroundColor(.red)
                            }
                        )
                    }
                    .alert("是否删除\(deletePasswd?.title ?? "该 passwd")", isPresented: $confirmDeletePasswdAlert) {
                        Button("Cancel", role: .cancel) {
                        }
                        
                        Button("Delete") {
                            if (deletePasswd != nil) {
                                model.loadingAlert = true
                                model.deletePasswd(passwd: deletePasswd!) { result in
                                    deletePasswd = nil
                                    model.loadingAlert = false
                                }
                            }
                        }
                    }
            }
            .onMove(perform: { source, destination in
                print("passwds move \(source) to \(destination)")
            })
        }
        .onChange(of: model.currentPasswdId) { oldPasswdId, newPasswdId in
            model.onPasswdClick(passwdId: newPasswdId)
        }
        .navigationTitle(model.currentGroup?.groupName ?? "")
    }
}
