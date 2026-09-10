//
//  TimerDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI
import Combine
import Foundation

/// 把 Combine 的 Timer Publisher 接入 SwiftUI，并用 State 决定收到事件后的界面变化。
struct TimerDemoView: View {

    @State private var elapsedSeconds = 0
    @State private var isRunning = false
    
    /// autoconnect 会在订阅出现时自动连接定时器；即使暂停显示，Publisher 仍按秒发送事件。
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    /// 展示文本是由秒数推导出的计算属性，不需要再维护一份可能不同步的 State。
    private var timeText: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 26) {
            Image(systemName: isRunning ? "timer.circle.fill" : "timer.circle")
                .font(.system(size: 76))
                .foregroundStyle(isRunning ? .green : .blue)
            
            Text(timeText)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                /// 等宽数字避免数字宽度变化时计时文本左右跳动。
                .monospacedDigit()
            
            Text(isRunning ? "计时中，每秒自动累加" : "已暂停，点击开始继续计时")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 16) {
                Button {
                    isRunning.toggle()
                } label: {
                    Label(isRunning ? "暂停" : "开始", systemImage: isRunning ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.borderedProminent)
                
                Button(role: .destructive) {
                    elapsedSeconds = 0
                    isRunning = false
                } label: {
                    Label("重置", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        /// onReceive 把 Publisher 的事件转换为状态更新；guard 让暂停时忽略 tick。
        .onReceive(ticker) { _ in
            guard isRunning else { return }
            elapsedSeconds += 1
        }
    }
}
