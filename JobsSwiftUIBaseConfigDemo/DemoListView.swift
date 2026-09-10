//
//  DemoListView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI
import UniformTypeIdentifiers

/// Demo 主列表：集中演示持久化状态、搜索、导航，以及拖拽排序的数据流。
struct DemoListView: View {

    /// `@AppStorage` 把值同步到 UserDefaults；重新启动 App 后仍能读到上次排序。
    @AppStorage("JobsSwiftUIBaseConfigDemo.demoFeatureOrder") private var storedFeatureOrder = ""
    /// 下面三个 `@State` 只属于当前视图生命周期，不应由父视图传入。
    @State private var orderedFeatures = DemoFeature.allCases
    @State private var draggingFeature: DemoFeature?
    @State private var searchText = ""

    /// 计算属性不额外保存状态，而是每次从当前 searchText 推导结果。
    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isSearching: Bool {
        !trimmedSearchText.isEmpty
    }
    
    private var filteredFeatures: [DemoFeature] {
        /// 闭包中的 `$0` 是当前遍历到的 feature；这里只过滤显示结果，不改变真实排序数组。
        isSearching ? orderedFeatures.filter {
            $0.title.localizedCaseInsensitiveContains(trimmedSearchText) ||
            $0.subtitle.localizedCaseInsensitiveContains(trimmedSearchText)
        } : orderedFeatures
    }
    
    private func loadFeatureOrder() {
        /// compactMap 同时完成字符串到枚举的转换，并丢弃已经失效的旧枚举值。
        let savedFeatures = storedFeatureOrder
            .split(separator: ",")
            .compactMap { DemoFeature(rawValue: String($0)) }
        var nextFeatures = [DemoFeature]()
        
        savedFeatures.forEach { feature in
            /// 去重后恢复已保存的相对顺序。
            if !nextFeatures.contains(feature) {
                nextFeatures.append(feature)
            }
        }
        
        DemoFeature.allCases.forEach { feature in
            /// 新版本增加 Demo 后，旧用户的持久化顺序里没有它，因此追加到末尾。
            if !nextFeatures.contains(feature) {
                nextFeatures.append(feature)
            }
        }
        
        orderedFeatures = nextFeatures
        persistFeatureOrder(nextFeatures)
    }
    
    private func persistFeatureOrder(_ features: [DemoFeature]) {
        /// KeyPath 写法 `\.rawValue` 等价于逐项读取 feature.rawValue。
        storedFeatureOrder = features.map(\.rawValue).joined(separator: ",")
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(filteredFeatures) { feature in
                        NavigationLink {
                            feature.destination
                                .navigationTitle(feature.title)
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            DemoFeatureRow(feature: feature)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                /// 扩大命中测试区域，让行内空白处也能接收拖放。
                                .contentShape(Rectangle())
                                /// `$` 将 State 投影成 Binding，DropDelegate 可读写父视图中的排序状态。
                                .onDrop(
                                    of: [UTType.text],
                                    delegate: DemoFeatureDropDelegate(
                                        feature: feature,
                                        insertionIndex: nil,
                                        features: $orderedFeatures,
                                        draggingFeature: $draggingFeature,
                                        isEnabled: !isSearching,
                                        persist: persistFeatureOrder
                                    )
                                )
                        }
                        .opacity(draggingFeature == feature ? 0.72 : 1)
                        .onDrag {
                            draggingFeature = feature
                            /// 拖拽系统通过 NSItemProvider 携带数据；真正的排序依据仍是本地 State。
                            return NSItemProvider(object: feature.rawValue as NSString)
                        }
                    }
                } header: {
                    Text("系统 UI Demo")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onDrop(
                            of: [UTType.text],
                            delegate: DemoFeatureDropDelegate(
                                feature: nil,
                                insertionIndex: 0,
                                features: $orderedFeatures,
                                draggingFeature: $draggingFeature,
                                isEnabled: !isSearching,
                                persist: persistFeatureOrder
                            )
                        )
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("SwiftUI 系统 UI")
            /// searchable 自动把系统搜索框接入 searchText Binding。
            .searchable(text: $searchText, prompt: "搜索功能名")
            /// body 可能多次计算，初始化副作用放在 onAppear，而不是直接写进 body。
            .onAppear(perform: loadFeatureOrder)
        }
    }
}

/// DropDelegate 把拖拽生命周期从 View 声明中拆出，专门负责排序规则。
private struct DemoFeatureDropDelegate: DropDelegate {

    /// 普通常量由创建方传值；Binding 则共享创建方拥有的可变状态。
    let feature: DemoFeature?
    let insertionIndex: Int?
    @Binding var features: [DemoFeature]
    @Binding var draggingFeature: DemoFeature?
    let isEnabled: Bool
    let persist: ([DemoFeature]) -> Void
    
    func validateDrop(info: DropInfo) -> Bool {
        isEnabled
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: isEnabled ? .move : .forbidden)
    }
    
    func dropEntered(info: DropInfo) {
        /// guard 把不可排序的条件提前退出，使后面的核心移动逻辑保持直线结构。
        guard isEnabled,
              let draggingFeature,
              let fromIndex = features.firstIndex(of: draggingFeature),
              let toOffset = toOffset(fromIndex: fromIndex) else {
            return
        }
        
        if let feature,
           draggingFeature == feature {
            return
        }
        
        guard fromIndex != toOffset,
              fromIndex + 1 != toOffset else {
            return
        }
        
        withAnimation(.snappy) {
            /// move 的目标是“插入偏移量”，从前往后移动时与目标元素索引存在一位差异。
            features.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: min(max(toOffset, 0), features.count)
            )
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        /// 放手时清理临时拖拽状态，并在排序成功后一次性持久化。
        draggingFeature = nil
        guard isEnabled else {
            return false
        }
        
        persist(features)
        return true
    }
    
    private func toOffset(fromIndex: Int) -> Int? {
        /// Header 明确传入 0，表示拖到列表最前面。
        if let insertionIndex {
            return insertionIndex
        }
        
        /// 目标行的位置从当前数组反查；向后移动时，move 的插入偏移量要比目标索引多 1。
        guard let feature,
              let toIndex = features.firstIndex(of: feature) else {
            return nil
        };return toIndex > fromIndex ? toIndex + 1 : toIndex
    }
}
