//
//  AlertDialogDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 演示“状态决定是否展示”的弹窗模型，而不是命令式地创建并 present 控制器。
struct AlertDialogDemoView: View {

    /// 两个 Bool 分别驱动两种弹窗；resultText 保存用户操作产生的业务结果。
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
        /// isPresented 接受 Binding；弹窗消失时系统也会把对应状态写回 false。
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
        /// ConfirmationDialog 更适合一组选项，role 会影响系统的视觉和交互语义。
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
