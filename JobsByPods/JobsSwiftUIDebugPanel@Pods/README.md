# `JobsSwiftUIDebugPanel`

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id=前言>前言</font>

`JobsSwiftUIDebugPanel` 是 iOS 17 起可用的本地 [**Swift**](https://www.swift.org/) / [**SwiftUI**](https://developer.apple.com/xcode/swiftui/) 调试工具 Pod。圆形 `UIButton` 通过 `UIViewRepresentable` 使用一张本地背景图，点击后在 `NavigationStack` 推出 `List`，首项固定为 App 环境切换，其后按配置顺序展示自定义动作。入口始终显示在面板上方，再次点击返回打开前的业务页面。

面板 UI、环境列表和自定义目标页均使用 SwiftUI。原生 [**UIKit**](https://developer.apple.com/documentation/uikit) 仅用于场景窗口绑定、最高浮层、圆形入口的点击／拖动／长按仲裁、触摸穿透和 `UIHostingController` 承载，不依赖 UIKit 版调试面板，也没有其它业务 Pod 依赖。

## 一、功能与边界 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 功能 | 行为 |
| --- | --- |
| Debug 专用 | Podfile 仅将该 Pod 链接到 Debug；源码及宿主入口均使用 `#if DEBUG` |
| 前台圆形按钮 | 每个已接入的前台场景创建独立透明窗口，窗口层级为 `.alert + 100`，不抢业务 key window |
| 拖动与安全区 | 单指拖动入口，位置限制在安全区域内；旋转后按相对位置重算，不会拖动后误触点击或长按 |
| 主题跟随 | 根视图 Hook 观察宿主 `colorScheme`，同步浮窗、已打开工具页、环境列表和自定义页面；宿主强制白天／黑夜及跟随系统均即时生效 |
| 点击开关 | 浮层自己的 `NavigationStack` 推出工具列表、环境列表及 SwiftUI 自定义目标页；同一圆形按钮始终可见，再次点击关闭整棵调试导航栈，保留业务页面状态，重开回到工具列表 |
| 长按关闭 | 长按 0.8 秒隐藏全部场景的按钮；状态只在本次进程中保留，重新启动 App 后恢复 |
| 环境切换 | 环境保存标识、备注和 Base URL；选择后保存标识，触发回调及环境变化通知 |
| 自定义动作 | 标题必填、图片可选；支持直接行为或 `byDestination` 推出 SwiftUI View，按数组顺序展示 |
| 配置快照 | 接收配置时复制有效模型，过滤无效 URL、重复环境标识、空标题及无行为动作 |

长按隐藏后前后台切换不会恢复按钮。环境选择会跨进程保存，恢复顺序为“仍存在的已保存标识 → 默认标识 → 第一项”；已删除的环境配置不会继续作为当前环境。环境列表始终提供空态说明和重新加载入口。

## 二、目录与职责 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

```text
.
├── JobsSwiftUIDebugPanel.podspec
├── LICENSE
├── README.md
├── Core
│   ├── JobsSwiftUIDebugPanel/JobsSwiftUIDebugPanel.swift
│   ├── JobsSwiftUIDebugEnvironment/JobsSwiftUIDebugEnvironment.swift
│   ├── JobsSwiftUIDebugAction/JobsSwiftUIDebugAction.swift
│   ├── JobsSwiftUIDebugMenuView/JobsSwiftUIDebugMenuView.swift
│   ├── JobsSwiftUIDebugHostModifier/JobsSwiftUIDebugHostModifier.swift
│   ├── JobsSwiftUIDebugSceneState/JobsSwiftUIDebugSceneState.swift
│   ├── JobsSwiftUIDebugEnvironmentsView/JobsSwiftUIDebugEnvironmentsView.swift
│   ├── JobsSwiftUIDebugOverlayWindow/JobsSwiftUIDebugOverlayWindow.swift
│   ├── JobsSwiftUIDebugOverlayView/JobsSwiftUIDebugOverlayView.swift
│   ├── JobsSwiftUIDebugResource/JobsSwiftUIDebugResource.swift
│   └── UIImage+Make/UIImage+Make.swift
└── Resource
    ├── JobsDebugPanelButton.png
    ├── JobsDebugPanelButton-round.svg
    ├── ant-design-bug-filled.svg
    ├── AntDesignIcons-LICENSE
    └── SOURCE.txt
```

本地 Swift Pod 采用“类型同名目录 / 同名文件”，通过 `Core/**/*.swift` 纳入源码。Swift 的 `public` / `internal` / `private` 控制接口可见性；生成的模块头由 CocoaPods 管理。

<table>
  <thead><tr><th>层次</th><th>公开接口 / 内部类型</th><th>职责</th><th>依赖方向</th></tr></thead>
  <tbody>
    <tr><td>宿主接入</td><td>公开 jobsSwiftUIDebugPanel()、jobsSwiftUIDebugOpenPanel</td><td>WindowGroup 根视图绑定当前业务窗口，向子 View 注入打开行为</td><td>场景状态 → 管理器</td></tr>
    <tr><td>配置模型</td><td>公开 JobsSwiftUIDebugEnvironment、JobsSwiftUIDebugAction</td><td>环境 URL / 备注与标题 / 可选图片 / 行为的链式配置</td><td>管理器读取配置快照</td></tr>
    <tr><td>调试管理</td><td>公开 JobsSwiftUIDebugPanel</td><td>环境恢复、顺序动作、选择回调、场景生命周期与进程隐藏</td><td>模型 → 场景浮层</td></tr>
    <tr><td>面板 UI</td><td>公开 JobsSwiftUIDebugMenuView；内部 EnvironmentsView、OverlayView</td><td>SwiftUI Button / List / NavigationStack，推出二级环境及自定义目标页</td><td>视图观察管理器与场景状态</td></tr>
    <tr><td>底层适配</td><td>内部 SceneState、OverlayWindow、Resource、UIImage 工厂</td><td>窗口绑定、圆形命中范围、资源 bundle 定位与 PNG 解码</td><td>原生窗口承载 SwiftUI，图片交给 SwiftUI Image</td></tr>
  </tbody>
</table>

资源只将 PNG 与许可打入 `JobsSwiftUIDebugPanelResources.bundle`；SVG 和来源记录留在源码目录供审计。`Support` 目录没有实际需要，未创建空目录或重复 subspec。

## 三、Debug 接入 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

在宿主工程 `Podfile.deps` 声明：[**CocoaPods**](https://guides.cocoapods.org/syntax/podfile.html#pod) 的 `:configurations` 限制该 Pod 只参与 Debug 链接和资源拷贝。

```ruby
pod 'JobsSwiftUIDebugPanel',
    :path => 'JobsByPods/JobsSwiftUIDebugPanel@Pods',
    :configurations => ['Debug']
```

宿主和 Pod 的 Debug 配置均需要 `SWIFT_ACTIVE_COMPILATION_CONDITIONS = $(inherited) DEBUG`。本工程在既有 `post_install` 中只为该 Pod 的 Debug 配置补入 `DEBUG`，Release 不增加该条件。不要把 `DEBUG` 写进全配置的 podspec xcconfig。

在项目根目录安装、刷新本地 Pod：

```shell
JOBS_SKIP_CODEGRAPH=1 pod install --no-repo-update
```

配置放在 `AppDelegate` 的 `didFinishLaunchingWithOptions`，完整示例位于 [JobsSwiftUIDebugAppDelegate.swift](../../JobsSwiftUIBaseConfigDemo/JobsSwiftUIDebugAppDelegate.swift)：

```swift
#if DEBUG
import JobsSwiftUIDebugPanel

JobsSwiftUIDebugPanel.shared
    .byEnvironments([
        JobsSwiftUIDebugEnvironment()
            .byIdentifier("local")
            .byTitle("本地 Mock")
            .byBaseURL("http://127.0.0.1:18080"),
        JobsSwiftUIDebugEnvironment()
            .byIdentifier("httpbin")
            .byTitle("公共测试")
            .byBaseURL("https://httpbin.org"),
        JobsSwiftUIDebugEnvironment()
            .byIdentifier("postman")
            .byTitle("联调测试")
            .byBaseURL("https://postman-echo.com")
    ])
    .byDefaultEnvironmentIdentifier("local")
    .byEnvironmentChanged { environment in
        // 将 environment.baseURL 交给宿主自己的网络配置。
    }
    .byActions([
        JobsSwiftUIDebugAction()
            .byTitle("功能页面")
            .byDestination {
                Text("自定义 SwiftUI 页面")
            },
        JobsSwiftUIDebugAction()
            .byTitle("查看当前环境")
            .byAction {
                let current = JobsSwiftUIDebugPanel.shared.currentEnvironment
                JobsSwiftUIDebugPanel.shared.byFeedback(current?.baseURL ?? "未配置")
            }
    ])
    .byStart()
#endif
```

App 使用 `@UIApplicationDelegateAdaptor` 注册该 delegate，并对 `WindowGroup` 根视图应用 `.jobsSwiftUIDebugPanel()`；所有 import、属性及修饰符入口置于 `#if DEBUG`。完整入口见 [JobsSwiftUIBaseConfigDemoApp.swift](../../JobsSwiftUIBaseConfigDemo/JobsSwiftUIBaseConfigDemoApp.swift)。

## 四、场景、动作与网络接入 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

窗口适配器绑定业务窗口所在的 `UIWindowScene`。只有已接入且处于前台的场景显示按钮；业务窗口更换时重建对应浮层，场景失活隐藏浮层，断开时释放窗口。圆形 `UIButton` 由 SwiftUI 布局，通过窗口坐标单指拖动；保存场景内的相对位置，尺寸或安全区域改变时重新钳制，整枚按钮距安全边界至少 8 点。位置仅在当前场景的本次运行保留，冷启动回到默认位置。几何测量后的圆形命中范围之外全部穿透到业务窗口。工具页推出后由浮层接收页面交互；按钮放在导航栈外的顶层，菜单、环境页和自定义页都能再次点击关闭并恢复穿透。关闭清除调试页及临时提示，再次打开回到工具列表，不改变业务 Tab、导航位置或所选环境。子页面注入的 `jobsSwiftUIDebugOpenPanel` 保持单向打开，重复调用不会关闭面板。

根视图 Hook 观察实际宿主 `@Environment(\.colorScheme)`，不读取特定宿主的偏好键或依赖主题管理器。外层的 `preferredColorScheme` 与系统外观变化均同步到浮窗的 UIKit trait 和 SwiftUI environment；已打开的导航栈、列表、文字、背景及弹窗会同时刷新，不重新创建页面或丢失环境选择。

导航根页面也必须透明：iOS 18 起使用 Apple 的 [containerBackground(_:for:)](https://developer.apple.com/documentation/swiftui/view/containerbackground(_:for:)) 设置 `.navigation` 容器背景；iOS 17 只清理本框架浮层内部的祖先背景，避免默认导航背景遮住主界面。

`byTitle`、`byImage`、`byAction`、`byDestination` 返回当前模型，可继续链式调用。`byAction` 和 `byDestination` 是互斥行为，后配置的行为生效。默认环境项始终第一行，自定义数组先配置的项先出现。闭包可直接执行宿主逻辑；推出目标页时使用 `byDestination`，不需要创建 UIKit VC。

管理器和 UI 操作在主线程执行；`byEnvironmentChanged` 启动时会收到恢复后的环境，选择时再次调用。网络请求属于宿主，本 Pod 不拦截或改写全 App 请求。Demo 的 [JobsSwiftUIDebugNetworkEnvironment.swift](../../JobsSwiftUIBaseConfigDemo/JobsSwiftUIDebugNetworkEnvironment.swift) 接收 Base URL，正在执行的请求保留发起时 URL 快照，环境变化取消旧任务并发起新请求。

## 五、Demo 与弱网说明 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

Debug 的 Demo 列表和速览页新增“SwiftUI Debug 调试面板”。面板自定义项为“SwiftUI 调试面板使用示例”和“查看当前环境”。使用示例提供“跟随系统／白天／黑夜”主题选择；该演示偏好由宿主 App 根视图消费，面板只观察最终外观。使用示例显示当前备注与 Base URL，进入页面或点击重新请求时真实发起 `GET /get`，超时 3 秒。

页面先显示本地示例，请求成功后展示服务器 JSON；失败、超时或解析失败继续显示本地示例，并提供重新请求入口，后续成功请求自动覆盖为真实结果。本地 Mock 默认 `http://127.0.0.1:18080`，模拟器可连接开发 Mac 的对应服务；真机需将地址配置为可访问的开发机 IP。本地服务未部署也可完整演示页面和环境切换。

本次未提供模拟全 App 带宽、丢包的默认弱网项。普通 App 的公开 API 无法承诺控制所有 URLSession、WebKit、Socket 和设备流量，这是本实现的能力判断。Apple 明确自定义 [**URLProtocol**](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/protocolclasses) 不支持后台 URLSession，无法用它覆盖所有请求路径。

需要设备级弱网时使用 Apple 的 [**Network Link Conditioner**](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/On_Demand_Resources_Guide/TestingPerformance.html)：在开发设备的 `Settings > Developer` 中启用并选择网络配置。该官方文档直接说明开关、配置及设备流量范围。

## 六、图片来源与许可 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

按规则先检索 [**iconfont**](https://www.iconfont.cn/)，未取得可核实具体作者许可的素材后，采用 [**Ant Design Icons**](https://github.com/ant-design/ant-design-icons/blob/master/packages/icons-svg/svg/filled/bug.svg) 官方 bug 矢量。MIT 许可为 Copyright (c) 2018-present Ant UED，完整许可随资源 bundle 打包，来源与处理过程见 [SOURCE.txt](./Resource/SOURCE.txt)。

最终 `JobsDebugPanelButton.png` 是 240×240 的淡金黄圆底与黑色 bug 图案，圆外透明，按钮只显示这张图片，无文字叠加或远程加载。入口的 `UIViewRepresentable.sizeThatFits` 按 SwiftUI 提议尺寸测量为 56×56 点，图片固有尺寸不会扩大按钮或遮挡旁边操作；圆形触摸范围与显示尺寸一致。原图路径未修改，圆底与布局由本项目组合，所有端复用同一图片。

## 七、验证与维护 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

Debug 验证宿主三态主题及已打开页面刷新、系统与宿主强制主题不一致时的文字／背景对比、拖动后点击／长按互斥、安全区域与旋转钳制、按钮在菜单／二级环境页／自定义页打开与关闭、关闭重开回到工具列表、环境二级选择与重启恢复、自定义动作顺序、真实 `GET /get`、长按隐藏及冷启动恢复；Release 验证宿主不链接该 Pod、不复制其资源 bundle，Demo 注册表和 App 入口均没有调试代码。

改变公开 API 时同步本 README、宿主 [配置方案](../../SwiftUIDoc.md/SwiftUI工程项目框架配置方案@Jobs.md/SwiftUI工程项目框架配置方案@Jobs.md) 与公共 Xcode CodeSnippet `SwiftUI@JobsSwiftUIDebugPanel`。当前 Pod 是 `:path` 本地模块，podspec 的本地 source 不可直接作为远程发布配置。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
