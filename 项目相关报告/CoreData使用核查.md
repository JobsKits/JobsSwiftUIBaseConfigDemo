# Core Data 模型使用核查与 SwiftUI Demo

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#%E5%89%8D%E8%A8%80)
- [一、文件含义与初次核查](#conclusions)
- [二、OC 新旧工程初次源码依据（历史）](#oc-evidence)
- [三、Swift UIKit 初次源码依据（历史）](#swift-evidence)
- [四、SwiftUI Demo 资产与操作](#swiftui-demo)
  - [4.1、数据库图标来源与打包](#icon-source)
- [五、验证边界与报告入口](#verification)
- [六、OC 新旧与 Swift UIKit 本轮实际接入](#native-integration)

</details>
<!-- jobs-toc:end -->

---

## 🔥 <span id="前言">前言</span>

初次核查日期：2026-11-15；接入状态更新于2026-11-16。覆盖 OC 新旧、Swift UIKit 与 SwiftUI 四工程。本文分别记录源码接线、模型与构建、真实存储测试和有限界面验证；OC 新旧与 Swift UIKit 初次未执行数据库实跑，本轮接入及验证单列于[实际接入](#native-integration)。资产入口见[App 骨架增量盘点](./App骨架功能盘点.md)。

## 一、<span id="conclusions">文件含义与初次核查</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

`.xcdatamodeld` 是 [**Core Data**](https://developer.apple.com/documentation/coredata) 的版本化数据模型定义，描述实体、属性与关系；编译后成为 `.momd` 资源。它本身不保存用户记录，运行时持久化容器使用模型生成或打开实际存储；本 Demo 使用应用沙盒内的 [**SQLite**](https://www.sqlite.org/) 文件。

下表保留2026-11-15初次核查；其中 OC 新旧“未接入”和 Swift UIKit“空模型未用”的结论已由用户2026-11-16明确要求接入，作为历史依据保留，不作为本轮当前状态。

| 工程 | 初次模型与使用情况 | 初次判断（非本轮状态） |
| --- | --- | --- |
| OC 老工程 | `JobsOCBaseConfigDemo.xcdatamodeld` 包含 `User(name, age)`；有 AppDelegate 懒加载栈和 `CoreDataVC` 的真实 CRUD 代码 | 未找到创建或路由 `CoreDataVC` 的可达入口；正常流程不会因后台保存而主动创建容器。属于模型、栈与未接入的演示源码，不能计作当前业务已使用 |
| OC 新工程 | 同样的 `User` 模型、懒加载栈和未接入 `CoreDataVC` | 与老工程结论一致 |
| <u>[**Swift**](https://www.swift.org/)</u> UIKit | `JobsSwiftBaseConfigDemo.xcdatamodeld` 只有空 `model` 与 `elements`，实体数为 0；主工程及 Jobs 自建 Pods 未找到 Core Data 栈、上下文或 CRUD 调用 | 当前为未使用的模型占位 |
| [**SwiftUI**](https://developer.apple.com/xcode/swiftui/) | `JobsSwiftUIBaseConfigDemo.xcdatamodeld` 包含 `DemoNote`，`DemoFeature.coreData` 指向实际演示页面，存储层执行真实增删改查 | 模型编译、完整 Debug arm64 模拟器构建及真实 SQLite 21 项断言通过；iOS 首屏空库与终止进程后读回展示已验，完整 UI 点击操作待验，详见[验证边界](#verification) |

以上“未使用”仅是2026-11-15源码与可达入口的核查结论，不推断用户设备上是否存在历史版本留下的数据库。OC 新旧及 Swift UIKit 的这部分状态由[本轮实际接入](#native-integration)替代（superseded）；SwiftUI 原验证范围保持下文所列边界。

## 二、<span id="oc-evidence">OC 新旧工程初次源码依据（历史）</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 核查点 | OC 老工程 | OC 新工程 |
| --- | --- | --- |
| 模型实体 | [当前模型](../../JobsBaseConfig@JobsOCBaseConfigDemo/JobsOCBaseConfigDemo/其他/CoreData/JobsOCBaseConfigDemo.xcdatamodeld/JobsBaseConfig.xcdatamodel/contents) 第 3～5 行定义 `User`、`age: Integer 32`、`name: String`；`.xccurrentversion` 指向 `JobsBaseConfig.xcdatamodel` | [当前模型](../../../JobsOCBaseConfigDemo@ByPods/JobsOCBaseConfigDemo/其他/CoreData/JobsOCBaseConfigDemo.xcdatamodeld/JobsBaseConfig.xcdatamodel/contents) 使用同一实体与属性 |
| 懒加载持久化栈 | [AppDelegate.m](../../JobsBaseConfig@JobsOCBaseConfigDemo/JobsOCBaseConfigDemo/入口/AppDelegate/AppDelegate.m) 第 125～138 行，以固定模型名 `JobsOCBaseConfigDemo` 创建 `NSPersistentCloudKitContainer` 并加载存储 | [AppDelegate.m](../../../JobsOCBaseConfigDemo@ByPods/JobsOCBaseConfigDemo/入口/AppDelegate/AppDelegate.m) 第 123～136 行，同一逻辑 |
| 后台保存 | 同文件第 102～119 行只读取 `_persistentContainer`，不存在或没有存储时返回，不通过 getter 触发懒加载 | 同文件第 100～117 行，同一边界 |
| CRUD 实现 | [CoreDataVC.m](<../../JobsBaseConfig@JobsOCBaseConfigDemo/JobsOCBaseConfigDemo/业务逻辑/功能模块/Demo@数据库/Core Data/ViewController/CoreDataVC/CoreDataVC.m>) 第 93～112 行在页面出现时插入 Alice／Bob、查询、更新与删除；第 189～240 行执行实体插入、fetch、修改、delete 与 save，结果只打日志 | [CoreDataVC.m](<../../../JobsOCBaseConfigDemo@ByPods/JobsOCBaseConfigDemo/业务逻辑/功能模块/Demo@数据库/Core Data/ViewController/CoreDataVC/CoreDataVC.m>) 对应行号与行为一致 |
| 页面入口 | 搜索 `CoreDataVC` 只命中自身声明／实现、Block 类型与前置声明、工程成员配置，没有首页注册、实例化或路由调用 | 同样没有可达入口 |

初次核查时，模型和控制器在工程成员名单中保留，不等于 App 正常运行时已经加载或操作。彼时 Demo 源码是“进入即执行并打印日志”的教学写法，没有可供用户逐步操作的数据库页面；本段不描述本轮接入后的实现。

## 三、<span id="swift-evidence">Swift UIKit 初次源码依据（历史）</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- [模型 contents](../../JobsBaseConfig@JobsSwiftBaseConfigDemo/JobsSwiftBaseConfigDemo/Resources/JobsSwiftBaseConfigDemo.xcdatamodeld/JobsSwiftBaseConfigDemo.xcdatamodel/contents) 第 2～4 行只有空 `model` 与 `<elements/>`，没有实体。
- [AppDelegate.swift](../../JobsBaseConfig@JobsSwiftBaseConfigDemo/JobsSwiftBaseConfigDemo/启动入口/AppDelegate.swift) 的启动路径（第 79／131 行）和 `SA()`（第 250 行）未建立 Core Data 栈；[SceneDelegate.swift](../../JobsBaseConfig@JobsSwiftBaseConfigDemo/JobsSwiftBaseConfigDemo/启动入口/SceneDelegate.swift) 第 50／261 行的生命周期没有上下文保存。
- 初次核查时，主工程及 Jobs 自建 `JobsByPods` 未找到 Core Data 导入、`NSPersistentContainer`／`NSManagedObjectContext`、fetch 或 `saveContext` 接线。因此彼时这份文件没有对应的数据库功能或 Demo；第三方、生成代码不作为 Jobs 已实现的依据。本段保留历史原因，不能用于判断本轮新增源码。

## 四、<span id="swiftui-demo">SwiftUI Demo 资产与操作</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 资产 | 当前实现／默认值 | 位置 |
| --- | --- | --- |
| 入口 | Demo 列表注册 `DemoFeature.coreData`，目的页为 `CoreDataDemoView`，沿用原导航和最近记录接线 | [DemoFeature.swift](../JobsSwiftUIBaseConfigDemo/DemoFeature.swift) 的 `.coreData` 与 `destination` |
| 模型 | `DemoNote` 包含 `id: UUID`、`title: String`、`createdAt: Date`、`isComplete: Bool`；`id` 唯一，完成态默认 `false` | [模型 contents](../JobsSwiftUIBaseConfigDemo/Resources/JobsSwiftUIBaseConfigDemo.xcdatamodeld/JobsSwiftUIBaseConfigDemo.xcdatamodel/contents) |
| 实际存储 | 默认空，不自动写示例数据；文件为 `NSPersistentContainer.defaultDirectoryURL()` 下的 `CoreDataDemo/JobsSwiftUIBaseConfigDemo.sqlite`，重启继续读取；不请求远端 API | [CoreDataDemoStore.swift](../JobsSwiftUIBaseConfigDemo/Persistence/CoreDataDemoStore.swift) 的 `init`、`reload` 与 `prepareIfNeeded` |
| CRUD | 输入标题新增、重命名、切换完成、单条删除、重新加载；清空前二次确认。空白标题不保存，操作失败回滚并呈现错误，支持重试 | [存储层](../JobsSwiftUIBaseConfigDemo/Persistence/CoreDataDemoStore.swift) 的 `add`、`rename`、`toggle`、`delete`、`deleteAll`、`validatedTitle` 与 `perform`；[演示页](../JobsSwiftUIBaseConfigDemo/Demos/CoreDataDemoView.swift) |
| 生命周期 | 存储由主队列串行访问；每次成功写操作立即保存再读取列表，不依赖退后台保存；页面重新加载使用已准备的容器 | [存储层](../JobsSwiftUIBaseConfigDemo/Persistence/CoreDataDemoStore.swift) 的 `@MainActor`、`prepareIfNeeded` 与 `perform` |
| 列表与空态 | 记录按创建时间倒序；初始空列表提供图标、说明及重载入口；列表显示独立值模型 | [CoreDataDemoRecord.swift](../JobsSwiftUIBaseConfigDemo/Persistence/CoreDataDemoRecord.swift)、[CoreDataDemoView.swift](../JobsSwiftUIBaseConfigDemo/Demos/CoreDataDemoView.swift) |
| 语言与主题 | 沿用全局设置，不增加页内私有开关；简繁藏英日法西德俄韩十语文案，白天／黑夜／跟随系统 | [AppText.json](../JobsSwiftUIBaseConfigDemo/Resources/AppText.json)、[AppPreferences.swift](../JobsSwiftUIBaseConfigDemo/AppPreferences.swift) |

操作时先输入标题并新增，再对记录执行重命名、完成切换或删除；重新加载读回已保存结果，清空后回到完整空态。存储层增删改查与跨进程恢复已有真实测试；界面按钮完整操作、清空取消／确认仍待验证，不能由存储测试替代。

### 4.1、<span id="icon-source">数据库图标来源与打包</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 取得日期：2026-11-15。来源为 [**iconfont**](https://www.iconfont.cn/) 的[「迈鼎icon」公开集合](https://www.iconfont.cn/collections/detail?cid=51731)，集合 ID `51731`；图标 `charts_数据库_data`，ID `43964161`，作者 `G_G曉楠`。取得时公开元数据为 `copyright=original`、`fees=free`，没有另列开源协议。
- 使用依据为 [iconfont 平台法律声明第三节第 4 条](https://terms.alicdn.com/legal-agreement/terms/product/20220705100131999/20220705100131999.html)：公共库或标为免费使用的素材，在展示期间允许其他用户下载使用。按此取得本地打包图标，不将空白 license 字段解释为某种开源许可证。
- 主体已核对为透明背景的四层圆柱数据库线条。原 SVG 仅把 `1em` 尺寸转换为明确的 `1024×1024`，保留图形路径与颜色，再导出矢量 PDF；运行时使用 [coredata-database.pdf](../JobsSwiftUIBaseConfigDemo/Assets.xcassets/JobsCoreDataDatabase.imageset/coredata-database.pdf)，不请求网络图片。
- [imageset 配置](../JobsSwiftUIBaseConfigDemo/Assets.xcassets/JobsCoreDataDatabase.imageset/Contents.json)启用 `preserves-vector-representation=true` 与 `template-rendering-intent=template`，由宿主前景色适配主题；资源名为 `JobsCoreDataDatabase`，不替换原有 Logo。

## 五、<span id="verification">验证边界与报告入口</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 源码与构建已验：四工程当前模型、持久化接线与可达入口完成源码核查；SwiftUI 最终模型编译及完整 Debug arm64 模拟器 App 构建通过。三份配套源码与模型编译成员唯一，`.momd` 已入包，最终 AppText 完整字典与源码一致，报告文件没有进入 App；原最近使用模型 13 项回归通过。此结果不代表 Release、真机或十语逐页界面验收。
- 真实存储已验：[CoreDataDemoStoreTests.swift](../Tests/CoreDataDemoStoreTests.swift)与实际存储源码共编译，21 项断言通过，覆盖完整 CRUD、独立容器与独立进程的记录及字段恢复、物理 SQLite 文件、空标题／错误数据不落盘、缺失模型、目录失败后的重试。范围为 [**MacOS**](https://www.apple.com/macos/) 实际 Core Data 存储层，不是 UI 点击测试；存储层生产源码在该轮验证后未改动。
- iOS 有限集成已验：独立 `JobsCoreDataDemo` 测试设备使用 iOS 27.2，首次空库到页截图 `first-launch.png` 已实看完整空态与数量 0，Device Hub 也可读取这些元素。终止测试 App 后，使用同一实际 `CoreDataDemoStore` 编译的测试可执行文件 `--seed`，配合 App 包内的真实 `.momd` 向该测试 App 沙盒写入 `CoreData process persistence`；重新启动 App 并以 `--jobs-coverage-route coreData` 到页后，`cold-readback.png` 实看标题、日期与数量 1，`sqlite3 -readonly` 对同一存储读得相同标题及未完成状态。此过程未手工修改 SQLite，证明模型入包、真实数据库及进程重启读取展示，不能称为点击“新增”已通过。
- UI 待验与限制：后续按钮自动操作遇到元素失效、窗口切换及超时，完整 UI CRUD、清空取消／确认、普通列表／搜索／速览点击入口和全局十语／三主题设置切换仍待验。iOS 26.5 仅启动模拟器，未运行本 App，不计入 App 验证。首屏与读回截图不能扩写为全部页面交互已验收。
- 验证证据保存在本次会话的外部 `coredata-demo/` 目录，包含 `build-final.log`、`store-tests.log`、`first-launch.png`、`cold-readback.png`、`final-cold-readback.png` 与 `review.json`；报告不把本机绝对路径固化为工程依赖。最后的标题标签／输入框排版调整版已重新完整构建、安装，并实看确认冷启动后同一记录的标题、日期与数量 1，标签和输入框位于同一 cell；此最终画面验证仍不替代完整 UI 点击验收。
- 四工程根导航的 `项目相关报告/` 使用 [**Xcode**](https://developer.apple.com/xcode/) 蓝色文件系统同步文件夹，按磁盘自动显示文件和子目录；不属于任何 target，不进入 Sources、Resources 或 Copy Files。四份工程配置已只读解析核对；仅 Swift UIKit 已在实际 Xcode 中看到蓝色目录展开与 5 份物理报告，OC 新旧及 SwiftUI 尚未实看，四工程均未实测文件增删自动跟随。
- 本文、[资产盘点](./App骨架功能盘点.md)及各工程根 `README.md` 是核查与后续维护入口；旧报告与既有正文保留。验证结果更新在本节与资产表，不把源码已实现与实际已验混写。

## 六、<span id="native-integration">OC 新旧与 Swift UIKit 本轮实际接入</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

2026-11-16用户明确要求三个工程现有模型“接入、使用”，三个工程的源码已实际接入：首页注册可达页面，使用 `User(name, age)` 手动增删改查，写入立即保存、错误可重试，空态含说明及重载；新安装不自动插入示例，有历史记录时保留读取。初次不可达／空模型结论已被本轮源码实现替代。OC新旧最终构建、Swift同源native隔离构建及实际Store测试已有下列通过证据，界面实际操作仍单独验收。

| 工程 | 当前入口、模型与操作 | 默认、持久化与生命周期 | 当前证据／待验范围 |
| --- | --- | --- | --- |
| OC 老工程 | 首页“数据、网络与文本 → Core Data 本地数据库”注册 `CoreDataVC`；保留原 `User(name, age)` 模型；原自动Alice／Bob日志演示替换为添加、点行编辑、左滑删除和清空确认 | 保留 `NSPersistentCloudKitContainer` 与原默认存储描述，不更名或清库；添加表单姓名／年龄为空；页面出现、回前台与手动重载查询；每次写入save，失败rollback；后台只保存已加载容器；模型／存储加载失败不缓存，可重试 | [专项资产与代码入口](../../JobsBaseConfig@JobsOCBaseConfigDemo/项目相关报告/App骨架功能盘点.md#coredata-assets)；最终构建exit0；实际App建库、初始0，同源seed后冷启动读回图已实看姓名／年龄42／数量1，通知遮挡其它区域；按钮CRUD未验 |
| OC 新工程 | 与老工程相同入口、模型、手动操作、错误与默认值 | 同一主工程存储适配层；原本地Pod装配不因数据库演示新增依赖；沿用同样的存储及生命周期边界 | [专项资产与代码入口](../../../JobsOCBaseConfigDemo@ByPods/项目相关报告/App骨架功能盘点.md#coredata-assets)；最终构建exit0、同源Store27项断言通过；安装后终止旧进程，以新PID88560启动，读回图及Probe均数量1、年龄42；读取同bundle共享库，非第二个全新空库；按钮CRUD未验 |
| Swift UIKit | 首页“系统能力与硬件通信 → Core Data 用户数据库”注册 `JobsCoreDataDemoVC`；原空模型补为 `User(name: String, age: Int32)`，手动NSManagedObject无生成文件；添加、点行编辑、左滑删除、清空确认 | `Application Support/JobsSwiftBaseConfigDemo/Users.sqlite`，默认空库；新增表单年龄默认18；页面出现加载／重读，操作立即save且失败rollback，初次加载失败可重试；fetch刷新其它容器已改字段；不给App启动／退后台新增数据库副作用 | [专项资产与代码入口](../../JobsBaseConfig@JobsSwiftBaseConfigDemo/项目相关报告/App骨架功能盘点.md#coredata-assets)；同源native隔离整包exit0、Store真实SQLite／跨进程／跨容器测试通过；实际App建库、同源seed、Probe数量1、重启成功；截图未展示完整业务页，页面读回与按钮UI未验；原workspace仍因既有Flutter冲突失败 |

三工程均校验姓名去两端空白后非空、年龄为0～150整数，沿用全局语言与主题及完整空态，不请求业务API、不使用假数据。OC保留CloudKit容器类型不代表本轮已验收iCloud同步；原模型／存储迁移、历史数据库兼容、真机和所有语言设备组合不能由源码接入或模拟器到页替代。

本轮外部`coredata-native`证据中，`oc-old-final-incremental.log`、`oc-new-final-incremental.log`记录补`viewDidAppear`生命周期后的最终增量构建，均exit0；首次OC刷新DSL链类型降级错误及失败日志保留，两侧已改为现有`byMJ_header`再接视图DSL。Swift的`swift-workspace-build.log`保留原Flutter阶段`kernel_snapshot_program`失败，`swift-isolated-final-build.log`记录最终同源native隔离构建exit0；`swift-final-comments-build.log`补充确认四条分支注释后的最终增量构建exit0；原Flutter锁文件与generated未改。最后两份生产源码指纹分别为Store `ba091b8094368c697bd472e67041e745fd94d941ea32a97becf513c44c38fe14`（仅新增四条`///`分支注释，与已验3342版本去除注释后的代码逐字一致）、VC `7154ca8bdbc9e72d727acaa6bbddd3aa26a939a839717ef2667a31ba57cb414f`，含跨容器刷新与按钮事件只注册一次修正；早期只读隔离盘点的瞬时差异不冒充最终冻结版本。

OC旧的有限运行证据来自独立模拟器：实际App创建`Application Support/JobsOCBaseConfigDemo.sqlite`，初始数量0；先停止App，使用实际Store和App内momd向同一隔离库写入`Jobs CoreData runtime / 42`后重启，`oc-old-readback.png`已实看姓名、年龄42及数量1，通知授权弹窗遮挡其它区域。OC新最终包安装后明确终止旧进程，再以新PID88560启动，`oc-new-readback.png`已实看同一姓名／年龄42／数量1，`oc-new-runtime-read.log`只读Probe同为数量1。两个OC包读取同bundle标识下的共享模拟器库，OC新继承种子记录，不能表述为两个全新空库。写入由同源生产Store程序完成，未实际点击App新增按钮。

Swift最终同源隔离App安装／启动成功，并自行创建`Application Support/JobsSwiftBaseConfigDemo/Users.sqlite`；先停止App，由最终实际Store与包内momd写入`Jobs Swift CoreData runtime / 42`，`swift-runtime-probe.log`写入后查询为数量1，随后重启成功。`swift-readback.png`只展示系统通知弹窗、未展示完整业务页，因此页面读回显示仍未验，不当作通过图。Mac锁定下，三工程完整菜单／按钮CRUD、清空取消／确认及十语三主题遍历仍未验收。

最初辅助RuntimeProbe曾引用安装迁移前的过期container UUID而失败，`oc-runtime-probe-stale-container.log`保留；动态取得当前container后修正成功。此项属于验证工具定位失败，不记为产品数据故障。最终隔离native与真实Swift主工程490/490文件SHA256一致（忽略`.DS_Store`）；三个App内完整词典分别为OC旧12、OC新12、Swift11，共35份，与当前源解析字典逐项一致，三份momd均在包。

资源已准备并参与上述最终构建：三个工程各自既有主工程 `Assets.xcassets` 新增 `CoreDataDatabaseIcon.imageset`，复用[同一 iconfont 来源与授权依据](#icon-source)的数据库图形；从同一原始SVG重导出44×44pt矢量PDF，仅调整逻辑页尺寸以适配UIKit按钮，三工程副本逐字一致，SwiftUI原PDF不变。最终版与原图同尺寸渲染已实看无差异、无裁切，均保留矢量及模板渲染，本地打包、不新增网络图片。三工程共35份既有主词库增量补齐统一32键（每份只追加原本缺失键，总计864项），覆盖简繁藏英日法西德俄韩及原 Tagalog 变体；旧文件字节前缀与旧字典值保留，语法和格式占位符已校验，35份最终包完整字典也已逐项一致。图标实际UI效果及所有翻译页面组合仍待验收。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
