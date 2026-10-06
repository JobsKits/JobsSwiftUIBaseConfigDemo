//
//  JobsSwiftUIDebugEnvironmentsView.swift
//  JobsSwiftUIDebugPanel
//
//  Created by Jobs on 2026年10月5日，星期一.
//

#if DEBUG
import SwiftUI

struct JobsSwiftUIDebugEnvironmentsView: View {
    @ObservedObject private var panel = JobsSwiftUIDebugPanel.shared
    @State private var reloadID = UUID()

    var body: some View {
        List {
            if panel.environments.isEmpty {
                VStack(spacing: 12) {
                    JobsSwiftUIDebugPanel.buttonImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                    Text("尚未配置有效的网络环境")
                        .font(.headline)
                    Text("请在 AppDelegate 配置 HTTP / HTTPS URL 与备注")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("重新加载") {
                        reloadID = UUID()
                    }
                        .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ForEach(panel.environments) { environment in
                    Button {
                        panel.select(environment)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(environment.title)
                                    .foregroundStyle(.primary)
                                Text(environment.baseURL)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if panel.currentEnvironment?.id == environment.id {
                                Text("✓")
                                    .foregroundStyle(.tint)
                                    .accessibilityLabel("当前环境")
                            }
                        }
                    }
                    .accessibilityIdentifier("JobsSwiftUIDebugEnvironment_" + environment.id)
                }
            }
        }
        .id(reloadID)
        .listStyle(.insetGrouped)
        .navigationTitle("选择网络环境")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("JobsSwiftUIDebugEnvironments")
    }
}
#endif
