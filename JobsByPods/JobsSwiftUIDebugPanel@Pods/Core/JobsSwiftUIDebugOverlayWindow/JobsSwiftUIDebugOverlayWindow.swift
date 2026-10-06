//
//  JobsSwiftUIDebugOverlayWindow.swift
//  JobsSwiftUIDebugPanel
//
//  Created by Jobs on 2026年10月5日，星期一.
//

#if DEBUG
import UIKit

final class JobsSwiftUIDebugOverlayWindow: UIWindow {
    weak var hostWindow: UIWindow?
    weak var sceneState: JobsSwiftUIDebugSceneState?
    var buttonFrame = CGRect.zero

    override var canBecomeKey: Bool {
        false
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden else {
            return nil
        }
        if sceneState?.isPresented == true {
            return super.hitTest(point, with: event)
        }
        let dx = point.x - buttonFrame.midX
        let dy = point.y - buttonFrame.midY
        let radius = buttonFrame.width * 0.5
        guard radius > 0, dx * dx + dy * dy <= radius * radius else {
            return nil
        }
        return super.hitTest(point, with: event)
    }
}
#endif
