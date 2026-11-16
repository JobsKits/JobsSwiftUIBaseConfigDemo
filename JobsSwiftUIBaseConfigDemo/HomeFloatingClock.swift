//
//  HomeFloatingClock.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月16日，星期一.
//

import SwiftUI

struct HomeFloatingClock: View {

    let active: Bool
    let onOpen: () -> Void
    @ObservedObject private var preferences = AppPreferences.shared
    @StateObject private var clock = JobsSwiftUIClock()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .body) private var fontSize = 18
    @State private var point = CGPoint(x: 8, y: 48)
    @State private var contentSize = CGSize.zero
    @State private var dragStart: CGPoint?
    @State private var dockedEdge: FloatingClockGeometry.Edge? = .left
    @State private var suppressTap = false
    @GestureState private var holding = false

    var body: some View {
        GeometryReader { geometry in
            let area = geometry.size
            let position = FloatingClockGeometry.position(point, size: contentSize, area: area, edge: dockedEdge)
            Button {
                guard !suppressTap else {
                    return
                }
                onOpen()
            } label: {
                clockSurface(area: area)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .scaleEffect(holding ? 1.02 : 1)
            .offset(x: position.x, y: position.y)
            .simultaneousGesture(clockGesture(position: position, area: area))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AppText.text("世界时钟"))
            .accessibilityValue(WorldClockText.time(at: clock.now, zone: .autoupdatingCurrent))
            .accessibilityHint(AppText.text("短按查看世界时钟，长按拖动"))
            .accessibilityAction {
                onOpen()
            }
            .accessibilityIdentifier("jobs.home.floatingClock")
            .onGeometryChange(for: CGSize.self) { geometry in
                geometry.size
            } action: { size in
                contentSize = size
            }
            .onChange(of: holding) { previous, current in
                if previous && !current && dragStart != nil {
                    dockedEdge = FloatingClockGeometry.nearestEdge(point, size: contentSize, area: area)
                    dragStart = nil
                }
            }
        }
        .onAppear {
            clock.setActive(active && scenePhase == .active)
        }
        .onDisappear {
            clock.setActive(false)
        }
        .onChange(of: active) { _, value in
            clock.setActive(value && scenePhase == .active)
        }
        .onChange(of: scenePhase) { _, value in
            clock.setActive(active && value == .active)
        }
    }

    private var clockText: some View {
        VStack(spacing: 0) {
            Text(AppText.text("当前时间"))
            Text("88:88:88")
                .hidden()
                .overlay {
                    Text(WorldClockText.time(at: clock.now, zone: .autoupdatingCurrent))
                }
        }
        .font(.system(size: fontSize, weight: .bold))
        .monospacedDigit()
        .multilineTextAlignment(.center)
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func clockSurface(area: CGSize) -> some View {
        ClockContentLayout(available: CGSize(width: max(1, area.width - 16),
                                            height: max(1, area.height - 16))) {
            ViewThatFits(in: .vertical) {
                clockText.fixedSize(horizontal: false, vertical: true)
                ScrollView(.vertical) {
                    clockText
                }
            }
        }
        .background(Color(red: 0.082, green: 0.396, blue: 0.753), in: RoundedRectangle(cornerRadius: 10))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func clockGesture(position: CGPoint, area: CGSize) -> some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .updating($holding) { value, state, _ in
                if case .second(true, _) = value {
                    state = true
                }
            }
            .onChanged { value in
                if case .first(true) = value {
                    // 第一阶段只是按压进行中；第二阶段才算长按完成。
                    suppressTap = false
                }
                if case .second(true, let drag) = value {
                    suppressTap = true
                    guard let drag else {
                        return
                    }
                    if dragStart == nil {
                        dragStart = position
                        dockedEdge = nil
                    }
                    let start = dragStart ?? position
                    point = FloatingClockGeometry.clamp(CGPoint(x: start.x + drag.translation.width,
                                                               y: start.y + drag.translation.height),
                                                        size: contentSize,
                                                        area: area)
                }
            }
            .onEnded { value in
                guard case .second(true, _) = value else {
                    return
                }
                let edge = FloatingClockGeometry.nearestEdge(point, size: contentSize, area: area)
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                    dockedEdge = edge
                }
                dragStart = nil
            }
    }
}

/// 先测文字自然尺寸，再以当前安全区域提议重排；不以屏幕比例或固定宽度撑大按钮。
private struct ClockContentLayout: Layout {

    let available: CGSize

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let content = subviews.first else {
            return .zero
        }
        let natural = content.sizeThatFits(.unspecified)
        let width = min(max(44, natural.width), available.width)
        let fitted = content.sizeThatFits(ProposedViewSize(width: width, height: nil))
        return CGSize(width: width, height: min(max(44, fitted.height), available.height))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.first?.place(at: bounds.origin,
                             proposal: ProposedViewSize(width: bounds.width, height: bounds.height))
    }
}
