//
//  DemoFeature.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI
#if DEBUG
import JobsSwiftUIDebugPanel
#endif

/// Demo 的单一数据源：一个枚举值同时提供标题、说明、图标和目标页面。
/// `CaseIterable` 会为这种不带关联值的枚举自动生成 `allCases`，用于遍历全部 Demo。
/// `Identifiable` 要求每项提供稳定且唯一的 `id`，让 ForEach 能识别插入、删除、移动的是哪一项。
enum DemoFeature: String, CaseIterable, Identifiable {
    case textImage
    case buttonMenu
    case inputFields
    case controlValues
    case pickers
    case progressGauge
    case listForm
    case navigation
    case directionalPush
    case alertDialog
    case presentation
    case layout
    case tabPage
    case disclosureOutline
    case asyncLinkShare
    case animation
    case timer
#if DEBUG
    case debugPanel
#endif
    
    /// rawValue 对每个 case 唯一且稳定，适合作为视图身份和持久化值。
    var id: String { rawValue }

    /// Swift 允许只含一个表达式的分支省略 `return`。
    var title: String {
        switch self {
        /// 文本与图片 Demo 的列表标题。
        case .textImage: "Text / Label / Image"
        /// 按钮与菜单 Demo 的列表标题。
        case .buttonMenu: "Button / Menu / ControlGroup"
        /// 输入控件 Demo 的列表标题。
        case .inputFields: "TextField / SecureField / TextEditor"
        /// 数值控件 Demo 的列表标题。
        case .controlValues: "Toggle / Slider / Stepper"
        /// 选择控件 Demo 的列表标题。
        case .pickers: "Picker / DatePicker / ColorPicker"
        /// 进度与仪表盘 Demo 的列表标题。
        case .progressGauge: "ProgressView / Gauge"
        /// 列表与表单 Demo 的列表标题。
        case .listForm: "List / Form / Section"
        /// 导航 Demo 的列表标题。
        case .navigation: "NavigationStack / Toolbar"
        /// 自定义方向 Push Demo 的列表标题。
        case .directionalPush: "Directional Push VC"
        /// 弹窗 Demo 的列表标题。
        case .alertDialog: "Alert / ConfirmationDialog"
        /// 模态展示 Demo 的列表标题。
        case .presentation: "Sheet / Popover / FullScreenCover"
        /// 布局 Demo 的列表标题。
        case .layout: "ScrollView / LazyVGrid / Grid"
        /// 分页 Demo 的列表标题。
        case .tabPage: "TabView 分页"
        /// 折叠树 Demo 的列表标题。
        case .disclosureOutline: "DisclosureGroup / OutlineGroup"
        /// 异步图片、链接与分享 Demo 的列表标题。
        case .asyncLinkShare: "AsyncImage / Link / ShareLink"
        /// 动画 Demo 的列表标题。
        case .animation: "Animation / Transition"
        /// 计时器 Demo 的列表标题。
        case .timer: "Timer 定时器"
#if DEBUG
        /// Debug 专属的独立 SwiftUI 调试框架。
        case .debugPanel: "SwiftUI Debug 调试面板"
#endif
        }
    }

    var subtitle: String {
        switch self {
        /// 概括文本和图片页面的能力。
        case .textImage: "文本、Label、SF Symbols 与基础图片展示"
        /// 概括按钮和菜单页面的能力。
        case .buttonMenu: "按钮样式、菜单、按钮组和角色按钮"
        /// 概括输入页面的能力。
        case .inputFields: "单行输入、密码输入、多行文本和键盘焦点"
        /// 概括数值控件页面的能力。
        case .controlValues: "开关、滑杆、步进器等数值交互"
        /// 概括选择控件页面的能力。
        case .pickers: "分段选择、滚轮选择、日期和颜色选择"
        /// 概括进度页面的能力。
        case .progressGauge: "进度条、加载指示器和仪表盘"
        /// 概括列表和表单页面的能力。
        case .listForm: "列表、表单、分组和只读信息行"
        /// 概括导航页面的能力。
        case .navigation: "导航推出、工具栏按钮和层级页面"
        /// 概括方向 Push 页面及其 UIKit 互操作能力。
        case .directionalPush: "从上、下、左、右四个方向按百分比 Push 页面"
        /// 概括系统弹窗页面的能力。
        case .alertDialog: "系统弹窗、确认弹窗和破坏性操作"
        /// 概括模态展示页面的能力。
        case .presentation: "模态页面、浮层和全屏展示"
        /// 概括布局页面的能力。
        case .layout: "滚动容器、自适应网格和新式 Grid"
        /// 概括分页页面的能力。
        case .tabPage: "分页 TabView 和索引切换"
        /// 概括折叠树页面的能力。
        case .disclosureOutline: "折叠分组和树形结构"
        /// 概括异步与系统服务页面的能力。
        case .asyncLinkShare: "远程图片、外链打开和系统分享"
        /// 概括动画页面的能力。
        case .animation: "状态驱动动画、转场和显隐"
        /// 概括 Combine 计时器页面的能力。
        case .timer: "非 UI 控件：Timer 发布器与计时器"
#if DEBUG
        /// 环境配置、工具导航与真实网络回退示例。
        case .debugPanel: "圆形悬浮入口、环境切换、顺序动作与真实 GET /get"
#endif
        }
    }

    var symbol: String {
        switch self {
        /// 文本和图片使用文字格式图标。
        case .textImage: "textformat"
        /// 按钮和菜单使用点按图标。
        case .buttonMenu: "hand.tap"
        /// 输入控件使用键盘图标。
        case .inputFields: "keyboard"
        /// 数值控件使用滑杆图标。
        case .controlValues: "slider.horizontal.3"
        /// 选择控件使用日期时间图标。
        case .pickers: "calendar.badge.clock"
        /// 进度页面使用仪表盘图标。
        case .progressGauge: "gauge.with.dots.needle.67percent"
        /// 列表和表单使用列表图标。
        case .listForm: "list.bullet.rectangle"
        /// 导航页面使用前进路径图标。
        case .navigation: "point.forward.to.point.capsulepath"
        /// 方向 Push 使用四方向图标。
        case .directionalPush: "arrow.up.and.down.and.arrow.left.and.right"
        /// 弹窗页面使用警告气泡图标。
        case .alertDialog: "exclamationmark.bubble"
        /// 模态页面使用层叠矩形图标。
        case .presentation: "rectangle.on.rectangle"
        /// 布局页面使用网格图标。
        case .layout: "square.grid.3x3"
        /// 分页页面使用分栏图标。
        case .tabPage: "rectangle.split.3x1"
        /// 折叠树页面使用树形列表图标。
        case .disclosureOutline: "list.triangle"
        /// 异步与链接页面使用网络图标。
        case .asyncLinkShare: "network"
        /// 动画页面使用闪光图标。
        case .animation: "sparkles"
        /// 计时器页面使用计时器图标。
        case .timer: "timer"
#if DEBUG
        /// 此入口实际图标通过 icon 使用已打包圆形背景图。
        case .debugPanel: ""
#endif
        }
    }

    @ViewBuilder
    var icon: some View {
#if DEBUG
        if self == .debugPanel {
            JobsSwiftUIDebugPanel.buttonImage
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
        } else {
            Image(systemName: symbol)
        }
#else
        Image(systemName: symbol)
#endif
    }

    /// `@ViewBuilder` 允许不同 case 返回不同的具体 View，而对外仍统一表现为 `some View`。
    @ViewBuilder
    var destination: some View {
        switch self {
        /// 构建文本与图片 Demo。
        case .textImage: TextImageDemoView()
        /// 构建按钮与菜单 Demo。
        case .buttonMenu: ButtonMenuDemoView()
        /// 构建输入控件 Demo。
        case .inputFields: InputFieldsDemoView()
        /// 构建数值控件 Demo。
        case .controlValues: ControlValuesDemoView()
        /// 构建选择控件 Demo。
        case .pickers: PickersDemoView()
        /// 构建进度与仪表盘 Demo。
        case .progressGauge: ProgressGaugeDemoView()
        /// 构建列表与表单 Demo。
        case .listForm: ListFormDemoView()
        /// 构建导航 Demo。
        case .navigation: NavigationDemoView()
        /// 构建自定义方向 Push Demo。
        case .directionalPush: DirectionalPushDemoView()
        /// 构建系统弹窗 Demo。
        case .alertDialog: AlertDialogDemoView()
        /// 构建模态展示 Demo。
        case .presentation: PresentationDemoView()
        /// 构建布局 Demo。
        case .layout: LayoutDemoView()
        /// 构建分页 Demo。
        case .tabPage: TabPageDemoView()
        /// 构建折叠树 Demo。
        case .disclosureOutline: DisclosureOutlineDemoView()
        /// 构建异步图片、链接与分享 Demo。
        case .asyncLinkShare: AsyncLinkShareDemoView()
        /// 构建动画 Demo。
        case .animation: AnimationDemoView()
        /// 构建计时器 Demo。
        case .timer: TimerDemoView()
#if DEBUG
        /// 构建 SwiftUI Pod 配套网络与交互示例。
        case .debugPanel: JobsSwiftUIDebugPanelDemoView()
#endif
        }
    }
}
