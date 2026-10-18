# `JobsSwiftUIBaseConfigDemo`

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#jobs-toc-heading-1)
- [一、工程信息](#jobs-toc-heading-2)
- [二、目录结构](#jobs-toc-heading-3)
- [三、入口流程](#jobs-toc-heading-4)
- [四、功能清单](#jobs-toc-heading-5)
- [五、重点实现](#jobs-toc-heading-6)
  - [5.1、TabBar 结构](#jobs-toc-heading-7)
  - [5.2、列表推出 Demo 页面](#jobs-toc-heading-8)
  - [5.3、自定义双色圆形 Gauge](#jobs-toc-heading-9)
  - [5.4、Timer 定时器](#jobs-toc-heading-10)
  - [5.5、四向 Push 预览](#jobs-toc-heading-11)
  - [5.6、Debug 环境与动作](#jobs-toc-heading-12)
- [六、项目配置支持](#jobs-toc-heading-13)
  - [6.1、当前定位](#jobs-toc-heading-14)
  - [6.2、安装与构建自动挂载脚本](#jobs-toc-heading-15)
  - [6.3、脚本日志](#jobs-toc-heading-16)
- [七、运行方式](#jobs-toc-heading-17)
  - [7.1、使用 Xcode 运行](#jobs-toc-heading-18)
  - [7.2、使用命令行编译](#jobs-toc-heading-19)
  - [7.3、生成 CodeGraph](#jobs-toc-heading-20)
  - [7.4、自动输出构建产物](#jobs-toc-heading-21)
- [八、扩展 Demo](#jobs-toc-heading-22)
- [九、注意事项](#jobs-toc-heading-23)
- [十、排查方式](#jobs-toc-heading-24)

</details>
<!-- jobs-toc:end -->

---

## <span id="jobs-toc-heading-1" data-jobs-toc="v2">🔥 <font id=前言>前言</font></span><!-- jobs-toc:heading-end -->

`JobsSwiftUIBaseConfigDemo` 是一个纯原生 [**Swift**](https://www.swift.org/) / [**SwiftUI**](https://developer.apple.com/xcode/swiftui/) iOS Demo 工程，用来集中演示系统 UI 组件和常见交互写法。

工程入口模拟 iOS 新工程的基础结构：启动后先进入主 `TabView`，其中 `Demo` Tab 是功能列表，点击列表功能名后通过 `NavigationStack` 推出对应 Demo 页面。

本工程使用原生 SwiftUI 演示系统组件；Debug 额外接入独立的本地 `JobsSwiftUIDebugPanel` Pod，演示圆形浮层、环境切换和自定义动作。Release 不链接调试 Pod，也不显示调试 Demo。

工程使用 [**CocoaPods**](https://cocoapods.org/) 入口：`Podfile` 加载解耦后的 `Podfile.deps`，在 `pod install` 收尾阶段挂载 [**CodeGraph**](https://github.com/colbymchenry/codegraph) 脚本生成 `.codegraph`。依赖清单包含本地脚本锚点和仅 Debug 生效的 SwiftUI 调试 Pod；调试 Pod 无其它业务 Pod 依赖。

| 安装环节 | 当前行为 |
| --- | --- |
| 网络链路 | `pod install` / `pod update` 先同步实测当前链路，必要时验证机器上已配置、已启用的代理，并让后续源码下载继承同一进程环境 |
| 公共 Specs | 依据官方 CDN 与 Git Specs 的真实请求结果选源，替代固定 `https://github.com/CocoaPods/Specs.git` |
| 源码归档 | 仅已核验的 `AMPopTip 4.12.0` Git 网络失败可回退官方固定提交归档；本工程目前只有本地 Pod，不会触发该白名单 |
| 安装后任务 | 保留原有 `post_install` 工程设置及 `post_integrate` 后台 CodeGraph；网络增强异常只告警，依赖安装失败仍由 CocoaPods 正常报告 |

## <span id="jobs-toc-heading-2" data-jobs-toc="v2">一、工程信息 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

| 项目 | 说明 |
| --- | --- |
| 工作区文件 | `./JobsSwiftUIBaseConfigDemo.xcworkspace` |
| 工程文件 | `./JobsSwiftUIBaseConfigDemo.xcodeproj` |
| App 入口 | `./JobsSwiftUIBaseConfigDemo/JobsSwiftUIBaseConfigDemoApp.swift` |
| 主 Tab 容器 | `./JobsSwiftUIBaseConfigDemo/MainTabView.swift` |
| Demo 列表 | `./JobsSwiftUIBaseConfigDemo/DemoListView.swift` |
| Demo 注册表 | `./JobsSwiftUIBaseConfigDemo/DemoFeature.swift` |
| Demo 页面目录 | `./JobsSwiftUIBaseConfigDemo/Demos/` |
| Podfile 入口 | `./Podfile` |
| Pod 依赖清单 | `./Podfile.deps` |
| Pod 挂载脚本 | `./ScriptsByPods/` |
| 脚本锚点 Pod | `./ScriptsByPods/JobsSwiftUICodeGraphHook/` |
| Debug 调试 Pod | [JobsSwiftUIDebugPanel](./JobsByPods/JobsSwiftUIDebugPanel@Pods/README.md) |
| 框架配置说明 | [SwiftUI 工程项目框架配置方案](./SwiftUIDoc.md/SwiftUI工程项目框架配置方案@Jobs.md/SwiftUI工程项目框架配置方案@Jobs.md) |
| Bundle ID | `com.jobs.jobsswiftuibaseconfigdemo` |
| 最低系统 | iOS `17.0` |
| 支持平台 | `iphoneos` / `iphonesimulator` |
| 依赖方式 | 本地脚本锚点；Debug 专用独立 SwiftUI 调试 Pod |

## <span id="jobs-toc-heading-3" data-jobs-toc="v2">二、目录结构 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```text
.
├── README.md
├── icon.png
├── Podfile
├── Podfile.deps
├── JobsByPods
│   └── JobsSwiftUIDebugPanel@Pods    # Debug 专用原生 SwiftUI 调试框架
├── SwiftUIDoc.md
│   └── SwiftUI工程项目框架配置方案@Jobs.md
├── ScriptsByDevTools
│   └── save_device_ipa_after_build.sh
├── build                         # 仅保留本次真机.ipa 或模拟器.ipa
├── ScriptsByPods
│   ├── README.md
│   ├── JobsSwiftUICodeGraphHook
│   ├── 【MacOS】🌐CocoaPods网络适配.command
│   ├── 【MacOS】🌐CocoaPods源自动选择.command
│   ├── codegraph_init.command
│   └── codegraph_export_md.command
├── JobsSwiftUIBaseConfigDemo.xcworkspace
├── JobsSwiftUIBaseConfigDemo.xcodeproj
└── JobsSwiftUIBaseConfigDemo
    ├── Assets.xcassets
    ├── JobsSwiftUIBaseConfigDemoApp.swift
    ├── JobsSwiftUIDebugAppDelegate.swift
    ├── JobsSwiftUIDebugNetworkEnvironment.swift
    ├── MainTabView.swift
    ├── DemoListView.swift
    ├── DemoFeature.swift
    ├── DemoFeatureRow.swift
    ├── GalleryTabView.swift
    ├── AboutTabView.swift
    └── Demos
        ├── TextImageDemoView.swift
        ├── ButtonMenuDemoView.swift
        ├── InputFieldsDemoView.swift
        ├── ControlValuesDemoView.swift
        ├── PickersDemoView.swift
        ├── ProgressGaugeDemoView.swift
        ├── CustomCircularGaugeView.swift
        ├── ListFormDemoView.swift
        ├── NavigationDemoView.swift
        ├── DirectionalPushDemoView.swift
        ├── AlertDialogDemoView.swift
        ├── PresentationDemoView.swift
        ├── LayoutDemoView.swift
        ├── TabPageDemoView.swift
        ├── DisclosureOutlineDemoView.swift
        ├── AsyncLinkShareDemoView.swift
        ├── AnimationDemoView.swift
        ├── TimerDemoView.swift
        └── JobsSwiftUIDebugPanelDemoView.swift
```

## <span id="jobs-toc-heading-4" data-jobs-toc="v2">三、入口流程 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```mermaid
flowchart TD
    A["JobsSwiftUIBaseConfigDemoApp"] --> B["MainTabView"]
    B --> C["Demo Tab"]
    B --> D["速览 Tab"]
    B --> E["关于 Tab"]
    C --> F["DemoListView"]
    D --> G["GalleryTabView"]
    E --> H["AboutTabView"]
    F --> I["DemoFeature"]
    G --> I
    I --> J["Demos/*DemoView.swift"]
```

主流程说明：

- `JobsSwiftUIBaseConfigDemoApp` 使用 `WindowGroup` 加载 `MainTabView`。
- `MainTabView` 使用 `TabView` 提供 `Demo`、`速览`、`关于` 三个 Tab。
- `DemoListView` 使用 `NavigationStack`、`List`、`NavigationLink` 组织功能列表。
- `DemoFeature` 是 Demo 注册表，集中维护功能名、描述、图标和目标页面。
- `Demos/` 目录下每个文件对应一个独立演示页面。
- Debug 的 App 通过 `@UIApplicationDelegateAdaptor` 配置调试 Pod，再用根视图 `.jobsSwiftUIDebugPanel()` 绑定每个业务场景。浮层有独立 `NavigationStack`，完整保留各 Tab 的导航状态。

## <span id="jobs-toc-heading-5" data-jobs-toc="v2">四、功能清单 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

| 功能名 | 演示内容 | 对应文件 |
| --- | --- | --- |
| `Text / Label / Image` | 文本、`Label`、SF Symbols 与基础图片展示 | `./JobsSwiftUIBaseConfigDemo/Demos/TextImageDemoView.swift` |
| `Button / Menu / ControlGroup` | 按钮样式、菜单、按钮组和角色按钮 | `./JobsSwiftUIBaseConfigDemo/Demos/ButtonMenuDemoView.swift` |
| `TextField / SecureField / TextEditor` | 单行输入、密码输入、多行文本和键盘焦点 | `./JobsSwiftUIBaseConfigDemo/Demos/InputFieldsDemoView.swift` |
| `Toggle / Slider / Stepper` | 开关、滑杆、步进器等数值交互 | `./JobsSwiftUIBaseConfigDemo/Demos/ControlValuesDemoView.swift` |
| `Picker / DatePicker / ColorPicker` | 分段选择、滚轮选择、日期和颜色选择 | `./JobsSwiftUIBaseConfigDemo/Demos/PickersDemoView.swift` |
| `ProgressView / Gauge` | 进度条、加载指示器、线性 Gauge 和自定义圆形 Gauge | `./JobsSwiftUIBaseConfigDemo/Demos/ProgressGaugeDemoView.swift` |
| `List / Form / Section` | 列表、表单、分组和只读信息行 | `./JobsSwiftUIBaseConfigDemo/Demos/ListFormDemoView.swift` |
| `NavigationStack / Toolbar` | 导航推出、工具栏按钮和层级页面 | `./JobsSwiftUIBaseConfigDemo/Demos/NavigationDemoView.swift` |
| `Directional Push VC` | 从上、下、左、右四个方向按百分比 Push 页面 | `./JobsSwiftUIBaseConfigDemo/Demos/DirectionalPushDemoView.swift` |
| `Alert / ConfirmationDialog` | 系统弹窗、确认弹窗和破坏性操作 | `./JobsSwiftUIBaseConfigDemo/Demos/AlertDialogDemoView.swift` |
| `Sheet / Popover / FullScreenCover` | 模态页面、浮层和全屏展示 | `./JobsSwiftUIBaseConfigDemo/Demos/PresentationDemoView.swift` |
| `ScrollView / LazyVGrid / Grid` | 滚动容器、自适应网格和新式 `Grid` | `./JobsSwiftUIBaseConfigDemo/Demos/LayoutDemoView.swift` |
| `TabView 分页` | 分页 `TabView` 和索引切换 | `./JobsSwiftUIBaseConfigDemo/Demos/TabPageDemoView.swift` |
| `DisclosureGroup / OutlineGroup` | 折叠分组和树形结构 | `./JobsSwiftUIBaseConfigDemo/Demos/DisclosureOutlineDemoView.swift` |
| `AsyncImage / Link / ShareLink` | 远程图片、外链打开和系统分享 | `./JobsSwiftUIBaseConfigDemo/Demos/AsyncLinkShareDemoView.swift` |
| `Animation / Transition` | 状态驱动动画、转场和显隐 | `./JobsSwiftUIBaseConfigDemo/Demos/AnimationDemoView.swift` |
| `Timer 定时器` | 非 UI 控件：`Timer.publish`、`autoconnect` 和 `onReceive` | `./JobsSwiftUIBaseConfigDemo/Demos/TimerDemoView.swift` |
| `SwiftUI Debug 调试面板` | Debug 圆形悬浮按钮、环境选择、顺序动作、真实 `GET /get` 与失败回退 | `./JobsSwiftUIBaseConfigDemo/Demos/JobsSwiftUIDebugPanelDemoView.swift` |

## <span id="jobs-toc-heading-6" data-jobs-toc="v2">五、重点实现 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

### <span id="jobs-toc-heading-7" data-jobs-toc="v2">5.1、TabBar 结构 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

`MainTabView` 使用 SwiftUI 的 `TabView` 实现主 TabBar：

```swift
TabView(selection: $selectedTab) {
    DemoListView()
        .tabItem {
            Label("Demo", systemImage: "list.bullet.rectangle")
        }
        .tag(AppTab.demos)
}
```

### <span id="jobs-toc-heading-8" data-jobs-toc="v2">5.2、列表推出 Demo 页面 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

`DemoListView` 通过 `NavigationStack` 包住 `List`，每个功能项都是一个 `NavigationLink`：

```swift
NavigationLink {
    feature.destination
        .navigationTitle(feature.title)
        .navigationBarTitleDisplayMode(.inline)
} label: {
    DemoFeatureRow(feature: feature)
}
```

首页列表支持长按 cell 后拖拽排序，排序结果通过 `AppStorage` 写入 `UserDefaults`。再次进入 `DemoListView` 时，会优先读取已保存顺序；新增 Demo 未出现在旧顺序里时会自动追加到列表末尾。

### <span id="jobs-toc-heading-9" data-jobs-toc="v2">5.3、自定义双色圆形 Gauge <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

`CustomCircularGaugeView` 用 `Circle().trim(...)` 分别绘制两段弧线：

- 已走过的弧线使用 `completedColor`，默认蓝色。
- 未走过的弧线使用 `remainingColor`，默认浅灰。
- 小圆点根据 `progress` 计算角度和坐标，跟随当前进度移动。

这个写法用于解决系统 `Gauge` 圆形样式不方便细分“走过 / 未走过”颜色的问题。

### <span id="jobs-toc-heading-10" data-jobs-toc="v2">5.4、Timer 定时器 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

`TimerDemoView` 使用 `Timer.publish(every:on:in:)` 创建发布器，并通过 `onReceive` 每秒更新页面状态：

```swift
private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
```

### <span id="jobs-toc-heading-11" data-jobs-toc="v2">5.5、四向 Push 预览 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

`DirectionalPushDemoView` 使用分段选择控制 Push 方向，使用 `Slider` 控制 Push 百分比，并在预览区域模拟从上、下、左、右四个方向进入目标 VC 页面。

### <span id="jobs-toc-heading-12" data-jobs-toc="v2">5.6、Debug 环境与动作 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

圆形 `UIButton` 由 `UIViewRepresentable` 桥接，只显示本地打包背景图，点击推出工具 `List`，首项固定为“App 环境切换”，再按 `byActions` 数组顺序展示“SwiftUI 调试面板使用示例”和“查看当前环境”。入口保留在调试导航栈上方，菜单、环境页和使用示例中再次点击均关闭面板，返回打开前的业务页面；重新打开回到工具列表，保留业务导航状态与所选环境。入口支持单指拖动并钳制在安全区域，旋转后按相对位置重算；拖动不会额外触发点击或长按。长按隐藏当前进程全部按钮，前后台切换保持隐藏，重新启动 App 恢复。

根视图修饰符观察宿主真实 `colorScheme`，浮窗及已打开的工具页、环境页同步使用宿主主题。Debug 使用示例提供“跟随系统／白天／黑夜”选择，App 根视图以 `preferredColorScheme` 消费该演示偏好；跟随系统时保留实时系统变化。调试 Pod 不新增公开主题 API，也不读取宿主偏好键。

`JobsSwiftUIDebugAppDelegate` 使用 `byIdentifier`、`byTitle`、`byBaseURL` 配置“本地 Mock / 公共测试 / 联调测试”三组环境，默认地址依次为 `http://127.0.0.1:18080`、`https://httpbin.org`、`https://postman-echo.com`。选择标识写入 `UserDefaults`，启动时恢复；回调更新 Demo 的网络配置。

Demo 进入或重新请求时真实访问当前环境 `GET /get`，超时 3 秒，先显示本地示例，请求成功后使用服务器 JSON，失败或解析无效继续使用本地示例，重试成功自动恢复真数据。环境变更取消旧任务，避免旧环境响应覆盖新页面。真机使用本地 Mock 时需配置可访问的开发机 IP。

默认弱网项按能力边界省略。设备级弱网使用 Apple [**Network Link Conditioner**](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/On_Demand_Resources_Guide/TestingPerformance.html) 的开发者设置。资源来源、许可、完整 DSL 与窗口穿透说明见 [调试 Pod README](./JobsByPods/JobsSwiftUIDebugPanel@Pods/README.md)。

## <span id="jobs-toc-heading-13" data-jobs-toc="v2">六、项目配置支持 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

### <span id="jobs-toc-heading-14" data-jobs-toc="v2">6.1、当前定位 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

`Podfile` 存在是为了和兄弟工程保持一致的工程维护入口：

- `Podfile` 负责安装前网络适配和公共源选择、CocoaPods 基础配置、加载 `Podfile.deps`、挂载 `post_integrate` 脚本。
- `Podfile.deps` 声明 `JobsSwiftUIBaseConfigDemo` target、`JobsSwiftUICodeGraphHook` 脚本锚点及仅 Debug 生效的 `JobsSwiftUIDebugPanel` 本地 Pod。
- `JobsSwiftUIDebugPanel` 的菜单、环境页、自定义页面全部使用 SwiftUI，只用原生窗口桥接实现浮层；Release 的 import、AppDelegate、根视图修饰符和 Demo 入口均通过条件编译移除。
- `JobsSwiftUICodeGraphHook` 只用于让 CocoaPods 完整走 install 生命周期，不在 SwiftUI Demo 业务代码中 `import`。
- `ScriptsByPods/codegraph_init.command` 在 `pod install` 完成后后台生成 `.codegraph/codegraph.db`。
- `ScriptsByPods/codegraph_export_md.command` 从数据库导出 `.codegraph/codegraph.md/`。

### <span id="jobs-toc-heading-15" data-jobs-toc="v2">6.2、安装与构建自动挂载脚本 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

| 入口 | 挂载与行为 | 产物、依赖与失败边界 |
| --- | --- | --- |
| [网络适配包](<./ScriptsByPods/【MacOS】🌐CocoaPods网络适配.command/README.md>) | Podfile 顶部、选源前同步执行；仅真实 `pod install` / `pod update` 查询 Git tag，优先验证显式代理或复用原链路，必要时并发测试系统已启用的 HTTPS / HTTP / SOCKS 代理 | 复用 Ruby、Git 与 `scutil`；只修改当前进程环境及子进程继承值，退出时恢复，不写全局代理、Git 配置或 shell profile；摘要在安装终端，所有链路失败时告警并继续原流程 |
| 同包 `jobs_cocoapods_download_fallback.rb` | 仅安装 / 更新时注册；原 Git 下载因网络失败时，对已核验 `AMPopTip 4.12.0` 尝试同一固定提交的官方归档 | 不变更 Pod 声明、版本、校验和或锁对象；其它版本 / 仓库、分支、认证错误不回退；兼容基线 CocoaPods `1.17.0` / downloader `2.1`，未知 API 告警跳过；本工程当前不依赖 AMPopTip |
| [公共源选择包](<./ScriptsByPods/【MacOS】🌐CocoaPods源自动选择.command/README.md>) | Podfile 在 `source` 声明前同步测试官方 CDN 与 Git Specs；优先使用锁文件里的公开 Pod 样本，无样本时用内置公开规格 | 复用 zsh、curl、Git；保留私有源与锁定版本，不主动重写磁盘锁文件；双源失败时尝试原有效 Git 缓存或回用 CDN，交回 CocoaPods；脚本缺失 / 异常告警回用 CDN |
| `./ScriptsByPods/codegraph_init.command/codegraph_init.command` | `post_integrate` 后台启动；已有后台 PID 时跳过重复启动 | 生成 / 刷新 `.codegraph/codegraph.db` 并调度 Markdown 导出；`JOBS_SKIP_CODEGRAPH=1` 跳过，启动失败只告警，主安装流程无须等待 |

上述网络逻辑放在 Podfile 中，终端以及将来调用该 Podfile 的手动安装入口都会生效，无须为每个入口另配代理。查询命令不发送网络探测；Specs 可达不代表所有源码地址可达。缺少可用代理且 Git / 官方归档均受限时，安装仍可能失败。`--no-repo-update` 不关闭前置探测，也不保证完全离线；`--deployment` 保留原有严格锁文件校验。

日常命令保持 `pod install`。`JOBS_POD_NETWORK_ADAPT=0` 关闭代理适配，`JOBS_POD_GITHUB_ARCHIVE_FALLBACK=0` 关闭白名单归档回退；`JOBS_SPECS_SOURCE=auto` 默认实测，也可设为 `cdn` / `git` 固定来源并继续报告测试结果。Git 单轮默认超时 `6` 秒，Specs 每条候选默认 `8` 秒，具体配置见两个包的 README。

迁移工程需同时保留本工程 Podfile、两个完整脚本包及锁文件；不引用兄弟工程绝对路径，不需要迁移临时日志。独立 `.command` 只读诊断入口先展示自述并等待回车，不触发安装。当前接入通过隔离网络、真实下载器夹具和完整 Podfile 只读解析验证，未执行真实 `pod install` 或构建。

```mermaid
flowchart TD
    A["pod install"] --> B["Load Podfile"]
    B --> N["同步验证已有网络与代理"]
    N --> R["注册已核验依赖归档回退"]
    R --> S["同步测试并选择公共 Specs 源"]
    S --> C["Load Podfile.deps"]
    C --> D["Target: JobsSwiftUIBaseConfigDemo"]
    D --> E["Debug: JobsSwiftUIDebugPanel"]
    E --> F["Local Hook Pod"]
    F --> G["post_install: patch build settings"]
    G --> H["post_integrate"]
    H --> I["codegraph_init.command"]
    I --> J[".codegraph/codegraph.db"]
    I --> K[".codegraph/codegraph.md"]
```

### <span id="jobs-toc-heading-16" data-jobs-toc="v2">6.3、脚本日志 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

| 日志 | 说明 |
| --- | --- |
| 安装终端中的 `[PodNetwork]` 摘要 | 本次链路验证与已核验归档回退结果；不打印代理凭据 |
| 系统临时目录中的 `jobs-cocoapods-source-<工程路径摘要>.log` | Podfile 自动选源测试日志，按工程路径隔离，运行时显示具体位置 |
| 系统临时目录中的 `jobs-cocoapods-network.log` | 独立网络诊断入口确认后覆盖的摘要日志 |
| 系统临时目录中的 `codegraph_init.async.log` | `pod install` 启动的 CodeGraph 后台流程日志 |
| 系统临时目录中的 `codegraph_init.log` | CodeGraph 初始化 / 同步日志 |
| 系统临时目录中的 `codegraph_export_md.log` | Markdown 导出日志 |
| 系统临时目录中的 `codegraph_export_md.async.log` | 后台导出日志 |

## <span id="jobs-toc-heading-17" data-jobs-toc="v2">七、运行方式 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

### <span id="jobs-toc-heading-18" data-jobs-toc="v2">7.1、使用 Xcode 运行 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

1. 使用 [**Xcode**](https://developer.apple.com/xcode) 打开工作区：

   ```shell
   open ./JobsSwiftUIBaseConfigDemo.xcworkspace
   ```

2. 选择 `JobsSwiftUIBaseConfigDemo` Scheme。

3. 选择任意 iOS Simulator。

4. 点击 Run。

### <span id="jobs-toc-heading-19" data-jobs-toc="v2">7.2、使用命令行编译 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```shell
xcodebuild \
  -workspace ./JobsSwiftUIBaseConfigDemo.xcworkspace \
  -scheme JobsSwiftUIBaseConfigDemo \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
build
```

### <span id="jobs-toc-heading-20" data-jobs-toc="v2">7.3、生成 CodeGraph <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

首次需要 CocoaPods 工作区或需要刷新 `.codegraph` 时，在工程根目录执行：

```shell
pod install
```

执行后会生成 / 更新：

- `./JobsSwiftUIBaseConfigDemo.xcworkspace`
- `./Pods/`
- `./Podfile.lock`
- `./.codegraph/`

`Pods/` 是 CocoaPods 生成物，不修改其中源码；业务调试源码维护在 `./JobsByPods/JobsSwiftUIDebugPanel@Pods/`，脚本锚点维护在 `./ScriptsByPods/JobsSwiftUICodeGraphHook/`。仅安装和编译验证、不刷新索引时使用 `JOBS_SKIP_CODEGRAPH=1 pod install --no-repo-update`。

### <span id="jobs-toc-heading-21" data-jobs-toc="v2">7.4、自动输出构建产物 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

主 App 最后一个 Build Phase `Save Build IPA` 调用 [save_device_ipa_after_build.sh](./ScriptsByDevTools/save_device_ipa_after_build.sh)，每次 iOS App 构建都会执行，Xcode 内无须手动确认。按设备平台保存以下产物：

| 构建平台 | 本次唯一产物 |
| --- | --- |
| `iphoneos`（真机） | `./build/真机.ipa` |
| `iphonesimulator`（iOS 模拟器） | `./build/模拟器.ipa` |

1、将本次 `.app` 复制到系统临时目录的 `Payload/<App产品名>.app`，保留 App 原名与资源结构。

2、真机要求有效的 Xcode 签名身份：已有完整有效签名则保留原签名元数据，否则尝试补签，再执行严格签名校验。模拟器允许 `CODE_SIGNING_ALLOWED=NO`，不要求真机签名身份。

3、先在临时目录完成 IPA 压缩。App 不存在、签名失败或压缩失败时，构建阶段报错并保留原 `./build/` 内容。

4、打包成功后，清空 `./build/` 全部内容，包括隐藏文件、子目录、历史 IPA 和另一平台的包，再放入本次 IPA。真机和模拟器包不会同时留存；临时快照在脚本退出时自动清理。

**目录边界：** `./build/` 只存放可丢弃的构建产物，不要放源码、文档或需要保留的文件。DerivedData、构建中间目录和源 App 必须位于 `./build/` 外；命令行可使用 `-derivedDataPath ./DerivedData`。脚本拒绝清空作为软链接的 build 目录，或包含当前构建工作路径的 build 目录。

**使用边界：** `模拟器.ipa` 是模拟器 `.app` 的 Payload 压缩快照，不能安装到真机，也不能用于 App Store 分发；解压后使用其中的 `.app` 安装到兼容的模拟器。`真机.ipa` 的安装范围取决于当前签名及描述文件，不能替代 Archive / 正式分发导出。

`clean`、非 iOS 平台、Tests / Widget 构建不独立输出 IPA；该阶段只挂在主 App，测试触发主 App 重建时仍会更新产物。Build Phase 发生在 Scheme 后置动作之前，产物存在不代表整个 workspace 或测试已成功完成。输入只声明脚本文件，不把整个 App 目录列为输入，避免签名、扩展和测试包造成依赖循环；输出声明 `./build/` 目录，以覆盖平台切换及全部内容清理。

日志同步输出到 Xcode 构建日志与系统临时目录中的 `save_device_ipa_after_build.log`。终端手动运行会先展示内置自述并等待回车，仍需提供 Xcode 构建环境变量。

## <span id="jobs-toc-heading-22" data-jobs-toc="v2">八、扩展 Demo <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

新增一个 Demo 页面时，按下面顺序处理：

1. 在 `./JobsSwiftUIBaseConfigDemo/Demos/` 下新增独立 Swift 文件，保持一个文件一个主 `View`。

2. 在 `DemoFeature` 中新增 `case`。

3. 在 `title`、`subtitle`、`symbol` 中补齐列表展示信息。

4. 在 `destination` 中绑定目标页面。

5. 确认新文件已加入 `JobsSwiftUIBaseConfigDemo` target。

6. 使用 `xcodebuild` 或 [**Xcode**](https://developer.apple.com/xcode) 编译验证。

## <span id="jobs-toc-heading-23" data-jobs-toc="v2">九、注意事项 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

- 系统 UI Demo 保持原生 SwiftUI 写法；新增调试能力集中在独立本地 `JobsSwiftUIDebugPanel` Pod，不套用 UIKit 版面板或增加无关依赖。
- `pod install` 维护 Debug 依赖及资源集成，并可生成 / 刷新 `.codegraph`，保持和兄弟工程一致的 CocoaPods 生命周期入口。
- `AsyncImage` 页面依赖网络图片，网络不可用时会显示失败占位。
- `Assets.xcassets/AppIcon.appiconset` 保留了 AppIcon 资源槽，正式发布前需要补齐图标素材。
- 当前工程面向 Demo 演示；Debug 环境 Demo 包含短超时网络请求及环境标识持久化，其它页面不扩展为完整业务网络层或登录系统。
- 命令行编译示例使用 `CODE_SIGNING_ALLOWED=NO`，适合本地模拟器构建；真机运行需要按实际开发者账号配置签名。

## <span id="jobs-toc-heading-24" data-jobs-toc="v2">十、排查方式 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

| 现象 | 处理方式 |
| --- | --- |
| Xcode 打不开工程 | 优先打开 `./JobsSwiftUIBaseConfigDemo.xcworkspace`；未执行过 `pod install` 时再打开 `./JobsSwiftUIBaseConfigDemo.xcodeproj` |
| 找不到新增 Demo 页面 | 确认新文件已加入 target，并已在 `DemoFeature.destination` 注册 |
| Demo 列表排序不符合预期 | 删除 App 后重装，或清空 `JobsSwiftUIBaseConfigDemo.demoFeatureOrder` 对应的 `UserDefaults` 值 |
| 命令行编译提示签名问题 | 模拟器构建命令加上 `CODE_SIGNING_ALLOWED=NO` |
| `pod install` 后没有 `.codegraph` | 查看系统临时目录中的 `codegraph_init.async.log` |
| 只想验证 Podfile，不想启动 CodeGraph | 执行 `JOBS_SKIP_CODEGRAPH=1 pod install --no-repo-update` |
| 不想刷新 CodeGraph | 只用 `xcodebuild` 或 Xcode 运行工程，不执行 `pod install` |
| 远程图片加载失败 | 检查网络，或观察 `AsyncImage` 的失败占位是否正常展示 |
| 自定义 Gauge 颜色不符合预期 | 修改 `CustomCircularGaugeView` 的 `completedColor` 和 `remainingColor` |
| Debug 按钮没有出现 | 确认使用 Debug 构建、AppDelegate 已 `byStart()`，且 WindowGroup 根视图已添加 `.jobsSwiftUIDebugPanel()`；长按关闭后需冷启动恢复 |
| 本地 Mock 请求回退 | 确认对应地址的服务已启动；Demo 继续显示本地示例，服务恢复后点击重新请求即可显示服务器数据 |
| Release 出现调试入口 | 检查 Podfile 的 `:configurations => ['Debug']`，且 Release 未定义 `DEBUG` |

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
