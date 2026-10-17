# `ScriptsByPods`

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id=前言>前言</font>

`ScriptsByPods` 存放由 [**CocoaPods**](https://cocoapods.org/) 生命周期挂载的辅助脚本。

当前工程业务代码保持纯原生 [**SwiftUI**](https://developer.apple.com/xcode/swiftui/) 演示，Debug 额外集成本地调试 Pod。`Podfile` 在安装前同步准备网络与选择公共 Specs 源，在集成完成后后台生成 `.codegraph` 索引和 Markdown 图谱；所有能力由本工程内脚本包提供。

## 一、脚本清单 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 脚本 | 触发方式 | 作用 |
| --- | --- | --- |
| [CocoaPods 网络适配](<./【MacOS】🌐CocoaPods网络适配.command/README.md>) | Podfile 顶部，选源前同步执行 | 实测已有链路 / 已启用代理，本次安装进程及后续源码下载继承相同配置；已核验 AMPopTip 网络失败有官方固定归档回退 |
| [CocoaPods 源自动选择](<./【MacOS】🌐CocoaPods源自动选择.command/README.md>) | Podfile 的 `source` 声明前同步执行 | 测试官方 CDN 与 Git Specs，选择当前可用公共源，保留私有源与锁定版本 |
| `./JobsSwiftUICodeGraphHook/` | `Podfile.deps` | 本地脚本锚点 Pod，让 CocoaPods 完整走 install 生命周期 |
| `./codegraph_init.command/codegraph_init.command` | `Podfile` 的 `post_integrate` | 初始化 / 同步 `.codegraph/codegraph.db`，并调度 Markdown 导出 |
| `./codegraph_export_md.command/codegraph_export_md.command` | `codegraph_init.command` 调用 | 从 `.codegraph/codegraph.db` 导出 `.codegraph/codegraph.md/` |

## 二、运行方式 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

在工程根目录执行：

```shell
pod install
```

`pod install` 完成后会启动 CodeGraph 后台任务，并直接返回主流程；索引和 Markdown 导出进度写入系统临时目录中的 `codegraph_init.async.log`。

## 三、注意事项 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 业务 Demo 保持原生 SwiftUI；本地 Pod 分别服务脚本挂载与 Debug 调试面板。
- `Podfile.deps` 声明本地 `JobsSwiftUICodeGraphHook` 与仅 Debug 生效的 `JobsSwiftUIDebugPanel`；当前没有远程 AMPopTip 依赖，归档白名单不会因接入脚本而新增依赖。
- 网络与选源仅在真实安装 / 更新时同步探测，查询命令不联网；可选模块缺失或初始化失败告警后继续原流程，实际下载失败仍由 CocoaPods 报告。
- 迁移需保留本工程 Podfile 和两个完整网络脚本包；终端及调用该 Podfile 的其它安装入口自动覆盖，不写全局代理。测试不运行真实安装或构建，相关日志和环境开关见两个包的 README。
- CodeGraph 脚本会自动检查 `Homebrew`、`npm` 和 `codegraph` 命令；缺失时按脚本逻辑处理。
- 如果上一次 CodeGraph 后台任务仍在运行，`pod install` 不会重复启动第二个任务。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
