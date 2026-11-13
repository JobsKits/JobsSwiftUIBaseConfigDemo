//
//  LayoutDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 演示 SwiftUI 的提议尺寸布局、懒加载网格和二维 Grid。
struct LayoutDemoView: View {

    @ObservedObject private var appPreferences = AppPreferences.shared

    /// 自适应列会尽量放入更多单元格，同时保证每格至少 82 点宽。
    private let columns = [
        GridItem(.adaptive(minimum: 82), spacing: 12)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("ViewThatFits")
                    .font(.title2.bold())
                /// ViewThatFits 按声明顺序尝试子视图，选择第一个能放进当前水平空间的方案。
                ViewThatFits(in: .horizontal) {
                    HStack {
                        DemoLayoutBadge(title: AppText.text("宽屏横排"), color: AppPalette.accent)
                        DemoLayoutBadge(title: AppText.text("自动适配"), color: AppPalette.success)
                        DemoLayoutBadge(title: AppText.text("优先尝试"), color: AppPalette.warm)
                    }
                    VStack(alignment: .leading) {
                        DemoLayoutBadge(title: AppText.text("窄屏竖排"), color: AppPalette.accent)
                        DemoLayoutBadge(title: AppText.text("自动适配"), color: AppPalette.success)
                        DemoLayoutBadge(title: AppText.text("优先尝试"), color: AppPalette.warm)
                    }
                }
                
                Text("LazyVGrid")
                    .font(.title2.bold())
                /// LazyVGrid 适合滚动长列表，屏幕外单元格会延后创建。
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(1...12, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(index.isMultiple(of: 2) ? AppPalette.accent : AppPalette.success)
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
                /// Grid 按 GridRow 对齐二维单元格，适合规模较小且需要行列对齐的内容。
                Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                    GridRow {
                        DemoGridCell(title: "A1", color: AppPalette.violet)
                        DemoGridCell(title: "A2", color: AppPalette.warm)
                    }
                    GridRow {
                        DemoGridCell(title: "B1", color: AppPalette.accent)
                        DemoGridCell(title: "B2", color: AppPalette.violet)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

/// 拆分小 View 可以降低父 body 的阅读成本，也能独立复用和预览。
private struct DemoLayoutBadge: View {

    @ObservedObject private var appPreferences = AppPreferences.shared
    
    let title: String
    let color: Color
    
    var body: some View {
        Text(AppText.text(title))
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(color, in: Capsule())
    }
}

/// Grid 单元格只接收展示数据，本身不拥有业务状态。
private struct DemoGridCell: View {

    @ObservedObject private var appPreferences = AppPreferences.shared
    
    let title: String
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(color)
            .frame(height: 64)
            .overlay {
                Text(AppText.text(title))
                    .font(.headline)
                    .foregroundStyle(.white)
            }
    }
}
