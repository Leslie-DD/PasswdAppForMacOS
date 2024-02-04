//
//  DetailView.swift
//  passwd
//
//  Created by Leslie D on 2024/2/6.
//

import SwiftUI
import AppKit


struct PasswdsView: View {
    
    @EnvironmentObject var model: DataModel
    
    private var group: Group? = nil
    
    @State private var isSearching: Bool = false
    @State private var detailEditable: Bool = false
    
    @State private var editButtonImageViewEnabled = true
    @State private var cancelEditButtonImageViewEnabled = false
    
    @State private var confirmDeletePasswdAlert = false
    
    @State private var deletePasswd: Passwd? = nil
    
    @State private var originTitle: String = ""
    @State private var originUsername: String = ""
    @State private var originPassword: String = ""
    @State private var originLink: String = ""
    @State private var originComment: String = ""
    
    var body: some View {
        
        HStack {
            List(model.currentPasswds, id: \.id) { passwd in
                PasswdItemView(passwd: passwd, selected: model.currentPasswd?.id == passwd.id) {
                    model.onPasswdClick(passwd: passwd)
                }.contextMenu {
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
            
            VStack(spacing: 10) {
                DetailSecureItemView(value: $model.title, hint: "Title", editable: $detailEditable)
                DetailSecureItemView(value: $model.usernameString, hint: "Username", enableSecure: true, editable: $detailEditable)
                DetailSecureItemView(value: $model.passwordString, hint: "Password", enableSecure: true, editable: $detailEditable)
                DetailSecureItemView(value: $model.link, hint: "link", editable: $detailEditable)
                CommentView(value: $model.comment, editable: $detailEditable)
                    .padding([.top], 6)
                
                HStack {
                    Spacer()
                    
                    ButtonImageViewWithReplace(isOrigin: $editButtonImageViewEnabled, originSystemName: "square.and.pencil", replacedSystemName: "square.and.arrow.up") {
                        if (editButtonImageViewEnabled) {
                            detailEditable = true
                            
                            editButtonImageViewEnabled = false
                            cancelEditButtonImageViewEnabled = true
                            
                            originTitle = model.title
                            originUsername = model.usernameString
                            originPassword = model.passwordString
                            originLink = model.link
                            originComment = model.comment
                        } else {
                            if (model.title.isEmpty) {
                                return
                            }
                            let updatePasswd = Passwd(id: model.currentPasswd?.id ?? -1,
                                                      userId: model.userId,
                                                      groupId: model.currentPasswd?.groupId ?? -1,
                                                      title: model.title,
                                                      usernameString: model.usernameString,
                                                      passwordString: model.passwordString,
                                                      link: model.link,
                                                      comment: model.comment
                            )
                            
                            model.loadingAlert.toggle()
                            model.updatePasswd(passwd: updatePasswd) { result in
                                originTitle = ""
                                originUsername = ""
                                originPassword = ""
                                originLink = ""
                                originComment = ""
                                model.loadingAlert.toggle()
                            }
                            
                            detailEditable = false
                            
                            editButtonImageViewEnabled = true
                            cancelEditButtonImageViewEnabled = false
                        }
                        
                    }
                    ButtonImageView(enabled: $cancelEditButtonImageViewEnabled, systemName: "xmark.circle") {
                        model.title = originTitle
                        model.usernameString = originUsername
                        model.passwordString = originPassword
                        model.link = originLink
                        model.comment = originComment
                        
                        originTitle = ""
                        originUsername = ""
                        originPassword = ""
                        originLink = ""
                        originComment = ""
                        
                        detailEditable = false
                        
                        editButtonImageViewEnabled = true
                        cancelEditButtonImageViewEnabled = false
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.top)
            .padding([.bottom], 6)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            Button("") {
                isSearching = true
            }
            .keyboardShortcut("f", modifiers: .command).hidden()
        )
        .searchable(text: $model.searchText, isPresented: $isSearching, placement: .automatic, prompt: Text("(Command + F) Search"))
    }
    
}

struct PasswdItemView : View {
    var passwd: Passwd
    var selected: Bool
    var action: () -> Void
    
    var body: some View {
        Text("\(passwd.title)")
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selected ? Color.blue : Color.clear)
            .foregroundColor(selected ? Color.white : Color.primary)
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .lineLimit(1)
            .truncationMode(.tail)
            .onTapGesture {
                action()
            }
    }
}

struct DetailSecureItemView : View {
    
    var value: Binding<String>
    var hint: String
    
    var enableSecure: Bool = false
    var editable: Binding<Bool>
    
    @State private var buttonImageViewEnabled = true
    
    @State private var isSecured: Bool = true
    
    var body: some View {
        HStack {
            if (enableSecure && isSecured) {
                SecureField(hint, text: value)
                    .disabled(!editable.wrappedValue)
            } else {
                TextField(hint, text: value)
                    .disabled(!editable.wrappedValue)
            }
            if (enableSecure) {
                ButtonImageView(enabled: $buttonImageViewEnabled, systemName: "eye") {
                    isSecured.toggle()
                }
                
                ButtonImageView(enabled: $buttonImageViewEnabled, systemName: "doc.on.doc") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(value.wrappedValue, forType: .string)
                }
            }
        }
    }
}

struct CommentView : View {
    
    var value: Binding<String>
    var editable: Binding<Bool>
    
    var body: some View {
        HStack {
            TextEditor(text: value)
                .disabled(!editable.wrappedValue)
        }
        
    }
}

struct ButtonImageView : View {
    
    @State private var isHovering = false
    @State private var showAlert = false
    
    @State private var bounceTrigger = false
    
    var enabled: Binding<Bool>
    
    var systemName: String
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
            showAlert.toggle()
        }) {
            Image(systemName: systemName)
                .frame(maxHeight: 20)
//                .symbolEffect(.bounce, options:.nonRepeating, value: bounceTrigger)
                .scaleEffect(isHovering ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isHovering)
        }
        .padding(6)
        .background(isHovering ? Color.customGray : Color.clear)
        .clipShape(RoundedRectangle(
            cornerRadius: 4,
            style: .continuous
        ))
        .buttonStyle(PlainButtonStyle())
        .onContinuousHover { phase in
            switch phase {
            case .active:
                if (!isHovering) {
                    bounceTrigger.toggle()
                }
                isHovering = true
            case .ended:
                isHovering = false
            }
        }
        .disabled(!enabled.wrappedValue)
    }
}

struct ButtonImageViewWithReplace : View {
    
    @State private var isHovering = false
    @State private var showAlert = false
    
    @State private var bounceTrigger = false
    
    var isOrigin: Binding<Bool>
    
    var originSystemName: String
    var replacedSystemName: String
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
            showAlert.toggle()
        }) {
            Image(systemName: isOrigin.wrappedValue ? originSystemName : replacedSystemName)
                .frame(maxHeight: 20)
                .scaleEffect(isHovering ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isHovering)
        }
        .contentTransition(.symbolEffect(.replace))
        .padding(6)
        .background(isHovering ? Color.customGray : Color.clear)
        .clipShape(RoundedRectangle(
            cornerRadius: 4,
            style: .continuous
        ))
        .buttonStyle(PlainButtonStyle())
        .onContinuousHover { phase in
            switch phase {
            case .active:
                if (!isHovering) {
                    bounceTrigger.toggle()
                }
                isHovering = true
            case .ended:
                isHovering = false
            }
        }
    }
}
