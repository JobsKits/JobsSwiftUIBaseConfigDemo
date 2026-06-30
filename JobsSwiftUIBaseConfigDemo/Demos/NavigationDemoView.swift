//
//  NavigationDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct NavigationDemoView: View {
    
    @State private var showToolbarState = false
    
    var body: some View {
        List {
            Section("NavigationLink") {
                ForEach(NavigationSample.allCases) { sample in
                    NavigationLink {
                        NavigationDetailView(sample: sample)
                    } label: {
                        Label(sample.title, systemImage: sample.symbol)
                    }
                }
            }
            
            Section("Toolbar 状态") {
                LabeledContent("右侧按钮", value: showToolbarState ? "已点亮" : "未点亮")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showToolbarState.toggle()
                } label: {
                    Image(systemName: showToolbarState ? "star.fill" : "star")
                }
            }
        }
    }
}

private struct NavigationDetailView: View {
    
    let sample: NavigationSample
    
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: sample.symbol)
                .font(.system(size: 64))
                .foregroundStyle(.blue)
            Text(sample.title)
                .font(.title.bold())
            Text(sample.message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle(sample.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private enum NavigationSample: String, CaseIterable, Identifiable {
    case push
    case toolbar
    case inlineTitle
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .push: "普通 Push"
        case .toolbar: "工具栏"
        case .inlineTitle: "内联标题"
        }
    }
    
    var symbol: String {
        switch self {
        case .push: "arrowshape.forward"
        case .toolbar: "wrench.and.screwdriver"
        case .inlineTitle: "textformat.size"
        }
    }
    
    var message: String {
        switch self {
        case .push: "NavigationLink 会在当前 NavigationStack 内推出新页面。"
        case .toolbar: "toolbar 可以挂载导航栏按钮、底部按钮和键盘按钮。"
        case .inlineTitle: "navigationBarTitleDisplayMode 可以控制标题展示样式。"
        }
    }
}
