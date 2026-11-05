//
//  JobsSwiftUIBaseConfigDemoApp.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI
#if DEBUG
import JobsSwiftUIDebugPanel
#endif

/// SwiftUI App 的程序入口。它取代 UIKit 中由 AppDelegate 创建根窗口和根控制器的常见写法。
@main
struct JobsSwiftUIBaseConfigDemoApp: App {

#if DEBUG
    @UIApplicationDelegateAdaptor(JobsSwiftUIDebugAppDelegate.self) private var debugDelegate
    @AppStorage("com.jobs.swiftui.debugPanel.demoAppearance") private var debugDemoAppearance = "system"
#endif

    /// `Scene` 描述 App 可以展示的场景。
    /// `some Scene` 是“不透明返回类型”：编译器知道这里返回的是某个确定的 Scene 类型，
    /// 外部只需要知道它遵守 Scene 协议，不需要依赖 `WindowGroup<MainTabView>` 这类复杂具体类型。
    /// 它仍保留编译期类型信息，不等同于把不同 Scene 装进运行时容器的 `any Scene`。
    var body: some Scene {
        /// `WindowGroup` 为每个窗口会话创建一棵视图树，闭包中的 View 就是该窗口的根视图。
        WindowGroup {
#if DEBUG
            debugRootView
                .jobsSwiftUIDebugPanel()
                .preferredColorScheme((JobsSwiftUIDebugDemoAppearance(rawValue: debugDemoAppearance) ?? .system).colorScheme)
#else
            MainTabView()
#endif
        }
    }

#if DEBUG
    @ViewBuilder
    private var debugRootView: some View {
        let arguments = ProcessInfo.processInfo.arguments
        if let optionIndex = arguments.firstIndex(of: "--jobs-coverage-route") {
            if arguments.indices.contains(optionIndex + 1) {
                debugCoverageDestination(arguments[optionIndex + 1])
            } else {
                Text("巡检入口缺少页面路由 ID")
            }
        } else {
            MainTabView()
        }
    }

    @ViewBuilder
    private func debugCoverageDestination(_ routeID: String) -> some View {
        if let feature = DemoFeature(rawValue: routeID) {
            NavigationStack {
                feature.destination
                    .navigationTitle(feature.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .modifier(JobsCoverageReadyModifier(routeID: routeID))
            }
        } else if routeID == "gallery" {
            GalleryTabView()
                .modifier(JobsCoverageReadyModifier(routeID: routeID))
        } else if routeID == "about" {
            AboutTabView()
                .modifier(JobsCoverageReadyModifier(routeID: routeID))
        } else if routeID == "home" {
            MainTabView()
                .modifier(JobsCoverageReadyModifier(routeID: routeID))
        } else {
            Text("当前构建不包含巡检页面：\(routeID)")
        }
    }
#endif
}

#if DEBUG
/// 标记由实际页面的 onAppear 发布，不把启动参数存在当作已经进入页面。
private struct JobsCoverageReadyModifier: ViewModifier {

    let routeID: String
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                if appeared {
                    Text("巡检页面已就绪")
                        .foregroundStyle(.clear)
                        .frame(width: 1, height: 1)
                        .accessibilityIdentifier("jobs.coverage.ready.\(routeID)")
                        .allowsHitTesting(false)
                }
            }
            .onAppear {
                appeared = true
            }
            .onDisappear {
                appeared = false
            }
    }
}
#endif
