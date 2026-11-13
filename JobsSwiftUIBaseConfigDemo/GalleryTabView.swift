//
//  GalleryTabView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 用网格展示同一份 Demo 数据，体现“数据不变、视图表现可以不同”的声明式思路。
struct GalleryTabView: View {

    @ObservedObject private var appPreferences = AppPreferences.shared

    /// `.adaptive` 会按可用宽度自动计算列数，每列至少 150 点。
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: dynamicTypeSize.isAccessibilitySize ? 280 : 160), spacing: 16)]
    }

    var body: some View {
        /// 每个 Tab 建立自己的 NavigationStack，因此三个 Tab 的导航历史彼此独立。
        NavigationStack {
            ScrollView {
                /// `LazyVGrid` 只在元素接近可视区域时创建视图，适合数量较多的滚动内容。
                LazyVGrid(columns: columns, spacing: 16) {
                    /// `DemoFeature` 遵守 Identifiable，ForEach 可用其 `id` 跟踪每一项的身份。
                    ForEach(DemoFeature.allCases) { feature in
                        NavigationLink {
                            /// destination 是根据枚举返回的具体 Demo，导航标题在入口处统一设置。
                            feature.destination
                                .navigationTitle(feature.title)
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            VStack(alignment: .leading, spacing: 12) {
                                feature.icon
                                    .font(.title2)
                                    .foregroundStyle(AppPalette.interactive)
                                    .accessibilityHidden(true)
                                Text(feature.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(feature.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                        }
                        /// `.plain` 去掉按钮默认外观，但不会移除点击和无障碍语义。
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(AppText.text("组件速览"))
            .navigationBarTitleDisplayMode(dynamicTypeSize.isAccessibilitySize ? .inline : .large)
        }
    }
}
