//
//  DirectionalPushDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI
import UIKit

struct DirectionalPushDemoView: View {
    
    @State private var direction = PushDirection.right
    @State private var pushProgress = 0.55
    @StateObject private var navigationTransitionController = DirectionalNavigationTransitionController()
    
    var body: some View {
        Form {
            Section("Push 方向") {
                Picker("方向", selection: animatedDirectionSelection) {
                    ForEach(PushDirection.allCases) { direction in
                        Label(direction.title, systemImage: direction.symbol)
                            .tag(direction)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("Push 百分比") {
                Slider(value: $pushProgress, in: 0...1, step: 0.01)
                LabeledContent("当前百分比", value: "\(Int(pushProgress * 100))%")
                
                HStack {
                    Button("0%") {
                        withAnimation(.snappy) {
                            pushProgress = 0
                        }
                    }
                    
                    Spacer()
                    
                    Button("50%") {
                        withAnimation(.snappy) {
                            pushProgress = 0.5
                        }
                    }
                    
                    Spacer()
                    
                    Button("100%") {
                        withAnimation(.snappy) {
                            pushProgress = 1
                        }
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Section("触发 Push") {
                Button {
                    pushPage()
                } label: {
                    Label("Push \(direction.title)侧页面", systemImage: "play.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 62)
                        .background(.blue, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            
            Section("VC Push 预览") {
                DirectionalPushPreview(direction: direction, progress: pushProgress)
                    .frame(height: 260)
                    .animation(.easeInOut(duration: 0.35), value: direction)
            }
        }
        .animation(.snappy, value: direction)
        .animation(.snappy, value: pushProgress)
        .background {
            NavigationTransitionConfigurator(controller: navigationTransitionController)
                .frame(width: 0, height: 0)
        }
    }
    
    private var animatedDirectionSelection: Binding<PushDirection> {
        Binding(
            get: {
                direction
            },
            set: { newDirection in
                guard newDirection != direction else {
                    return
                }
                
                withAnimation(.easeInOut(duration: 0.35)) {
                    direction = newDirection
                }
            }
        )
    }
    
    private func pushPage() {
        navigationTransitionController.pushDetail(direction: direction)
    }
}

private enum PushDirection: String, CaseIterable, Identifiable {
    
    case top
    case bottom
    case left
    case right
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .top: "上"
        case .bottom: "下"
        case .left: "左"
        case .right: "右"
        }
    }
    
    var symbol: String {
        switch self {
        case .top: "arrow.up"
        case .bottom: "arrow.down"
        case .left: "arrow.left"
        case .right: "arrow.right"
        }
    }
    
    func transitionOffset(size: CGSize) -> CGVector {
        switch self {
        case .top:
            return CGVector(dx: 0, dy: -size.height)
        case .bottom:
            return CGVector(dx: 0, dy: size.height)
        case .left:
            return CGVector(dx: -size.width, dy: 0)
        case .right:
            return CGVector(dx: size.width, dy: 0)
        }
    }
}

private final class DirectionalNavigationTransitionController: NSObject, ObservableObject {
    
    private var direction = PushDirection.right
    private var shouldAnimateNextPush = false
    private var isDirectionalDetailActive = false
    private var detailStackDepth = 0
    private weak var navigationController: UINavigationController?
    private weak var previousDelegate: UINavigationControllerDelegate?
    
    func attach(to navigationController: UINavigationController?) {
        guard let navigationController else {
            return
        }
        
        self.navigationController = navigationController
        
        if navigationController.delegate !== self {
            previousDelegate = navigationController.delegate
            navigationController.delegate = self
        }
    }
    
    func detach(from navigationController: UINavigationController?) {
        guard let navigationController,
              navigationController.delegate === self else {
            return
        };navigationController.delegate = previousDelegate
        previousDelegate = nil
    }
    
    func pushDetail(direction: PushDirection) {
        guard let navigationController else {
            return
        }
        
        self.direction = direction
        shouldAnimateNextPush = true
        detailStackDepth = navigationController.viewControllers.count + 1
        
        let detailViewController = UIHostingController(rootView: DirectionalPushDetailView(direction: direction))
        detailViewController.title = "次级页面"
        detailViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(detailViewController, animated: true)
    }
}

extension DirectionalNavigationTransitionController: UINavigationControllerDelegate {
    
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            guard shouldAnimateNextPush else {
                return previousDelegate?.navigationController?(
                    navigationController,
                    animationControllerFor: operation,
                    from: fromVC,
                    to: toVC
                )
            }
            
            shouldAnimateNextPush = false
            isDirectionalDetailActive = true
            return DirectionalNavigationAnimator(direction: direction, operation: operation)
        case .pop:
            guard isDirectionalDetailActive,
                  navigationController.viewControllers.count >= detailStackDepth - 1 else {
                return previousDelegate?.navigationController?(
                    navigationController,
                    animationControllerFor: operation,
                    from: fromVC,
                    to: toVC
                )
            };return DirectionalNavigationAnimator(direction: direction, operation: operation)
        default:
            return previousDelegate?.navigationController?(
                navigationController,
                animationControllerFor: operation,
                from: fromVC,
                to: toVC
            )
        }
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        if isDirectionalDetailActive,
           navigationController.viewControllers.count < detailStackDepth {
            isDirectionalDetailActive = false
            detailStackDepth = 0
        }
        
        previousDelegate?.navigationController?(
            navigationController,
            didShow: viewController,
            animated: animated
        )
    }
}

private final class DirectionalNavigationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let direction: PushDirection
    private let operation: UINavigationController.Operation
    
    init(direction: PushDirection, operation: UINavigationController.Operation) {
        self.direction = direction
        self.operation = operation
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to),
              let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        let offset = direction.transitionOffset(size: finalFrame.size)
        let duration = transitionDuration(using: transitionContext)
        let isPush = operation == .push
        let parallaxRatio = 0.18
        
        if isPush {
            toView.frame = finalFrame.offsetBy(dx: offset.dx, dy: offset.dy)
            containerView.addSubview(toView)
        } else {
            toView.frame = finalFrame.offsetBy(
                dx: -offset.dx * parallaxRatio,
                dy: -offset.dy * parallaxRatio
            )
            containerView.insertSubview(toView, belowSubview: fromView)
        }
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.curveEaseInOut]
        ) {
            if isPush {
                fromView.frame = fromView.frame.offsetBy(
                    dx: -offset.dx * parallaxRatio,
                    dy: -offset.dy * parallaxRatio
                )
                toView.frame = finalFrame
            } else {
                fromView.frame = fromView.frame.offsetBy(dx: offset.dx, dy: offset.dy)
                toView.frame = finalFrame
            }
        } completion: { _ in
            let wasCancelled = transitionContext.transitionWasCancelled
            
            if wasCancelled {
                toView.removeFromSuperview()
            }
            
            fromView.frame = transitionContext.initialFrame(for: fromViewController)
            toView.frame = transitionContext.finalFrame(for: toViewController)
            transitionContext.completeTransition(!wasCancelled)
        }
    }
}

private struct NavigationTransitionConfigurator: UIViewControllerRepresentable {
    
    let controller: DirectionalNavigationTransitionController
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .clear
        viewController.view.isUserInteractionEnabled = false
        
        DispatchQueue.main.async {
            controller.attach(to: viewController.nearestNavigationController)
        };return viewController
    }
    
    func updateUIViewController(_ viewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            controller.attach(to: viewController.nearestNavigationController)
        }
    }
    
    static func dismantleUIViewController(
        _ viewController: UIViewController,
        coordinator: Coordinator
    ) {
        coordinator.controller?.detach(from: viewController.nearestNavigationController)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(controller: controller)
    }
    
    final class Coordinator {
        
        weak var controller: DirectionalNavigationTransitionController?
        
        init(controller: DirectionalNavigationTransitionController) {
            self.controller = controller
        }
    }
}

private extension UIViewController {
    
    var nearestNavigationController: UINavigationController? {
        if let navigationController {
            return navigationController
        }
        
        var currentParent = parent
        while let viewController = currentParent {
            if let navigationController = viewController as? UINavigationController {
                return navigationController
            }
            
            if let navigationController = viewController.navigationController {
                return navigationController
            }
            
            currentParent = viewController.parent
        };return nil
    }
}

private struct DirectionalPushDetailView: View {
    
    let direction: PushDirection
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                Image(systemName: direction.symbol)
                    .font(.system(size: 68, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 116, height: 116)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 8))
                
                VStack(spacing: 10) {
                    Text("次级页面")
                        .font(.largeTitle.bold())
                    Text("从\(direction.title)侧 Push 进入")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(24)
        }
    }
}

private struct DirectionalPushPreview: View {
    
    let direction: PushDirection
    let progress: Double
    
    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VCPushCard(
                    title: "Root VC",
                    subtitle: "当前页面",
                    symbol: "iphone",
                    tint: .gray
                )
                .scaleEffect(1 - clampedProgress * 0.04)
                .opacity(1 - clampedProgress * 0.28)
                .offset(rootOffset(size: proxy.size))
                
                VCPushCard(
                    title: "Target VC",
                    subtitle: "\(direction.title)侧 Push 入场",
                    symbol: direction.symbol,
                    tint: .blue
                )
                .offset(targetOffset(size: proxy.size))
                .shadow(color: .black.opacity(0.12 * clampedProgress), radius: 14, y: 8)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
    }
    
    private func rootOffset(size: CGSize) -> CGSize {
        let distance = rootDistance(size: size)
        
        switch direction {
        case .top:
            return CGSize(width: 0, height: distance)
        case .bottom:
            return CGSize(width: 0, height: -distance)
        case .left:
            return CGSize(width: distance, height: 0)
        case .right:
            return CGSize(width: -distance, height: 0)
        }
    }
    
    private func targetOffset(size: CGSize) -> CGSize {
        let hiddenRatio = 1 - clampedProgress
        
        switch direction {
        case .top:
            return CGSize(width: 0, height: -size.height * hiddenRatio)
        case .bottom:
            return CGSize(width: 0, height: size.height * hiddenRatio)
        case .left:
            return CGSize(width: -size.width * hiddenRatio, height: 0)
        case .right:
            return CGSize(width: size.width * hiddenRatio, height: 0)
        }
    }
    
    private func rootDistance(size: CGSize) -> CGFloat {
        switch direction {
        case .top, .bottom:
            return size.height * clampedProgress * 0.16
        case .left, .right:
            return size.width * clampedProgress * 0.16
        }
    }
}

private struct VCPushCard: View {
    
    let title: String
    let subtitle: String
    let symbol: String
    let tint: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separator).opacity(0.28), lineWidth: 1)
                }
            
            VStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 72, height: 72)
                    .background(tint, in: RoundedRectangle(cornerRadius: 8))
                
                VStack(spacing: 5) {
                    Text(title)
                        .font(.title3.bold())
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
