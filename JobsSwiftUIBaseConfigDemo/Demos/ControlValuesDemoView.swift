//
//  ControlValuesDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct ControlValuesDemoView: View {
    
    @State private var isEnabled = true
    @State private var volume = 0.55
    @State private var quantity = 3
    
    var body: some View {
        Form {
            Section("开关") {
                Toggle(isOn: $isEnabled) {
                    Label("启用功能", systemImage: isEnabled ? "checkmark.circle.fill" : "xmark.circle")
                }
                .tint(.green)
            }
            
            Section("滑杆") {
                Slider(value: $volume, in: 0...1, step: 0.05) {
                    Text("音量")
                } minimumValueLabel: {
                    Image(systemName: "speaker")
                } maximumValueLabel: {
                    Image(systemName: "speaker.wave.3")
                }
                LabeledContent("当前音量", value: "\(Int(volume * 100))%")
            }
            
            Section("步进器") {
                Stepper(value: $quantity, in: 0...12) {
                    LabeledContent("数量", value: "\(quantity)")
                }
            }
        }
    }
}
