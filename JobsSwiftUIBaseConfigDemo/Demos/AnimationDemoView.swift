//
//  AnimationDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

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
                .animation(.spring(response: 0.45, dampingFraction: 0.72), value: isExpanded)
            
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(.orange)
                .rotationEffect(.degrees(isRotated ? 180 : 0))
                .scaleEffect(isRotated ? 1.25 : 1)
                .animation(.easeInOut(duration: 0.35), value: isRotated)
            
            if isExpanded {
                Text("这是由状态驱动的转场内容。")
                    .font(.headline)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Button {
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
