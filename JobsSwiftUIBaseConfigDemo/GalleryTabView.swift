//
//  GalleryTabView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 用网格展示同一份 Demo 数据，体现“数据不变、视图表现可以不同”的声明式思路。
struct GalleryTabView: View {

    /// `.adaptive` 会按可用宽度自动计算列数，每列至少 150 点。
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 12)
    ]

    var body: some View {
        /// 每个 Tab 建立自己的 NavigationStack，因此三个 Tab 的导航历史彼此独立。
        NavigationStack {
            ScrollView {
                /// `LazyVGrid` 只在元素接近可视区域时创建视图，适合数量较多的滚动内容。
                LazyVGrid(columns: columns, spacing: 12) {
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
                                    .foregroundStyle(.blue)
                                Text(feature.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                Text(feature.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(3)
                            }
                            .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
                            .padding(14)
                            .background(.background, in: RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.quaternary)
                            }
                        }
                        /// `.plain` 去掉按钮默认外观，但不会移除点击和无障碍语义。
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("组件速览")
        }
    }
}
