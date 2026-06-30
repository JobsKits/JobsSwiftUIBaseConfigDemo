//
//  AlertDialogDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct AlertDialogDemoView: View {
    
    @State private var showAlert = false
    @State private var showConfirmDialog = false
    @State private var resultText = "尚未选择"
    
    var body: some View {
        List {
            Section("Alert") {
                Button("显示普通 Alert") {
                    showAlert = true
                }
                LabeledContent("结果", value: resultText)
            }
            
            Section("ConfirmationDialog") {
                Button(role: .destructive) {
                    showConfirmDialog = true
                } label: {
                    Label("显示操作确认", systemImage: "exclamationmark.triangle")
                }
            }
        }
        .alert("系统 Alert", isPresented: $showAlert) {
            Button("取消", role: .cancel) {
                resultText = "取消"
            }
            Button("确定") {
                resultText = "确定"
            }
        } message: {
            Text("这是 SwiftUI 原生 alert 修饰符。")
        }
        .confirmationDialog("确认执行操作？", isPresented: $showConfirmDialog, titleVisibility: .visible) {
            Button("删除", role: .destructive) {
                resultText = "执行删除"
            }
            Button("取消", role: .cancel) {
                resultText = "取消删除"
            }
        } message: {
            Text("ConfirmationDialog 适合动作列表和危险操作确认。")
        }
    }
}
