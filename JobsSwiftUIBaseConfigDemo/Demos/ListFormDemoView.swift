//
//  ListFormDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 对比 Form、Section 和普通数据集合的组合方式。
struct ListFormDemoView: View {

    @ObservedObject private var appPreferences = AppPreferences.shared

    @State private var notificationsEnabled = true
    @State private var accountType = "个人"
    
    private let items = [
        AppText.text("列表行"),
        AppText.text("分组标题"),
        AppText.text("系统图标"),
        AppText.text("只读信息"),
        AppText.text("表单输入")
    ]
    
    var body: some View {
        /// Form 会根据平台自动采用表单样式，并为 Toggle、Picker 等控件提供合适布局。
        Form {
            Section(AppText.text("表单")) {
                Toggle(AppText.text("允许通知"), isOn: $notificationsEnabled)
                Picker(AppText.text("账号类型"), selection: $accountType) {
                    Text(AppText.text("个人")).tag("个人")
                    Text(AppText.text("团队")).tag("团队")
                    Text(AppText.text("企业")).tag("企业")
                }
                LabeledContent(AppText.text("当前状态"), value: notificationsEnabled ? AppText.text("已开启") : AppText.text("已关闭"))
            }
            
            Section(AppText.text("列表")) {
                /// String 遵守 Hashable，因此静态且不重复的数据可用自身作为 id。
                ForEach(items, id: \.self) { item in
                    Label(AppText.text(item), systemImage: "checkmark.circle")
                }
            }
        }
    }
}
