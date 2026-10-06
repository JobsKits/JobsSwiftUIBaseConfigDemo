//
//  JobsSwiftUIDebugAppDelegate.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年10月5日，星期一.
//

#if DEBUG
import UIKit
import JobsSwiftUIDebugPanel

final class JobsSwiftUIDebugAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        JobsSwiftUIDebugPanel.shared
            .byEnvironments([
                JobsSwiftUIDebugEnvironment()
                    .byIdentifier("local")
                    .byTitle("本地 Mock")
                    .byBaseURL("http://127.0.0.1:18080"),
                JobsSwiftUIDebugEnvironment()
                    .byIdentifier("httpbin")
                    .byTitle("公共测试")
                    .byBaseURL("https://httpbin.org"),
                JobsSwiftUIDebugEnvironment()
                    .byIdentifier("postman")
                    .byTitle("联调测试")
                    .byBaseURL("https://postman-echo.com")
            ])
            .byDefaultEnvironmentIdentifier("local")
            .byEnvironmentChanged { environment in
                JobsSwiftUIDebugNetworkEnvironment.shared.byBaseURL(environment.baseURL)
            }
            .byActions([
                JobsSwiftUIDebugAction()
                    .byTitle("SwiftUI 调试面板使用示例")
                    .byDestination {
                        JobsSwiftUIDebugPanelDemoView()
                    },
                JobsSwiftUIDebugAction()
                    .byTitle("查看当前环境")
                    .byAction {
                        let environment = JobsSwiftUIDebugPanel.shared.currentEnvironment
                        JobsSwiftUIDebugPanel.shared.byFeedback(
                            (environment?.title ?? "未配置") + "\n" + (environment?.baseURL ?? "")
                        )
                    }
            ])
            .byStart()
        return true
    }
}
#endif
