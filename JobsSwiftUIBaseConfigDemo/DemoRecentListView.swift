//
//  DemoRecentListView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月15日，星期日.
//

import SwiftUI

/// 复用首页导航栈；从最近页打开功能后返回这里，再返回首页时保留原搜索和列表状态。
struct DemoRecentListView: View {

    @ObservedObject private var appPreferences = AppPreferences.shared
    @ObservedObject var history: DemoRecentHistory

    private var features: [DemoFeature] {
        history.featureIDs.compactMap(DemoFeature.init(rawValue:))
    }

    var body: some View {
        List {
            ForEach(features) { feature in
                NavigationLink {
                    feature.destination
                        .navigationTitle(feature.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .onAppear {
                            history.record(feature.rawValue)
                        }
                } label: {
                    DemoFeatureRow(feature: feature)
                }
                .accessibilityIdentifier("jobs.recent.\(feature.id)")
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if features.isEmpty {
                ContentUnavailableView {
                    Label(AppText.text("尚无最近使用"), systemImage: "clock")
                } description: {
                    Text(AppText.text("打开任一功能后会显示在这里。"))
                } actions: {
                    Button(AppText.text("重新加载")) {
                        history.reload()
                    }
                }
            }
        }
        .refreshable {
            history.reload()
        }
        .accessibilityIdentifier("jobs.demo.recent.list")
        .navigationTitle(AppText.text("最近使用"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !features.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        history.reload()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel(AppText.text("重新加载"))
                }
            }
        }
        .onAppear(perform: history.reload)
    }
}
