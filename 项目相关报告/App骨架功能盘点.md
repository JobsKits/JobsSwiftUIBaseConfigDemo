# <span id="前言">SwiftUI App 骨架增量盘点</span>

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#jobs-toc-heading-1)
- [一、最近使用资产](#recent-assets)
- [二、验证与后续维护](#verification)
- [三、项目相关报告 Xcode 物理目录入口](#report-folder)
- [四、Core Data 本地数据库资产](#coredata-assets)
- [五、首页悬浮时钟核查边界](#floating-clock-scope)
  - [5.1、世界时钟与首页标识新需求](#world-clock-requirement)
  - [5.2、当前实现与验证](#world-clock-assets)
- [当前时区卡片与制式标题合同（2026-11-16）](#jobs-toc-heading-9)
- [首页返回、侧栏与开屏浮控增量](#home-return-sidebar-20261116)
- [Rust OCR 独立 Demo 接线（2026-11-16）](#jobs-toc-heading-11)

</details>
<!-- jobs-toc:end -->

---

## <span id="jobs-toc-heading-1" data-jobs-toc="v2">🔥 前言</span><!-- jobs-toc:heading-end -->

核对日期：2026-11-16。本表盘点“最近使用”、报告目录入口、Core Data 既有增量接线与本次首页浮钟／世界时钟骨架，不是整个 App 或 Demo 子页面的全量盘点。原有四 Tab、拖动排序、系统搜索及各功能页保留；本工程没有侧栏，因此最近入口放在 Demo 首页右上工具栏。

## 一、<span id="recent-assets">最近使用资产</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

| 编号 | 入口／资产 | 当前行为／默认 | 状态与边界 | 源码 |
| --- | --- | --- | --- | --- |
| SUI-RECENT-01 | 首页最近入口 | Demo Tab 右上时钟按钮进入独立最近页，按钮名称使用当前全局语言 | 原首页无其它右上动作；未增加 Tab 或嵌套导航栈 | [DemoListView](../JobsSwiftUIBaseConfigDemo/DemoListView.swift) 的工具栏 |
| SUI-RECENT-02 | 历史数据 | 默认空；保存 `DemoFeature.rawValue`，最近在前、去重、最多30项；只接受当前注册的ID | 删除／Release中不注册的条目在读取时过滤并回写；偏好类型损坏回空 | [DemoRecentHistory](../JobsSwiftUIBaseConfigDemo/DemoRecentHistory.swift) |
| SUI-RECENT-03 | 访问记录 | 普通列表、系统搜索结果、最近列表和速览进入目标后，在目标 `onAppear` 记录 | 创建行／预构建 `NavigationLink` 不写记录；普通入口及最近重开已实看去重；搜索／速览为源码接线与模型验证，未实看这些入口 | [首页](../JobsSwiftUIBaseConfigDemo/DemoListView.swift)、[最近页](../JobsSwiftUIBaseConfigDemo/DemoRecentListView.swift)、[速览](../JobsSwiftUIBaseConfigDemo/GalleryTabView.swift) |
| SUI-RECENT-04 | 列表／空态／重载 | 复用真实 `DemoFeature.destination`；空态含图标、标题、说明和重新加载；有数据支持下拉与按钮重载 | 本地注册目录与历史，无远端接口；重载读取当前偏好并清理失效ID | [DemoRecentListView](../JobsSwiftUIBaseConfigDemo/DemoRecentListView.swift) |
| SUI-RECENT-05 | 来源与返回 | 最近页复用 Demo Tab 的 `NavigationStack`；目标返回先到最近，再返回首页 | 从最近重开目标后返回仍在最近列表已实看；首页搜索文本、排序状态及各 Tab 独立导航为当前源码行为，搜索返回待单独实看 | [MainTabView](../JobsSwiftUIBaseConfigDemo/MainTabView.swift)、[DemoListView](../JobsSwiftUIBaseConfigDemo/DemoListView.swift) |
| SUI-RECENT-06 | 共享状态／持久化 | App根以 `StateObject` 持有同一历史模型，注入正常Tab及Debug独立巡检根；键为 `JobsSwiftUIBaseConfigDemo.recentDemoIDs` | 普通首页／速览／最近页消费同一对象；每次记录先读最新落盘值，不以旧实例覆盖其它Scene先写的新记录 | [App根](../JobsSwiftUIBaseConfigDemo/JobsSwiftUIBaseConfigDemoApp.swift)、[DemoRecentHistory](../JobsSwiftUIBaseConfigDemo/DemoRecentHistory.swift) |
| SUI-RECENT-07 | 语言与主题 | 新增最近使用、尚无最近使用、说明三键，复用已有重新加载，沿用十语AppText与白天／黑夜／跟随系统 | 最近页不增私有语言或主题设置，文字和背景使用原生语义角色 | [AppText.json](../JobsSwiftUIBaseConfigDemo/Resources/AppText.json)、[AppPreferences](../JobsSwiftUIBaseConfigDemo/AppPreferences.swift) |

## 二、<span id="verification">验证与后续维护</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

- [真实模型隔离测试](../Tests/DemoRecentHistoryTests.swift)13项断言通过：未知／重复过滤、净化回写、前插去重、持久恢复、跨实例合并、容量淘汰及损坏偏好回退。测试使用独立UserDefaults suite，不读取或改动用户历史。
- 工程引用通过属性列表校验；新源码已加入主 App Sources。独占DerivedData的Debug Simulator完整构建通过，包含最终App根注入版本。构建保留现有工具链路径与脚本输出声明告警，没有修改外部工具链或依赖。
- 模拟器限定UI实测：新安装无历史时显示完整空态且可重新加载；普通入口打开 `Text/Label/Image` 后返回，最近列表为1条；从最近再次打开，返回仍为最近列表且无重复。最终App根注入版重新安装、终止并冷启动后，该条记录仍恢复，最近重开后的返回来源和去重再次通过。搜索／速览实际打开、十语逐项画面与三主题逐项画面没有在本批实看，不将共享接线或模型结果扩大为这些UI验收。
- 新增或删除注册项时保持已有稳定ID；以后每次改 App，在同一任务更新对应行为、入口、默认、持久化、源码位置与验证结果。报告归本目录，根目录README保留。
- 本次没有迁移无关文档、修改第三方／生成代码、执行依赖安装或重生成巡检JSON。

## 三、<span id="report-folder">项目相关报告 Xcode 物理目录入口</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

| 编号 | 入口／资产 | 当前行为／默认 | 状态与边界 | 工程依据 |
| --- | --- | --- | --- | --- |
| SUI-REPORT-01 | 根导航的 `项目相关报告/` | 使用 [**Xcode**](https://developer.apple.com/xcode/) 蓝色文件系统同步文件夹 `PBXFileSystemSynchronizedRootGroup`，按磁盘自动发现文件和子目录，增删报告后无需逐个维护文件引用 | 仅工程导航；不属于任何 target，不进入 Sources、Resources 或 Copy Files；没有 App 偏好或运行时生命周期。四工程结构已核查；仅Swift UIKit已实看蓝色展开与5份物理报告，本SwiftUI及OC新旧尚未实看，四工程文件增删跟随均未实测 | [project.pbxproj](../JobsSwiftUIBaseConfigDemo.xcodeproj/project.pbxproj) 中 `项目相关报告` 同步组与主导航引用 |

## 四、<span id="coredata-assets">Core Data 本地数据库资产</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

| 编号 | 入口／资产 | 当前行为／默认 | 持久化／生命周期 | 状态与源码 |
| --- | --- | --- | --- | --- |
| SUI-CORE-01 | Demo 列表／搜索／速览 | `DemoFeature.coreData` 路由至原生 `CoreDataDemoView`，不加嵌套导航；最近记录沿用统一接线 | 稳定 ID `coreData` 自动补入旧排序 | [注册表](../JobsSwiftUIBaseConfigDemo/DemoFeature.swift)；iOS27.2独立测试设备已通过巡检路由到页，普通列表／搜索／速览的实际点击待验 |
| SUI-CORE-02 | 模型与真实数据库 | `DemoNote(id, title, createdAt, isComplete)`，默认空库与未完成；UUID唯一 | 模型编译入App，SQLite 在 Application Support 下 `CoreDataDemo/JobsSwiftUIBaseConfigDemo.sqlite`；每次写入立即保存，退出／重启保留 | [模型](../JobsSwiftUIBaseConfigDemo/Resources/JobsSwiftUIBaseConfigDemo.xcdatamodeld/JobsSwiftUIBaseConfigDemo.xcdatamodel/contents)、[Store](../JobsSwiftUIBaseConfigDemo/Persistence/CoreDataDemoStore.swift)；模型编译、完整Debug arm64模拟器构建与真实SQLite21项断言通过；iOS终止进程后读回并显示测试记录已验，记录由实际Store测试入口写入，非UI新增 |
| SUI-CORE-03 | 增删改查／空态与异常 | 新增、改名、切换完成、单删、清空确认、下拉与菜单重载；空态含说明和按钮，失败回滚并可重试 | 主Actor串行访问；页面进入与回前台重读，不依赖后台回调保存；不请求API或回退假记录 | [页面](../JobsSwiftUIBaseConfigDemo/Demos/CoreDataDemoView.swift)、[值快照](../JobsSwiftUIBaseConfigDemo/Persistence/CoreDataDemoRecord.swift)；存储层CRUD、独立容器／进程字段恢复及错误重试21项通过；首屏空态数量0和冷启动读回数量1已实看。后续点击遇元素失效／窗口切换／超时，完整UI CRUD与清空取消／确认待验 |
| SUI-CORE-04 | 全局设置与图片 | 复用全局十语与白天／黑夜／系统，不增私有设置；独立iconfont数据库图标随包 | 词条加入现有AppText，矢量PDF使用template随主题着色 | [资源](../JobsSwiftUIBaseConfigDemo/Resources/AppText.json)、[图标](../JobsSwiftUIBaseConfigDemo/Assets.xcassets/JobsCoreDataDatabase.imageset/Contents.json)；构建通过，首屏及读回画面已实看，十语／三主题全局设置切换待验；图标来源见核查报告 |

四工程模型使用差异、来源与逐项验证见[Core Data 使用核查](./CoreData使用核查.md)。本节是本次Demo增量，未扩展为其它所有Demo的全量盘点。

## 五、<span id="floating-clock-scope">首页悬浮时钟核查边界</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

2026-11-16起始源码核查：本工程首页、共享App根与主工程中没有 UIKit／Flutter 首页那种显示“当前时间＋HH:mm:ss”的可拖动悬浮按钮。首页右上 `clock.arrow.circlepath` 是[最近使用入口](../JobsSwiftUIBaseConfigDemo/DemoListView.swift)，[TimerDemoView](../JobsSwiftUIBaseConfigDemo/Demos/TimerDemoView.swift) 属于独立计时示例，均不当作悬浮时间按钮。此“尚无浮钟”的起始结论保留为历史；用户随后明确要求补齐，原“不新增”范围已被新需求替代。

### 5.1、<span id="world-clock-requirement">世界时钟与首页标识新需求</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

需求已确认，先登记后实现：SwiftUI 首页新增默认可见的蓝色悬浮时间按钮，文字为当前时间与24小时制时分秒。按语言、动态字号及设备安全区自适应，左右16／上下10留白；短按沿当前导航栈 push 世界时钟，长按起拖、松手四边吸附，拖动不兼触发导航。设置可控制显示并保存，位置仅当前视图存活期间保留。首页统一“功能实验室”，项目来源副标题为 `JobsSwiftUIBaseConfigDemo`。

世界时钟是 App 骨架页，不登记为 Demo、不增加列表数量、不写入最近记录。当前系统时区独立置顶；世界列表以同一瞬间有效UTC偏移分组，每个偏移一个知名代表，巴黎／纽约优先，覆盖半小时及四十五分钟。每行显示地区、IANA标识、UTC偏移、当地完整日期、星期和时分秒；由系统时区规则处理夏令时，不用固定偏移表。前台且页面可见时每秒读取绝对时间，进入／恢复立即更新，后台／被覆盖／离开停止；系统时区或显著时间改变后重算。十语三主题沿用全局设置，窄屏大字可滚动，异常／空数据提供完整空态和重载。

用户追加格式需求已确认：世界页提供“12小时制”Toggle，默认关闭即24小时制，开启后所有时区时间立即切换为12小时制并明确显示大写 AM／PM；午夜为12:xx AM、中午为12:xx PM。该选择持久化，只作用于世界时钟，不改变首页24小时浮钟；切换保持导航与滚动位置，边界测试与当前源码状态随后回填。

Swift UIKit `JobsSwiftTimer` 已作为实现参考：采用幂等启动／停止、主线程投递和停止后拒收迟到回调的原则。SwiftUI 工程未依赖该 UIKit 多内核 Pod，因此采用主工程轻量 ObservableObject 适配已有 Combine 调度，并由 scenePhase 和页面可见状态驱动，避免为秒级显示引入整套 UIKit 依赖。当前源码、专项测试与最终完整构建已完成，实际界面验证单列如下。

### 5.2、<span id="world-clock-assets">当前实现与验证</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

全屏拖动范围复核（2026-11-16，先登记后修正）：此前浮钟在 `List.overlay`，GeometryReader只获得列表承载范围，位于NavigationStack内部，不能据此声称已覆盖导航区域并保持可触。现已只将同一常驻浮钟提升到整个NavigationStack的外部overlay，覆盖其可用安全区域且位于导航条上方；底部仍由TabView的可用区域隔开Tab栏，不把allowedArea缩到导航条下方。首页可见／Tab选中／设置显隐及页面计时治理不变，没有修改浮钟几何算法或既有Debug层。90项生产模型回归重跑通过，Debug arm64完整增量构建通过；该范围修正后的物理长按／导航命中仍未验，具体阻塞见本节末。

| 编号 | 入口／行为 | 默认／持久化／生命周期 | 代码位置与状态 |
| --- | --- | --- | --- |
| SUI-CLOCK-01 | Demo Tab 首页蓝色时间浮钮，标准Button短按 push 世界页；长按0.5秒后拖动，松手按最近四边吸附；simultaneousGesture协调序列，first(true)只重置会话，second(true, _)才锁存长按并抑制松手短按；保留无障碍默认动作 | 默认显示，设置开关键 `JobsSwiftUIBaseConfigDemo.showFloatingClock`；拖动位置仅当前浮控存活期间；切换Tab、进入子页及后台取消计时 | [首页](../JobsSwiftUIBaseConfigDemo/DemoListView.swift)、[浮钟](../JobsSwiftUIBaseConfigDemo/HomeFloatingClock.swift)、[几何](../JobsSwiftUIBaseConfigDemo/FloatingClockGeometry.swift)、[设置](../JobsSwiftUIBaseConfigDemo/AppSettingsView.swift)；最终真实中心短按、静止长按、四向拖动及导航顶部中心可点／返回保位已通过 |
| SUI-CLOCK-02 | 自然宽度以当前文字／字体测量，H16／V10留白；受当前可用安全区域约束，大字窄宽重新测高；尺寸变化保留吸边；从Button本体onGeometryChange读取实际尺寸供clamp使用 | 18pt粗体与等宽数字模板，DynamicType按body缩放；不以屏幕比例撑宽，不缩小文字；可用高度不足时ViewThatFits切换纵向滚动内容 | [ClockContentLayout](../JobsSwiftUIBaseConfigDemo/HomeFloatingClock.swift)；纯几何矩阵通过，最终真实Button尺寸接线及四边安全落点通过；模型矩阵不是实际绑定验收。其它设备／大字与内部滚动画面待验 |
| SUI-CLOCK-03 | 当前时区独立圆角强调卡片、大号当前时间＋世界有效偏移分组；巴黎纽约优先，半小时／45分钟；贝克岛作为无人常住的UTC−12代表 | `TimeZone.knownTimeZoneIdentifiers`合并有效优先别名与 `Etc/GMT+12` 后按同一Date计算，范围−12…+14；无自建固定夏令时表／无授时API／不存世界时间快照 | [Catalog](../JobsSwiftUIBaseConfigDemo/WorldClockCatalog.swift)、[世界页](../JobsSwiftUIBaseConfigDemo/WorldClockView.swift)；与Swift UIKit同源算法；ICU城市／日期星期本地化，藏文巴黎名称依系统回退为Paris |
| SUI-CLOCK-04 | Toggle左标题随当前值显示“24小时制／12小时制”，关24h／开12h；当前及世界各行同步、明确AM／PM；首页仍24h | 默认关闭；键 `com.jobs.worldClock.uses12HourFormat`，保存在当前App偏好；切换不重建导航／列表ID | [AppPreferences](../JobsSwiftUIBaseConfigDemo/AppPreferences.swift)、[格式与计时](../JobsSwiftUIBaseConfigDemo/JobsSwiftUIClock.swift)；格式边界断言通过；真实开关轨道点击、返回重进保留及结束恢复24h已验；冷启动格式恢复仍待验 |
| SUI-CLOCK-05 | 前台且可见每秒重读Date，时区／系统时钟通知立即刷新；停止时取消Combine连接、generation拒收迟到回调 | 幂等启停，恢复立即更新；StateObject释放时订阅随之取消；不复用独立TimerDemo的常驻autoconnect | [JobsSwiftUIClock](../JobsSwiftUIBaseConfigDemo/JobsSwiftUIClock.swift)；真实主RunLoop启停／恢复与通知断言通过 |
| SUI-CLOCK-06 | 首页“功能实验室”＋项目来源副标题；世界页沿用首页导航，提供完整空态与重载 | 十语／白天黑夜系统沿用全局；世界页不登记Demo、不增加数量、不写最近 | [DemoListView](../JobsSwiftUIBaseConfigDemo/DemoListView.swift)、[词表](../JobsSwiftUIBaseConfigDemo/Resources/AppText.json)；12键均覆盖十语；首页标题来源与世界页导航已实看，十语／三主题全矩阵及空态仍待验 |

[WorldClockTests](../Tests/WorldClockTests.swift)直接调用生产模型／格式／几何和真实Combine主RunLoop，90项断言通过，包含冬夏完整系统偏移及UTC−12、去重、巴黎纽约夏令时切换、30／45分钟、当地跨日星期、十语城市、AM／PM午夜正午和首页默认24h、四边保位、停表后无更新及恢复／通知立即刷新。完整Debug arm64模拟器包构建通过，包含最终偏移覆盖、统一12小时制偏好键及高度不足时内部滚动；最后新世界页次文字对比增强亦再次完整增量构建成功并安装启动，生产计时与格式逻辑未变，90项断言不重复运行。无新增Swift编译错误，保留工具链搜索路径、资源脚本输出声明及无AppIntents依赖的既有告警。工程属性列表、73条本地文档链接、锚点唯一与差异空白检查通过；CodeGraph因本机Node缺libsimdutf不能运行，使用源码定位，没有修改环境。实际界面补验及最后视觉增量的证据边界如下。

Root限定实际界面补验（2026-11-16，iPhone18Pro／iOS27.2）：逻辑最终包安装启动后已实看首页“功能实验室＋项目来源”与蓝色自适应浮钟；短按push世界页，当前上海／IANA／UTC偏移、当地日期星期及跨日代表显示正常。开12h立即显示PM，返回重进仍开启，关闭恢复24h，返回首页恢复浮钟；尚未验证冷启动格式、物理长按拖动及全部主题语言画面。截图发现世界页次文字偏浅，随后只将新页时区／日期和分组标题改为主文字70%以提高局部对比，首页原来源副标题保持；此最后视觉增量完整增量构建成功且已安装启动，但再次进入世界页时CUA出现元素失效及30秒超时／内核重置，增强后的世界页画面未重新实看。此前逻辑包的限定交互仍记为已验，不外推最后视觉画面或全部主题对比通过。

全范围版本的真实手势验证记录：复用既有独立UI测试Runner工程，在仓外临时副本放入一条真实触点测试，计划检查初始中心点击、12h与返回、右／左／底／导航顶部四向0.75秒长按拖动、吸附后可触且不误push、导航上再次短按及返回保位，并在结束恢复24h偏好。App与小Runner均构建成功。首次专用模拟器因磁盘满，Runner安装被InstallCoordination的PromiseStaging目录创建失败拒绝，测试方法尚未执行，部分xcresult亦无法完整落盘；经明确授权仅关闭并删除本轮新建模拟器数据回收空间，保留全部日志与Runner产物，没有清理其它设备或项目。随后在已授权primary设备以 `parallel-testing-enabled NO` 执行同一唯一用例 `test-without-building`，11.5秒后因testmanagerd声明的unix-domain.socket文件不存在而无法建立Runner通信，同样没有进入测试方法、没有修改12h偏好。完整第二次xcresult与错误日志已保留；最终全范围App已安装primary，未为此反复大编译、重启设备或修改系统服务。该结果属于测试基础设施阻塞，不能记为手势通过或业务断言失败。

共享最终模拟器首次真实用例已运行（iPhone18Pro／iOS27.2）：浮钟实际frame为 `(8,110,113.33,63.33)`，位于导航／搜索区域；真实中心短按后仍在首页，世界页未出现，17.48秒用例以首个导航断言失败结束。该轮设备基础设施正常，属于真实交互缺陷，不能继续只列为测试环境阻塞。失败AX树中浮钟仅有标题与时间两条StaticText，未启用ViewThatFits备用ScrollView。原AX默认动作绕过 `LongPress.sequence.exclusively(Tap)` 路径，不能代替物理短按。按先登记的修正合同，当前源码已使用标准SwiftUI Button承接短按和无障碍，原长按→拖动序列改为Button的highPriorityGesture，移除exclusive Tap分支；外置导航overlay、几何与生命周期不改。此选择参考[Apple按钮与手势指引](https://developer.apple.com/documentation/swiftui/gestures)及[高优先级手势](https://developer.apple.com/documentation/swiftui/view/highprioritygesture%28_%3Aincluding%3A%29)；构建与同一真实用例复验将分别回填，失败日志／AX树／截图／录屏保留。

单变量诊断进一步区分：标准Button＋highPriority序列仍物理短按失败；临时DEBUG标记证实导航区域中心、可见标题、按钮底部以及拖出导航后的列表区域短按均未进入Button action（次数始终0），而同一起点的长按可以改变真实frame。仅在Button label内部追加contentShape后重测，结果仍相同。因此不再将问题归为原生导航层／路由布尔或单独的label形状，也不把初始点避开导航当修复。下一修正合同是同优先级simultaneousGesture协调Button与长按序列：按真实触摸会话锁存已长按／移动，阻止松手误触短按；新touchdown清除锁存，取消时由GestureState回收，不使用延时来猜测事件先后。原始失败与诊断证据全部保留，最终删除DEBUG探针后再运行完整真实场景。

最终诊断与修正闭环：以上早期标记位于onOpen回调，并不等于原始Button action；补充guard前raw计数后，真实短按raw每次增加而onOpen为0，first阶段已经出现但second未出现，备用ScrollView明确为false，证实simultaneous已将输入交给Button，新增长按门禁却在first(true)过早锁住短按。最终只在second(true, _)锁长按；first(true)表示识别进行中，只负责清除上一触摸会话门禁，移除额外min0触摸会话识别器，不加延时。源码保留一条why注释，临时DEBUG探针／计数／阶段日志全部删除。选择同优先级协调的API语义见[Apple simultaneousGesture](https://developer.apple.com/documentation/swiftui/view/simultaneousgesture%28_%3Aincluding%3A%29)，具体失效与修复以实际证据为准。

完整真实case还检出另一处接线问题：Button label内部Preference测量没有可靠传到外层，clamp收到零宽，右吸边使实际frame.maxX达到507.33而屏宽402。90项纯模型／几何断言通过并不能证明UI测量接线正确。最终改为Button本体onGeometryChange读取真实CGSize，安全区与四边公式保持；随后无探针最终App构建通过，原完整真实用例26.814秒、0失败：初始物理中心push、12h轨道点击、返回保留、静止0.75秒长按不push、左右／底／导航顶四向拖动不误push且吸附后可触、导航区域中心再次push、12h保留并关闭恢复24h、返回浮钟原落点均已验。实际frame：右 `(280.67,359,113.33,63.33)`、左x8、底maxY783（Tab栏minY791）、顶部y70并处于导航范围；返回顶部frame逐项一致。此前整行中心点点击Toggle未命中轨道的测试定位问题已改为真实右侧开关轨道，原值断言保留。

最后视觉增量另验：世界页两分组标题和两行次文字统一明确使用Color.primary.opacity(0.7)，避免Header环境把层级式.primary再次弱化；首页来源副标题不变。完整四拖case对应上一逻辑最终包，本次纯色小增量Debug arm64构建已成功。等待短链期间共享3C及原primary等整个available设备集消失，用户随后明确确认自己已清理模拟器并要求重建，属于用户确认的环境重置，既有真实证据仍有效。Root统一安排唯一Final2，各端串行交棒后，本工程冻结App的颜色／格式短链真实执行1项、12.803秒、0失败：中心push、真实轨道切12h且当前行明确AM／PM、12h截图、关回24h截图、返回浮钟可触均通过，结束恢复24h。两张最终截图已导出并实际查看，浅色世界页的分组标题与行次文字均清晰，上海IANA／偏移／日期星期、UTC−12的跨日及12／24h表达均可读；没有为纯色重复四向拖动。最后颜色短链首次过滤曾得到exit0但实际0 tests，未记为通过；核查发现先前轻Runner编译受旧设备被清理影响，重编轻Runner后核对xcresult的totalTestCount=1才计入本次结果。完整十语三主题／其它设备大字及SwiftUI冷启动格式恢复仍是待验项，不从这两张浅色截图外推。


## <span id="jobs-toc-heading-9" data-jobs-toc="v2">当前时区卡片与制式标题合同（2026-11-16）</span><!-- jobs-toc:heading-end -->

用户明确要求原生世界页向Flutter学习：开关下方独立圆角当前时区卡片，以适配白天／黑夜的柔和强调底色、清晰主副文字和大号当前时间形成层级；卡内保留城市／IANA／UTC偏移、日期及星期，支持大字换行。全球列表仍在卡片之后。开关左侧标题反映已持久化的实际制式：ON为12小时制，OFF为24小时制，即时切换且十语完整。仅表现层增量，不改变偏好键、AM／PM、时区模型、生命周期、Demo注册或最近记录。

盘点：三个UIKit工程原为普通首分组行；SwiftUI虽为insetGrouped首分组，但没有独立强调底色与大号当前时间。实施前状态为待补齐；现四端生产源码已改，Swift语法通过，35份原生词典与SwiftUI十语言制式词条有效；实际UIKit字体／生产formatter小测1项0失败（160组合）通过。卡片主／副字浅色与深色四对对比均≥4.5。字体测量不代替实际AutoLayout接线；本工程当前合并普通arm64模拟器构建通过，23.820秒真实当前时区卡片用例1项0失败：独立卡片完整IANA／UTC／星期、大号时间、24／12小时标题即时变换与AM／PM、秒值推进不改卡片frame，已捕获两态并实看12h图；测试结束恢复原格式。当前实际画面限iPhone18Pro／iOS27.2简中浅色，其它语言／深色／极端字号仍待验。


## <span id="home-return-sidebar-20261116">首页返回、侧栏与开屏浮控增量</span>

2026-11-16用户新需求，先登记后实现：设置增加真实开关“返回首页时收缩分组”，默认开；只从具体Demo返回主首页时自动收缩，关闭后保留离开时展开与滚动位置，手动单组／批量收缩仍可用。选择持久保存，不能被既有“返回回顶部并刷新”间接覆盖；设置、搜索、最近列表和世界时钟返回不冒充具体Demo返回。首页分组展开与浮钟坐标仍属视图内存，不泛称所有状态均跨启动保存。

用户报告左上侧栏点击无反应，并补充Swift疑似异常、OC正常：优先核查Swift实际按钮事件、宿主查找与呈现链路，OC只回归既有路径；没有既有侧栏的工程不额外创造侧栏入口。用户还报告浮钟盖住开屏：实际开屏呈现期间隐藏且不接收触摸，真正结束且首页可交互后恢复；重播／根切换／多Scene以当前owner的生命周期为准，不使用固定延迟。

收口复核补充：三UIKit时间Timer原先使用全局固定注册ID，两个首页实例会共用同一个Timer，按ID暂停可能影响另一Scene。现仅时间Timer改为每首页实例唯一ID：两OC懒注册`ViewController_1.suspendTimeBtn.<实例地址>`，Swift为`RootListVC.suspendBtn.<UUID>`；恢复／暂停／销毁使用自己的ID，旋转Timer与手势不扩围。原单Scene首页／开屏真实用例证据保留。另以生产源码逐字提取的两个ID及实际JobsTimerMgr／JobsSwiftTimerMgr后端验证暂停、恢复与移除隔离，独立XCTest两项／零失败；OC新旧Manager源码哈希相同。收口ID增量先受并行RustOCR集成阻断，旧失败日志保留；OCRowner修复guarded调用方及旧target membership后，两OC final6普通arm64增量均构建通过，独立冻结App及逐文件哈希，在A3以冻结包完成最终开屏短验：新10.225秒／旧7.214秒，两项／零失败；两端倒计时画面均无浮钟，skip后恢复可命中，四张截图已实看。该包未集成OCR Apple SDK，不代表OCR识别已验。Swift隔离副本已同步guarded OCR类与适配，唯一ID普通增量构建通过，在新共享设备A3（JobsDemoSharedFinal3）真实开屏短验1项／零失败（13.072秒），倒计时画面无浮钟、skip后恢复可命中且截图实看通过。各阶段包和证据明确对应，实际多Scene窗口组合仍待验。

起始缺口：新返回收缩开关尚未提供；UIKit原有返回刷新可能重建展开集合；SwiftUI当前只有一个未提供收缩交互的“系统 UI Demo”分组、没有侧栏，也没有独立开屏。新增开关须在SwiftUI补齐该既有组的手动展开／收缩语义；不新增侧栏或开屏。三个UIKit工程的侧栏按钮及开屏期间浮控命中需要本轮复测。当前源码已接入新开关及具体Demo返回门禁：OC新旧键com.BSports.JobsOCDemoListCollapseOnDemoReturn、Swift键RootList.collapseOnDemoReturn、SwiftUI键JobsSwiftUIBaseConfigDemo.collapseOnDemoReturn，均NSUserDefaults／UserDefaults，缺值默认开。三个UIKit的开屏以当前宿主树呈现前抑制、真实finish移除后的下一主队列恢复，首页不可交互时仍隐藏并暂停；不缩小原全屏拖动范围。Swift左菜单改factory显式注入真实drawer owner，避免可选祖先查找静默无动作。HOME-04：两OC/SUI首页按Swift卡片圆角14／H10V8留白、组17/13与内行17/12、基准行56及多行标题测高对齐，保留目录稳定ID和交互。当前源码、构建与限定真实UI验证均已完成，范围见下表；完整矩阵继续单列待验。


| 资产 | 当前行为／存储 | 本轮验证与边界 |
| --- | --- | --- |
| HOME-01 返回收缩开关 | 设置的原生UISwitch／Toggle；缺值默认开，只在本首页实际推入具体Demo后返回时处理；关闭优先保留离开前展开和滚动，普通设置／世界页及最近列表返回不当作Demo。新键UserDefaults落盘；展开集合与浮钟位置仍内存 | 四端实际开关ON／OFF、普通设置返回、具体Demo返回、冷启动新键恢复通过；当前只简中浅色，不冒称所有历史设置都已重新冷启验证 |
| HOME-02 左上侧栏 | Swift由根工厂把实际JobsSideDrawerVC弱引用注入首页，点按不再只依赖可选祖先查找；两OC未改正常侧栏实现；SwiftUI本无侧栏，不新增 | 三UIKit实际按钮点击、首页平移及收回通过并留图；用户信息／最近／设置等其它侧栏目的页不借本次入口测试冒称全验 |
| HOME-03 开屏浮钟 | 当前开屏宿主树中逐个抑制首页时间控件；skip／倒计时实际finish移除后下一主队列恢复，首页未可交互仍隐藏并暂停；多Scene只作用于该owner，不以秒数硬延迟，不限制既有全屏拖动 | 三UIKit实际开屏倒计时画面中控件AX不存在、结束后真实恢复且可点击通过；SwiftUI无开屏。实际多Scene／重播／根切换组合未穷举，源码按同一宿主树门禁处理 |
| HOME-04 首页目录视觉 | 两OC/SUI参照Swift：圆角14、卡片左右10／上下8；组17/13、内行17/12、基准行56，动态字号／自然增高与明暗语义色；两OC标题支持多行，代理高度和点按命中阈值同步；稳定Demo ID、拖排／置顶／最近入口不变 | OC收缩页与SwiftUI展开页实际简中浅色实看；SUI副文字改显式Color.primary的72%以消除控件层级继承变浅，最后纯色包另跑1真实用例；完整语言／主题／设备矩阵待验 |

当前代码入口：[DemoListView.swift](<../JobsSwiftUIBaseConfigDemo/DemoListView.swift>)、[AppSettingsView.swift](<../JobsSwiftUIBaseConfigDemo/AppSettingsView.swift>)、[AppPreferences.swift](<../JobsSwiftUIBaseConfigDemo/AppPreferences.swift>)、[DemoFeatureRow.swift](<../JobsSwiftUIBaseConfigDemo/DemoFeatureRow.swift>)。

新增开关实际保存位置已逐App只读核验：App沙盒`Library/Preferences/<bundleID>.plist`核验时对应新键为true，未读取／展示其它偏好；CLI证据在本机任务产物`native-home-settings/preferences-on-disk.json`。UI通过的是正常主应用，没有`--jobs-coverage-route`或新测试探针；仅语言／旧开屏／旧入口／旧浮钟显隐使用临时launch arguments，新增收缩键没有用启动参数覆盖，冷启动读取的是实际落盘值。已恢复测试前该新开关选择；测试没有清空用户排序或最近记录。 这些四App落盘与冷启证据采自原609设备；随后用户授权的其它任务清理了整个设备集，原设备及其沙盒已不存在，历史证据继续保留。Root按原授权重建的A3为全新沙盒，本轮三UIKit最终开屏短验未改新增收缩键，也未用旧数据冒称新设备已保存；四App在A3的当前值均不由旧证据推断。 A3首次启动的Swift及两OC都在系统通知授权框选择了“不允许”（Runner记录Swift8.45秒、新OC6.62秒、旧OC3.71秒）；该测试选择仅属于新设备的通知许可，不能称所有偏好未变。未为恢复未询问状态而卸载或重置App。两OC短验后已恢复现装最终Flutter首页并截图确认，设备明确交还Root。

本工程bundle为`com.jobs.jobsswiftuibaseconfigdemo`，新增键`JobsSwiftUIBaseConfigDemo.collapseOnDemoReturn`。首页完整链33.631秒／1test通过（所在旧两用例批次另一开屏夹具失败，未冒称整批全绿）；最后显式颜色包目录短链11.001秒／1test／0失败；普通arm64构建通过。

失败历史保留：外部Runner首轮误选离屏侧栏同名“设置”，改已有稳定菜单panel／cellID后真实补轮通过；早期Swift开屏夹具查询不存在控件的isHittable会自动等待，恰好跨过5秒开屏结束，已改为skip存在同帧检查clock.exists。末轮五用例批次共5项／0失败（105.043秒）。最后SUI颜色新增短case首Runner编译错误导致一次0tests，明确排除；修正坐标类型、确认非零后11.001秒通过。生产未因夹具修改而放宽门禁或修改开屏时长。



## <span id="jobs-toc-heading-11" data-jobs-toc="v2">Rust OCR 独立 Demo 接线（2026-11-16）</span><!-- jobs-toc:heading-end -->

入口为“系统 UI Demo → Rust OCR 离线识别”，页面位于 `JobsSwiftUIBaseConfigDemo/Demos/RustOCRDemoView.swift`，核心本地 Pod 归 `JobsByPods/JobsRustOCR@Pods`。内置真实样例／选照片、识别／取消、结果与空态重试均已接线；图片和结果仅页面内存，离开取消并忽略过期回调，十语与宿主三主题同步。缺模块明确错误，不冒充识别成功。完整规范 SDK 已装配，原 workspace arm64 模拟器构建成功；专用 iPhone 17 Pro／iOS 27.2 真实样例已识别 35 行、1326 字符，约 603 ms，原图／入口／完成状态截图与 JSON 已保存。另已通过 iPhoneOS ARM64 真机目标编译／链接；无签名导出被既有 Save Build IPA 保护拒绝，总退出码 65，未签名 App 不能直接安装、未在真机运行。完整十语三主题交互及极端字号仍待验。详细入口、行为、默认、生命周期和证据位置见[OCR 接入盘点](./RustOCR接入盘点.md)。

<a id="🔚" href="#前言">返回首页</a>
