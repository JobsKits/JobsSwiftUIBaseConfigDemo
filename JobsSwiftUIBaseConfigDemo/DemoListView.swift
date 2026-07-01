//
//  DemoListView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI
import UniformTypeIdentifiers

struct DemoListView: View {
    
    @AppStorage("JobsSwiftUIBaseConfigDemo.demoFeatureOrder") private var storedFeatureOrder = ""
    @State private var orderedFeatures = DemoFeature.allCases
    @State private var draggingFeature: DemoFeature?
    @State private var searchText = ""
    
    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isSearching: Bool {
        !trimmedSearchText.isEmpty
    }
    
    private var filteredFeatures: [DemoFeature] {
        isSearching ? orderedFeatures.filter {
            $0.title.localizedCaseInsensitiveContains(trimmedSearchText) ||
            $0.subtitle.localizedCaseInsensitiveContains(trimmedSearchText)
        } : orderedFeatures
    }
    
    private func loadFeatureOrder() {
        let savedFeatures = storedFeatureOrder
            .split(separator: ",")
            .compactMap { DemoFeature(rawValue: String($0)) }
        var nextFeatures = [DemoFeature]()
        
        savedFeatures.forEach { feature in
            if !nextFeatures.contains(feature) {
                nextFeatures.append(feature)
            }
        }
        
        DemoFeature.allCases.forEach { feature in
            if !nextFeatures.contains(feature) {
                nextFeatures.append(feature)
            }
        }
        
        orderedFeatures = nextFeatures
        persistFeatureOrder(nextFeatures)
    }
    
    private func persistFeatureOrder(_ features: [DemoFeature]) {
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
                                .contentShape(Rectangle())
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
            .searchable(text: $searchText, prompt: "搜索功能名")
            .onAppear(perform: loadFeatureOrder)
        }
    }
}

private struct DemoFeatureDropDelegate: DropDelegate {
    
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
            features.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: min(max(toOffset, 0), features.count)
            )
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggingFeature = nil
        guard isEnabled else {
            return false
        }
        
        persist(features)
        return true
    }
    
    private func toOffset(fromIndex: Int) -> Int? {
        if let insertionIndex {
            return insertionIndex
        }
        
        guard let feature,
              let toIndex = features.firstIndex(of: feature) else {
            return nil
        };return toIndex > fromIndex ? toIndex + 1 : toIndex
    }
}
