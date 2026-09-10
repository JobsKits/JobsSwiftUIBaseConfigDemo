//
//  CustomCircularGaugeView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

/// 可交互的自定义环形仪表盘，展示 Binding、几何计算、Shape 绘制、手势和无障碍支持。
struct CustomCircularGaugeView: View {

    /// `@Binding` 不拥有数据；真实 progress 存在父视图中，这里只获得读写通道。
    @Binding var progress: Double
    /// 普通存储属性是初始化参数，适合由父视图传入不需要反向修改的配置。
    let title: String
    var completedColor: Color = .blue
    var remainingColor: Color = Color(.systemGray5)
    
    private var clampedProgress: Double {
        /// 把外部输入保护在合法区间，避免绘制和角度计算越界。
        min(max(progress, 0), 1)
    }
    
    private var progressText: String {
        "\(Int(clampedProgress * 100))%"
    }
    
    var body: some View {
        /// GeometryReader 把父容器实际分配的尺寸交给闭包，适合依赖尺寸的自定义绘制。
        GeometryReader { proxy in
            /// body 闭包内可以声明局部常量；任一输入变化后都会随 body 一起重新计算。
            let side = min(proxy.size.width, proxy.size.height)
            let lineWidth = side * 0.1
            let radius = side * 0.39
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let angle = Angle.degrees(135 + clampedProgress * 270)
            /// SwiftUI 坐标原点在左上角，x 向右、y 向下；用三角函数求滑块圆心。
            let knobCenter = CGPoint(
                x: center.x + radius * cos(angle.radians),
                y: center.y + radius * sin(angle.radians)
            )
            
            ZStack {
                /// Circle.trim 使用 0...1 的路径比例；0.75 表示绘制 270°，留出底部 90° 缺口。
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        remainingColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(135))
                
                Circle()
                    /// 完成弧只绘制“进度 × 总弧长比例”。
                    .trim(from: 0, to: clampedProgress * 0.75)
                    .stroke(
                        completedColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(135))
                
                Circle()
                    /// position 接收父坐标系内的绝对点，把滑块放到当前角度对应的位置。
                    .fill(.background)
                    .frame(width: lineWidth * 1.9, height: lineWidth * 1.9)
                    .overlay {
                        Circle()
                            .fill(completedColor)
                            .frame(width: lineWidth * 1.25, height: lineWidth * 1.25)
                    }
                    .position(knobCenter)
                
                VStack(spacing: 2) {
                    Text(progressText)
                        .font(.system(size: side * 0.22, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text(title)
                        .font(.system(size: side * 0.12, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .contentShape(Rectangle())
            /// minimumDistance 为 0，点按和拖动都能立即更新数值。
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        updateProgress(from: value.location, in: proxy.size)
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(progressText)
        /// VoiceOver 用户可以上下滑动，以固定步长调整这个自定义控件。
        .accessibilityAdjustableAction { direction in
            switch direction {
            /// 无障碍“增加”动作把进度提高 5%。
            case .increment:
                progress = min(progress + 0.05, 1)
            /// 无障碍“减少”动作把进度降低 5%。
            case .decrement:
                progress = max(progress - 0.05, 0)
            /// 为未来系统新增的方向保留安全兜底。
            @unknown default:
                break
            }
        }
    }
    
    private func updateProgress(from location: CGPoint, in size: CGSize) {
        progress = progressValue(from: location, in: size)
    }
    
    private func progressValue(from location: CGPoint, in size: CGSize) -> Double {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let dx = location.x - center.x
        let dy = location.y - center.y
        /// atan2 把触点相对圆心的向量转换为 -180°...180° 的极角。
        let rawDegrees = atan2(Double(dy), Double(dx)) * 180 / .pi
        /// 统一换算到 0°...360°，便于处理跨过 0° 的有效弧段。
        let degrees = rawDegrees < 0 ? rawDegrees + 360 : rawDegrees
        var value = 0.0
        
        if degrees >= 135 {
            /// 135°...360° 映射到进度 0...约 0.83。
            value = (degrees - 135) / 270
        } else if degrees <= 45 {
            /// 0°...45° 是同一条 270° 弧的尾段，接续映射到约 0.83...1。
            value = (degrees + 225) / 270
        } else {
            /// 45°...135° 位于缺口，按靠近的端点吸附为 1 或 0。
            value = degrees < 90 ? 1 : 0
        };return min(max(value, 0), 1)
    }
}
