//
//  PickersDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 演示多个 Picker 共存时，分别用独立 State 保存用户选择。
struct PickersDemoView: View {

    @State private var selectedFruit: Fruit = .apple
    @State private var selectedMode: DemoMode = .preview
    @State private var selectedDate = Date()
    @State private var selectedColor = Color.blue
    
    var body: some View {
        Form {
            Section("Picker") {
                /// Picker 的 selection 与每个子项的 tag 共同建立“值 ↔ 选中项”映射。
                Picker("模式", selection: $selectedMode) {
                    ForEach(DemoMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                
                Picker("水果", selection: $selectedFruit) {
                    /// allCases 来自 CaseIterable，避免手工维护重复的选项数组。
                    ForEach(Fruit.allCases) { fruit in
                        Text(fruit.title).tag(fruit)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 120)
            }
            
            Section("DatePicker") {
                DatePicker(
                    "日期时间",
                    selection: $selectedDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
            
            Section("ColorPicker") {
                /// ColorPicker 改写 selectedColor，下面的色块直接读取它形成实时预览。
                ColorPicker("主题色", selection: $selectedColor, supportsOpacity: true)
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedColor)
                    .frame(height: 56)
            }
        }
    }
}

/// RawRepresentable 提供字符串原始值；Identifiable 让枚举可直接用于 ForEach。
private enum Fruit: String, CaseIterable, Identifiable {
    case apple
    case orange
    case banana
    case grape
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        /// 苹果选项的中文标题。
        case .apple: "苹果"
        /// 橙子选项的中文标题。
        case .orange: "橙子"
        /// 香蕉选项的中文标题。
        case .banana: "香蕉"
        /// 葡萄选项的中文标题。
        case .grape: "葡萄"
        }
    }
}

private enum DemoMode: String, CaseIterable, Identifiable {
    case preview
    case edit
    case export
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        /// 预览模式的中文标题。
        case .preview: "预览"
        /// 编辑模式的中文标题。
        case .edit: "编辑"
        /// 导出模式的中文标题。
        case .export: "导出"
        }
    }
}
