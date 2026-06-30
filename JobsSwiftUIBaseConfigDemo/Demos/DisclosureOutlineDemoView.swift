//
//  DisclosureOutlineDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct DisclosureOutlineDemoView: View {
    
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
                DisclosureGroup("展开系统控件") {
                    Label("TextField", systemImage: "keyboard")
                    Label("Toggle", systemImage: "switch.2")
                    Label("Picker", systemImage: "list.bullet")
                }
            }
            
            Section("OutlineGroup") {
                OutlineGroup(nodes, children: \.children) { node in
                    Label(node.title, systemImage: node.symbol)
                }
            }
        }
    }
}

private struct DemoTreeNode: Identifiable {
    let id = UUID()
    let title: String
    let symbol: String
    var children: [DemoTreeNode]?
}
