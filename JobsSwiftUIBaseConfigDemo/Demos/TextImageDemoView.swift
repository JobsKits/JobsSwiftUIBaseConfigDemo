//
//  TextImageDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 演示最基础的声明式视图组合：容器负责布局，修饰符负责外观和行为。
struct TextImageDemoView: View {

    var body: some View {
        /// ScrollView 只提供滚动能力，内部仍需 VStack 决定子视图如何排列。
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("系统文本")
                        /// 每个修饰符都会返回一个新的 View 值，原 Text 值不会被原地修改。
                        .font(.largeTitle.bold())
                    Text("SwiftUI 的 Text 可以组合字体、颜色、行距、对齐方式和动态类型。")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Text("渐变文字")
                        .font(.title.bold())
                        .foregroundStyle(
                            /// foregroundStyle 接受 ShapeStyle，因此不只可以传单色，也可以直接传渐变。
                            LinearGradient(
                                colors: [.blue, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 14) {
                    /// Label 同时提供图标和文字语义，系统可根据上下文调整布局。
                    Label("Label = SF Symbol + Text", systemImage: "textformat")
                        .font(.headline)
                    Label("多色图标", systemImage: "heart.circle.fill")
                        /// palette 使用后续 foregroundStyle 参数依次填充符号的不同图层。
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.pink, .blue)
                    Label("层级图标", systemImage: "square.stack.3d.up.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.orange)
                }
                
                HStack(spacing: 22) {
                    /// SF Symbols 是矢量模板，字体大小会同时决定符号的显示尺寸。
                    Image(systemName: "swift")
                        .font(.system(size: 72))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.orange)
                    Image(systemName: "iphone.gen3")
                        .font(.system(size: 72))
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.blue)
                    Image(systemName: "sparkles")
                        .font(.system(size: 72))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.yellow, .purple)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}
