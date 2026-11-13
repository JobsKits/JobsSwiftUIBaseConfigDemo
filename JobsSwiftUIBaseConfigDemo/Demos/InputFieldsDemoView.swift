//
//  InputFieldsDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 演示文本输入与焦点管理；输入控件通过 Binding 直接读写 View 拥有的状态。
struct InputFieldsDemoView: View {

    @ObservedObject private var appPreferences = AppPreferences.shared

    @State private var username = "Jobs"
    @State private var password = ""
    @State private var notes = AppText.text("这里可以输入多行文本。")
    /// `@FocusState` 专门描述当前焦点；可选值为 nil 时表示所有输入框都失焦。
    @FocusState private var focusedField: InputField?

    var body: some View {
        Form {
            Section(AppText.text("单行输入")) {
                /// `$username` 是双向绑定：用户输入更新 State，State 变化也会回填 TextField。
                TextField(AppText.text("用户名"), text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .username)
                
                SecureField(AppText.text("密码"), text: $password)
                    /// SecureField 只负责遮挡显示，不等于对字符串做了加密存储。
                    .focused($focusedField, equals: .password)
            }
            
            Section(AppText.text("多行输入")) {
                /// TextEditor 自身没有固定高度，放在 Form 中时需要给出最小高度。
                TextEditor(text: $notes)
                    .frame(minHeight: 120)
                    .focused($focusedField, equals: .notes)
                    .accessibilityLabel(AppText.text("备注"))
            }
            
            Section(AppText.text("当前状态")) {
                LabeledContent(AppText.text("用户名"), value: username)
                LabeledContent(AppText.text("密码长度"), value: "\(password.count)")
                LabeledContent(AppText.text("焦点"), value: focusedField?.title ?? AppText.text("无"))
            }
        }
        .toolbar {
            /// `.keyboard` 把工具项放到键盘上方；设置 nil 即可统一收起键盘。
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(AppText.text("完成")) {
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
        case .username: AppText.text("用户名")
        /// 密码输入框的可读名称。
        case .password: AppText.text("密码")
        /// 备注输入框的可读名称。
        case .notes: AppText.text("备注")
        }
    }
}
