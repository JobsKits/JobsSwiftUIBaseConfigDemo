//
//  FloatingClockGeometry.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年11月16日，星期一.
//

import Foundation

enum FloatingClockGeometry {

    enum Edge: CaseIterable {
        case left, right, top, bottom
    }

    static func clamp(_ point: CGPoint, size: CGSize, area: CGSize) -> CGPoint {
        CGPoint(x: min(max(8, point.x), max(8, area.width - size.width - 8)),
                y: min(max(8, point.y), max(8, area.height - size.height - 8)))
    }

    static func position(_ point: CGPoint, size: CGSize, area: CGSize, edge: Edge?) -> CGPoint {
        var result = clamp(point, size: size, area: area)
        switch edge {
        case .left:
            result.x = 8
        case .right:
            result.x = max(8, area.width - size.width - 8)
        case .top:
            result.y = 8
        case .bottom:
            result.y = max(8, area.height - size.height - 8)
        case nil:
            break
        }
        return result
    }

    static func nearestEdge(_ point: CGPoint, size: CGSize, area: CGSize) -> Edge {
        let point = clamp(point, size: size, area: area)
        let distances: [(Edge, CGFloat)] = [
            (.left, point.x - 8),
            (.right, area.width - point.x - size.width - 8),
            (.top, point.y - 8),
            (.bottom, area.height - point.y - size.height - 8)
        ]
        return distances.min(by: { $0.1 < $1.1 })?.0 ?? .left
    }
}
