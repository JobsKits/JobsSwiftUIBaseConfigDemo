# `ScriptsByPods`

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#jobs-toc-heading-1)
- [一、脚本清单](#jobs-toc-heading-2)
- [二、运行方式](#jobs-toc-heading-3)
- [三、注意事项](#jobs-toc-heading-4)

</details>
<!-- jobs-toc:end -->

---

## <span id="jobs-toc-heading-1" data-jobs-toc="v2">🔥 <font id=前言>前言</font></span><!-- jobs-toc:heading-end -->

`ScriptsByPods` 存放由 [**CocoaPods**](https://cocoapods.org/) 生命周期挂载的辅助脚本。

当前工程业务代码保持纯原生 [**SwiftUI**](https://developer.apple.com/xcode/swiftui/) 演示，Debug 额外集成本地调试 Pod。`Podfile` 在安装前同步准备网络与选择公共 Specs 源，在集成完成后后台生成 `.codegraph` 索引和 Markdown 图谱；所有能力由本工程内脚本包提供。

## <span id="jobs-toc-heading-2" data-jobs-toc="v2">一、脚本清单 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

| 脚本 | 触发方式 | 作用 |
| --- | --- | --- |
| [CocoaPods 网络适配](<./【MacOS】🌐CocoaPods网络适配.command/README.md>) | Podfile 顶部，选源前同步执行 | 实测已有链路 / 已启用代理，本次安装进程及后续源码下载继承相同配置；已核验 AMPopTip 网络失败有官方固定归档回退 |
| [CocoaPods 源自动选择](<./【MacOS】🌐CocoaPods源自动选择.command/README.md>) | Podfile 的 `source` 声明前同步执行 | 测试官方 CDN 与 Git Specs，选择当前可用公共源，保留私有源与锁定版本 |
| `./JobsSwiftUICodeGraphHook/` | `Podfile.deps` | 本地脚本锚点 Pod，让 CocoaPods 完整走 install 生命周期 |
| `./codegraph_init.command/codegraph_init.command` | `Podfile` 的 `post_integrate`，后台执行 | 完整体检工具链、按需安装，初始化 / 同步 `.codegraph/codegraph.db`，并导出 Markdown |
| `./codegraph_export_md.command/codegraph_export_md.command` | `codegraph_init.command` 调用 | 从 `.codegraph/codegraph.db` 导出 `.codegraph/codegraph.md/` |

## <span id="jobs-toc-heading-3" data-jobs-toc="v2">二、运行方式 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

在工程根目录执行：

```shell
pod install
```

`pod install` 成功集成后会用 `/bin/zsh` 启动 CodeGraph 后台任务，传入明确工程根目录、`CODEGRAPH_AUTO_INIT=1` 和 `CODEGRAPH_EXPORT_ASYNC=0`，安装主流程无须等待体检、索引和 Markdown 导出。进度追加到系统临时目录中的 `codegraph_init.<工程摘要>.async.log`，按工程路径隔离；实际位置随安装输出显示。

## <span id="jobs-toc-heading-4" data-jobs-toc="v2">三、注意事项 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

- 业务 Demo 保持原生 SwiftUI；本地 Pod 分别服务脚本挂载与 Debug 调试面板。
- `Podfile.deps` 声明本地 `JobsSwiftUICodeGraphHook` 与仅 Debug 生效的 `JobsSwiftUIDebugPanel`；当前没有远程 AMPopTip 依赖，归档白名单不会因接入脚本而新增依赖。
- 网络与选源仅在真实安装 / 更新时同步探测，查询命令不联网；可选模块缺失或初始化失败告警后继续原流程，实际下载失败仍由 CocoaPods 报告。
- 迁移需保留本工程 Podfile 和两个完整网络脚本包；终端及调用该 Podfile 的其它安装入口自动覆盖，不写全局代理。测试不运行真实安装或构建，相关日志和环境开关见两个包的 README。
- CodeGraph 会完整检查系统 Shell / curl / Git / CLT、[**Homebrew**](https://brew.sh/) 的版本 / 配置 / doctor、Node.js 实际执行及 npm 配置、SQLite 内存查询、CLI 子命令与隔离样例建图，再核对目标状态 JSON 的工程路径与完整性。体检只读入口为 `./codegraph_init.command/codegraph_init.command --check-only`，不安装、不建图、不导出。
- Homebrew 没有该官方 [**CodeGraph**](https://github.com/colbymchenry/codegraph) 对应 formula；缺失或损坏的 Node/npm 优先由 Brew 的 `node@24` 补齐，再将官方 npm 包 `@colbymchenry/codegraph` 安装到用户独立前缀。安装前显示来源，已有健康 CLI 直接复用，不自动升级。
- `JOBS_SKIP_CODEGRAPH=1` 跳过地图；`JOBS_POD_INSTALL_OFFLINE=1` 或 `CODEGRAPH_ALLOW_INSTALL=0` 禁止工具安装，健康工具仍可更新地图。`JOBS_POD_INSTALL_POST_SCRIPTS_CHECK_ONLY=1` 让后台任务只体检；这些开关不保证 CocoaPods 自身完全离线。
- 调度日志中的 PID 只供观察，重复任务由 `.codegraph/.jobs-update.lock` 工程锁处理。工具安装、体检、索引或导出失败只写后台日志，不阻断已经完成的 CocoaPods 安装。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
