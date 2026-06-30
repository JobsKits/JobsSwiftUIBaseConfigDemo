//
//  TextImageDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct TextImageDemoView: View {
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("系统文本")
                        .font(.largeTitle.bold())
                    Text("SwiftUI 的 Text 可以组合字体、颜色、行距、对齐方式和动态类型。")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Text("渐变文字")
                        .font(.title.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 14) {
                    Label("Label = SF Symbol + Text", systemImage: "textformat")
                        .font(.headline)
                    Label("多色图标", systemImage: "heart.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.pink, .blue)
                    Label("层级图标", systemImage: "square.stack.3d.up.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.orange)
                }
                
                HStack(spacing: 22) {
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
