//
//  PasswdsView.swift
//  passwd
//
//  Created by EvanD on 2025/9/28.
//


import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct PasswdsView: View {
    
    @EnvironmentObject var model: DataModel
    
    @State private var confirmDeletePasswdAlert = false
    @State private var deletePasswd: Passwd? = nil
    
    @State private var exportErrorAlert = false
    @State private var exportErrorMessage = ""
    
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: exportPasswords) {
                    Image(systemName: "square.and.arrow.up")
                }
                .help("导出所有密码到 JSON 文件")
            }
        }
        .alert("导出失败", isPresented: $exportErrorAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(exportErrorMessage)
        }
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
    
    private func exportPasswords() {
        DispatchQueue.main.async {
            guard !self.model.passwdsMap.isEmpty else {
                self.exportErrorMessage = "没有密码数据可导出"
                self.exportErrorAlert = true
                return
            }
            
            guard let jsonData = self.model.exportAllPasswords() else {
                self.exportErrorMessage = "导出数据失败，请重试"
                self.exportErrorAlert = true
                return
            }
            
            let savePanel = NSSavePanel()
            savePanel.title = "导出密码数据"
            savePanel.message = "选择保存 JSON 文件的位置"
            savePanel.nameFieldStringValue = "passwords_export_\(Date().timeIntervalSince1970).json"
            savePanel.allowedContentTypes = [UTType.json]
            
            // 尝试获取当前窗口
            if let window = NSApplication.shared.keyWindow {
                savePanel.beginSheetModal(for: window) { response in
                    if response == .OK, let url = savePanel.url {
                        do {
                            try jsonData.write(to: url)
                            print("导出成功: \(url.path)")
                        } catch {
                            DispatchQueue.main.async {
                                self.exportErrorMessage = "保存文件失败: \(error.localizedDescription)"
                                self.exportErrorAlert = true
                            }
                        }
                    }
                }
            } else {
                // 如果没有窗口，使用 runModal
                let response = savePanel.runModal()
                if response == .OK, let url = savePanel.url {
                    do {
                        try jsonData.write(to: url)
                        print("导出成功: \(url.path)")
                    } catch {
                        DispatchQueue.main.async {
                            self.exportErrorMessage = "保存文件失败: \(error.localizedDescription)"
                            self.exportErrorAlert = true
                        }
                    }
                }
            }
        }
    }
    
}
