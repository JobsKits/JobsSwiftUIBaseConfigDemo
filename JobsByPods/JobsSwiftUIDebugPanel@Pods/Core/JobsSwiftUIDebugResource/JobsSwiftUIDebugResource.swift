//
//  JobsSwiftUIDebugResource.swift
//  JobsSwiftUIDebugPanel
//
//  Created by Jobs on 2026年10月5日，星期一.
//

#if DEBUG
import SwiftUI
import UIKit

enum JobsSwiftUIDebugResource {
    static let bundle: Bundle = {
        let owner = Bundle(for: BundleToken.self)
        let url = owner.url(forResource: "JobsSwiftUIDebugPanelResources", withExtension: "bundle")
            ?? Bundle.main.url(forResource: "JobsSwiftUIDebugPanelResources", withExtension: "bundle")
        return url.flatMap(Bundle.init(url:)) ?? owner
    }()

    static var buttonImage: Image {
        Image(uiImage: UIImage.makeDebugPanelBackground(in: bundle))
            .renderingMode(.original)
    }

    private final class BundleToken: NSObject {}
}
#endif
