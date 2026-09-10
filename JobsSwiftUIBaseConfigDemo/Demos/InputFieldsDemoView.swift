//
//  InputFieldsDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 演示文本输入与焦点管理；输入控件通过 Binding 直接读写 View 拥有的状态。
struct InputFieldsDemoView: View {

    @State private var username = "Jobs"
    @State private var password = ""
    @State private var notes = "这里可以输入多行文本。"
    /// `@FocusState` 专门描述当前焦点；可选值为 nil 时表示所有输入框都失焦。
    @FocusState private var focusedField: InputField?

    var body: some View {
        Form {
            Section("单行输入") {
                /// `$username` 是双向绑定：用户输入更新 State，State 变化也会回填 TextField。
                TextField("用户名", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .username)
                
                SecureField("密码", text: $password)
                    /// SecureField 只负责遮挡显示，不等于对字符串做了加密存储。
                    .focused($focusedField, equals: .password)
            }
            
            Section("多行输入") {
                /// TextEditor 自身没有固定高度，放在 Form 中时需要给出最小高度。
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
            /// `.keyboard` 把工具项放到键盘上方；设置 nil 即可统一收起键盘。
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完成") {
                    focusedField = nil
                }
            }
        }
    }
}

/// 用枚举代替多个 Bool，保证同一时刻最多只有一个输入框拥有焦点。
private enum InputField: Hashable {
    case username
    case password
    case notes
    
    var title: String {
        switch self {
        /// 用户名输入框的可读名称。
        case .username: "用户名"
        /// 密码输入框的可读名称。
        case .password: "密码"
        /// 备注输入框的可读名称。
        case .notes: "备注"
        }
    }
}
