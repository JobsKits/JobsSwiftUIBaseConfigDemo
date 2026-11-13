//
//  ButtonMenuDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 演示 Button 的 action/label 双闭包，以及 Menu、Picker、ControlGroup 的组合方式。
struct ButtonMenuDemoView: View {

    @ObservedObject private var appPreferences = AppPreferences.shared

    /// View 是值类型，但 `@State` 的存储由 SwiftUI 托管，因此重建 View 时状态不会随临时值一起丢失。
    @State private var tapCount = 0
    @State private var favoriteAction = "收藏"
    @State private var playbackState = "停止"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text(AppText.text("Button 样式"))
                    .font(.title2.bold())
                
                Button {
                    /// 修改 State 后无需手动刷新 Label，SwiftUI 会重新计算依赖 tapCount 的 body。
                    tapCount += 1
                } label: {
                    Label(AppText.format("普通按钮：%@", String(tapCount)), systemImage: "hand.tap")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppPalette.accent)
                
                HStack {
                    /// destructive 是语义角色，系统可据此提供颜色、确认或无障碍提示。
                    Button(role: .destructive) {
                        tapCount = 0
                    } label: {
                        Label(AppText.text("重置"), systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    
                    Button {
                        favoriteAction = "已置顶"
                    } label: {
                        Label(AppText.text("胶囊按钮"), systemImage: "pin")
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                }
                
                Divider()
                
                Menu {
                    /// Menu 的内容也由 ViewBuilder 组合，可混放按钮、分隔线和选择器。
                    Button(AppText.text("复制"), systemImage: "doc.on.doc") {
                        favoriteAction = "复制"
                    }
                    Button(AppText.text("标记"), systemImage: "tag") {
                        favoriteAction = "标记"
                    }
                    Divider()
                    Picker(AppText.text("动作"), selection: $favoriteAction) {
                        /// 每个 tag 的类型必须与 selection 的值类型一致，这里都是 String。
                        Text(AppText.text("收藏")).tag("收藏")
                        Text(AppText.text("稍后看")).tag("稍后看")
                        Text(AppText.text("已归档")).tag("已归档")
                    }
                } label: {
                    Label(AppText.format("Menu 菜单：%@", AppText.text(favoriteAction)), systemImage: "ellipsis.circle")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppPalette.accent)
                
                ControlGroup {
                    /// ControlGroup 表达“一组相关操作”，最终外观由当前平台和容器决定。
                    Button(AppText.text("播放"), systemImage: "play.fill") {
                        playbackState = "播放"
                    }
                    Button(AppText.text("暂停"), systemImage: "pause.fill") {
                        playbackState = "暂停"
                    }
                    Button(AppText.text("停止"), systemImage: "stop.fill") {
                        playbackState = "停止"
                    }
                }
                .controlGroupStyle(.automatic)
                LabeledContent(AppText.text("播放状态"), value: AppText.text(playbackState))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}
