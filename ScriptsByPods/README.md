# `ScriptsByPods`

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id=前言>前言</font>

`ScriptsByPods` 存放由 [**CocoaPods**](https://cocoapods.org/) 生命周期挂载的辅助脚本。

当前工程业务代码仍然保持纯原生 [**SwiftUI**](https://developer.apple.com/xcode/swiftui/) 演示，不声明任何业务 Pod 依赖；`Podfile` 的作用是复用兄弟工程的 `pod install` 收尾能力，在集成完成后后台生成 `.codegraph` 索引和 Markdown 图谱。

## 一、脚本清单 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 脚本 | 触发方式 | 作用 |
| --- | --- | --- |
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

- 这里的 Pod 介入只服务脚本挂载，不代表 SwiftUI Demo 业务层依赖 Pod。
- `Podfile.deps` 当前只挂载 `JobsSwiftUICodeGraphHook`，后续如需临时验证 Pod，可集中写在该文件里。
- CodeGraph 脚本会自动检查 `Homebrew`、`npm` 和 `codegraph` 命令；缺失时按脚本逻辑处理。
- 如果上一次 CodeGraph 后台任务仍在运行，`pod install` 不会重复启动第二个任务。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
