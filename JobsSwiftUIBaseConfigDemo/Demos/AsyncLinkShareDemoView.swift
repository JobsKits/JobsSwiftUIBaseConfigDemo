//
//  AsyncLinkShareDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 演示异步内容的状态分支，以及跳转外链和调用系统分享面板。
struct AsyncLinkShareDemoView: View {

    @ObservedObject private var appPreferences = AppPreferences.shared
    @State private var reloadID = 0

    /// `!` 表示确信字面量一定能生成 URL；动态字符串应使用安全解包处理失败。
    private let imageURL = URL(string: "https://picsum.photos/680/420")!
    private let swiftUIURL = URL(string: "https://developer.apple.com/xcode/swiftui/")!
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                AsyncImage(url: imageURL) { phase in
                    /// 异步任务不会马上得到图片，必须为各个阶段分别声明界面。
                    switch phase {
                    /// 请求尚未完成时显示加载状态。
                    case .empty:
                        VStack(spacing: 12) {
                            Image("JobsLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .padding(8)
                                .background(.white, in: RoundedRectangle(cornerRadius: 8))
                                .accessibilityHidden(true)
                            ProgressView(AppText.text("加载图片"))
                        }
                    /// 请求成功后取得 Image；resizable 允许它按容器尺寸缩放。
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    /// 网络或解码失败时提供可见的错误状态。
                    case .failure:
                        VStack(spacing: 12) {
                            Image("JobsLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .padding(8)
                                .background(.white, in: RoundedRectangle(cornerRadius: 8))
                                .accessibilityHidden(true)
                            Text(AppText.text("图片加载失败"))
                            Button(AppText.text("重新加载")) {
                                reloadID += 1
                            }
                            .buttonStyle(.bordered)
                        }
                    /// 为系统未来新增的 phase 保留编译器可检查的兜底。
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 220)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .id(reloadID)
                
                VStack(alignment: .leading, spacing: 14) {
                    /// Link 交给系统打开 URL，不需要手动调用 UIApplication。
                    Link(destination: swiftUIURL) {
                        Label(AppText.text("打开 Apple SwiftUI 页面"), systemImage: "safari")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppPalette.accent)
                    
                    /// ShareLink 自动提供当前平台的系统分享界面。
                    ShareLink(item: swiftUIURL) {
                        Label(AppText.text("系统分享链接"), systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }
}
