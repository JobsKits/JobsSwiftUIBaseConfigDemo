//
//  AboutTabView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 纯展示页面不需要状态；输入不变时，整个 View 可以保持为简单值类型。
struct AboutTabView: View {

    @ObservedObject private var appPreferences = AppPreferences.shared

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        NavigationStack {
            /// List/Section 会自动获得平台原生的分组、间距和可访问性行为。
            List {
                Section(AppText.text("工程信息")) {
                    LabeledContent(AppText.text("项目类型"), value: "iOS App")
                    LabeledContent(AppText.text("实现方式"), value: AppText.text("SwiftUI 原生"))
                    LabeledContent(AppText.text("依赖"), value: AppText.text("系统控件与本地调试 Pod"))
                    LabeledContent(AppText.text("Demo 数量"), value: "\(DemoFeature.allCases.count)")
                }
                
                Section(AppText.text("入口结构")) {
                    /// Label 将图标和文字组合为一个语义元素，比手写 HStack 更适合系统列表。
                    Label(AppText.text("TabView 作为主 TabBar 容器"), systemImage: "rectangle.split.3x1")
                    Label(AppText.text("Demo 列表使用 NavigationStack 推出详情页"), systemImage: "point.forward.to.point.capsulepath")
                    Label(AppText.text("Timer 页面演示非 UI 控件能力"), systemImage: "timer")
                }
            }
            .navigationTitle(AppText.text("关于"))
            .navigationBarTitleDisplayMode(dynamicTypeSize.isAccessibilitySize ? .inline : .large)
        }
    }
}
