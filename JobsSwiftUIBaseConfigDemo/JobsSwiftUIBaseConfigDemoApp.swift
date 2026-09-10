//
//  JobsSwiftUIBaseConfigDemoApp.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// SwiftUI App 的程序入口。它取代 UIKit 中由 AppDelegate 创建根窗口和根控制器的常见写法。
@main
struct JobsSwiftUIBaseConfigDemoApp: App {

    /// `Scene` 描述 App 可以展示的场景。
    /// `some Scene` 是“不透明返回类型”：编译器知道这里返回的是某个确定的 Scene 类型，
    /// 外部只需要知道它遵守 Scene 协议，不需要依赖 `WindowGroup<MainTabView>` 这类复杂具体类型。
    /// 它仍保留编译期类型信息，不等同于把不同 Scene 装进运行时容器的 `any Scene`。
    var body: some Scene {
        /// `WindowGroup` 为每个窗口会话创建一棵视图树，闭包中的 View 就是该窗口的根视图。
        WindowGroup {
            MainTabView()
        }
    }
}
