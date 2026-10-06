//
//  JobsSwiftUIDebugPanelDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年10月5日，星期一.
//

#if DEBUG
import SwiftUI
import JobsSwiftUIDebugPanel

struct JobsSwiftUIDebugPanelDemoView: View {
    @ObservedObject private var panel = JobsSwiftUIDebugPanel.shared
    @ObservedObject private var network = JobsSwiftUIDebugNetworkEnvironment.shared
    @Environment(\.jobsSwiftUIDebugOpenPanel) private var openPanel
    @AppStorage("com.jobs.swiftui.debugPanel.demoAppearance") private var appearance = "system"
    @State private var retry = 0
    @State private var result = "本地演示数据：请求成功后显示服务端 JSON。"

    var body: some View {
        List {
            Section("宿主主题") {
                Picker("主题", selection: $appearance) {
                    ForEach(JobsSwiftUIDebugDemoAppearance.allCases) { value in
                        Text(value.title).tag(value.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("JobsSwiftUIDebugDemoAppearance")
            }
            Section("当前网络环境") {
                Text(panel.currentEnvironment?.title ?? "未配置")
                Text(network.baseURL)
                    .font(.caption)
                    .textSelection(.enabled)
            }
            Section("操作") {
                Button("打开 SwiftUI 调试面板", action: openPanel)
                Button("重新请求当前环境 /get") {
                    retry += 1
                }
                    .accessibilityIdentifier("JobsSwiftUIDebugRetryRequest")
            }
            Section("请求结果") {
                Text(result)
                    .font(.footnote.monospaced())
                    .textSelection(.enabled)
                    .accessibilityIdentifier("JobsSwiftUIDebugRequestResult")
            }
            Section {
                Text("GET /get · 3 秒超时 · 服务器优先，失败继续显示本地示例，重试成功自动恢复真实结果。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("SwiftUI DebugPanel Demo")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("JobsSwiftUIDebugDemo")
        .task(id: network.baseURL + "#" + String(retry)) {
            await requestEnvironment()
        }
    }

    private func requestEnvironment() async {
        let baseURL = network.baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: baseURL + "/get") else {
            result = "本地演示数据：URL 无效，配置环境后可重新请求。"
            return
        }
        result = "本地演示数据（正在请求服务器）\n" + url.absoluteString
        do {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 3)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard !Task.isCancelled, network.baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")) == baseURL else {
                return
            }
            guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode),
                  let object = try? JSONSerialization.jsonObject(with: data),
                  let formatted = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
                  let text = String(data: formatted, encoding: .utf8) else {
                result = "本地演示数据：服务端响应无效，点击重新请求可重试。"
                return
            }
            result = "服务器数据 · " + url.absoluteString + "\n" + String(text.prefix(2000))
        } catch {
            guard !Task.isCancelled else {
                return
            }
            result = "本地演示数据 · " + url.absoluteString + "\n服务器不可达或超时，点击重新请求可恢复真数据。"
        }
    }
}

enum JobsSwiftUIDebugDemoAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        /// 由系统外观决定宿主与调试浮层的主题。
        case .system:
            return "跟随系统"
        /// 演示宿主强制白天时调试面板同步刷新。
        case .light:
            return "白天"
        /// 演示宿主强制黑夜时调试面板同步刷新。
        case .dark:
            return "黑夜"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        /// nil 保留系统主题变化。
        case .system:
            return nil
        /// 白天主题。
        case .light:
            return .light
        /// 黑夜主题。
        case .dark:
            return .dark
        }
    }
}
#endif
