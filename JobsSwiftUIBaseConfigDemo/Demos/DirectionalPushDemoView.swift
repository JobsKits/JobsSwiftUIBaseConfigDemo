//
//  DirectionalPushDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct DirectionalPushDemoView: View {
    
    @State private var direction = PushDirection.right
    @State private var pushProgress = 0.55
    
    var body: some View {
        Form {
            Section("Push 方向") {
                Picker("方向", selection: $direction) {
                    ForEach(PushDirection.allCases) { direction in
                        Label(direction.title, systemImage: direction.symbol)
                            .tag(direction)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("Push 百分比") {
                Slider(value: $pushProgress, in: 0...1, step: 0.01)
                LabeledContent("当前百分比", value: "\(Int(pushProgress * 100))%")
                
                HStack {
                    Button("0%") {
                        withAnimation(.snappy) {
                            pushProgress = 0
                        }
                    }
                    
                    Spacer()
                    
                    Button("50%") {
                        withAnimation(.snappy) {
                            pushProgress = 0.5
                        }
                    }
                    
                    Spacer()
                    
                    Button("100%") {
                        withAnimation(.snappy) {
                            pushProgress = 1
                        }
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Section("VC Push 预览") {
                DirectionalPushPreview(direction: direction, progress: pushProgress)
                    .frame(height: 260)
            }
        }
        .animation(.snappy, value: direction)
        .animation(.snappy, value: pushProgress)
    }
}

private enum PushDirection: String, CaseIterable, Identifiable {
    
    case top
    case bottom
    case left
    case right
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .top: "上"
        case .bottom: "下"
        case .left: "左"
        case .right: "右"
        }
    }
    
    var symbol: String {
        switch self {
        case .top: "arrow.up"
        case .bottom: "arrow.down"
        case .left: "arrow.left"
        case .right: "arrow.right"
        }
    }
}

private struct DirectionalPushPreview: View {
    
    let direction: PushDirection
    let progress: Double
    
    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VCPushCard(
                    title: "Root VC",
                    subtitle: "当前页面",
                    symbol: "iphone",
                    tint: .gray
                )
                .scaleEffect(1 - clampedProgress * 0.04)
                .opacity(1 - clampedProgress * 0.28)
                .offset(rootOffset(size: proxy.size))
                
                VCPushCard(
                    title: "Target VC",
                    subtitle: "\(direction.title)侧 Push 入场",
                    symbol: direction.symbol,
                    tint: .blue
                )
                .offset(targetOffset(size: proxy.size))
                .shadow(color: .black.opacity(0.12 * clampedProgress), radius: 14, y: 8)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
    }
    
    private func rootOffset(size: CGSize) -> CGSize {
        let distance = rootDistance(size: size)
        
        switch direction {
        case .top:
            CGSize(width: 0, height: distance)
        case .bottom:
            CGSize(width: 0, height: -distance)
        case .left:
            CGSize(width: distance, height: 0)
        case .right:
            CGSize(width: -distance, height: 0)
        }
    }
    
    private func targetOffset(size: CGSize) -> CGSize {
        let hiddenRatio = 1 - clampedProgress
        
        switch direction {
        case .top:
            CGSize(width: 0, height: -size.height * hiddenRatio)
        case .bottom:
            CGSize(width: 0, height: size.height * hiddenRatio)
        case .left:
            CGSize(width: -size.width * hiddenRatio, height: 0)
        case .right:
            CGSize(width: size.width * hiddenRatio, height: 0)
        }
    }
    
    private func rootDistance(size: CGSize) -> CGFloat {
        switch direction {
        case .top, .bottom:
            size.height * clampedProgress * 0.16
        case .left, .right:
            size.width * clampedProgress * 0.16
        }
    }
}

private struct VCPushCard: View {
    
    let title: String
    let subtitle: String
    let symbol: String
    let tint: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separator).opacity(0.28), lineWidth: 1)
                }
            
            VStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 72, height: 72)
                    .background(tint, in: RoundedRectangle(cornerRadius: 8))
                
                VStack(spacing: 5) {
                    Text(title)
                        .font(.title3.bold())
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
