//
//  DemoFeatureRow.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 列表行是一个可复用的小 View；父视图通过常量参数把展示数据传进来。
struct DemoFeatureRow: View {

    @ObservedObject private var appPreferences = AppPreferences.shared

    /// `let` 表示该行不拥有也不修改数据，刷新由父视图传入新的 feature 值完成。
    let feature: DemoFeature

    var body: some View {
        /// HStack 横向排列图标和文字区域，VStack 再把标题与副标题纵向组合。
        HStack(spacing: 12) {
            feature.icon
                .font(.system(size: 22))
                .foregroundStyle(Color.primary.opacity(0.72))
                .frame(width: 34, height: 34)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.body)
                    .foregroundStyle(Color.primary)
                Text(feature.subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.primary.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        /// 修饰符按顺序包装前一个 View；这里给整行增加垂直内边距。
        .frame(minHeight: 56)
        .padding(.vertical, 8)
    }
}
