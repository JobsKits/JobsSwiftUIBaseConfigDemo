//
//  ListFormDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 对比 Form、Section 和普通数据集合的组合方式。
struct ListFormDemoView: View {

    @State private var notificationsEnabled = true
    @State private var accountType = "个人"
    
    private let items = [
        "列表行",
        "分组标题",
        "系统图标",
        "只读信息",
        "表单输入"
    ]
    
    var body: some View {
        /// Form 会根据平台自动采用表单样式，并为 Toggle、Picker 等控件提供合适布局。
        Form {
            Section("表单") {
                Toggle("允许通知", isOn: $notificationsEnabled)
                Picker("账号类型", selection: $accountType) {
                    Text("个人").tag("个人")
                    Text("团队").tag("团队")
                    Text("企业").tag("企业")
                }
                LabeledContent("当前状态", value: notificationsEnabled ? "已开启" : "已关闭")
            }
            
            Section("列表") {
                /// String 遵守 Hashable，因此静态且不重复的数据可用自身作为 id。
                ForEach(items, id: \.self) { item in
                    Label(item, systemImage: "checkmark.circle")
                }
            }
        }
    }
}
