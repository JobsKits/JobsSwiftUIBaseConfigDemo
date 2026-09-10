//
//  DisclosureOutlineDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 对比手工折叠的一层内容和由递归数据自动生成的树形内容。
struct DisclosureOutlineDemoView: View {

    /// children 仍是同类型数组，这种“递归模型”可以表达任意层级的树。
    private let nodes = [
        DemoTreeNode(
            title: "SwiftUI",
            symbol: "swift",
            children: [
                DemoTreeNode(title: "Controls", symbol: "slider.horizontal.3"),
                DemoTreeNode(title: "Layout", symbol: "square.grid.3x3"),
                DemoTreeNode(title: "Navigation", symbol: "point.forward.to.point.capsulepath")
            ]
        ),
        DemoTreeNode(
            title: "Foundation",
            symbol: "shippingbox",
            children: [
                DemoTreeNode(title: "Timer", symbol: "timer"),
                DemoTreeNode(title: "URL", symbol: "link")
            ]
        )
    ]
    
    var body: some View {
        List {
            Section("DisclosureGroup") {
                /// 未提供 isExpanded Binding 时，DisclosureGroup 在内部管理展开状态。
                DisclosureGroup("展开系统控件") {
                    Label("TextField", systemImage: "keyboard")
                    Label("Toggle", systemImage: "switch.2")
                    Label("Picker", systemImage: "list.bullet")
                }
            }
            
            Section("OutlineGroup") {
                /// children KeyPath 告诉 OutlineGroup 去哪里寻找下一层节点；nil 表示叶子节点。
                OutlineGroup(nodes, children: \.children) { node in
                    Label(node.title, systemImage: node.symbol)
                }
            }
        }
    }
}

/// OutlineGroup 需要稳定 id 来区分节点；这里的 UUID 在该 View 实例生命周期内保持不变。
private struct DemoTreeNode: Identifiable {
    let id = UUID()
    let title: String
    let symbol: String
    var children: [DemoTreeNode]?
}
