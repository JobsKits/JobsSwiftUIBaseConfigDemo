//
//  TabPageDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 同一个 selectedPage Binding 同时连接分页 TabView 和分段 Picker。
struct TabPageDemoView: View {

    @State private var selectedPage = 0

    /// 页面模型使用 struct 表达不可变展示数据。
    private let pages: [DemoPage] = [
        DemoPage(title: "第一页", symbol: "1.circle.fill", color: .blue),
        DemoPage(title: "第二页", symbol: "2.circle.fill", color: .green),
        DemoPage(title: "第三页", symbol: "3.circle.fill", color: .purple),
        DemoPage(title: "第四页", symbol: "4.circle.fill", color: .orange)
    ]
    
    var body: some View {
        VStack(spacing: 22) {
            /// selection 与每页 tag 对应；滑动页面会写回 selectedPage。
            TabView(selection: $selectedPage) {
                /// indices 适合既需要数组下标又需要元素的固定数组。
                ForEach(pages.indices, id: \.self) { index in
                    let page = pages[index]
                    RoundedRectangle(cornerRadius: 8)
                        .fill(page.color)
                        .overlay {
                            VStack(spacing: 12) {
                                Image(systemName: page.symbol)
                                    .font(.system(size: 52))
                                Text(page.title)
                                    .font(.title.bold())
                            }
                            .foregroundStyle(.white)
                        }
                        .padding(.horizontal)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: 280)
            
            Picker("分页", selection: $selectedPage) {
                ForEach(pages.indices, id: \.self) { index in
                    Text("\(index + 1)").tag(index)
                }
            }
            /// Picker 写入同一个状态，因此点选分段也会驱动上面的 TabView 翻页。
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
    }
}

/// 这是纯数据模型，不遵守 View；只有被 body 转换后才成为可见界面。
private struct DemoPage {
    let title: String
    let symbol: String
    let color: Color
}
