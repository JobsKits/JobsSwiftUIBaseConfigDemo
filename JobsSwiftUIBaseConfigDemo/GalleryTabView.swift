//
//  GalleryTabView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct GalleryTabView: View {
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(DemoFeature.allCases) { feature in
                        NavigationLink {
                            feature.destination
                                .navigationTitle(feature.title)
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            VStack(alignment: .leading, spacing: 12) {
                                Image(systemName: feature.symbol)
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
