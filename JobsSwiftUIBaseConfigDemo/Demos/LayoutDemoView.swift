//
//  LayoutDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct LayoutDemoView: View {
    
    private let columns = [
        GridItem(.adaptive(minimum: 82), spacing: 12)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("ViewThatFits")
                    .font(.title2.bold())
                ViewThatFits(in: .horizontal) {
                    HStack {
                        DemoLayoutBadge(title: "宽屏横排", color: .blue)
                        DemoLayoutBadge(title: "自动适配", color: .green)
                        DemoLayoutBadge(title: "优先尝试", color: .orange)
                    }
                    VStack(alignment: .leading) {
                        DemoLayoutBadge(title: "窄屏竖排", color: .blue)
                        DemoLayoutBadge(title: "自动适配", color: .green)
                        DemoLayoutBadge(title: "优先尝试", color: .orange)
                    }
                }
                
                Text("LazyVGrid")
                    .font(.title2.bold())
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(1...12, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(index.isMultiple(of: 2) ? .blue : .green)
                            .frame(height: 72)
                            .overlay {
                                Text("\(index)")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                    }
                }
                
                Text("Grid")
                    .font(.title2.bold())
                Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                    GridRow {
                        DemoGridCell(title: "A1", color: .purple)
                        DemoGridCell(title: "A2", color: .orange)
                    }
                    GridRow {
                        DemoGridCell(title: "B1", color: .teal)
                        DemoGridCell(title: "B2", color: .pink)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

private struct DemoLayoutBadge: View {
    
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(color, in: Capsule())
    }
}

private struct DemoGridCell: View {
    
    let title: String
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(color)
            .frame(height: 64)
            .overlay {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
    }
}
