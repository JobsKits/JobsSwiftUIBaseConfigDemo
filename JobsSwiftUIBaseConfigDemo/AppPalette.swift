//
//  AppPalette.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月12日，星期四.
//

import SwiftUI
import UIKit

enum AppPalette {
    /// Foreground controls need a brighter tint against dark grouped surfaces.
    static let interactive = Color(UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return UIColor(red: 0.42, green: 0.76, blue: 0.94, alpha: 1)
        }
        return UIColor(red: 0.098, green: 0.369, blue: 0.514, alpha: 1)
    })
    static let accent = Color(red: 0.098, green: 0.369, blue: 0.514)
    static let success = Color(red: 0.075, green: 0.408, blue: 0.314)
    static let warm = Color(red: 0.545, green: 0.286, blue: 0.067)
    static let violet = Color(red: 0.392, green: 0.259, blue: 0.588)
}
