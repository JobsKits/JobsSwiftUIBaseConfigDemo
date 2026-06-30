//
//  MainTabView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct MainTabView: View {
    
    @State private var selectedTab: AppTab = .demos
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DemoListView()
                .tabItem {
                    Label("Demo", systemImage: "list.bullet.rectangle")
                }
                .tag(AppTab.demos)
            
            GalleryTabView()
                .tabItem {
                    Label("速览", systemImage: "square.grid.2x2")
                }
                .tag(AppTab.gallery)
            
            AboutTabView()
                .tabItem {
                    Label("关于", systemImage: "info.circle")
                }
                .tag(AppTab.about)
        }
    }
}

private enum AppTab: Hashable {
    case demos
    case gallery
    case about
}
