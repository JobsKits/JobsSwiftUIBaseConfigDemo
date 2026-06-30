//
//  TabPageDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct TabPageDemoView: View {
    
    @State private var selectedPage = 0
    
    private let pages: [DemoPage] = [
        DemoPage(title: "第一页", symbol: "1.circle.fill", color: .blue),
        DemoPage(title: "第二页", symbol: "2.circle.fill", color: .green),
        DemoPage(title: "第三页", symbol: "3.circle.fill", color: .purple),
        DemoPage(title: "第四页", symbol: "4.circle.fill", color: .orange)
    ]
    
    var body: some View {
        VStack(spacing: 22) {
            TabView(selection: $selectedPage) {
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
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
    }
}

private struct DemoPage {
    let title: String
    let symbol: String
    let color: Color
}
