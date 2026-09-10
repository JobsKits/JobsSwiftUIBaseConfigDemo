//
//  ProgressGaugeDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 父视图拥有 progress，系统 Slider 和自定义仪表盘通过同一个 Binding 保持同步。
struct ProgressGaugeDemoView: View {

    @State private var progress = 0.42

    var body: some View {
        Form {
            Section("ProgressView") {
                /// 提供 value/total 时是确定进度；只提供标题时是无法预估时长的加载状态。
                ProgressView(value: progress, total: 1) {
                    Text("下载进度")
                } currentValueLabel: {
                    Text("\(Int(progress * 100))%")
                }
                
                ProgressView("加载中")
                    .controlSize(.large)
            }
            
            Section("Gauge") {
                /// `$progress` 允许子视图拖动仪表盘后反向修改父视图的 State。
                CustomCircularGaugeView(
                    progress: $progress,
                    title: "完成度",
                    completedColor: .blue,
                    remainingColor: Color(.systemGray5)
                )
                .frame(width: 92, height: 92)
                
                Gauge(value: progress, in: 0...1) {
                    /// 系统 Gauge 只负责语义和值，gaugeStyle 决定具体视觉形态。
                    Label("容量", systemImage: "externaldrive")
                }
                .gaugeStyle(.accessoryLinearCapacity)
                .tint(.blue)
            }
            
            Section("调试") {
                Slider(value: $progress, in: 0...1)
            }
        }
    }
}
