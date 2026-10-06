//
//  JobsSwiftUIDebugMenuView.swift
//  JobsSwiftUIDebugPanel
//
//  Created by Jobs on 2026年10月5日，星期一.
//

#if DEBUG
import SwiftUI

public struct JobsSwiftUIDebugMenuView: View {
    @ObservedObject private var panel = JobsSwiftUIDebugPanel.shared

    public init() {}

    public var body: some View {
        List {
            NavigationLink {
                JobsSwiftUIDebugEnvironmentsView()
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text("App 环境切换")
                    Text(panel.currentEnvironment?.title ?? "尚未配置环境")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityIdentifier("JobsSwiftUIDebugEnvironmentEntry")
            ForEach(panel.actions) { action in
                if let destination = action.destination {
                    NavigationLink {
                        destination()
                    } label: {
                        actionLabel(action)
                    }
                } else {
                    Button {
                        action.handler?()
                    } label: {
                        actionLabel(action)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("SwiftUI 调试工具")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("JobsSwiftUIDebugMenu")
        .alert("当前网络环境", isPresented: Binding(
            get: {
                panel.feedback != nil
            },
            set: { isPresented in
                if !isPresented {
                    panel.feedback = nil
                }
            }
        )) {
            Button("知道了", role: .cancel) {
                panel.feedback = nil
            }
        } message: {
            Text(panel.feedback ?? "")
        }
    }

    private func actionLabel(_ action: JobsSwiftUIDebugAction) -> some View {
        HStack(spacing: 12) {
            if let image = action.image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            Text(action.title)
                .foregroundStyle(.primary)
        }
    }
}
#endif
