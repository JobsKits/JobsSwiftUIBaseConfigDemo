//
//  CoreDataDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月15日，星期日.
//

import SwiftUI

struct CoreDataDemoView: View {

    @ObservedObject private var preferences = AppPreferences.shared
    @ObservedObject private var store = CoreDataDemoStore.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var title = ""
    @State private var editingID: UUID?
    @State private var editedTitle = ""
    @State private var isRenaming = false
    @State private var isConfirmingClear = false
    @FocusState private var isEditingTitle: Bool

    var body: some View {
        List {
            Section {
                Text(AppText.text("模型定义数据结构，SQLite 文件保存实际记录。本页仅演示本地持久化。"))
                    .foregroundStyle(.secondary)
            } header: {
                Text(AppText.text("Core Data 使用说明"))
            }

            if let failure = store.failureKey {
                Section {
                    Label(AppText.text(failure), systemImage: "exclamationmark.triangle")
                    if let diagnostic = store.diagnostic {
                        Text(diagnostic)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Button(AppText.text("重试数据库加载")) {
                        store.reload()
                    }
                    .accessibilityIdentifier("jobs.coredata.retry")
                } header: {
                    Text(AppText.text("数据库操作失败"))
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(AppText.text("记录标题"))
                        .font(.caption)
                        .foregroundStyle(.primary.opacity(0.72))
                    TextField(AppText.text("记录标题"), text: $title)
                        .focused($isEditingTitle)
                        .submitLabel(.done)
                        .onSubmit(addRecord)
                        .accessibilityIdentifier("jobs.coredata.title")
                }
                Button(AppText.text("添加记录"), action: addRecord)
                    .disabled(!store.isReady || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("jobs.coredata.add")
            } header: {
                Text(AppText.text("添加记录"))
            } footer: {
                Text(AppText.text("操作立即保存，退出页面或重启 App 后仍可读取。"))
            }

            Section {
                if store.records.isEmpty {
                    ContentUnavailableView {
                        Label(AppText.text("尚无数据库记录"), systemImage: "list.bullet.rectangle")
                    } description: {
                        Text(AppText.text("输入标题并添加第一条记录，也可以重新加载本地数据库。"))
                    } actions: {
                        Button(AppText.text("重新加载")) {
                            store.reload()
                        }
                        .accessibilityIdentifier("jobs.coredata.empty.reload")
                    }
                    .accessibilityIdentifier("jobs.coredata.empty")
                } else {
                    ForEach(store.records) { record in
                        recordRow(record)
                    }
                }
            } header: {
                Text(AppText.text("数据库记录"))
            } footer: {
                Text(AppText.format("记录数量：%@", String(store.records.count)))
                    .accessibilityIdentifier("jobs.coredata.count")
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .refreshable {
            store.reload()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(AppText.text("重新加载")) {
                        store.reload()
                    }
                    Button(AppText.text("清空数据库"), role: .destructive) {
                        isConfirmingClear = true
                    }
                    .disabled(store.records.isEmpty)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel(AppText.text("数据库记录"))
                .accessibilityIdentifier("jobs.coredata.actions")
            }
        }
        .alert(AppText.text("重命名记录"), isPresented: $isRenaming) {
            TextField(AppText.text("记录标题"), text: $editedTitle)
            Button(AppText.text("取消"), role: .cancel) {}
            Button(AppText.text("保存修改")) {
                if let editingID {
                    store.rename(id: editingID, title: editedTitle)
                }
            }
            .disabled(editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .confirmationDialog(AppText.text("清空数据库"), isPresented: $isConfirmingClear, titleVisibility: .visible) {
            Button(AppText.text("清空数据库"), role: .destructive) {
                store.deleteAll()
            }
            Button(AppText.text("取消"), role: .cancel) {}
        } message: {
            Text(AppText.text("确定删除本 Demo 的全部记录？此操作无法撤销。"))
        }
        .task {
            store.reload()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                store.reload()
            }
        }
    }

    private func recordRow(_ record: CoreDataDemoRecord) -> some View {
        HStack(spacing: 12) {
            Button {
                store.toggle(id: record.id)
            } label: {
                Image(systemName: record.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(AppText.text(record.isComplete ? "标为未完成" : "标为已完成"))
            .accessibilityIdentifier("jobs.coredata.toggle.\(record.id)")

            VStack(alignment: .leading, spacing: 5) {
                Text(record.title)
                    .strikethrough(record.isComplete)
                    .foregroundStyle(.primary)
                Text(record.createdAt, format: .dateTime.year().month().day().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Menu {
                Button(AppText.text("重命名记录")) {
                    editingID = record.id
                    editedTitle = record.title
                    isRenaming = true
                }
                Button(AppText.text("删除记录"), role: .destructive) {
                    store.delete(id: record.id)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .frame(minWidth: 44, minHeight: 44)
            }
            .accessibilityLabel(record.title)
            .accessibilityIdentifier("jobs.coredata.record.actions.\(record.id)")
        }
        .swipeActions {
            Button(AppText.text("删除记录"), role: .destructive) {
                store.delete(id: record.id)
            }
        }
    }

    private func addRecord() {
        if store.add(title: title) {
            title = ""
            isEditingTitle = false
        }
    }
}
