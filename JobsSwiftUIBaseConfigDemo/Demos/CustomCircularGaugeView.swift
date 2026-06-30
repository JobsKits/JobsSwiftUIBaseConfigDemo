//
//  CustomCircularGaugeView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

struct CustomCircularGaugeView: View {
    
    @Binding var progress: Double
    let title: String
    var completedColor: Color = .blue
    var remainingColor: Color = Color(.systemGray5)
    
    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
    
    private var progressText: String {
        "\(Int(clampedProgress * 100))%"
    }
    
    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let lineWidth = side * 0.1
            let radius = side * 0.39
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let angle = Angle.degrees(135 + clampedProgress * 270)
            let knobCenter = CGPoint(
                x: center.x + radius * cos(angle.radians),
                y: center.y + radius * sin(angle.radians)
            )
            
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        remainingColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(135))
                
                Circle()
                    .trim(from: 0, to: clampedProgress * 0.75)
                    .stroke(
                        completedColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(135))
                
                Circle()
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
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                progress = min(progress + 0.05, 1)
            case .decrement:
                progress = max(progress - 0.05, 0)
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
        let rawDegrees = atan2(Double(dy), Double(dx)) * 180 / .pi
        let degrees = rawDegrees < 0 ? rawDegrees + 360 : rawDegrees
        var value = 0.0
        
        if degrees >= 135 {
            value = (degrees - 135) / 270
        } else if degrees <= 45 {
            value = (degrees + 225) / 270
        } else {
            value = degrees < 90 ? 1 : 0
        };return min(max(value, 0), 1)
    }
}
