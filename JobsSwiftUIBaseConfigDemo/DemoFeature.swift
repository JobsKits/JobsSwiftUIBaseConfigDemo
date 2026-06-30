//
//  DemoFeature.swift
//  JobsSwiftUIBaseConfigDemo
//
//  Created by Jobs on 2026年6月30日，星期二.
//

import SwiftUI

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
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .textImage: "Text / Label / Image"
        case .buttonMenu: "Button / Menu / ControlGroup"
        case .inputFields: "TextField / SecureField / TextEditor"
        case .controlValues: "Toggle / Slider / Stepper"
        case .pickers: "Picker / DatePicker / ColorPicker"
        case .progressGauge: "ProgressView / Gauge"
        case .listForm: "List / Form / Section"
        case .navigation: "NavigationStack / Toolbar"
        case .directionalPush: "Directional Push VC"
        case .alertDialog: "Alert / ConfirmationDialog"
        case .presentation: "Sheet / Popover / FullScreenCover"
        case .layout: "ScrollView / LazyVGrid / Grid"
        case .tabPage: "TabView 分页"
        case .disclosureOutline: "DisclosureGroup / OutlineGroup"
        case .asyncLinkShare: "AsyncImage / Link / ShareLink"
        case .animation: "Animation / Transition"
        case .timer: "Timer 定时器"
        }
    }
    
    var subtitle: String {
        switch self {
        case .textImage: "文本、Label、SF Symbols 与基础图片展示"
        case .buttonMenu: "按钮样式、菜单、按钮组和角色按钮"
        case .inputFields: "单行输入、密码输入、多行文本和键盘焦点"
        case .controlValues: "开关、滑杆、步进器等数值交互"
        case .pickers: "分段选择、滚轮选择、日期和颜色选择"
        case .progressGauge: "进度条、加载指示器和仪表盘"
        case .listForm: "列表、表单、分组和只读信息行"
        case .navigation: "导航推出、工具栏按钮和层级页面"
        case .directionalPush: "从上、下、左、右四个方向按百分比 Push 页面"
        case .alertDialog: "系统弹窗、确认弹窗和破坏性操作"
        case .presentation: "模态页面、浮层和全屏展示"
        case .layout: "滚动容器、自适应网格和新式 Grid"
        case .tabPage: "分页 TabView 和索引切换"
        case .disclosureOutline: "折叠分组和树形结构"
        case .asyncLinkShare: "远程图片、外链打开和系统分享"
        case .animation: "状态驱动动画、转场和显隐"
        case .timer: "非 UI 控件：Timer 发布器与计时器"
        }
    }
    
    var symbol: String {
        switch self {
        case .textImage: "textformat"
        case .buttonMenu: "hand.tap"
        case .inputFields: "keyboard"
        case .controlValues: "slider.horizontal.3"
        case .pickers: "calendar.badge.clock"
        case .progressGauge: "gauge.with.dots.needle.67percent"
        case .listForm: "list.bullet.rectangle"
        case .navigation: "point.forward.to.point.capsulepath"
        case .directionalPush: "arrow.up.and.down.and.arrow.left.and.right"
        case .alertDialog: "exclamationmark.bubble"
        case .presentation: "rectangle.on.rectangle"
        case .layout: "square.grid.3x3"
        case .tabPage: "rectangle.split.3x1"
        case .disclosureOutline: "list.triangle"
        case .asyncLinkShare: "network"
        case .animation: "sparkles"
        case .timer: "timer"
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .textImage: TextImageDemoView()
        case .buttonMenu: ButtonMenuDemoView()
        case .inputFields: InputFieldsDemoView()
        case .controlValues: ControlValuesDemoView()
        case .pickers: PickersDemoView()
        case .progressGauge: ProgressGaugeDemoView()
        case .listForm: ListFormDemoView()
        case .navigation: NavigationDemoView()
        case .directionalPush: DirectionalPushDemoView()
        case .alertDialog: AlertDialogDemoView()
        case .presentation: PresentationDemoView()
        case .layout: LayoutDemoView()
        case .tabPage: TabPageDemoView()
        case .disclosureOutline: DisclosureOutlineDemoView()
        case .asyncLinkShare: AsyncLinkShareDemoView()
        case .animation: AnimationDemoView()
        case .timer: TimerDemoView()
        }
    }
}
