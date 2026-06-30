//
//  InputFieldsDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct InputFieldsDemoView: View {
    
    @State private var username = "Jobs"
    @State private var password = ""
    @State private var notes = "这里可以输入多行文本。"
    @FocusState private var focusedField: InputField?
    
    var body: some View {
        Form {
            Section("单行输入") {
                TextField("用户名", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .username)
                
                SecureField("密码", text: $password)
                    .focused($focusedField, equals: .password)
            }
            
            Section("多行输入") {
                TextEditor(text: $notes)
                    .frame(minHeight: 120)
                    .focused($focusedField, equals: .notes)
            }
            
            Section("当前状态") {
                LabeledContent("用户名", value: username)
                LabeledContent("密码长度", value: "\(password.count)")
                LabeledContent("焦点", value: focusedField?.title ?? "无")
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完成") {
                    focusedField = nil
                }
            }
        }
    }
}

private enum InputField: Hashable {
    case username
    case password
    case notes
    
    var title: String {
        switch self {
        case .username: "用户名"
        case .password: "密码"
        case .notes: "备注"
        }
    }
}
