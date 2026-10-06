# `SwiftUI 工程项目框架配置方案@Jobs`

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id=前言>前言</font>

本说明记录 `JobsSwiftUIBaseConfigDemo` 的入口、原生 [**SwiftUI**](https://developer.apple.com/xcode/swiftui/) Debug 工具 Pod、环境配置与验证方式。系统组件 Demo 使用 [**Swift**](https://www.swift.org/) / SwiftUI；调试模块独立下沉到本地 Pod，Release 不链接该模块。

## 一、工程入口与依赖 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 文件 | 用途 |
| --- | --- |
| [App 入口](../../JobsSwiftUIBaseConfigDemo/JobsSwiftUIBaseConfigDemoApp.swift) | WindowGroup、Debug AppDelegate 适配与根视图 Hook |
| [AppDelegate](../../JobsSwiftUIBaseConfigDemo/JobsSwiftUIDebugAppDelegate.swift) | 启动配置环境与顺序动作 |
| [网络环境](../../JobsSwiftUIBaseConfigDemo/JobsSwiftUIDebugNetworkEnvironment.swift) | 宿主网络配置与环境回调连接 |
| [Demo](../../JobsSwiftUIBaseConfigDemo/Demos/JobsSwiftUIDebugPanelDemoView.swift) | 当前环境、真实 GET 请求、失败回退和重试 |
| [Pod README](../../JobsByPods/JobsSwiftUIDebugPanel@Pods/README.md) | 完整公开接口、内部职责与资源说明 |
| [Podfile.deps](../../Podfile.deps) | 本地脚本锚点及 Debug 专用调试 Pod |

最低系统为 iOS 17。[**CocoaPods**](https://cocoapods.org/) 只引入本地脚本锚点和 `JobsSwiftUIDebugPanel`；调试 Pod 没有其它业务 Pod 依赖。原生 UIKit 负责透明窗口、可拖动圆形 `UIButton` 入口和 SwiftUI 承载，面板页面仍使用 `List`、`NavigationStack`。

## 二、AppDelegate 初始化 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

Debug 的 App 用 `@UIApplicationDelegateAdaptor(JobsSwiftUIDebugAppDelegate.self)` 注册 delegate，在 `didFinishLaunchingWithOptions` 内调用：

```swift
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
        JobsSwiftUIDebugNetworkEnvironment.shared.byBaseURL(environment.baseURL)
    }
    .byActions([
        JobsSwiftUIDebugAction()
            .byTitle("SwiftUI 调试面板使用示例")
            .byDestination {
                JobsSwiftUIDebugPanelDemoView()
            },
        JobsSwiftUIDebugAction()
            .byTitle("查看当前环境")
            .byAction {
                let environment = JobsSwiftUIDebugPanel.shared.currentEnvironment
                JobsSwiftUIDebugPanel.shared.byFeedback(environment?.baseURL ?? "未配置")
            }
    ])
    .byStart()
```

`byIdentifier` 是持久化标识，应长期稳定；`byTitle` 是给开发者看的备注；`byBaseURL` 必须是有效的 HTTP / HTTPS 地址。模型及管理器的配置方法返回当前对象，可继续链式调用。

## 三、SwiftUI 场景绑定与导航 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

在 App 的 `WindowGroup` 内，仅对 Debug 分支添加根视图修饰符：

```swift
WindowGroup {
    #if DEBUG
    MainTabView()
        .jobsSwiftUIDebugPanel()
    #else
    MainTabView()
    #endif
}
```

根视图 Hook 找到自己的业务窗口，绑定到对应 `UIWindowScene`；管理器为已绑定的前台场景创建高层透明浮窗，不抢 key window。按钮支持单指拖动，保存当前场景的相对位置；整枚按钮钳制在安全区域，旋转后重新布局，拖动与点击／长按互斥。圆形以外的触摸穿透到原界面；点击推出后由独立浮层导航栈承载工具页。按钮始终在导航栈顶层，菜单、环境页和自定义页再次点击均关闭整棵调试导航栈并恢复穿透，返回打开前的业务页面；再次打开回到工具列表，所选环境保持。注入的 `jobsSwiftUIDebugOpenPanel` 仍只负责打开，重复调用不会关闭。场景失活隐藏、断开释放、业务窗口或绑定状态更换则重建。

根视图 Hook 观察宿主 `@Environment(\.colorScheme)`，同步浮窗 trait 与 SwiftUI 环境，已打开的工具列表、环境列表和自定义目标页同步刷新。宿主可以通过 `preferredColorScheme` 强制外观，值为 `nil` 时跟随系统；框架无需新的公开主题配置。Demo 的三态 Picker 使用宿主 App 根视图消费的演示偏好，以真实验证传播链路。

根导航容器同样透明：iOS 18 起使用 [containerBackground(_:for:)](https://developer.apple.com/documentation/swiftui/view/containerbackground(_:for:)) 的 `.navigation` 背景；iOS 17 的窗口适配探针只清理自有浮层祖先，保持业务页面原有背景。

业务 Tab 的导航栈保持自己的状态。子页面通过 `@Environment(\.jobsSwiftUIDebugOpenPanel)` 获取打开行为。自定义 `byDestination` 返回任意 SwiftUI View，并获得同一环境值；`byAction` 直接执行行为，两种配置互斥，以最后配置者为准。

## 四、顺序、隐藏与持久化 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

工具列表首项固定为“App 环境切换”，自定义动作按 `byActions` 数组顺序展示；可选图片通过 `byImage(Image?)` 配置，不配置时只显示标题。点击环境项继续推出“选择网络环境”二级列表。

选择环境后保存标识并调用宿主回调，启动恢复顺序为“已保存且仍有效的标识 → 默认标识 → 第一项”。未配置环境时显示完整空态与重新加载入口；无效 URL、重复标识、空标题或无行为动作被过滤。

长按按钮 0.8 秒后，全场景按钮在本次进程内隐藏，前后台切换和重复启动管理器都不会重新出现；冷启动重新显示。隐藏状态不持久化，环境选择则独立持久化，两者不互相影响。

## 五、网络 Demo 与图片 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

Debug Demo 列表与速览页新增“SwiftUI Debug 调试面板”。页面进入、环境改变或点击重新请求时，使用当前 Base URL 请求 `GET /get`，超时 3 秒。先显示本地示例，服务器成功返回 JSON 后覆盖；请求失败、超时或解析失败继续显示本地示例与重试入口，后续成功请求自动恢复真数据。环境改变取消旧任务并检查 URL 快照，避免旧响应覆盖新环境。

本地 Mock 默认地址为 `http://127.0.0.1:18080`，模拟器对应开发 Mac 的回环服务；真机需改为设备可访问的地址。未部署服务也可展示本地数据、环境切换和自定义动作。

圆形按钮是随 Pod 打包的本地 PNG。素材先检索 [**iconfont**](https://www.iconfont.cn/)，未取得可核实作者许可后使用官方 [**Ant Design Icons**](https://github.com/ant-design/ant-design-icons/blob/master/packages/icons-svg/svg/filled/bug.svg) bug 矢量，保留 MIT 许可并组合圆底；许可随资源 bundle 打包，详见 [SOURCE.txt](../../JobsByPods/JobsSwiftUIDebugPanel@Pods/Resource/SOURCE.txt)。

## 六、Debug 与 Release 验证 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

Pod 声明使用 `:configurations => ['Debug']`，Pod 和 App 的 Debug 编译条件包含 `DEBUG`，Release 不添加。App 的 import、delegate 属性、根视图 Hook、注册表分支与 Demo 源码均受 `#if DEBUG` 保护。

项目根目录执行安装和编译：

```shell
JOBS_SKIP_CODEGRAPH=1 pod install --no-repo-update
xcodebuild -workspace JobsSwiftUIBaseConfigDemo.xcworkspace \
  -scheme JobsSwiftUIBaseConfigDemo -configuration Debug \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
xcodebuild -workspace JobsSwiftUIBaseConfigDemo.xcworkspace \
  -scheme JobsSwiftUIBaseConfigDemo -configuration Release \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Debug 检查圆形按钮、列表顺序、二级环境选择、重启恢复、直接行为、目标页面、真实请求与长按隐藏；Release 检查不链接调试 Pod、不复制资源 bundle、不出现调试 Demo。

## 七、弱网能力边界 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

本次按“不可行就不写”省略全 App 弱网模拟。普通 App 无法用公开 API 承诺控制所有网络栈的真实带宽、丢包和设备流量，这是本框架的实现边界。Apple 说明自定义 [**URLProtocol**](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/protocolclasses) 不适用于后台 URLSession，不能把请求延迟包装称为设备级弱网。

真实弱网测试使用 Apple 官方 [**Network Link Conditioner**](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/On_Demand_Resources_Guide/TestingPerformance.html)，在开发设备 `Settings > Developer` 中开关、选择配置；文档直接提供设备入口和配置说明。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
