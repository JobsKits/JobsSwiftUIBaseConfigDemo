//
//  JobsSwiftUIDebugOverlayView.swift
//  JobsSwiftUIDebugPanel
//
//  Created by Jobs on 2026年10月5日，星期一.
//

#if DEBUG
import SwiftUI
import UIKit

struct JobsSwiftUIDebugOverlayView: View {
    @ObservedObject var state: JobsSwiftUIDebugSceneState
    @State private var dragOrigin: CGPoint?
    let frameChanged: (CGRect) -> Void

    var body: some View {
        ZStack {
            NavigationStack {
                Color.clear
                    .ignoresSafeArea()
                    .modifier(TransparentNavigationBackground())
                    .toolbar(.hidden, for: .navigationBar)
                    .navigationDestination(isPresented: $state.isPresented) {
                        JobsSwiftUIDebugMenuView()
                            .toolbar(.visible, for: .navigationBar)
                    }
            }
            /// 入口保留在导航栈外，二级页面也能用同一按钮返回业务界面。
            GeometryReader { geometry in
                let range = legalCenterRange(in: geometry)
                Color.clear
                    .overlay(alignment: .topLeading) {
                        FloatingButton(
                            isPresented: state.isPresented,
                            toggle: { JobsSwiftUIDebugPanel.shared.toggle(state) },
                            hide: { JobsSwiftUIDebugPanel.shared.byHideForCurrentLaunch() },
                            beginDrag: { dragOrigin = state.buttonPosition },
                            drag: { translation in
                                guard let origin = dragOrigin else {
                                    return
                                }
                                state.buttonPosition = CGPoint(
                                    x: min(1, max(0, origin.x + translation.x / max(1, range.width))),
                                    y: min(1, max(0, origin.y + translation.y / max(1, range.height)))
                                )
                            },
                            endDrag: { dragOrigin = nil }
                        )
                        .frame(width: 56, height: 56)
                        .background {
                            GeometryReader { buttonGeometry in
                                Color.clear.preference(key: ButtonFrameKey.self, value: buttonGeometry.frame(in: .global))
                            }
                        }
                        .position(
                            x: range.minX + range.width * state.buttonPosition.x,
                            y: range.minY + range.height * state.buttonPosition.y
                        )
                    }
            }
                .ignoresSafeArea()
        }
        .environment(\.jobsSwiftUIDebugOpenPanel, {
            JobsSwiftUIDebugPanel.shared.open(state)
        })
        .environment(\.colorScheme, state.colorScheme)
        .onPreferenceChange(ButtonFrameKey.self, perform: frameChanged)
    }

    /// 保存相对位置，尺寸或安全区变化后仍将整枚按钮限制在可操作范围内。
    private func legalCenterRange(in geometry: GeometryProxy) -> CGRect {
        let margin: CGFloat = 36
        let insets = state.hostWindow?.safeAreaInsets ?? UIEdgeInsets(
            top: geometry.safeAreaInsets.top,
            left: geometry.safeAreaInsets.leading,
            bottom: geometry.safeAreaInsets.bottom,
            right: geometry.safeAreaInsets.trailing
        )
        let minimumX = insets.left + margin
        let minimumY = insets.top + margin
        let maximumX = max(minimumX, geometry.size.width - insets.right - margin)
        let maximumY = max(minimumY, geometry.size.height - insets.bottom - margin)
        return CGRect(x: minimumX, y: minimumY, width: maximumX - minimumX, height: maximumY - minimumY)
    }

    private struct FloatingButton: UIViewRepresentable {
        var isPresented: Bool
        var toggle: () -> Void
        var hide: () -> Void
        var beginDrag: () -> Void
        var drag: (CGPoint) -> Void
        var endDrag: () -> Void

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        func makeUIView(context: Context) -> FloatingUIButton {
            let button = FloatingUIButton.make()
            context.coordinator.configure(button)
            button.updateAppearance(isPresented: isPresented)
            return button
        }

        func updateUIView(_ uiView: FloatingUIButton, context: Context) {
            context.coordinator.parent = self
            uiView.updateAppearance(isPresented: isPresented)
        }

        /// 图片像素尺寸不参与布局，圆形命中区域与 SwiftUI 的 56 点入口保持一致。
        func sizeThatFits(_ proposal: ProposedViewSize, uiView: FloatingUIButton, context: Context) -> CGSize? {
            CGSize(width: proposal.width ?? 56, height: proposal.height ?? 56)
        }

        final class Coordinator: NSObject {
            var parent: FloatingButton

            init(_ parent: FloatingButton) {
                self.parent = parent
            }

            func configure(_ button: FloatingUIButton) {
                let pan = UIPanGestureRecognizer.makeDebugPanel(target: self, action: #selector(didPan(_:)))
                let longPress = UILongPressGestureRecognizer.makeDebugPanel(target: self, action: #selector(didLongPress(_:)))
                let tap = UITapGestureRecognizer.makeDebugPanel(target: self, action: #selector(didTap(_:)))
                /// 移动超过长按容差后拖动胜出；松手不会额外打开或关闭面板。
                pan.require(toFail: longPress)
                tap.require(toFail: pan)
                tap.require(toFail: longPress)
                button.addGestureRecognizer(pan)
                button.addGestureRecognizer(longPress)
                button.addGestureRecognizer(tap)
                button.activate = { [weak self] in
                    self?.parent.toggle()
                }
            }

            @objc private func didTap(_ gesture: UITapGestureRecognizer) {
                guard gesture.state == .ended else {
                    return
                }
                parent.toggle()
            }

            @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
                guard gesture.state == .began else {
                    return
                }
                parent.hide()
            }

            @objc private func didPan(_ gesture: UIPanGestureRecognizer) {
                switch gesture.state {
                /// 记录起点并消费手势识别前已经发生的位移。
                case .began:
                    parent.beginDrag()
                    parent.drag(gesture.translation(in: gesture.view?.window))
                /// 位移以窗口坐标计算，按钮自身移动不会干扰继续拖动。
                case .changed:
                    parent.drag(gesture.translation(in: gesture.view?.window))
                /// 结束或取消只停止拖动，不触发点击。
                case .ended, .cancelled, .failed:
                    parent.endDrag()
                /// 未识别时等待手指移动。
                default:
                    break
                }
            }
        }
    }

    private final class FloatingUIButton: UIButton {
        var activate: (() -> Void)?

        static func make() -> FloatingUIButton {
            let button = FloatingUIButton(type: .custom)
            button.setBackgroundImage(UIImage.makeDebugPanelBackground(in: JobsSwiftUIDebugResource.bundle), for: .normal)
            button.accessibilityIdentifier = "JobsSwiftUIDebugPanelButton"
            return button
        }

        func updateAppearance(isPresented: Bool) {
            accessibilityLabel = isPresented ? "关闭 SwiftUI 调试面板，返回原页面" : "打开 SwiftUI 调试面板"
            accessibilityHint = "可拖动，长按隐藏至下次启动"
            accessibilityValue = isPresented ? "已打开" : "已关闭"
        }

        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            let radius = min(bounds.width, bounds.height) * 0.5
            return hypot(point.x - bounds.midX, point.y - bounds.midY) <= radius
        }

        override func accessibilityActivate() -> Bool {
            activate?()
            return true
        }
    }

    private struct ButtonFrameKey: PreferenceKey {
        static var defaultValue = CGRect.zero
        static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
            let next = nextValue()
            if !next.isEmpty {
                value = next
            }
        }
    }

    private struct TransparentNavigationBackground: ViewModifier {
        @ViewBuilder
        func body(content: Content) -> some View {
            if #available(iOS 18.0, *) {
                content.containerBackground(.clear, for: .navigation)
            } else {
                content.background(NavigationBackgroundProbe())
            }
        }
    }

    private struct NavigationBackgroundProbe: UIViewRepresentable {
        func makeUIView(context: Context) -> ProbeView {
            ProbeView()
        }

        func updateUIView(_ uiView: ProbeView, context: Context) {}

        final class ProbeView: UIView {
            override func didMoveToWindow() {
                super.didMoveToWindow()
                DispatchQueue.main.async { [weak self] in
                    guard let self, self.window is JobsSwiftUIDebugOverlayWindow else {
                        return
                    }
                    /// iOS 17 无导航容器背景接口，只清理自有浮层内的祖先背景。
                    var ancestor = self.superview
                    while let view = ancestor, !(view is UIWindow) {
                        view.backgroundColor = .clear
                        ancestor = view.superview
                    }
                }
            }
        }
    }
}

private extension UIPanGestureRecognizer {
    static func makeDebugPanel(target: Any, action: Selector) -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer(target: target, action: action)
        gesture.maximumNumberOfTouches = 1
        return gesture
    }
}

private extension UILongPressGestureRecognizer {
    static func makeDebugPanel(target: Any, action: Selector) -> UILongPressGestureRecognizer {
        let gesture = UILongPressGestureRecognizer(target: target, action: action)
        gesture.minimumPressDuration = 0.8
        gesture.allowableMovement = 8
        return gesture
    }
}

private extension UITapGestureRecognizer {
    static func makeDebugPanel(target: Any, action: Selector) -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: target, action: action)
    }
}
#endif
