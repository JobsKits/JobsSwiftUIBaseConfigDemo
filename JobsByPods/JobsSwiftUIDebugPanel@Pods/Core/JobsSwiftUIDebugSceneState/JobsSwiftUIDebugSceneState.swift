//
//  JobsSwiftUIDebugSceneState.swift
//  JobsSwiftUIDebugPanel
//
//  Created by Jobs on 2026年10月5日，星期一.
//

#if DEBUG
import UIKit
import Combine
import SwiftUI

@MainActor
final class JobsSwiftUIDebugSceneState: ObservableObject {
    @Published var isPresented = false
    @Published var colorScheme = ColorScheme.light
    /// Keep the first position away from navigation actions and modal close buttons.
    @Published var buttonPosition = CGPoint(x: 1, y: 0.84)
    weak var hostWindow: UIWindow?
}
#endif
