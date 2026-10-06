//
//  JobsSwiftUIDebugHostModifier.swift
//  JobsSwiftUIDebugPanel
//
//  Created by Jobs on 2026年10月5日，星期一.
//

#if DEBUG
import SwiftUI
import UIKit

public extension View {
    func jobsSwiftUIDebugPanel() -> some View {
        modifier(JobsSwiftUIDebugHostModifier())
    }
}

public extension EnvironmentValues {
    var jobsSwiftUIDebugOpenPanel: () -> Void {
        get {
            self[OpenPanelKey.self]
        }
        set {
            self[OpenPanelKey.self] = newValue
        }
    }
}

private struct OpenPanelKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

private struct JobsSwiftUIDebugHostModifier: ViewModifier {
    @StateObject private var state = JobsSwiftUIDebugSceneState()
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background {
                JobsSwiftUIDebugWindowReader { window in
                    JobsSwiftUIDebugPanel.shared.synchronizeAppearance(colorScheme, for: state)
                    JobsSwiftUIDebugPanel.shared.attach(state, to: window)
                }
                .allowsHitTesting(false)
            }
            .environment(\.jobsSwiftUIDebugOpenPanel, {
                JobsSwiftUIDebugPanel.shared.open(state)
            })
            .onChange(of: colorScheme) { _, scheme in
                JobsSwiftUIDebugPanel.shared.synchronizeAppearance(scheme, for: state)
            }
    }
}

private struct JobsSwiftUIDebugWindowReader: UIViewRepresentable {
    let windowChanged: (UIWindow) -> Void

    func makeUIView(context: Context) -> WindowProbe {
        let view = WindowProbe()
        view.windowChanged = windowChanged
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: WindowProbe, context: Context) {
        uiView.windowChanged = windowChanged
    }

    final class WindowProbe: UIView {
        var windowChanged: ((UIWindow) -> Void)?
        override func didMoveToWindow() {
            super.didMoveToWindow()
            guard let window else {
                return
            }
            DispatchQueue.main.async { [weak self, weak window] in
                guard let window else {
                    return
                }
                self?.windowChanged?(window)
            }
        }
    }
}
#endif
