//
//  AsyncLinkShareDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct AsyncLinkShareDemoView: View {
    
    private let imageURL = URL(string: "https://picsum.photos/680/420")!
    private let swiftUIURL = URL(string: "https://developer.apple.com/xcode/swiftui/")!
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView("加载图片")
                            .frame(maxWidth: .infinity, minHeight: 220)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        ContentUnavailableView("图片加载失败", systemImage: "wifi.exclamationmark")
                            .frame(maxWidth: .infinity, minHeight: 220)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 14) {
                    Link(destination: swiftUIURL) {
                        Label("打开 Apple SwiftUI 页面", systemImage: "safari")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    ShareLink(item: swiftUIURL) {
                        Label("系统分享链接", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }
}
