//
//  DirectionalPushDemoView.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI
import UIKit

/// SwiftUI 页面负责收集参数和展示预览，真正的自定义 Push 由下方 UIKit 导航代理完成。
struct DirectionalPushDemoView: View {

    @State private var direction = PushDirection.right
    @State private var pushProgress = 0.55
    /// `@StateObject` 让这个引用类型由当前 View 拥有，并在 body 多次重算时保持同一实例。
    @StateObject private var navigationTransitionController = DirectionalNavigationTransitionController()

    var body: some View {
        Form {
            Section("Push 方向") {
                /// 使用自定义 Binding，可在 Picker 写入新值时统一追加动画逻辑。
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
                /// 预览只读取值，不会修改父状态，所以传普通参数而不是 Binding。
                DirectionalPushPreview(direction: direction, progress: pushProgress)
                    .frame(height: 260)
                    .animation(.easeInOut(duration: 0.35), value: direction)
            }
        }
        .animation(.snappy, value: direction)
        .animation(.snappy, value: pushProgress)
        .background {
            /// 放入一个 0 尺寸的 UIKit 桥，只为取得 SwiftUI 当前所在的 UINavigationController。
            NavigationTransitionConfigurator(controller: navigationTransitionController)
                .frame(width: 0, height: 0)
        }
    }

    /// Binding 由 get/set 两个闭包组成：get 提供当前值，set 接收控件写回的新值。
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
        /// View 不直接操作 UIKit 导航栈，把命令交给专门的控制器对象。
        navigationTransitionController.pushDetail(direction: direction)
    }
}

/// 方向枚举把显示文案、系统图标和转场位移统一绑定到同一个值上。
private enum PushDirection: String, CaseIterable, Identifiable {
    
    case top
    case bottom
    case left
    case right
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        /// 从上方进入。
        case .top: "上"
        /// 从下方进入。
        case .bottom: "下"
        /// 从左侧进入。
        case .left: "左"
        /// 从右侧进入。
        case .right: "右"
        }
    }
    
    var symbol: String {
        switch self {
        /// 上方向对应的图标。
        case .top: "arrow.up"
        /// 下方向对应的图标。
        case .bottom: "arrow.down"
        /// 左方向对应的图标。
        case .left: "arrow.left"
        /// 右方向对应的图标。
        case .right: "arrow.right"
        }
    }
    
    func transitionOffset(size: CGSize) -> CGVector {
        switch self {
        /// 上方入场从容器顶边外开始，y 使用负高度。
        case .top:
            return CGVector(dx: 0, dy: -size.height)
        /// 下方入场从容器底边外开始，y 使用正高度。
        case .bottom:
            return CGVector(dx: 0, dy: size.height)
        /// 左侧入场从容器左边外开始，x 使用负宽度。
        case .left:
            return CGVector(dx: -size.width, dy: 0)
        /// 右侧入场从容器右边外开始，x 使用正宽度。
        case .right:
            return CGVector(dx: size.width, dy: 0)
        }
    }
}

/// UIKit 导航转场协调器：持有转场配置，并临时接管 UINavigationControllerDelegate。
private final class DirectionalNavigationTransitionController: NSObject, ObservableObject {

    /// 这些属性描述下一次 Push/Pop 的 UIKit 转场状态，不直接驱动 SwiftUI 界面，因此无需 `@Published`。
    private var direction = PushDirection.right
    private var shouldAnimateNextPush = false
    private var isDirectionalDetailActive = false
    private var detailStackDepth = 0
    /// 导航控制器和原代理都使用 weak，避免“导航控制器 → delegate → 导航控制器”的引用环。
    private weak var navigationController: UINavigationController?
    private weak var previousDelegate: UINavigationControllerDelegate?
    
    func attach(to navigationController: UINavigationController?) {
        guard let navigationController else {
            return
        }
        
        self.navigationController = navigationController

        /// 保存原代理，非本 Demo 发起的导航仍可继续交给原代理处理。
        if navigationController.delegate !== self {
            previousDelegate = navigationController.delegate
            navigationController.delegate = self
        }
    }
    
    func detach(from navigationController: UINavigationController?) {
        /// 只有代理仍是自己时才恢复，避免覆盖页面生命周期中别人刚设置的新代理。
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
        /// 只让本次主动 Push 使用自定义动画，避免影响同导航栈中的其它页面。
        shouldAnimateNextPush = true
        detailStackDepth = navigationController.viewControllers.count + 1
        
        /// UIHostingController 把 SwiftUI View 包装成 UIKit UIViewController，才能压入现有导航栈。
        let detailViewController = UIHostingController(rootView: DirectionalPushDetailView(direction: direction))
        detailViewController.title = "次级页面"
        detailViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(detailViewController, animated: true)
    }
}

extension DirectionalNavigationTransitionController: UINavigationControllerDelegate {

    /// UIKit 在 Push/Pop 前询问动画控制器；返回 nil 表示采用系统默认动画。
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        /// 只拦截由 pushDetail 标记的下一次 Push。
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
        /// 从本 Demo 详情页返回时，使用相反过程完成 Pop。
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
        /// set/none 等其它导航操作继续交还原代理。
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
        /// 导航完成后检查详情层级是否已经退出，及时停止拦截后续 Pop。
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

/// UIKit 转场动画器：计算起止 frame，并在动画结束时向 transitionContext 回报结果。
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
        /// transitionContext 是转场真值来源；任一必要对象缺失时也必须结束转场。
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
        /// 让底层页面轻微反向移动，产生纵深感，而不是与新页面等距离滑动。
        let parallaxRatio = 0.18

        if isPush {
            /// Push：目标页先放在指定方向的屏幕外，再加到容器最上层。
            toView.frame = finalFrame.offsetBy(dx: offset.dx, dy: offset.dy)
            containerView.addSubview(toView)
        } else {
            /// Pop：目标页先放在轻微偏移位置，并插入当前页下方。
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
            /// 动画闭包只设置终态，UIKit 负责在起止 frame 之间插值。
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

            /// 交互转场若被取消，要移除未完成展示的目标视图。
            if wasCancelled {
                toView.removeFromSuperview()
            }
            
            fromView.frame = transitionContext.initialFrame(for: fromViewController)
            toView.frame = transitionContext.finalFrame(for: toViewController)
            /// 自定义转场必须调用 completeTransition，否则导航控制器会一直停在转场状态。
            transitionContext.completeTransition(!wasCancelled)
        }
    }
}

/// UIViewControllerRepresentable 是 SwiftUI 与 UIKit 控制器之间的生命周期适配器。
private struct NavigationTransitionConfigurator: UIViewControllerRepresentable {
    
    let controller: DirectionalNavigationTransitionController
    
    func makeUIViewController(context: Context) -> UIViewController {
        /// make 只在创建桥接控制器时调用一次，适合完成一次性 UIKit 初始化。
        let viewController = UIViewController()
        viewController.view.backgroundColor = .clear
        viewController.view.isUserInteractionEnabled = false
        
        /// 延后一轮 RunLoop，等待桥接控制器真正进入父子层级后再寻找导航控制器。
        DispatchQueue.main.async {
            controller.attach(to: viewController.nearestNavigationController)
        };return viewController
    }

    /// SwiftUI 输入变化时会调用 update；重复 attach 内部已做身份判断。
    func updateUIViewController(_ viewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            controller.attach(to: viewController.nearestNavigationController)
        }
    }
    
    static func dismantleUIViewController(
        _ viewController: UIViewController,
        coordinator: Coordinator
    ) {
        /// 桥从视图树移除时恢复原导航代理，避免影响其它页面。
        coordinator.controller?.detach(from: viewController.nearestNavigationController)
    }

    /// Coordinator 是 Representable 的长期引用容器，其生命周期独立于临时 struct 值。
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

    /// 从桥接控制器自身或父控制器链向上查找最近的 UINavigationController。
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

/// 被 UIHostingController 包装并 Push 的 SwiftUI 详情页面。
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

/// 纯 SwiftUI 的转场进度预览，不会实际修改 UINavigationController。
private struct DirectionalPushPreview: View {
    
    let direction: PushDirection
    let progress: Double
    
    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
    
    var body: some View {
        /// GeometryReader 提供预览区域尺寸，位移才能同时适配横竖屏和不同设备。
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
        /// 底层页面只移动完整距离的 16%，模拟系统导航的视差效果。
        let distance = rootDistance(size: size)

        switch direction {
        /// 新页面从上方进入时，底层页面向下退让。
        case .top:
            return CGSize(width: 0, height: distance)
        /// 新页面从下方进入时，底层页面向上退让。
        case .bottom:
            return CGSize(width: 0, height: -distance)
        /// 新页面从左侧进入时，底层页面向右退让。
        case .left:
            return CGSize(width: distance, height: 0)
        /// 新页面从右侧进入时，底层页面向左退让。
        case .right:
            return CGSize(width: -distance, height: 0)
        }
    }
    
    private func targetOffset(size: CGSize) -> CGSize {
        /// progress 为 0 时完全在屏幕外，为 1 时归零到最终位置。
        let hiddenRatio = 1 - clampedProgress

        switch direction {
        /// 上方目标页按剩余比例保留负 y 位移。
        case .top:
            return CGSize(width: 0, height: -size.height * hiddenRatio)
        /// 下方目标页按剩余比例保留正 y 位移。
        case .bottom:
            return CGSize(width: 0, height: size.height * hiddenRatio)
        /// 左侧目标页按剩余比例保留负 x 位移。
        case .left:
            return CGSize(width: -size.width * hiddenRatio, height: 0)
        /// 右侧目标页按剩余比例保留正 x 位移。
        case .right:
            return CGSize(width: size.width * hiddenRatio, height: 0)
        }
    }
    
    private func rootDistance(size: CGSize) -> CGFloat {
        switch direction {
        /// 垂直转场的视差距离取容器高度。
        case .top, .bottom:
            return size.height * clampedProgress * 0.16
        /// 水平转场的视差距离取容器宽度。
        case .left, .right:
            return size.width * clampedProgress * 0.16
        }
    }
}

/// 预览中的通用页面卡片；四个 let 都是父视图传入的只读配置。
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
