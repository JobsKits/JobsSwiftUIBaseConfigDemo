# <span id="前言">SwiftUI 主工程隔离测试</span>

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [一、最近使用存储](#recent-history)
- [二、Core Data 真实 SQLite](#coredata-store)
- [三、世界时钟与浮钟边界](#world-clock-tests)

</details>
<!-- jobs-toc:end -->

---

## 一、<span id="recent-history">最近使用存储</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

[DemoRecentHistoryTests.swift](./DemoRecentHistoryTests.swift)直接测试[实际模型源码](../JobsSwiftUIBaseConfigDemo/DemoRecentHistory.swift)，共13项断言，覆盖持久恢复、前插去重、容量30、失效ID过滤、跨实例合并和损坏偏好。测试创建独立 `UserDefaults` suite，退出删除自己的测试域，不改变用户记录。

从仓库根目录，将两份源码传给 `swiftc`，用 `-o` 指定仓外临时可执行文件，再运行该产物即可。测试不启动 App、不依赖 iOS Simulator，不代表页面导航或冷启动UI已验收；实际状态见[资产盘点](../项目相关报告/App骨架功能盘点.md)。

## 二、<span id="coredata-store">Core Data 真实 SQLite</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

[CoreDataDemoStoreTests.swift](./CoreDataDemoStoreTests.swift)与实际 [Store](../JobsSwiftUIBaseConfigDemo/Persistence/CoreDataDemoStore.swift)／[Record](../JobsSwiftUIBaseConfigDemo/Persistence/CoreDataDemoRecord.swift) 一起编译，传入由 `xcrun momc` 编译的 `.momd` 路径。21 项断言覆盖默认空、标题验证、完整 CRUD、独立容器及独立进程的记录与字段恢复、物理 SQLite、错误数据不写入、缺模型与目录失败后重试。测试只使用随机临时目录并清理自己的产物，不访问 App 数据。

从工程根先用 `xcrun momc JobsSwiftUIBaseConfigDemo/Resources/JobsSwiftUIBaseConfigDemo.xcdatamodeld <临时目录>/JobsSwiftUIBaseConfigDemo.momd` 编译模型，再将三份 Swift 源码交给 `swiftc`，运行产物时传入上述 `.momd` 路径。此测试验证 macOS 的实际 Core Data 存储层与独立进程恢复；iOS App 入包、界面点击与冷启动读取展示单列于[核查报告](../项目相关报告/CoreData使用核查.md#verification)。

## 三、<span id="world-clock-tests">世界时钟与浮钟边界</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

[WorldClockTests.swift](./WorldClockTests.swift)直接与 [WorldClockCatalog](../JobsSwiftUIBaseConfigDemo/WorldClockCatalog.swift)、[JobsSwiftUIClock](../JobsSwiftUIBaseConfigDemo/JobsSwiftUIClock.swift)、[FloatingClockGeometry](../JobsSwiftUIBaseConfigDemo/FloatingClockGeometry.swift) 一起用 `swiftc` 编译为仓外可执行文件。测试实际系统时区、ICU格式与主RunLoop的Combine计时，不用伪造时钟实现替代生产代码。当前90项断言覆盖冬夏偏移全量／去重、UTC−12补齐、巴黎纽约夏令时跳变、30／45分钟、当地跨日星期、十语城市、12／24小时午夜正午边界、不同可用区域的四边保位、真实启停与时区通知。后续时区数据库变更应以同一瞬间的系统规则为准，不固定代表数量。

此测试不运行SwiftUI手势或画面，不把几何算法断言视为设备字号、主题和拖动验收；当前构建与UI验证见[骨架盘点](../项目相关报告/App骨架功能盘点.md#world-clock-requirement)。

<a id="🔚" href="#前言">返回首页</a>
