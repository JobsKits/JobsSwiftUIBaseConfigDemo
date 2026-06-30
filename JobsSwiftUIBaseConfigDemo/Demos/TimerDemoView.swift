//
//  TimerDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI
import Combine
import Foundation

struct TimerDemoView: View {
    
    @State private var elapsedSeconds = 0
    @State private var isRunning = false
    
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
        .onReceive(ticker) { _ in
            guard isRunning else { return }
            elapsedSeconds += 1
        }
    }
}
