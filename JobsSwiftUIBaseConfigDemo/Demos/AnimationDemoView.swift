//
//  AnimationDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// SwiftUI 动画的核心是“状态改变 → 新旧视图值之间插值”，而不是直接操作图层帧。
struct AnimationDemoView: View {

    @State private var isExpanded = false
    @State private var isRotated = false
    
    var body: some View {
        VStack(spacing: 26) {
            RoundedRectangle(cornerRadius: 8)
                .fill(isExpanded ? .green : .blue)
                .frame(width: isExpanded ? 260 : 120, height: 96)
                .overlay {
                    Text(isExpanded ? "展开" : "收起")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                /// value 指定动画只响应 isExpanded 的变化，避免其它状态变化被意外动画化。
                .animation(.spring(response: 0.45, dampingFraction: 0.72), value: isExpanded)
            
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(.orange)
                .rotationEffect(.degrees(isRotated ? 180 : 0))
                .scaleEffect(isRotated ? 1.25 : 1)
                .animation(.easeInOut(duration: 0.35), value: isRotated)
            
            if isExpanded {
                /// transition 只在 View 插入或移出视图树时生效，单纯改变属性不会触发它。
                Text("这是由状态驱动的转场内容。")
                    .font(.headline)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Button {
                /// withAnimation 把闭包内的状态变化放进同一个动画事务，覆盖条件 View 的插入/移除。
                withAnimation {
                    isExpanded.toggle()
                    isRotated.toggle()
                }
            } label: {
                Label("切换动画", systemImage: "play.circle")
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
    }
}
