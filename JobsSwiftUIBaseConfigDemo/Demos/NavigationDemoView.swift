//
//  NavigationDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 当前页面复用上层的 NavigationStack，只声明链接和工具栏，不重复创建导航容器。
struct NavigationDemoView: View {

    @ObservedObject private var appPreferences = AppPreferences.shared

    @State private var showToolbarState = false

    var body: some View {
        List {
            Section("NavigationLink") {
                /// NavigationLink 的第一个闭包描述目标页面，label 闭包描述当前可点击行。
                ForEach(NavigationSample.allCases) { sample in
                    NavigationLink {
                        NavigationDetailView(sample: sample)
                    } label: {
                        Label(sample.title, systemImage: sample.symbol)
                    }
                    .accessibilityIdentifier("jobs.navigation.open.\(sample.rawValue)")
                }
            }
            
            Section(AppText.text("Toolbar 状态")) {
                LabeledContent(AppText.text("右侧按钮"), value: showToolbarState ? AppText.text("已点亮") : AppText.text("未点亮"))
            }
        }
        .toolbar {
            /// topBarTrailing 对应 UIKit 导航栏右侧区域。
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showToolbarState.toggle()
                } label: {
                    Image(systemName: showToolbarState ? "star.fill" : "star")
                }
                .accessibilityLabel(AppText.text("右侧按钮"))
                .accessibilityValue(AppText.text(showToolbarState ? "已点亮" : "未点亮"))
            }
        }
    }
}

/// 导航目标通过不可变参数接收选中的样例，不需要再保存一份 State。
private struct NavigationDetailView: View {

    @ObservedObject private var appPreferences = AppPreferences.shared
    
    let sample: NavigationSample
    
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: sample.symbol)
                .font(.system(size: 64))
                .foregroundStyle(.blue)
            Text(sample.title)
                .font(.title.bold())
                .accessibilityIdentifier("jobs.coverage.page.navigation.\(sample.rawValue)")
            Text(sample.message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        /// 导航标题修饰目标页面本身，由外层 NavigationStack 负责实际显示。
        .navigationTitle(sample.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// 枚举把导航样例的数据集中管理，并提供稳定身份给 ForEach。
private enum NavigationSample: String, CaseIterable, Identifiable {
    case push
    case toolbar
    case inlineTitle
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        /// 普通 Push 样例的标题。
        case .push: AppText.text("普通 Push")
        /// 工具栏样例的标题。
        case .toolbar: AppText.text("工具栏")
        /// 内联标题样例的标题。
        case .inlineTitle: AppText.text("内联标题")
        }
    }
    
    var symbol: String {
        switch self {
        /// 普通 Push 样例的图标。
        case .push: "arrowshape.forward"
        /// 工具栏样例的图标。
        case .toolbar: "wrench.and.screwdriver"
        /// 内联标题样例的图标。
        case .inlineTitle: "textformat.size"
        }
    }
    
    var message: String {
        switch self {
        /// 说明 NavigationLink 的入栈语义。
        case .push: AppText.text("NavigationLink 会在当前 NavigationStack 内推出新页面。")
        /// 说明 toolbar 的挂载能力。
        case .toolbar: AppText.text("toolbar 可以挂载导航栏按钮、底部按钮和键盘按钮。")
        /// 说明导航标题的展示模式。
        case .inlineTitle: AppText.text("navigationBarTitleDisplayMode 可以控制标题展示样式。")
        }
    }
}
