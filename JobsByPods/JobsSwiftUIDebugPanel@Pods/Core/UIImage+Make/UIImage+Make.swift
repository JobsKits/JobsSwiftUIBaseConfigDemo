//
//  UIImage+Make.swift
//  JobsSwiftUIDebugPanel
//
//  Created by Jobs on 2026年10月5日，星期一.
//

#if DEBUG
import UIKit

extension UIImage {
    static func makeDebugPanelBackground(in bundle: Bundle) -> UIImage {
        if let path = bundle.path(forResource: "JobsDebugPanelButton", ofType: "png"),
           let image = UIImage(contentsOfFile: path) {
            return image
        }
        return UIImage()
    }
}
#endif
