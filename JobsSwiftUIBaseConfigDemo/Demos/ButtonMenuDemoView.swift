//
//  ButtonMenuDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 演示 Button 的 action/label 双闭包，以及 Menu、Picker、ControlGroup 的组合方式。
struct ButtonMenuDemoView: View {

    /// View 是值类型，但 `@State` 的存储由 SwiftUI 托管，因此重建 View 时状态不会随临时值一起丢失。
    @State private var tapCount = 0
    @State private var favoriteAction = "收藏"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Button 样式")
                    .font(.title2.bold())
                
                Button {
                    /// 修改 State 后无需手动刷新 Label，SwiftUI 会重新计算依赖 tapCount 的 body。
                    tapCount += 1
                } label: {
                    Label("普通按钮：\(tapCount)", systemImage: "hand.tap")
                }
                .buttonStyle(.borderedProminent)
                
                HStack {
                    /// destructive 是语义角色，系统可据此提供颜色、确认或无障碍提示。
                    Button(role: .destructive) {
                        tapCount = 0
                    } label: {
                        Label("重置", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        favoriteAction = "已置顶"
                    } label: {
                        Label("胶囊按钮", systemImage: "pin")
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                }
                
                Divider()
                
                Menu {
                    /// Menu 的内容也由 ViewBuilder 组合，可混放按钮、分隔线和选择器。
                    Button("复制", systemImage: "doc.on.doc") {
                        favoriteAction = "复制"
                    }
                    Button("标记", systemImage: "tag") {
                        favoriteAction = "标记"
                    }
                    Divider()
                    Picker("动作", selection: $favoriteAction) {
                        /// 每个 tag 的类型必须与 selection 的值类型一致，这里都是 String。
                        Text("收藏").tag("收藏")
                        Text("稍后看").tag("稍后看")
                        Text("已归档").tag("已归档")
                    }
                } label: {
                    Label("Menu 菜单：\(favoriteAction)", systemImage: "ellipsis.circle")
                }
                .buttonStyle(.borderedProminent)
                
                ControlGroup {
                    /// ControlGroup 表达“一组相关操作”，最终外观由当前平台和容器决定。
                    Button("播放", systemImage: "play.fill") {}
                    Button("暂停", systemImage: "pause.fill") {}
                    Button("停止", systemImage: "stop.fill") {}
                }
                .controlGroupStyle(.automatic)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}
