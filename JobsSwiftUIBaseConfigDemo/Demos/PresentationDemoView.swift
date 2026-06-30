//
//  PresentationDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct PresentationDemoView: View {
    
    @State private var showSheet = false
    @State private var showPopover = false
    @State private var showFullScreenCover = false
    
    var body: some View {
        List {
            Section("模态展示") {
                Button("显示 Sheet") {
                    showSheet = true
                }
                Button("显示 Popover") {
                    showPopover = true
                }
                Button("显示 FullScreenCover") {
                    showFullScreenCover = true
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            PresentationContentView(title: "Sheet", symbol: "rectangle.bottomthird.inset.filled")
                .presentationDetents([.medium, .large])
        }
        .popover(isPresented: $showPopover) {
            PresentationContentView(title: "Popover", symbol: "bubble.left.and.bubble.right")
                .frame(width: 320, height: 240)
        }
        .fullScreenCover(isPresented: $showFullScreenCover) {
            NavigationStack {
                PresentationContentView(title: "FullScreenCover", symbol: "rectangle.fill")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("关闭") {
                                showFullScreenCover = false
                            }
                        }
                    }
            }
        }
    }
}

private struct PresentationContentView: View {
    
    let title: String
    let symbol: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 56))
                .foregroundStyle(.blue)
            Text(title)
                .font(.title.bold())
            Text("这是 SwiftUI 原生的页面展示能力。")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
