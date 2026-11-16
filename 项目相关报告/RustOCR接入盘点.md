# SwiftUI Rust OCR Demo 接入

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#%E5%89%8D%E8%A8%80)
- [一、入口与行为](#entry)
- [二、SDK 装配合同](#sdk)
- [三、验证状态](#verification)
- [四、源码交付与本地编译](#source-delivery)
- [五、拍照输入与整页操作](#capture-page-20261116)

</details>
<!-- jobs-toc:end -->

---

## 🔥 <span id="前言">前言</span>

核查日期：2026-11-16。本页登记共享 Rust OCR SDK 的宿主接线与验收状态。原有其它 Demo、首页交互和未提交修改继续保留。

## 一、<span id="entry">入口与行为</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

| 资产 | 当前接线 |
| --- | --- |
| 入口 | 系统 UI Demo → Rust OCR 离线识别 |
| 页面源码 | `../JobsSwiftUIBaseConfigDemo/Demos/RustOCRDemoView.swift` |
| 核心归属 | `JobsByPods/JobsRustOCR@Pods`，共享 Rust 核心的 Apple 封装 |
| 输入 | 包内真实样例、相册照片、设备真实相机拍照；权限与真机验收见本批记录 |
| 操作 | 开始离线识别；运行中改为取消；空态可重新加载 |
| 输出 | 真实识别文本、耗时和核心版本；整页滚动、文本选择及快捷复制 |
| 默认 | 内置样例；默认不自动运行、不联网 |
| 持久化 | 图片与结果只保存在页面内存，不写相册或用户数据库 |
| 生命周期 | 离开页面／退后台取消；请求代际门禁丢弃取消后或过期回调；相机权限回调只呈现仍可见页面 |
| 语言与主题 | 跟随宿主十语言与白天／黑夜／跟随系统选择，运行状态和空态同步翻译 |
| 缺少 SDK | 明确显示“OCR 核心尚未安装”，不生成模拟成功结果 |

## 二、<span id="sdk">SDK 装配合同</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

- `Podfile.deps` 在本地 podspec 和 XCFramework 都存在时注册 `JobsRustOCR`；宿主适配器通过 `canImport` 判断真实模块。完整包安装后自动调用原生封装，不需要切换演示模式。
- SDK 接口为 `coreVersion()`、`sampleImage()`、`image(from:)`、`recognize(image:completion:)` 与 `cancel()`，资源位于 `JobsRustOCRResources.bundle`。识别完成回调由 SDK 送回主队列。
- `JobsOCRSDKAdapter` 只负责模块可用性和跨语言调用，不实现另一套识别算法。不能将模块缺失、资源缺失或推理错误视为成功。
- 图片和模型均在设备本地处理，此 Demo 不走网络 API。识别依赖模型权重的字符范围和能力，不能将界面十语支持等同所有文字都可识别。

## 三、<span id="verification">验证状态</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

| 项目 | 状态 |
| --- | --- |
| Demo 源码与目录入口 | 已实现 |
| 缺模块适配器 | 已通过独立模拟器 SDK 类型检查；缺模块明确错误 |
| 十语词条、字符串格式、依赖声明 | 已静态检查 |
| 原生 SDK 复制与 CocoaPods 装配 | 已 APFS clone 完整规范包；纯 pod install 成功，3 个本地 Pod |
| 主工程构建 | 原 workspace Debug arm64 模拟器构建成功 |
| iOS 模拟器真实识别 | 专用 iPhone 17 Pro / iOS 27.2 已验：35 行、1326 字符、约 603 ms；真实 JSON 和页面截图已保存 |
| iOS ARM64 真机目标编译／链接 | 已通过：iPhoneOS ARM64 Mach-O 含真实 Rust／ORT 符号；workspace 最后 Save Build IPA 阶段因无签名主动拒绝，总退出码 65 |
| iOS 真机真实识别 | 待验：当前真机不可用，不以模拟器代替 |
| 十语三主题实屏与极端字号 | 待验 |

自动验收可在正常 App 构建后用 `--jobs-coverage-route rustOCR --jobs-ocr-auto --jobs-ocr-output ocr-probe.json` 进入该页面并触发内置样例的真实推理。显式给出相对输出文件名时，JSON 保存到 App 沙盒 Documents；也支持调用方明确指定的绝对路径。正常使用不保存结果文件。该参数不替换模型或识别结果；应核对 JSON 的 `ok`、真实文本、文字行和核心版本，而非只看进程启动。

实际证据位于 OCR 仓库 `测试/报告与证据/iOS/SwiftUI`；可安装 App 冻结在 `交付/iOS/SwiftUI`。截图已实看，内置原图、操作入口、完成状态和核心版本可见；识别文本位于下方可滚动区域，JSON 已核对真实文本与 35 个原图坐标行框。本次未把完整主题语言交互、文字框叠加或真机运行标记为通过。

无签名真机目标 App 另存于 OCR `交付/iOS/SwiftUI-Device`，不能直接安装、未在真机运行。链接命令、Mach-O 的 `platform IOS / minos 17.0`、Rust／ORT 符号、产物 SHA 及完整退出码 65 日志在 `测试/报告与证据/iOS/SwiftUI-Device`。没有修改或绕过宿主既有的 IPA 签名保护，不能把编译／链接成功写成完整工作区打包通过。

## 四、<span id="source-delivery">源码交付与本地编译</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

2026-11-16 用户确认五个 Demo 全部交付自有源码；此前预编译包构建和设备结果保留为历史批次证据。当前交付改造先登记、后分发和验证。

| 资产 | 当前合同 | 默认／持久化／生命周期与验证 |
| --- | --- | --- |
| 自有核心源码 | SDK 的 `Source/JobsOCR` 包含 Cargo 清单、锁文件、src、C接口、测试与许可 | 不依赖开发机外部OCR目录；源码可直接研究修改；六SDK的21份Source／Scripts／忽略规则逐字节同源，自检与Cargo.lock可见性已验 |
| 构建入口 | [BuildRustOCR.command](<../JobsByPods/JobsRustOCR@Pods/Scripts/BuildRustOCR.command>)；[参数及依赖](<../JobsByPods/JobsRustOCR@Pods/Scripts/README.md>) | 先手动运行再执行原有pod install／构建；CI显式--non-interactive；源码变化后重新执行 |
| 本地产物 | `Frameworks/JobsOCRCore.xcframework` 的.a与 `.build-rust-ocr/` 缓存 | Git忽略；当前暂存中的自建.a精确移除并保留本地文件；不擅自重写历史 |
| 第三方与模型 | 锁定官方ONNX Runtime 1.24.2 ZIP并核对SHA；原模型／许可继续随资源bundle分发 | 自有Rust本地编译与第三方官方依赖下载分别声明；首次构建可能联网，准备完可显式离线 |
| 运行行为 | 既有入口、手动识别、取消、真实结果、错误重试、十语三主题 | 默认值、偏好和生命周期沿原合同，不新增假识别回退；本批实际构建及运行另记 |
| GitHub验收 | 五个Demo分别核对本批实际提交与全部必需workflow | 本地检查、远端运行和旧证据分别记账；未完成前不写通过 |

从本项目根目录构建核心：

```shell
/bin/zsh "JobsByPods/JobsRustOCR@Pods/Scripts/BuildRustOCR.command" --yes
```

本批源码验证：共享包与Flutter iOS SDK副本均已实际用Rust1.95.0完成五Apple目标编译、组合XCFramework及原库保留；六SDK源码／脚本同源检查、自检、Cargo.lock不会被OC的*.lock误忽略、Git索引无自建.a均通过。21项核心测试与7组失败／迁移检查见共享OCR的源码交付报告；其它宿主本批UI改造后的构建及远端Workflow仍须各自验收，不外推上述构建。


## 五、<span id="capture-page-20261116">拍照输入与整页操作</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

2026-11-16 用户确认本批改造；先登记，实际实现和验证分开回填。

| 资产 | 本批合同 | 默认／持久化／生命周期／当前状态 |
| --- | --- | --- |
| 输入操作 | 原图预览下提供样本、相册、真实相机拍照 | 默认内置样本；取消或拒绝保留既有图片和结果；不保存相册；样本／系统相机呈现与取消已验，相册和实体拍照另验 |
| 整页浏览 | 单一外层纵向滚动，结果自适应撑高并支持选中文字 | 结果区没有独立滚动；不新增持久偏好；长结果实际整页滑动已验 |
| 识别主动作 | 44–48pt紧凑开始／取消；结果标题旁快捷复制 | 识别期间禁止替换输入；主动作宽度小于屏幕85%、高至少44pt；真实复制与结果逐字一致；运行中取消竞争另验 |
| 外观与语言 | 白天操作底色和文字清晰成对，宿主十语与三主题 | OCR页唯一主题菜单直接绑定宿主appearance；不另建偏好；中文白天／黑夜／跟随系统真实切换已验，其余九语／大字另验 |
| 相机边界 | 可用性和权限检查，使用真实camera sourceType | 按真实camera可用性呈现系统照片相机；本模拟器可打开，取消后原图与结果保持；权限拒绝及实体拍摄另验 |

SwiftUI：真实 iOS 27.2 Simulator SDK 独立 view＋model 类型检查通过，随后原 workspace 的 Debug arm64 Simulator 完整构建 exit 0，包含真实三本地 Pod、相机桥接与十语 InfoPlist 权限资源；本批 App 已在专用 iOS 27.2 模拟器安装并运行。日志 `/tmp/jobs-ocr-swiftui-build.log`，本批可安装产物 `/tmp/jobs-ocr-swiftui-ui-dd/Build/Products/Debug-iphonesimulator/JobsSwiftUIBaseConfigDemo.app` 仅为本机验收定位，不是运行依赖。

配色：实际 UIKit trait 解析＋WCAG 亮度计算，输入／复制按钮白天黑字＋`#E5E5EA` 为16.727:1、黑夜白字＋`#2C2C2E` 为13.937:1；主动作白字＋`#1565C0` 两主题均5.746:1。SwiftUI状态文字白天0.33灰／系统分组底为6.770:1、黑夜0.78灰／黑底为12.410:1。UIKit title transformer 与 SwiftUI ButtonStyle 明确保留禁用文字前景，不依赖默认变淡；中文白天／黑夜实屏及空结果禁用复制按钮已查看，文字与操作底色清晰；其余组合状态不从颜色计算外推。

本批有限实屏验证：显式coverage路由 `rustOCR` 进入真实页面后手动点击识别，1项／零失败／33.238秒；JSON为真实Rust引擎、35行／1326字符，真实剪贴板与text逐字相同。通过唯一主题菜单依次选择白天、黑夜、跟随系统，结果不丢失；整个页面随长结果滑动；真实系统照片相机已呈现并取消，原图与结果保持。七张PNG已导出并实际查看；[浅深截图索引](./RustOCR页面验证/README.md)。iOS27.2此模拟器确有可用camera UI，不将“模拟器”硬编码为不可用。

仍待：其它九语／窄屏／大字完整实屏矩阵、相册选择、拒绝或受限权限分支、运行中取消竞争与实体设备拍照；不会以系统相机界面打开或模拟器结果冒充实体拍摄成功。


<a id="🔚" href="#前言">返回前言</a>
