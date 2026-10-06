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
    @Published var buttonPosition = CGPoint(x: 1, y: 0)
    weak var hostWindow: UIWindow?
}
#endif
