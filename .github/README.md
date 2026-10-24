# SwiftUI 持续集成

[**GitHub Actions**](https://docs.github.com/actions) 的 [Build Simulator App](./workflows/build_simulator_app.yml) 对 `main`、`codex/**` 推送和 Pull Request 自动运行，也可从 Actions 页面手动触发当前分支。

| 阶段 | 检查与产物 |
| --- | --- |
| 环境 | `xcode-27` runner，明确选择 Xcode 27.1，拒绝低于 iOS 27.1 的 Simulator SDK |
| 依赖 | Ruby 3.3、CocoaPods 1.17.0，按已提交锁文件执行 `pod install --deployment --no-repo-update`；不运行 CodeGraph 后台索引 |
| 构建 | 独立执行 Debug、Release 的完整 arm64 Simulator App 构建，保留原工程 Build Phases，不要求签名 |
| 产物 | 核对 Bundle ID、实际可执行文件、Simulator 平台和 SDK 后，上传完整 `.app` ZIP |
| 证据 | 依赖安装日志、构建日志、xcresult 与平台检查输出；失败也保留已生成的证据，保存 7 天 |

没有 XCTest / UI Test target，因此工作流不伪造测试步骤。构建通过只表示对应提交的两种配置可编译；Duo 的折叠姿态、分屏、安全区换边和浮钮交互仍需可用的模拟器或真机验收。任一构建或产物检查失败会保留失败结果。

原工程自动打包脚本会替换当前检出目录的 `build/`。runner 每次使用新的检出目录；本机复现应在独立副本中执行，DerivedData 与日志放在副本 `build/` 之外。发布到远端前，新增工作流不代表 GitHub 已运行或通过。
