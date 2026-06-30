//
//  PickersDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct PickersDemoView: View {
    
    @State private var selectedFruit: Fruit = .apple
    @State private var selectedMode: DemoMode = .preview
    @State private var selectedDate = Date()
    @State private var selectedColor = Color.blue
    
    var body: some View {
        Form {
            Section("Picker") {
                Picker("模式", selection: $selectedMode) {
                    ForEach(DemoMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                
                Picker("水果", selection: $selectedFruit) {
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
                ColorPicker("主题色", selection: $selectedColor, supportsOpacity: true)
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedColor)
                    .frame(height: 56)
            }
        }
    }
}

private enum Fruit: String, CaseIterable, Identifiable {
    case apple
    case orange
    case banana
    case grape
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .apple: "苹果"
        case .orange: "橙子"
        case .banana: "香蕉"
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
        case .preview: "预览"
        case .edit: "编辑"
        case .export: "导出"
        }
    }
}
