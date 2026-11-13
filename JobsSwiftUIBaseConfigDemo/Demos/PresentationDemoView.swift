//
//  PresentationDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 用三个独立状态演示半屏、浮层和全屏三种系统展示方式。
struct PresentationDemoView: View {

    @ObservedObject private var appPreferences = AppPreferences.shared

    @State private var showSheet = false
    @State private var showPopover = false
    @State private var showFullScreenCover = false
    
    var body: some View {
        List {
            Section(AppText.text("模态展示")) {
                Button(AppText.text("显示 Sheet")) {
                    showSheet = true
                }
                .accessibilityIdentifier("jobs.presentation.open.sheet")
                Button(AppText.text("显示 Popover")) {
                    showPopover = true
                }
                .accessibilityIdentifier("jobs.presentation.open.popover")
                .popover(isPresented: $showPopover) {
                    PresentationContentView(title: "Popover", symbol: "bubble.left.and.bubble.right")
                        .frame(width: 320)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button(AppText.text("显示 FullScreenCover")) {
                    showFullScreenCover = true
                }
                .accessibilityIdentifier("jobs.presentation.open.fullScreenCover")
            }
        }
        /// sheet 依附于当前 View；presentationDetents 定义用户可以停留的高度档位。
        .sheet(isPresented: $showSheet) {
            PresentationContentView(title: "Sheet", symbol: "rectangle.bottomthird.inset.filled")
                .presentationDetents([.medium, .large])
        }
        .fullScreenCover(isPresented: $showFullScreenCover) {
            PresentationContentView(title: "FullScreenCover", symbol: "rectangle.fill")
        }
    }
}

/// 三种展示方式复用同一个内容 View，仅通过初始化参数改变文字和图标。
private struct PresentationContentView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var appPreferences = AppPreferences.shared
    
    let title: String
    let symbol: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 56))
                .foregroundStyle(.blue)
            Text(AppText.text(title))
                .font(.title.bold())
                .accessibilityIdentifier("jobs.coverage.page.presentation.\(title)")
            Text(AppText.text("这是 SwiftUI 原生的页面展示能力。"))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            Button(AppText.text("关闭")) {
                dismiss()
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("jobs.presentation.close.\(title)")
        }
        .padding()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("jobs.presentation.content.\(title)")
    }
}
