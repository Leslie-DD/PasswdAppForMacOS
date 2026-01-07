//
//  PasswdsView.swift
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
                    .frame(alignment: .leading)
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
                movePasswd(from: source, to: destination)
            })
        }
        .onChange(of: model.currentPasswdId) { oldPasswdId, newPasswdId in
            model.onPasswdClick(passwdId: newPasswdId)
        }
        .navigationTitle(model.currentGroup?.groupName ?? "")
    }
    
    private func movePasswd(from source: IndexSet, to destination: Int) {
        print("movePasswd from \(source) to \(destination)")
        guard let sourceIndex = source.first else { return }
        
        // 获取要移动的passwd
        let movedPasswd = model.currentPasswds[sourceIndex]
        
        // 计算目标位置
        var afterPasswdId: Int? = nil
        
        if destination == 0 {
            // 移动到开头
            afterPasswdId = nil
        } else if destination >= model.currentPasswds.count {
            // 移动到末尾
            afterPasswdId = -1 // 使用特殊值表示移动到末尾
        } else {
            // 移动到指定passwd之后
            let targetIndex = destination > sourceIndex ? destination - 1 : destination
            print("movePasswd targetIndex: \(targetIndex)")
            if targetIndex < model.currentPasswds.count {
                if targetIndex < sourceIndex {
                    afterPasswdId = model.currentPasswds[targetIndex - 1].id
                } else {
                    afterPasswdId = model.currentPasswds[targetIndex].id
                }
            }
        }
        
        // 调用API移动passwd
        model.loadingAlert = true
        model.movePasswd(passwdId: movedPasswd.id, afterPasswdId: afterPasswdId) { result in
            DispatchQueue.main.async {
                model.loadingAlert = false
                switch result {
                case .success(_):
                    print("Passwd移动成功")
                case .failure(let error):
                    print("Passwd移动失败: \(error)")
                }
            }
        }
    }
    
}
