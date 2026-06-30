//
//  ListFormDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

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
                ForEach(items, id: \.self) { item in
                    Label(item, systemImage: "checkmark.circle")
                }
            }
        }
    }
}
