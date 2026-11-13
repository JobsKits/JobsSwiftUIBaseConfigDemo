//
//  ProgressGaugeDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 父视图拥有 progress，系统 Slider 和自定义仪表盘通过同一个 Binding 保持同步。
struct ProgressGaugeDemoView: View {

    @ObservedObject private var appPreferences = AppPreferences.shared
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ScaledMetric(relativeTo: .body) private var gaugeSize = 92

    @State private var progress = 0.42

    private var adaptiveControlLayout: AnyLayout {
        if dynamicTypeSize.isAccessibilitySize {
            return AnyLayout(VStackLayout(spacing: 16))
        }
        return AnyLayout(HStackLayout(spacing: 16))
    }

    var body: some View {
        Form {
            Section("ProgressView") {
                /// 提供 value/total 时是确定进度；只提供标题时是无法预估时长的加载状态。
                ProgressView(value: progress, total: 1) {
                    Text(AppText.text("下载进度"))
                } currentValueLabel: {
                    Text("\(Int(progress * 100))%")
                }
                
                ProgressView(AppText.text("加载中"))
                    .controlSize(.large)
            }
            
            Section("Gauge") {
                /// `$progress` 允许子视图拖动仪表盘后反向修改父视图的 State。
                #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("--jobs-coverage-route") {
                    adaptiveControlLayout {
                        CustomCircularGaugeView(
                            progress: $progress,
                            title: AppText.text("完成度"),
                            completedColor: .blue,
                            remainingColor: Color(.systemGray5)
                        )
                        .frame(width: min(gaugeSize, 240), height: min(gaugeSize, 240))

                        VStack(alignment: .leading, spacing: 6) {
                            Text(AppText.text("可交互环形仪表盘"))
                                .font(.headline)
                            Text(AppText.text("拖动圆环调整完成度"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityElement(children: .contain)
                } else {
                    originalCustomGauge
                }
                #else
                originalCustomGauge
                #endif
                
                Gauge(value: progress, in: 0...1) {
                    /// 系统 Gauge 只负责语义和值，gaugeStyle 决定具体视觉形态。
                    Label(AppText.text("容量"), systemImage: "externaldrive")
                }
                .gaugeStyle(.accessoryLinearCapacity)
                .tint(.blue)
            }
            
            Section(AppText.text("调试")) {
                Slider(value: $progress, in: 0...1)
            }
        }
    }

    private var originalCustomGauge: some View {
        CustomCircularGaugeView(
            progress: $progress,
            title: AppText.text("完成度"),
            completedColor: .blue,
            remainingColor: Color(.systemGray5)
        )
        .frame(width: min(gaugeSize, 240), height: min(gaugeSize, 240))
    }

}
