//
//  ButtonMenuDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct ButtonMenuDemoView: View {
    
    @State private var tapCount = 0
    @State private var favoriteAction = "收藏"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Button 样式")
                    .font(.title2.bold())
                
                Button {
                    tapCount += 1
                } label: {
                    Label("普通按钮：\(tapCount)", systemImage: "hand.tap")
                }
                .buttonStyle(.borderedProminent)
                
                HStack {
                    Button(role: .destructive) {
                        tapCount = 0
                    } label: {
                        Label("重置", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        favoriteAction = "已置顶"
                    } label: {
                        Label("胶囊按钮", systemImage: "pin")
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                }
                
                Divider()
                
                Menu {
                    Button("复制", systemImage: "doc.on.doc") {
                        favoriteAction = "复制"
                    }
                    Button("标记", systemImage: "tag") {
                        favoriteAction = "标记"
                    }
                    Divider()
                    Picker("动作", selection: $favoriteAction) {
                        Text("收藏").tag("收藏")
                        Text("稍后看").tag("稍后看")
                        Text("已归档").tag("已归档")
                    }
                } label: {
                    Label("Menu 菜单：\(favoriteAction)", systemImage: "ellipsis.circle")
                }
                .buttonStyle(.borderedProminent)
                
                ControlGroup {
                    Button("播放", systemImage: "play.fill") {}
                    Button("暂停", systemImage: "pause.fill") {}
                    Button("停止", systemImage: "stop.fill") {}
                }
                .controlGroupStyle(.automatic)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}
