//
//  MainTabView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// App 的根视图：用一个状态值统一控制当前选中的 Tab。
struct MainTabView: View {

    /// `@State` 由 SwiftUI 持有，值改变后会让依赖它的 `body` 重新计算。
    @State private var selectedTab: AppTab = .demos

    /// `View` 协议只要求提供 `body`；这里声明的是视图结构，不是像 UIKit 那样立刻创建并摆放控件。
    var body: some View {
        /// `$selectedTab` 是 `Binding<AppTab>`，允许 TabView 读取并反向写回选中状态。
        TabView(selection: $selectedTab) {
            DemoListView()
                .tabItem {
                    Label("Demo", systemImage: "list.bullet.rectangle")
                }
                .tag(AppTab.demos)
            
            GalleryTabView()
                .tabItem {
                    Label("速览", systemImage: "square.grid.2x2")
                }
                .tag(AppTab.gallery)
            
            AboutTabView()
                .tabItem {
                    Label("关于", systemImage: "info.circle")
                }
                .tag(AppTab.about)
        }
    }
}

/// `Hashable` 表示值既能判断是否相等，也能生成哈希值，因此可用于 Set 元素、Dictionary Key 等场景。
/// TabView 用它比较 `selection` 与各页面的 `tag`；这种无关联值枚举由编译器自动生成 Hashable 实现。
private enum AppTab: Hashable {
    case demos
    case gallery
    case about
}
