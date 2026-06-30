//
//  ProgressGaugeDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct ProgressGaugeDemoView: View {
    
    @State private var progress = 0.42
    
    var body: some View {
        Form {
            Section("ProgressView") {
                ProgressView(value: progress, total: 1) {
                    Text("下载进度")
                } currentValueLabel: {
                    Text("\(Int(progress * 100))%")
                }
                
                ProgressView("加载中")
                    .controlSize(.large)
            }
            
            Section("Gauge") {
                CustomCircularGaugeView(
                    progress: $progress,
                    title: "完成度",
                    completedColor: .blue,
                    remainingColor: Color(.systemGray5)
                )
                .frame(width: 92, height: 92)
                
                Gauge(value: progress, in: 0...1) {
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
