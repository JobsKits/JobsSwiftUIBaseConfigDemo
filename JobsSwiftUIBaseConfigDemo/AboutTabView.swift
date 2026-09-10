//
//  AboutTabView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 纯展示页面不需要状态；输入不变时，整个 View 可以保持为简单值类型。
struct AboutTabView: View {

    var body: some View {
        NavigationStack {
            /// List/Section 会自动获得平台原生的分组、间距和可访问性行为。
            List {
                Section("工程信息") {
                    LabeledContent("项目类型", value: "iOS App")
                    LabeledContent("实现方式", value: "SwiftUI 原生")
                    LabeledContent("依赖", value: "无 Pod / 无三方库")
                    LabeledContent("Demo 数量", value: "\(DemoFeature.allCases.count)")
                }
                
                Section("入口结构") {
                    /// Label 将图标和文字组合为一个语义元素，比手写 HStack 更适合系统列表。
                    Label("TabView 作为主 TabBar 容器", systemImage: "rectangle.split.3x1")
                    Label("Demo 列表使用 NavigationStack 推出详情页", systemImage: "point.forward.to.point.capsulepath")
                    Label("Timer 页面演示非 UI 控件能力", systemImage: "timer")
                }
            }
            .navigationTitle("关于")
        }
    }
}
