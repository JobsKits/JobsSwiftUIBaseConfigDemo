# [**SwiftUI**](https://developer.apple.com/xcode/swiftui/) 相关经验

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id="前言">前言</font>

> 面向已有 [**UIKit**](https://developer.apple.com/documentation/uikit) 基础的 SwiftUI 开发笔记。按状态归属、视图身份、布局、任务生命周期和框架互操作组织正文；面试问答集中在文章末尾。

语言机制在 [**Swift 相关经验**](/Users/jobs/Documents/Github/JobsBaseConfig/JobsBaseConfig@JobsSwiftBaseConfigDemo/SwiftDoc.md/Swift相关经验.md/Swift相关经验.md) 维护；本页集中说明 SwiftUI 的使用方式与生产边界。

- 语法部分：**它是什么 → UIKit 类比 → Demo → 运行效果 → 推荐场景 / 边界**。
- 面试部分：<a href="#faq" style="color:red;font-weight:bold;">末尾 FAQ</a>统一使用**问题 → 期望回答 → 追问与答案**。所有追问都附答案。
- 快速查阅：<a href="#decision" style="color:red;font-weight:bold;">第二十章选型表</a>；第一次练习：<a href="#first-demo" style="color:red;font-weight:bold;">第三章计数器</a>；综合练习：<a href="#todo-demo" style="color:red;font-weight:bold;">第十九章待办清单</a>。

## 一、<font id="ui-section-1">使用与运行边界</font>

### 1、<font id="ui-1-1">Swift、SwiftUI 与 UIKit 的关系</font>

[**Swift**](https://www.swift.org/) 是语言；SwiftUI 和 UIKit 是 UI 框架。[**Objective-C**](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html) 也是语言，不是另一套 UI 框架。

使用 Swift 描述 SwiftUI 界面，或使用 Swift / Objective-C 操作 UIKit；语言和 UI 框架分开选择。

SwiftUI 的泛型 View 不能直接当作 OC 类使用。OC 工程接入时，通常由 Swift 层创建 Hosting Controller，再通过 OC 可见的控制器接口交回旧工程，使用 <a href="#ui-17-6" style="color:red;font-weight:bold;">控制器桥接入口</a>。

### 2、<font id="ui-1-2">本文版本基线</font>

整理日期：**2026-08-31**。

主线采用 **iOS 17+、Swift 6 语言模式、Xcode 26 系列可用写法**；兼容章节再说明旧版本。这里的 iOS 17 是教程最低运行基线，不是“当前最新系统”。本机核对环境为 Xcode 26.6、Apple Swift 6.3.3、iPhone Simulator SDK 26.5。

| 能力 | 常见最低 iOS 版本 | 本文处理方式 |
| --- | --- | --- |
| SwiftUI、<font color="red"><b><code>@State</code></b></font>、<font color="red"><b><code>@Binding</code></b></font>、Hosting / Representable | 13 | 基础概念仍适用 |
| SwiftUI `App` 生命周期、<font color="red"><b><code>@StateObject</code></b></font>、<font color="red"><b><code>@AppStorage</code></b></font>、<font color="red"><b><code>@SceneStorage</code></b></font>、Lazy 容器 | 14 | 老项目必须能读懂 |
| `.task`、`.refreshable`、`.searchable`、<font color="red"><b><code>@FocusState</code></b></font>、`dismiss` | 15 | 常用交互与任务 |
| `NavigationStack`、`NavigationSplitView`、`Grid`、`Layout`、`UIHostingConfiguration` | 16 | 导航、布局和混用 |
| Observation 集成、<font color="red"><b><code>@Observable</code></b></font> 配合 SwiftUI、<font color="red"><b><code>@Bindable</code></b></font>、按类型注入模型 | 17 | 新页面状态管理主线 |
| 本文的双参数 <font color="red"><b><code>.onChange(of:) { old, new in }</code></b></font> | 17 | 不和旧单参数重载混写 |

<font color="red"><b><code>#Preview</code></b></font> 是工具链宏，不能只用“手机系统版本”判断是否可用；预览目标和所用 API 的部署要求仍要检查。本文直接以 iOS 17+ 练习，减少兼容干扰。

**版本边界：**本文固定使用 Xcode 26 SDK 中的 State 属性包装器与 ViewBuilder 结果构建器。升级 SDK 后按实际声明核对变化，不将新工具链特性混入当前基线。

### 3、<font id="ui-1-3">示例使用步骤</font>

1、在 [**Xcode**](https://developer.apple.com/xcode) 新建 iOS App，Interface 选 SwiftUI，最低部署版本设为 iOS 17 或以上。

2、每段 `Dxx` 是一个教学单元。复制这一段涉及的类型；若注明依赖前面的模型，也一并复制。没有外部账号、图片或第三方库要求。

3、把默认 App 的 `WindowGroup` 内容替换为对应根视图，例如 `CounterDemo()`。文中只给一个 <font color="red"><b><code>@main</code></b></font>；不要把它和模板 App 的 <font color="red"><b><code>@main</code></b></font> 同时保留。

4、示例为便于阅读，把互相配合的短类型放在同一个代码块。真正落入 Jobs 工程时，按职责拆文件，补标准文件头，并对接既有封装。**本文原生 API 是教学材料，不是要求重构既有 UIKit 工程。**

5、标为“片段”的函数需要由宿主调用；定义能通过类型检查，不代表已真实执行网络、导航、动画或设备权限流程。验证范围见第二十一章。

## 二、<font id="ui-section-2">从操作控件转向描述状态</font>

### 1、<font id="ui-2-1">从“操作控件”变成“描述状态对应的界面”</font>

UIKit 中通常持有 Label，在事件中更新数据，再给 Label 赋值。SwiftUI 中，先声明数据和界面的对应关系，事件只修改状态。

```text
UIKit 常见思路：点击 → 修改 count → 手动设置 label.text
SwiftUI 思路：  点击 → 修改 count → SwiftUI 重新求值相关界面描述 → 更新需要变化的部分
```

这里说的是框架主导方式。UIKit 也可以使用响应式绑定，SwiftUI 也有命令式事件处理；不是两者完全互斥。

**先确定 Text 依赖的状态，再通过修改状态更新内容。**

<a href="#ui-faq-1" style="color:red;font-weight:bold;">FAQ 1</a>

### 2、<font id="ui-2-2">UIKit 概念迁移速查</font>

| UIKit 里熟悉的东西 | SwiftUI 的常见对应 | 不能机械等同的地方 |
| --- | --- | --- |
| `UIView` 子类 | <font color="red"><b><code>struct ...: View</code></b></font> | View 值不是长期持有的 UIView 实例 |
| `UIViewController` 页面 | 一个或多个 View + 状态模型 | 并没有强制一页一个控制器 |
| `UILabel` | `Text` | 修改输入数据，不给 Text 实例赋 text |
| `UIButton` + Target-Action / Block | `Button` + action 闭包 | 样式和事件分开表达 |
| `UITextField` | `TextField` + `Binding<String>` | 文本通过绑定读写 |
| `UIStackView` | `HStack` / `VStack` | 不是同一个布局引擎 |
| `UITableView` | `List` | 不需要自己写 DataSource / Cell 复用回调 |
| `UICollectionView` | `List`、Lazy Grid，必要时桥接 UIKit | 并非所有复杂集合布局都能直接一比一替换 |
| `UINavigationController` | `NavigationStack` | SwiftUI 路径存的是路由数据，不是控制器数组 |
| `present` | `.sheet` / `.fullScreenCover` | 展示由状态驱动 |
| Delegate / 回调 Block | 闭包 / Binding / 模型方法 | “发生事件”和“修改值”要区分 |
| 手动 `reloadData()` | 更新受观察的数据 | 不是每改一个值就保证只绘制一个像素区域 |
| KVO / 通知订阅 | Observation 或 ObservableObject | 机制不同，不是 Runtime KVO 的别名 |

### 3、<font id="ui-2-3">视图描述、身份与资源</font>

**View 结构体是轻量的界面描述。** 使用值语义组合和重新计算描述；持久状态由框架关联到视图身份。结构体并非必然不可变或一定在栈上，也不保证比类更快。可观察模型仍可使用引用类型。

- **View 值**：例如新构造的 `CounterDemo()`，轻量描述，可以反复产生。
- **View 身份**：SwiftUI 判断“前后是不是同一个逻辑位置 / 数据项”的依据。
- **实际呈现资源**：框架管理的布局、渲染和平台资源，不能假定每个 View 都对应一个 UIView。

因此：`body` 再计算 ≠ `UIView` 全部销毁重建 ≠ 屏幕全部重画。身份、状态存储和更新依赖要分别讨论。[Apple：Demystify SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10022/)。

<a href="#ui-faq-2" style="color:red;font-weight:bold;">FAQ 2</a>

## 三、<font id="first-demo">基本语法与首个页面</font>

### 1、<font id="ui-3-1">D01：计数器</font>

```swift
import SwiftUI

struct CounterDemo: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("点击了 \(count) 次")
                .font(.title2)
            Button("加一") {
                count += 1
            }
            Button("清零") {
                count = 0
            }
        }
        .padding()
    }
}
```

**效果：**点击“加一”数字变化，点击“清零”恢复 0；没有手动刷新 Label。

| 语法 | 人话解释 | UIKit 开发者容易误会的点 |
| --- | --- | --- |
| <font color="red"><b><code>struct CounterDemo</code></b></font> | 定义一个值类型 | 不继承 UIViewController |
| `: View` | 遵循 View 协议 | 冒号这里是协议遵循，不是类继承 |
| <font color="red"><b><code>@State</code></b></font> | 把状态交给 SwiftUI 管理 | 不是普通实例变量的别名 |
| <font color="red"><b><code>private</code></b></font> | 状态归当前组件内部管理 | 外部不该随便改初始存储 |
| <font color="red"><b><code>var body</code></b></font> | 一个计算属性 | 不是保存子视图数组的字段 |
| <font color="red"><b><code>some View</code></b></font> | 返回某个确定但隐藏具体名字的 View 类型 | 不是“任何类型都能随便返回” |
| `VStack(spacing: 16)` | 竖排内容，间隔 16 point | 闭包里写的是子内容 |
| `Text("...\(count)...")` | 字符串插值后展示 | `\(...)` 是 Swift 语法 |
| `.font(.title2)` | 生成带字体效果的视图描述 | 不等于修改某个 UILabel.font |
| `Button("加一") { ... }` | 点击时执行闭包 | 这里的闭包是事件，不是布局 |

**推荐：**先用这段建立状态驱动直觉。**边界：**不要在 `body` 中直接执行 `count += 1`，否则描述界面本身又改变界面依赖，可能造成更新循环。

<a href="#ui-faq-3" style="color:red;font-weight:bold;">FAQ 3</a>

### 2、<font id="ui-3-2">D02：App、Scene、View 三层</font>

```swift
import SwiftUI

@main
struct SwiftUIExperienceApp: App {
    var body: some Scene {
        WindowGroup {
            CounterDemo()
        }
    }
}

#Preview {
    CounterDemo()
}
```

<font color="red"><b><code>@main</code></b></font> 指定程序入口；`App.body` 返回 Scene；`WindowGroup` 描述窗口内容；窗口中放 View。**App 的 body 是 <font color="red"><b><code>some Scene</code></b></font>，页面的 body 才是 <font color="red"><b><code>some View</code></b></font>。**

已有 UIKit App 不需要改入口才能使用 SwiftUI，直接嵌入 Hosting Controller 即可。不要为了新增一页把 AppDelegate、SceneDelegate 全部改掉。

### 3、<font id="ui-3-3"><font color="red"><b><code>some View</code></b></font>、<font color="red"><b><code>any View</code></b></font> 与 `AnyView`</font>

| 写法 | 解决的问题 | 选择建议 |
| --- | --- | --- |
| <font color="red"><b><code>some View</code></b></font> | 隐藏一个确定的具体返回类型，保留类型身份 | 普通 `body`、视图片段优先 |
| `Content: View` | 由调用方决定具体类型 | 通用容器 / 组件优先 |
| <font color="red"><b><code>any View</code></b></font> | 协议存在类型，可以装不同遵循者 | 不可直接当作普通 `body` 返回类型的替代品 |
| `AnyView` | SwiftUI 提供的类型擦除包装，本身遵循 View | 真正需要运行时异构存储时再考虑 |

普通函数返回 <font color="red"><b><code>some View</code></b></font> 时，所有返回路径必须满足同一个底层类型。泛型情形是在每组泛型实参下保持该规则。[Swift：Opaque and Boxed Protocol Types](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/opaquetypes/)。

<font color="red"><b><code>any View</code></b></font> 并不意味着它在任何需要具体 `View` 的泛型位置都能直接使用；编译器有存在类型打开能力，但不能据此把 <font color="red"><b><code>var body: any View</code></b></font> 当成通用解法。

<a href="#ui-faq-4" style="color:red;font-weight:bold;">FAQ 4</a> · <a href="#ui-faq-6" style="color:red;font-weight:bold;">FAQ 6</a>

### 4、<font id="ui-3-4">D03：<font color="red"><b><code>@ViewBuilder</code></b></font> 组合分支</font>

```swift
import SwiftUI

struct BuilderDemo: View {
    let isLoading: Bool

    @ViewBuilder
    private var content: some View {
        if isLoading {
            ProgressView("加载中")
        } else {
            Text("准备好了")
        }
    }

    var body: some View {
        VStack {
            Text("页面状态")
            content
        }
    }
}
```

**效果：**用 <font color="red"><b><code>BuilderDemo(isLoading: true)</code></b></font> 显示进度指示；传 <font color="red"><b><code>false</code></b></font> 显示文字。

<font color="red"><b><code>@ViewBuilder</code></b></font> 会把这些表达式和条件分支转成一个组合结果类型，不是让 <font color="red"><b><code>some View</code></b></font> 放弃“确定类型”的规则。当前主线中，`View.body` 本身具有构建器语义，所以通常不用再给 `body` 写一次 <font color="red"><b><code>@ViewBuilder</code></b></font>；普通自定义辅助属性不应盲目假设也自动拥有它。

**边界：**构建器不是任意命令执行区。不要往里面直接放返回 `Void` 的打印、请求或赋值；需要调试可在 `.onAppear` 等事件位置做，列表内容用 `ForEach`，不是随便写一个命令式 <font color="red"><b><code>for</code></b></font> 循环。

<a href="#ui-faq-5" style="color:red;font-weight:bold;">FAQ 5</a>

### 5、<font id="ui-3-5">D04：尾随闭包、绑定投影与 KeyPath</font>

```swift
import SwiftUI

struct ClosureDemo: View {
    @State private var name = "Jobs"

    var body: some View {
        VStack {
            TextField("姓名", text: $name)
            Button {
                name = "新名字"
            } label: {
                Text("改名")
                    .font(.headline)
            }
        }
        .padding()
    }
}
```

**效果：**输入框与 `name` 双向同步，按钮点击改名。

- `Button { ... } label: { ... }`：前一个闭包执行动作；`label` 闭包构建按钮内容。
- `$name`：这里是 `State` 的投影 `Binding<String>`，不是取内存地址，也不是复制字符串。
- `$0`：另一个语法，表示闭包第一个匿名参数，和 `$name` 的投影不是一回事。
- `\.name`：Key Path，表示“从某个类型取 name 属性的路径”，不是马上读取一个实例。
- `.title2`：编译器已知道目标类型后的简写，不是动态查找字符串。
- <font color="red"><b><code>@State</code></b></font>、<font color="red"><b><code>@Binding</code></b></font> 是本基线下的属性包装器；<font color="red"><b><code>@Observable</code></b></font> 是宏；<font color="red"><b><code>@MainActor</code></b></font> 是隔离标记。**有 `@` 不代表同一种机制。**

## 四、<font id="ui-section-4">Modifier：组合外观与行为</font>

### 1、<font id="ui-4-1">D05：顺序不同，背景范围不同</font>

```swift
import SwiftUI

struct ModifierOrderDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("先留白，再加背景")
                .padding(16)
                .background(.blue.opacity(0.2))

            Text("先加背景，再留白")
                .background(.blue.opacity(0.2))
                .padding(16)
        }
    }
}
```

**效果：**第一段背景覆盖文字和留白；第二段背景主要覆盖文字区域，外层留白没有同样的背景。

可以把 modifier 理解成在前面的视图描述外继续组合一层行为或布局；不是给同一个对象连续写属性。Jobs UIKit DSL 常返回同一个主对象，SwiftUI modifier 通常生成新的组合描述，**链式外观相似，底层语义不同**。

<a href="#ui-faq-7" style="color:red;font-weight:bold;">FAQ 7</a>

### 2、<font id="ui-4-2">D06：使用 ViewModifier 复用样式</font>

```swift
import SwiftUI

struct NoteCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(.blue.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension View {
    func noteCard() -> some View {
        modifier(NoteCardStyle())
    }
}

struct CardStyleDemo: View {
    var body: some View {
        Text("这是一张笔记卡片")
            .noteCard()
    }
}
```

**效果：**文字获得统一内边距、背景和圆角。

**选型边界：**统一外观 / 行为用 modifier；有独立内容结构用子 View；专门统一 Button 的外观和按压反馈用 `ButtonStyle`。按职责拆分，避免基类聚合无关能力。

## 五、<font id="ui-section-5">布局：按容器组织尺寸与位置</font>

### 1、<font id="ui-5-1">SwiftUI 布局的基本过程</font>

父视图提出尺寸建议，子视图返回它选择的尺寸，父视图再安排位置。它是布局协商，不是 Auto Layout 约束方程；容器可能进行多次测量，不能假设整棵树永远只计算一遍。[Apple：Laying out a simple view](https://developer.apple.com/documentation/swiftui/laying-out-a-simple-view)。

<a href="#ui-faq-18" style="color:red;font-weight:bold;">FAQ 18</a>

### 2、<font id="ui-5-2">D07：HStack / VStack / Spacer</font>

```swift
import SwiftUI

struct ProfileRowDemo: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Jobs")
                    .font(.headline)
                Text("传统 iOS 开发者，正在学习 SwiftUI")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .layoutPriority(1)
            Spacer(minLength: 8)
            Text("在线")
        }
        .padding()
    }
}
```

**效果：**姓名和说明竖排，状态在右侧；较窄宽度下，说明允许增高换行。

`Spacer` 消耗主轴可用空白；`layoutPriority` 影响父布局分配空间时的优先顺序，不是 Auto Layout 的“1000 必选约束”；<font color="red"><b><code>fixedSize(horizontal: false, vertical: true)</code></b></font> 表示垂直方向尽量保留理想尺寸，仍受外部整体布局环境影响。

### 3、<font id="ui-5-3">D08：frame、overlay、offset</font>

```swift
import SwiftUI

struct FrameDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("占满父容器允许的宽度")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(.green.opacity(0.15))

            Text("正文")
                .padding(24)
                .overlay(alignment: .topTrailing) {
                    Text("新")
                        .font(.caption)
                }

            Text("视觉上向右移动")
                .offset(x: 20)
        }
        .padding()
    }
}
```

- `.frame(width:height:)` 创建布局包裹，不等于直接写 `UIView.frame`。
- `.frame(maxWidth: .infinity)` 是愿意扩展到父容器允许的宽度，不是拿到全屏宽度。
- `.offset` 主要改变呈现位置，不让兄弟布局按新位置按新位置腾出空间；不要拿它修所有排版问题。
- `overlay` 适合角标、描边等附着于主内容的层；`ZStack` 适合多个内容共同组成叠层布局。
- `frame` 本身不保证裁掉越界内容；需要裁剪时明确使用 `.clipped()` 或 `.clipShape(...)`。

布局修饰符的具体含义见 [Apple：Layout adjustments](https://developer.apple.com/documentation/swiftui/layout-adjustments)。

<a href="#ui-faq-19" style="color:red;font-weight:bold;">FAQ 19</a>

### 4、<font id="ui-5-4">D09：底部操作栏与安全区</font>

```swift
import SwiftUI

struct SafeAreaDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(1...30, id: \.self) { index in
                    Text("说明第 \(index) 行")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            Text("底部操作区域")
                .frame(maxWidth: .infinity)
                .padding()
                .background(.regularMaterial)
        }
    }
}
```

**效果：**底部区域常驻，滚动内容考虑这块占用空间。

**推荐：**底部工具栏、购买操作区优先评估 `safeAreaInset`。背景需要铺满时才让背景 `.ignoresSafeArea()`，正文和交互区域仍需避开刘海、Home Indicator 与键盘。

### 5、<font id="ui-5-5">D10：GeometryReader 的尺寸读取边界</font>

```swift
import SwiftUI

struct GeometryDemo: View {
    var body: some View {
        GeometryReader { proxy in
            Text("容器宽度：\(Int(proxy.size.width))")
                .frame(width: proxy.size.width * 0.7, height: 60)
                .background(.orange.opacity(0.2))
        }
        .frame(height: 80)
    }
}
```

**效果：**文字条使用自身容器宽度的 70%，不是屏幕宽度的 70%。

**推荐：**真的需要容器尺寸或坐标来计算时使用。普通两列、居中、留白先用 Stack / Grid / frame；不要每个页面都 `GeometryReader` 套满。它本身参与布局并倾向占用建议空间，尤其在 ScrollView 中要明确尺寸约束，避免测量与状态互相反馈。

更复杂的摆放算法可以实现 `Layout`（iOS 16+），负责测量与放置；已有成熟的 UIKit 复杂布局可以保留，不必为了“纯 SwiftUI”重写。[Layout 官方文档](https://developer.apple.com/documentation/swiftui/layout)。

<a href="#ui-faq-20" style="color:red;font-weight:bold;">FAQ 20</a>

## 六、<font id="ui-section-6">状态管理第一层：State、Binding 和回调</font>

### 1、<font id="ui-6-1">状态只有一个权威来源</font>

同一个业务值只保留一个权威来源。明确拥有者、只读使用者与修改入口，避免父子视图各存一份再互相同步。

<font color="red"><b><code>@State</code></b></font> 的存储由 SwiftUI 关联到视图身份。View 值重建不等于 State 清零；身份结束、分支移除或有意替换身份时，状态才可能重新建立。它不负责磁盘持久化。[State 官方文档](https://developer.apple.com/documentation/swiftui/state)。

### 2、<font id="ui-6-2">D11：父拥有 State，子拿 Binding</font>

```swift
import SwiftUI

struct FavoriteToggle: View {
    @Binding var isFavorite: Bool

    var body: some View {
        Button(isFavorite ? "取消收藏" : "收藏") {
            isFavorite.toggle()
        }
    }
}

struct BindingDemo: View {
    @State private var isFavorite = false

    var body: some View {
        VStack {
            Text(isFavorite ? "已收藏" : "未收藏")
            FavoriteToggle(isFavorite: $isFavorite)
        }
    }
}
```

**效果：**子组件点击按钮，父组件的状态文案跟着变化。

Binding 是对别处真值的读写通道，不是另开一份存储。<font color="red"><b><code>@Binding var x</code></b></font> 的 <font color="red"><b><code>var</code></b></font> 表示可经通道修改，不表示真值属于子组件。[Binding 官方文档](https://developer.apple.com/documentation/swiftui/binding)。

<a href="#ui-faq-8" style="color:red;font-weight:bold;">FAQ 8</a> · <a href="#ui-faq-9" style="color:red;font-weight:bold;">FAQ 9</a>

### 3、<font id="ui-6-3">D12：用闭包上报事件</font>

```swift
import SwiftUI

struct SaveAction: View {
    let canSave: Bool
    let onSave: () -> Void

    var body: some View {
        Button("保存", action: onSave)
            .disabled(!canSave)
    }
}

struct CallbackDemo: View {
    @State private var result = "尚未保存"

    var body: some View {
        VStack {
            Text(result)
            SaveAction(canSave: true) {
                result = "已提交保存意图"
            }
        }
    }
}
```

**效果：**子组件上报“用户点了保存”，父组件决定如何处理。

| 需求 | 推荐接口 | 原因 |
| --- | --- | --- |
| 显示标题 | <font color="red"><b><code>let title: String</code></b></font> | 只需要输入 |
| 编辑姓名 / 开关 | <font color="red"><b><code>@Binding</code></b></font> | 持续读写某个值 |
| 保存 / 删除 / 重试 / 支付 | 闭包或模型方法 | 这是业务意图，不是任意赋值权限 |
| 编辑后可取消 | 本地草稿 + 保存回调 | 不立即污染正式数据 |

<a href="#ui-faq-16" style="color:red;font-weight:bold;">FAQ 16</a>

### 4、<font id="ui-6-4">D13：自定义 Binding 与 `_name`</font>

```swift
import SwiftUI

struct BindingAdapterDemo: View {
    @State private var nickname = ""

    private var limitedNickname: Binding<String> {
        Binding(
            get: { nickname },
            set: { nickname = String($0.prefix(12)) }
        )
    }

    var body: some View {
        TextField("昵称，最多 12 个字符", text: limitedNickname)
            .textFieldStyle(.roundedBorder)
            .padding()
    }
}

struct InitialDraftDemo: View {
    @State private var draft: String

    init(initialName: String) {
        _draft = State(initialValue: initialName)
    }

    var body: some View {
        TextField("本地草稿", text: $draft)
    }
}
```

第一段演示 <font color="red"><b><code>get/set</code></b></font> 适配，效果是截到 12 个 Swift `Character`，不是 12 个字节。**真实中文输入法可能有组合文本，输入过程中强截断会干扰输入；生产表单更适合提交时校验，或在掌握 marked text 状态的桥接层处理。**

第二段中 `draft` 是值，`$draft` 是绑定，`_draft` 是包装器存储。`initialName` 只用于初始化当前身份的草稿，父页面后来传新名字不会自动覆盖已有编辑。需要持续同步用 Binding；需要切换编辑对象，明确重置草稿或以对象 ID 界定编辑会话。

`Binding.constant(...)` 适合只读展示 / 预览夹具，写入不会改变真值；不要把它当成能交互的 State。

<a href="#ui-faq-10" style="color:red;font-weight:bold;">FAQ 10</a>

## 七、<font id="ui-section-7">状态管理第二层：iOS 17+ 的 Observation</font>

### 1、<font id="ui-7-1">D14：自己拥有模型用 State，编辑模型属性用 Bindable</font>

```swift
import SwiftUI
import Observation

@MainActor
@Observable
final class ProfileModel {
    var name = "Jobs"
    var receivesMessages = true
}

struct ProfileEditor: View {
    @Bindable var model: ProfileModel

    var body: some View {
        Form {
            TextField("名字", text: $model.name)
            Toggle("接收消息", isOn: $model.receivesMessages)
        }
    }
}

struct ObservationDemo: View {
    @State private var model = ProfileModel()

    var body: some View {
        VStack {
            Text("当前姓名：\(model.name)")
            ProfileEditor(model: model)
        }
    }
}
```

**效果：**编辑名字时，外面的姓名同步更新；没有 <font color="red"><b><code>@Published</code></b></font>，也没有 `ObservableObject`。

- <font color="red"><b><code>@Observable</code></b></font>：宏，为模型生成变化观察支持。
- <font color="red"><b><code>@State private var model</code></b></font>：当前视图需要跨求值保有自己的模型实例。
- <font color="red"><b><code>@Bindable var model</code></b></font>：为传入模型的可写属性形成 `$model.name` 这样的绑定。
- <font color="red"><b><code>@MainActor</code></b></font>：明确 UI 模型的并发隔离，不是观察机制的一部分。

“创建并稳定保有模型”和“生成属性绑定”是两件事。<font color="red"><b><code>@Bindable</code></b></font> **不替代 State 的生命周期管理职责**。[Bindable 官方文档](https://developer.apple.com/documentation/swiftui/bindable)。

<a href="#ui-faq-12" style="color:red;font-weight:bold;">FAQ 12</a>

### 2、<font id="ui-7-2">D15：只展示或调用模型方法时，不一定需要 Bindable</font>

```swift
import SwiftUI

// 依赖 D14 的 ProfileModel，由父层持有它。
struct ProfileSummary: View {
    let model: ProfileModel

    var body: some View {
        VStack {
            Text(model.name)
            Button("恢复默认姓名") {
                model.name = "Jobs"
            }
        }
    }
}
```

**效果：**父层传入现代可观察模型，读取 `model.name` 会建立相关观察依赖；修改名字会使依赖它的界面有机会更新。

模型是 <font color="red"><b>class</b></font>；<font color="red"><b><code>let model</code></b></font> 限制引用改指向，不冻结对象内部属性。需要只读接口时，另外限制可写能力。

需要严格的只读接口，可以传纯值快照或只读协议；需要输入框绑定才引入 Bindable。不要把“没有 <font color="red"><b><code>@ObservedObject</code></b></font>”误判为现代模型不会触发更新。

### 3、<font id="ui-7-3">新方式和旧方式最大的机制差别</font>

Observation 主要基于 `body` 求值时实际读取的可观察属性建立依赖；不是模型每改一个无关字段，就必然以相同方式通知所有读它的界面。计算属性可以通过内部读取的可观察属性形成依赖。

这是一种更细的依赖表达，不是“保证只执行某一个 Text 的 body”或“完全不会多算”。父层输入、环境和结构变化仍然可能带来更新。[Apple：从 ObservableObject 迁移到 Observable](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)。

<a href="#ui-faq-11" style="color:red;font-weight:bold;">FAQ 11</a>

### 4、<font id="ui-7-4">选择边界</font>

- 最低 iOS 17+ 的新页面：通常优先评估 <font color="red"><b><code>@Observable</code></b></font>。
- 项目大量依赖 <font color="red"><b>Combine</b></font> Publisher / 操作符：可以保留 ObservableObject，不必只为少几个标记重写数据流。
- 需要兼容 iOS 16 或更早：使用系统原生能力时，优先旧式观察体系；不要只把 <font color="red"><b><code>@Observable</code></b></font> 粘上去。
- <font color="red"><b><code>@Observable</code></b></font> 不负责线程安全、磁盘持久化、网络去重、权限检查；这些都要独立设计。
- <font color="red"><b><code>@State</code></b></font> 中模型的默认值表达式可能随 View 构造反复求值；**不要在模型 <font color="red"><b>init</b></font> 中发请求、写文件或做重计算**。存储稳定不等于初始化表达式有“全局只执行一次”保证。

<a href="#ui-faq-31" style="color:red;font-weight:bold;">FAQ 31</a>

## 八、<font id="ui-section-8">ObservableObject：旧式模型观察</font>

### 1、<font id="ui-8-1">D16：StateObject 管生命周期，ObservedObject 接外部模型</font>

```swift
import SwiftUI
import Combine

@MainActor
final class LegacyCounterModel: ObservableObject {
    @Published var count = 0
}

struct LegacyCounterChild: View {
    @ObservedObject var model: LegacyCounterModel

    var body: some View {
        Button("加一，当前 \(model.count)") {
            model.count += 1
        }
    }
}

struct LegacyCounterDemo: View {
    @StateObject private var model = LegacyCounterModel()

    var body: some View {
        VStack {
            Text("父页面：\(model.count)")
            LegacyCounterChild(model: model)
        }
    }
}
```

**效果：**点击子组件，父页面也更新。

<font color="red"><b><code>@StateObject</code></b></font> 在同一视图身份下建立并保持模型存储；<font color="red"><b><code>@ObservedObject</code></b></font> 订阅传入对象，不负责创建对象后跨 View 重建保存它的职责。[StateObject 官方文档](https://developer.apple.com/documentation/swiftui/stateobject)。

<a href="#ui-faq-13" style="color:red;font-weight:bold;">FAQ 13</a>

### 2、<font id="ui-8-2">模型持有与观察边界</font>

- 当前视图创建并长期拥有旧式模型时使用 <font color="red"><b><code>@StateObject</code></b></font>；外部传入的模型使用 <font color="red"><b><code>@ObservedObject</code></b></font>。
- <font color="red"><b><code>@ObservedObject</code></b></font> 不是弱引用。外部负责生命周期，不等于包装器采用 <font color="red"><b>weak</b></font>。
- 普通 <font color="red"><b>class</b></font> 放进 State 不会自动观察内部字段；旧 ObservableObject 使用旧式对象包装器，现代 Observable 使用 Observation 集成。

<a href="#ui-faq-14" style="color:red;font-weight:bold;">FAQ 14</a>

### 3、<font id="ui-8-3">D17：旧式环境注入</font>

```swift
import SwiftUI

// 依赖 D16 的 LegacyCounterModel。
struct LegacyEnvironmentChild: View {
    @EnvironmentObject private var model: LegacyCounterModel

    var body: some View {
        Button("共享计数：\(model.count)") {
            model.count += 1
        }
    }
}

struct LegacyEnvironmentDemo: View {
    @StateObject private var model = LegacyCounterModel()

    var body: some View {
        LegacyEnvironmentChild()
            .environmentObject(model)
    }
}
```

**效果：**子树不逐层传参，也能获取同一个模型。

**边界：**缺少 `.environmentObject(model)` 会出运行时错误；预览和测试也必须注入。它不是整个进程的自动单例，注入范围是视图子树。

### 4、<font id="ui-8-4">新旧写法对照表</font>

| 责任 | ObservableObject 体系 | Observation 体系（iOS 17+） |
| --- | --- | --- |
| 模型声明 | <font color="red"><b><code>class ...: ObservableObject</code></b></font> | <font color="red"><b><code>@Observable class ...</code></b></font> |
| 可观察属性 | 常用 <font color="red"><b><code>@Published</code></b></font> | 普通可观察存储属性，无需 Published |
| 当前 View 稳定保有模型 | <font color="red"><b><code>@StateObject</code></b></font> | <font color="red"><b><code>@State</code></b></font> |
| 外部模型输入 | <font color="red"><b><code>@ObservedObject</code></b></font> | 普通 <font color="red"><b><code>let</code></b></font> / <font color="red"><b><code>var</code></b></font> 引用即可读取观察 |
| 编辑模型属性 | 包装器投影 `$model.property` | 需要绑定时使用 <font color="red"><b><code>@Bindable</code></b></font>，或已有 State 的投影 |
| 子树共享 | `.environmentObject(...)` | `.environment(...)` |
| 子树读取 | <font color="red"><b><code>@EnvironmentObject</code></b></font> | <font color="red"><b><code>@Environment(Model.self)</code></b></font> |

不要把 <font color="red"><b><code>@Observable</code></b></font> 和 <font color="red"><b><code>@Published</code></b></font> 机械叠加；不要用 <font color="red"><b><code>@StateObject</code></b></font> 包装一个未遵循 ObservableObject 的现代模型。

## 九、<font id="ui-section-9">Environment、AppStorage、SceneStorage</font>

### 1、<font id="ui-9-1">D18：Environment 注入子树依赖</font>

```swift
import SwiftUI

// 依赖 D14 的 ProfileModel。
struct ModernEnvironmentChild: View {
    @Environment(ProfileModel.self) private var profile
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        @Bindable var editableProfile = profile
        VStack {
            Text(colorScheme == .dark ? "深色环境" : "浅色环境")
            TextField("姓名", text: $editableProfile.name)
        }
        .padding()
    }
}

struct ModernEnvironmentDemo: View {
    @State private var profile = ProfileModel()

    var body: some View {
        ModernEnvironmentChild()
            .environment(profile)
    }
}
```

**效果：**子层既能读取系统深浅色，又能修改注入模型；同一个模型可让多层子视图共享。

<font color="red"><b><code>@Environment(\.colorScheme)</code></b></font> 读取系统环境值；<font color="red"><b><code>@Environment(ProfileModel.self)</code></b></font> 读取指定类型的可观察模型。<font color="red"><b><code>@Environment</code></b></font> 不负责创建该模型。非可选模型未注入会导致运行时错误。[Environment 官方文档](https://developer.apple.com/documentation/swiftui/environment)。

**推荐：**登录会话、应用设置等确实被整个子树使用的依赖。小组件只要一个标题，就传标题；避免组件隐式依赖全局上下文。后代可覆盖注入，同类型模型通常取更近的环境，因此复杂依赖要注意可读性。

<a href="#ui-faq-15" style="color:red;font-weight:bold;">FAQ 15</a>

### 2、<font id="ui-9-2">D19：用户偏好和窗口恢复不是一回事</font>

```swift
import SwiftUI

struct StorageDemo: View {
    @AppStorage("experience.largeText") private var largeText = false
    @SceneStorage("experience.draft") private var draft = ""

    var body: some View {
        Form {
            Toggle("使用更大文字", isOn: $largeText)
            TextField("当前窗口草稿", text: $draft)
            Text("预览文字")
                .font(largeText ? .title : .body)
        }
    }
}
```

**效果：**大字偏好通过 UserDefaults 保存；草稿作为当前 Scene 的轻量恢复状态交给系统管理。

| 包装器 / 存储 | 适合 | 不适合 |
| --- | --- | --- |
| <font color="red"><b><code>@State</code></b></font> | 页面临时状态 | 杀 App 后可靠恢复 |
| <font color="red"><b><code>@AppStorage</code></b></font> | 偏好开关、小型设置 | 密码、Token、业务数据库 |
| <font color="red"><b><code>@SceneStorage</code></b></font> | 每窗口选中项、轻量导航 / 草稿恢复 | 必须可靠保存的订单或长文档 |
| 文件 / 数据库 / SwiftData 等 | 业务数据持久化 | 用 UI 包装器代替完整一致性设计 |
| Keychain | 适合安全存储的凭据 | 把它当成普通列表缓存 |

SceneStorage 的保存时机由系统管理，不保证每次修改立刻落盘，Scene 被销毁也可能清除相关数据。**“草稿不能丢”是业务持久化需求，不能只靠 SceneStorage。**[AppStorage](https://developer.apple.com/documentation/swiftui/appstorage)、[SceneStorage](https://developer.apple.com/documentation/swiftui/scenestorage)。

<a href="#ui-faq-17" style="color:red;font-weight:bold;">FAQ 17</a>

### 3、<font id="ui-9-3">其他框架标记的职责</font>

| 标记 | 负责什么 | 边界 |
| --- | --- | --- |
| <font color="red"><b><code>@ScaledMetric</code></b></font> | 数值随 Dynamic Type 缩放 | 自定义尺寸仍需验证大字号布局 |
| <font color="red"><b><code>@FetchRequest</code></b></font> / <font color="red"><b><code>@SectionedFetchRequest</code></b></font> | 观察 Core Data 查询结果 | 需要正确的托管对象上下文与查询配置 |
| <font color="red"><b><code>@Query</code></b></font> | 在 SwiftUI 中观察 SwiftData 查询 | iOS 17+；模型容器需正确注入 |
| <font color="red"><b><code>@Model</code></b></font> | 声明 SwiftData 持久化模型 | 属于宏，不等于普通属性包装器 |
| <font color="red"><b><code>@Attribute</code></b></font> / <font color="red"><b><code>@Relationship</code></b></font> / <font color="red"><b><code>@Transient</code></b></font> | 配置持久化字段、关系或忽略字段 | 按数据模型和迁移策略使用 |
| <font color="red"><b><code>@ObservationIgnored</code></b></font> | 排除 Observation 追踪的属性 | 不提供额外的线程保护 |

<font color="red"><b><code>@Published</code></b></font> 与 <font color="red"><b>Combine</b></font> 的发布时机、订阅管理统一放在 [Swift 事件流章节](/Users/jobs/Documents/Github/JobsBaseConfig/JobsBaseConfig@JobsSwiftBaseConfigDemo/SwiftDoc.md/Swift相关经验.md/Swift相关经验.md#Combine)。

## 十、<font id="ui-section-10">List、ForEach 与稳定身份</font>

### 1、<font id="ui-10-1">D20：List 的可编辑数据</font>

```swift
import SwiftUI

struct LearningItem: Identifiable {
    let id: Int
    var title: String
    var isDone: Bool
}

struct EditableListDemo: View {
    @State private var items = [
        LearningItem(id: 1, title: "学 State", isDone: false),
        LearningItem(id: 2, title: "学 Binding", isDone: false)
    ]

    var body: some View {
        List {
            ForEach($items) { $item in
                Toggle(item.title, isOn: $item.isDone)
            }
            .onDelete { offsets in
                items.remove(atOffsets: offsets)
            }
        }
    }
}
```

**效果：**可以勾选每行，左滑删除；删除前面的项目不会让后面的项目改成另一个身份。

`List` 是列表容器；`ForEach` 根据数据和 ID 生成重复的视图内容，它本身不负责滚动，也不是 Array 的 `.forEach`。

<font color="red"><b><code>ForEach($items) { $item in ... }</code></b></font> 是绑定集合写法：这里闭包中的 `item` 是值访问，`$item` 能继续形成属性绑定。不要把这个 `$item` 当成普通命名装饰。

<a href="#ui-faq-21" style="color:red;font-weight:bold;">FAQ 21</a>

### 2、<font id="ui-10-2">D21：LazyVStack 与 Lazy Grid 选型</font>

```swift
import SwiftUI

struct GridDemo: View {
    private let columns = [GridItem(.adaptive(minimum: 120), spacing: 12)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(1...60, id: \.self) { index in
                    Text("知识卡片 \(index)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.opacity(0.1))
                }
            }
            .padding()
        }
    }
}
```

**效果：**宽度允许时自动放更多列；卡片内容按需构建。固定且不重排的整数范围可以用 <font color="red"><b><code>\.self</code></b></font>。

| 场景 | 优先选择 | 边界 |
| --- | --- | --- |
| 系统风格列表、分组、删除、选择 | `List` | 接受部分系统列表行为 |
| 长纵向自定义内容 | `ScrollView + LazyVStack` | 分页、滚动行为等要自己设计 |
| 很少且需立即布局的内容 | `VStack` / `HStack` | 不必为了“性能”全部 Lazy |
| 大量网格卡片 | `LazyVGrid` / `LazyHGrid` | 不等于完整 UICollectionView 能力 |
| 小型、跨行列对齐的表格 | `Grid` | 不以懒加载为主要目标 |
| 高复杂集合布局、成熟重型 Cell | UIKit 集合视图，按需混入 SwiftUI | 先测迁移收益 |

Lazy 表示延迟构建 / 按需工作，不表示屏幕外必定立刻释放，也不表示它不会预先计算部分内容，更不是自动网络分页。

LazyVGrid 按列排列并配合垂直滚动，LazyHGrid 按行排列并配合水平滚动；需要 UIKit 特有的集合布局或编辑行为时使用桥接。

<a href="#ui-faq-24" style="color:red;font-weight:bold;">FAQ 24</a>

### 3、<font id="ui-10-3">ID 要“同一项稳定，不同项唯一”</font>

**推荐：**服务器记录 ID；本地新增实体时生成一次并持久保留的 UUID；确实唯一且不变的值。

**不推荐：**每次读取都 `UUID()` 的计算属性；可能重名的标题；会删改重排列表中的下标；每次请求都给同一业务实体重新生成 UUID。

<font color="red"><b><code>id: \.self</code></b></font> 只适合值本身确实适合作身份的情况。字符串数组有两个“张三”时，名字就不是唯一 ID。

这关系到行状态、焦点、转场和增量更新，不只是消除编译错误。[Apple：Demystify SwiftUI，Identity 部分](https://developer.apple.com/videos/play/wwdc2021/10022/)。

<a href="#ui-faq-22" style="color:red;font-weight:bold;">FAQ 22</a> · <a href="#ui-faq-23" style="color:red;font-weight:bold;">FAQ 23</a>

### 4、<font id="ui-10-4">D22：有意重置身份，而不是滥用 id 刷新</font>

```swift
import SwiftUI

struct IdentityResetDemo: View {
    @State private var session = 0

    var body: some View {
        VStack {
            CounterDemo()
                .id(session)
            Button("开始新的计数会话") {
                session += 1
            }
        }
    }
}
```

**效果：**子计数器先加几次，再点“开始新的计数会话”，它的本地 State 会重新建立。

**推荐：**明确开始全新编辑会话 / 重置子树。**不推荐：**数据不刷新时直接 `.id(UUID())`。那会不断换身份，丢状态、打断焦点和任务，问题可能只是观察方式选错。

条件分支移除视图也可能结束其身份。临时隐藏但要保留草稿时，优先把草稿提升到稳定父层；仅 `.opacity(0)` 不会自动禁用点击和无障碍访问，需要另行处理。

## 十一、<font id="ui-section-11">导航、弹窗、Tab：把跳转也看成状态</font>

### 1、<font id="ui-11-1">D23：NavigationStack 路径里放数据，不放 VC</font>

```swift
import SwiftUI

enum StudyRoute: Hashable {
    case detail(Int)
    case settings
}

struct NavigationDemo: View {
    @State private var path: [StudyRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink("第 7 条笔记", value: StudyRoute.detail(7))
                Button("打开设置") {
                    path.append(.settings)
                }
            }
            .navigationTitle("笔记")
            .navigationDestination(for: StudyRoute.self) { route in
                switch route {
                /// 按业务 ID 展示详情
                case .detail(let id):
                    VStack {
                        Text("笔记 ID：\(id)")
                        Button("返回根页") { path.removeAll() }
                    }
                /// 展示设置入口
                case .settings:
                    Text("设置页")
                }
            }
        }
    }
}
```

**效果：**Link 或按钮都能压栈；系统返回会更新路径；清空路径回根页。

`[StudyRoute]` 适合统一路由枚举。`NavigationPath` 适合需要异构 Hashable 元素的路径；有统一类型时，不必为了“高级”做类型擦除。[Apple：Understanding the navigation stack](https://developer.apple.com/documentation/swiftui/understanding-the-navigation-stack)。

**边界：**`navigationDestination` 注册放在 Stack 内稳定、可发现的层级，不要藏进 Lazy 行内部。深链恢复还要验证登录态、数据存在性和路径版本，不能直接信任外部 URL。

<a href="#ui-faq-25" style="color:red;font-weight:bold;">FAQ 25</a>

### 2、<font id="ui-11-2">D24：sheet(item:) 与 dismiss</font>

```swift
import SwiftUI

struct SheetNote: Identifiable {
    let id: Int
    let title: String
}

struct NoteSheet: View {
    let note: SheetNote
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text(note.title)
            Button("关闭") { dismiss() }
        }
        .padding()
    }
}

struct SheetDemo: View {
    @State private var selected: SheetNote?

    var body: some View {
        Button("查看笔记") {
            selected = SheetNote(id: 7, title: "状态管理笔记")
        }
        .sheet(item: $selected) { note in
            NoteSheet(note: note)
        }
    }
}
```

**效果：**选择非 <font color="red"><b>nil</b></font> 的笔记即展示 Sheet，关闭后展示状态恢复。

有“选中哪个对象”时优先 `.sheet(item:)`，避免 `isPresented` 和 `selectedItem` 两份状态不一致；只有是否展示时，用 `.sheet(isPresented:)` 很自然。全屏模态需求使用 `.fullScreenCover`。

**重要边界：**`dismiss` 从被展示的子页面读取；如果从父页面读取后传下去，可能作用于错误的展示上下文。UIKit 承载场景也要区分由谁负责导航与关闭。

<a href="#ui-faq-26" style="color:red;font-weight:bold;">FAQ 26</a>

### 3、<font id="ui-11-3">D25：Alert / confirmationDialog</font>

```swift
import SwiftUI

struct AlertDemo: View {
    @State private var showsAlert = false
    @State private var message = "草稿仍保留"

    var body: some View {
        VStack {
            Text(message)
            Button("删除草稿", role: .destructive) {
                showsAlert = true
            }
        }
        .alert("确认删除", isPresented: $showsAlert) {
            Button("删除", role: .destructive) { message = "草稿已删除" }
            Button("取消", role: .cancel) { }
        } message: {
            Text("这个教学操作只修改页面文字。")
        }
    }
}
```

**效果：**先确认，再改变页面状态，没有真实删除文件。

确认重要结果用 Alert；从拍照 / 相册等多个动作中选择可以评估 `confirmationDialog`；复杂表单不要硬塞 Alert。

### 4、<font id="ui-11-4">D26：每个 Tab 独立导航</font>

```swift
import SwiftUI

struct TabsDemo: View {
    var body: some View {
        TabView {
            NavigationDemo()
                .tabItem { Text("笔记") }
            NavigationStack {
                StorageDemo()
                    .navigationTitle("偏好")
            }
            .tabItem { Text("设置") }
        }
    }
}
```

**效果：**两个业务标签，各自组织页面。

常见选法是每个 Tab 一条导航栈；需要独立恢复时，把每条 path 放进各自稳定拥有者。不应不加思考地再在外面包一层总 NavigationStack。iPad 多栏信息架构可以使用 `NavigationSplitView`，不是简单把所有设备都做成单列 push。

## 十二、<font id="ui-section-12">生命周期与事件回调</font>

### 1、<font id="ui-12-1">D27：观察出现、消失、状态变化与 Scene</font>

```swift
import SwiftUI

struct LifecycleDemo: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var count = 0

    var body: some View {
        Button("计数：\(count)") { count += 1 }
            .onAppear { print("当前内容出现") }
            .onDisappear { print("当前内容消失") }
            .onChange(of: count) { oldValue, newValue in
                print("从 \(oldValue) 改成 \(newValue)")
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .background {
                    print("当前 Scene 进入后台")
                }
            }
    }
}
```

**效果：**点击、页面出现 / 消失、当前 Scene 阶段变化时打印相应信息；观察输出即可，不要求固定次数。

| 放哪里 | 应该做什么 | 不应该假设什么 |
| --- | --- | --- |
| View <font color="red"><b><code>init</code></b></font> | 保存输入，做轻量初始化 | 不保证页面只调用一次 |
| `body` | 根据输入组合界面 | 不执行请求、写文件、反向改状态 |
| `.onAppear` | 出现时轻量事件 | 不是只执行一次的 viewDidLoad |
| `.onDisappear` | 离开当前呈现时的相关处理 | 不等于进程退出 / 对象 <font color="red"><b>deinit</b></font> |
| `.task` | 关联该视图呈现的异步工作 | 不保证 App 生命周期只运行一次 |
| `.task(id:)` | 输入身份变化，取消并重启相关工作 | 取消不是强制中断所有底层操作 |
| `.onChange` | 某个可比较值变化后的副作用 | 不是每次属性 setter 的逐次事件日志 |
| `scenePhase` | 当前作用域的 Scene 活跃 / 后台状态 | 不假设 App 永远只有一个窗口 |

`onChange` 是观察变化后的副作用入口，不是“为了让 Text 更新必须调用”的方法。双参数和零参数新重载需要 iOS 17；旧项目的单参数重载不要不看版本直接替换。[onChange 官方文档](https://developer.apple.com/documentation/swiftui/view/onchange(of:initial:_:)-8wgw9)。

<a href="#ui-faq-27" style="color:red;font-weight:bold;">FAQ 27</a>

### 2、<font id="ui-12-2">限定加载次数与生命周期</font>

先规定加载次数的归属：当前视图身份、路由会话、账号、缓存有效期或进程。把去重状态放在对应生命周期的拥有者中。

<font color="red"><b><code>@State private var hasLoaded</code></b></font> 只能表达当前身份范围的门禁，不能承诺整个 App 一次。通常让模型 / 数据服务根据状态、缓存有效期和请求 ID 决定是否加载；失败后能重试、取消后能再进，也应有明确规则。

## 十三、<font id="ui-section-13">异步加载：任务归属与旧结果保护</font>

### 1、<font id="ui-13-1">D28：搜索、防抖、取消和旧结果保护</font>

```swift
import SwiftUI
import Foundation

struct SearchDemo: View {
    private enum Phase {
        case idle
        case loading
        case loaded([String])
        case failed(String)
    }

    @State private var query = ""
    @State private var phase: Phase = .idle

    var body: some View {
        NavigationStack {
            Group {
                switch phase {
                /// 没有查询词时提示输入
                case .idle:
                    Text("请输入要搜索的技术")
                /// 请求正在进行
                case .loading:
                    ProgressView("搜索中")
                /// 区分空结果和有数据
                case .loaded(let names):
                    if names.isEmpty {
                        Text("没有匹配结果")
                    } else {
                        List(names, id: \.self) { Text($0) }
                    }
                /// 展示可理解的失败状态
                case .failed(let message):
                    Text(message)
                }
            }
            .navigationTitle("技术搜索")
        }
        .searchable(text: $query)
        .task(id: query) {
            await search(query)
        }
    }

    private func search(_ requestedQuery: String) async {
        let term = requestedQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else {
            phase = .idle
            return
        }
        phase = .loading
        do {
            try await Task.sleep(for: .milliseconds(300))
            let names = try await mockSearch(term)
            try Task.checkCancellation()
            guard query == requestedQuery else { return }
            phase = .loaded(names)
        } catch is CancellationError {
            // 输入变化或页面离开，不给用户弹“请求失败”。
        } catch {
            guard !Task.isCancelled, query == requestedQuery else { return }
            phase = .failed("搜索失败，请修改关键词重试")
        }
    }

    private func mockSearch(_ term: String) async throws -> [String] {
        try await Task.sleep(for: .milliseconds(250))
        return ["Swift", "SwiftUI", "UIKit", "Objective-C"]
            .filter { $0.localizedCaseInsensitiveContains(term) }
    }
}
```

**效果：**快速输入 `s`、`sw`、`swift` 时，先等待 300 毫秒；输入再变就取消旧任务。命中词显示列表，没命中显示空态。这里是本地模拟请求，不连接外部服务；失败分支供接入真实服务后使用。

这里有四层责任：

1、`.task(id: query)` 把任务关联到查询词和当前视图呈现。

2、<font color="red"><b><code>Task.sleep</code></b></font> 实现防抖等待，并能响应取消。

3、<font color="red"><b><code>Task.checkCancellation()</code></b></font> 在提交结果前再次检查取消。

4、校验当前 query，避免旧词结果覆盖新词。

**边界：**若同一个词允许并行刷新 / 重试，仅校验词不够，要增加递增请求序号或唯一 request ID；只有当前请求能提交结果和清理 loading。不要让旧请求的 <font color="red"><b><code>defer</code></b></font> 把新请求的 loading 关掉。

任务挂在稳定的外层 NavigationStack 上，不挂到 loading / loaded 切换时会被替换的分支上；否则分支变化本身可能打断任务生命周期。

SwiftUI 可以在视图消失后取消关联任务，ID 变化时取消并重建；取消是协作式信号，网络封装、回调桥接和计算循环必须配合，不是强杀线程。[task(id:) 官方文档](https://developer.apple.com/documentation/swiftui/view/task(id:name:priority:file:line:_:))。

<a href="#ui-faq-28" style="color:red;font-weight:bold;">FAQ 28</a> · <a href="#ui-faq-29" style="color:red;font-weight:bold;">FAQ 29</a>

### 2、<font id="ui-13-2">D29：下拉刷新要等待真正的工作</font>

```swift
import SwiftUI

struct RefreshDemo: View {
    @State private var version = 0

    var body: some View {
        List {
            Text("已刷新 \(version) 次")
        }
        .refreshable {
            do {
                try await Task.sleep(for: .milliseconds(500))
                try Task.checkCancellation()
                version += 1
            } catch {
                // 此 Demo 只有可取消等待，不伪装成网络错误。
            }
        }
    }
}
```

**效果：**下拉后等待半秒，再增加版本号。

不要在 `.refreshable` 里面只启动一个不等待的 <font color="red"><b><code>Task { ... }</code></b></font> 然后立即返回，那样刷新指示和真实工作生命周期脱节。直接 <font color="red"><b><code>await model.reload()</code></b></font> 更清楚。

<a href="#ui-faq-32" style="color:red;font-weight:bold;">FAQ 32</a>

### 3、<font id="ui-13-3">D30：网络服务与页面边界</font>

```swift
import Foundation

struct RemoteNote: Decodable, Sendable {
    let id: Int
    let title: String
}

actor NotesAPI {
    func fetch(from url: URL) async throws -> [RemoteNote] {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse,
              (200..<300).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }
        try Task.checkCancellation()
        return try JSONDecoder().decode([RemoteNote].self, from: data)
    }
}
```

**这是服务片段，不会自己发请求。**调用方传入真实接口 URL，并由页面 / 模型 <font color="red"><b><code>try await</code></b></font>。假定响应结构是 `[{"id":1,"title":"笔记"}]`；真实 API 如有外层 code/data，必须按真实结构建模。

这里用普通 <font color="red"><b>actor</b></font> 让服务有独立隔离域，可在该域内处理解码；它不等于专用后台线程。没有共享可变状态的轻量服务也可以用 <font color="red"><b>struct</b></font> / 普通函数，**不是所有网络 Service 都必须 <font color="red"><b>actor</b></font>**。

生产还需：认证与脱敏、超时、错误分类、取消转发、缓存、请求去重、幂等性、分页及测试。大数据解码即使不在 Main Actor，也要考虑是否长时间占住并发执行资源。

### 4、<font id="ui-13-4"><font color="red"><b>MainActor</b></font>、<font color="red"><b>Task</b></font>、<font color="red"><b>async</b></font> 的正确边界</font>

- <font color="red"><b><code>async</code></b></font> 表示可以挂起，不承诺开新线程。
- <font color="red"><b><code>Task {}</code></b></font> 是任务，不是 GCD 后台队列的别名；会受创建处 <font color="red"><b>actor</b></font> 上下文影响。
- <font color="red"><b><code>@MainActor</code></b></font> 适合 UI 状态模型；在其方法里做大量同步排序 / 解码照样可能卡 UI。
- 在 Main Actor 上 <font color="red"><b><code>await</code></b></font> 真正异步网络，并不等于主线程原地等待网络。
- <font color="red"><b><code>Task.detached</code></b></font> 不继承普通 <font color="red"><b>Task</b></font> 的 <font color="red"><b>actor</b></font> 上下文等语义，且取消和生命周期需显式管理，不能作为通用的性能修复手段。
- `.task` 里再套一个 <font color="red"><b><code>Task {}</code></b></font> 会另起非结构化任务；外层取消不保证这个内层任务自动跟着取消。
- 上传、后台下载等必须跨页面存活的工作，应由服务 / 任务管理器拥有，不归短命页面任务拥有。

先确定隔离归属和任务拥有者，再选择调度方式；异步声明不能替代取消、去重和旧结果校验。

<a href="#ui-faq-30" style="color:red;font-weight:bold;">FAQ 30</a>

## 十四、<font id="ui-section-14">表单、焦点和“编辑后取消”</font>

### 1、<font id="ui-14-1">D31：FocusState 代替到处找 firstResponder</font>

```swift
import SwiftUI

struct LoginFormDemo: View {
    private enum Field: Hashable { case account, password }
    @State private var account = ""
    @State private var password = ""
    @State private var result = ""
    @FocusState private var focusedField: Field?

    var body: some View {
        Form {
            TextField("账号", text: $account)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .account)
                .submitLabel(.next)
                .onSubmit { focusedField = .password }

            SecureField("密码", text: $password)
                .focused($focusedField, equals: .password)
                .submitLabel(.done)
                .onSubmit { submit() }

            Button("登录演示", action: submit)
                .disabled(account.isEmpty || password.isEmpty)
            Text(result)
        }
    }

    private func submit() {
        guard !account.isEmpty, !password.isEmpty else { return }
        focusedField = nil
        result = "校验通过，尚未调用真实登录接口"
    }
}
```

**效果：**账号键盘“下一项”进入密码框，提交后收起焦点并展示结果。代码不会打印或保存密码。

FocusState 的 `$focusedField` 是焦点专用绑定，不是普通 `Binding<Field?>`。同一个焦点枚举值不要同时分配给多个输入框；需要多个字段时用可选枚举，比多个 Bool 更清楚。[FocusState 官方文档](https://developer.apple.com/documentation/swiftui/focusstate)。

禁用按钮不是完整校验：快捷键、键盘提交和其它调用入口仍需在提交方法里验证；网络请求进行中还要防重复提交。

<a href="#ui-faq-33" style="color:red;font-weight:bold;">FAQ 33</a>

### 2、<font id="ui-14-2">D32：保存时提交，取消不污染正式数据</font>

```swift
import SwiftUI

struct DraftEditor: View {
    @State private var draft: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    init(initialName: String, onSave: @escaping (String) -> Void) {
        _draft = State(initialValue: initialName)
        self.onSave = onSave
    }

    var body: some View {
        Form {
            TextField("新名字", text: $draft)
            Button("保存") {
                onSave(draft)
                dismiss()
            }
            Button("取消", role: .cancel) { dismiss() }
        }
    }
}

struct DraftDemo: View {
    @State private var name = "Jobs"
    @State private var isEditing = false

    var body: some View {
        VStack {
            Text(name)
            Button("编辑名字") { isEditing = true }
        }
        .sheet(isPresented: $isEditing) {
            DraftEditor(initialName: name) { name = $0 }
        }
    }
}
```

**效果：**改名字后取消，父页面仍是原名字；保存才回写。

<font color="red"><b><code>@escaping</code></b></font> 表示回调要保存下来，之后用户点击时再执行。这里是本地同步保存；真实远程保存应等待成功再关闭，失败保留草稿并提供重试。

**边界：**直接把正式模型的字段 Binding 给输入框，就意味着输入过程中已经修改正式数据，关闭 Sheet 不会自动回滚。取消语义应通过草稿 / 事务明确实现。

## 十五、<font id="ui-section-15">动画与手势：动画描述变化，状态仍然是真值</font>

### 1、<font id="ui-15-1">D33：withAnimation 与 transition</font>

```swift
import SwiftUI

struct ExpandDemo: View {
    @State private var expanded = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(expanded ? "收起详情" : "展开详情") {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                    expanded.toggle()
                }
            }
            if expanded {
                Text("这里是展开后才加入层级的详情。")
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
    }
}
```

**效果：**点击展开 / 收起时，内容插入或移除有过渡；启用“减弱动态效果”时取消这段动画。

`withAnimation` 为这次状态修改建立动画上下文；`transition` 说明视图进入 / 离开层级的表现。只写 transition、不触发动画事务，不等于一定会看到动画。

<a href="#ui-faq-34" style="color:red;font-weight:bold;">FAQ 34</a>

### 2、<font id="ui-15-2">D34：animation(value:) 与 GestureState</font>

```swift
import SwiftUI

struct DragDemo: View {
    @GestureState private var translation: CGSize = .zero
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Text("拖动我，松手回原位")
            .padding(24)
            .background(.blue.opacity(0.15))
            .offset(translation)
            .gesture(
                DragGesture().updating($translation) { value, state, _ in
                    state = value.translation
                }
            )
            .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: translation)
    }
}
```

**效果：**拖动文字卡片，手势结束后临时位移重置。这是解释 API 的短例，给位移加动画也可能产生跟手滞后；追求直接跟手时不对每次拖动采样做插值，只为最终吸附 / 回弹设计动画事务。

| 需求 | 选择 |
| --- | --- |
| 这次事件引起的一组变化一起动画 | `withAnimation` |
| 视图在某个值变化时应用动画 | `.animation(_:value:)` |
| 内容插入 / 删除时的进入退出表现 | `.transition` |
| 持续的业务位置 / 缩放 | <font color="red"><b><code>@State</code></b></font> 保存最终状态 |
| 手势期间临时位移 / 按压状态 | <font color="red"><b><code>@GestureState</code></b></font>，结束自动复位 |

`animation(value:)` 的 value 是触发比较依据，不代表该次更新中只有这个属性能被动画；同一作用范围和事务里的其它可动画变化也可能被带上。范围尽量缩小。[Animation 官方文档](https://developer.apple.com/documentation/swiftui/animation)。

普通可点击动作优先 Button，保留可访问性、焦点和系统交互语义；不要为了处理点击把所有 Button 换成 Text + onTapGesture。复杂拖动与 ScrollView 手势竞争时，再考虑 `simultaneousGesture` / `highPriorityGesture`，并做真机验证。

<a href="#ui-faq-35" style="color:red;font-weight:bold;">FAQ 35</a>

## 十六、<font id="ui-section-16">组件和架构：SwiftUI 不强制 MVVM</font>

### 1、<font id="ui-16-1">D35：泛型容器和 ViewBuilder</font>

```swift
import SwiftUI

struct StudyCard<Content: View>: View {
    let title: String
    private let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            content
        }
        .noteCard()
    }
}

struct CompositionDemo: View {
    var body: some View {
        StudyCard(title: "今天的学习计划") {
            Text("先学状态归属")
            Text("再学导航和请求")
        }
    }
}
```

**效果：**不同内容可以复用同一张卡片外壳。依赖 D06 的 `.noteCard()`。

`Content: View` 表示内容类型由调用方决定；初始化器立即执行构建闭包并保存结果，所以这里不需要 <font color="red"><b><code>@escaping</code></b></font>。如果改为保存闭包留到以后执行，就要重新考虑逃逸与捕获语义。

### 2、<font id="ui-16-2">业务层职责划分</font>

| 层 | 负责 | 不应该负责 |
| --- | --- | --- |
| View | 展示、绑定、上报意图 | Token 刷新、SQL、复杂请求重试 |
| 页面模型 / ViewModel | 页面状态、用例编排、校验 | 持有一堆 SwiftUI Text 实例 |
| Service / Repository | 请求、缓存、持久化与领域规则 | 决定页面字体和内边距 |
| 导航拥有者 | 路径和展示状态 | 同时承担所有业务的全局单例 |

小计数器没有必要再造 ViewModel；跨页面状态、复杂异步、多个错误分支、独立测试需求出现后再拆。**MVVM 是组织方式，Observation 是观察机制，SwiftUI 是 UI 框架，三者不是同一个层级。**

<a href="#ui-faq-36" style="color:red;font-weight:bold;">FAQ 36</a> · <a href="#ui-faq-42" style="color:red;font-weight:bold;">FAQ 42</a>

### 3、<font id="ui-16-3">避免 Bool 状态爆炸</font>

如果同一请求同时用 `isLoading`、`hasError`、`isEmpty`、`isSuccess`，容易出现“加载中又成功又失败”的矛盾组合。互斥阶段用 <font color="red"><b>enum</b></font>；可以同时发生的独立状态，例如“数据已展示”和“正在后台刷新”，则可以分开建模。

也不要反过来把完全无关的弹窗、焦点、网络和登录都塞进一个几十种 <font color="red"><b>case</b></font> 的总枚举。建模边界看业务不变量，不看关键字偏好。

## 十七、<font id="ui-section-17">UIKit 与 SwiftUI 互操作</font>

### 1、<font id="ui-17-1">嵌入方向与系统版本分开处理</font>

| 谁装谁 | API | 用途 |
| --- | --- | --- |
| UIKit 装 SwiftUI 页面 | `UIHostingController` | 原有导航里 push / present 新页面 |
| UIKit Cell 装 SwiftUI 内容 | `UIHostingConfiguration`，iOS 16+ | 保留列表体系，只替换 Cell 内容 |
| SwiftUI 装 UIView | `UIViewRepresentable` | 文本编辑器、已有自定义视图等 |
| SwiftUI 装 UIViewController | `UIViewControllerRepresentable` | 已有控制器 / 系统控制器集成 |

这些 API 解决的是 UI 框架互操作。能嵌套，并不代表高版本 API 自动获得低版本兼容能力。

<a href="#ui-faq-37" style="color:red;font-weight:bold;">FAQ 37</a>

### 2、<font id="ui-17-2">D36：现有导航栈 push 一个 SwiftUI 页面</font>

```swift
import SwiftUI
import UIKit

@MainActor
func pushCounter(from navigationController: UINavigationController) {
    let host = UIHostingController(rootView: CounterDemo())
    host.title = "SwiftUI 计数器"
    navigationController.pushViewController(host, animated: true)
}
```

**这是 UIKit 调用片段。**从旧页面按钮事件中传入当前 navigationController；效果是原生导航栈进入 SwiftUI 计数器。

此时导航由 UIKit 管理，CounterDemo 内不再套 NavigationStack。不要出现两套返回栏、两个路径拥有者互相争抢返回行为。[UIHostingController 官方文档](https://developer.apple.com/documentation/swiftui/uihostingcontroller)。

局部嵌入时还必须完成控制器 containment：`addChild(host)` → 加入 host.view 并布局 → `host.didMove(toParent:)`；移除时对应 <font color="red"><b><code>willMove(toParent: nil)</code></b></font> → 移除 view → `removeFromParent()`。**只把 host.view 加进父视图，而不建立父子控制器关系是不完整的。**外层约束可继续使用既有 [**SnapKit**](https://github.com/SnapKit/SnapKit) 体系，SwiftUI 内部仍使用自己的布局方式。

### 3、<font id="ui-17-3">D37：UIKit Cell 用 SwiftUI 描述内容</font>

```swift
import SwiftUI
import UIKit

@MainActor
func configureStudyCell(_ cell: UITableViewCell, title: String, subtitle: String) {
    cell.contentConfiguration = UIHostingConfiguration {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(subtitle).foregroundStyle(.secondary)
        }
    }
}
```

**效果：**保留原有 UITableView 数据源和复用策略，Cell 内容由 SwiftUI 描述。调用方在配置已复用 Cell 时传入本次数据。

**推荐：**旧列表稳定，只想渐进尝试新内容。行级重要业务状态仍放模型，不能依赖 Cell 内容中的本地 State 恰好长期存活。[UIHostingConfiguration 官方文档](https://developer.apple.com/documentation/swiftui/uihostingconfiguration)。

### 4、<font id="ui-17-4">D38：SwiftUI 包一个 UIKit 开关，完整打通双向同步</font>

```swift
import SwiftUI
import UIKit

struct UIKitSwitch: UIViewRepresentable {
    @Binding var isOn: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isOn: $isOn)
    }

    func makeUIView(context: Context) -> UISwitch {
        let control = UISwitch()
        control.addTarget(context.coordinator,
                          action: #selector(Coordinator.changed(_:)),
                          for: .valueChanged)
        return control
    }

    func updateUIView(_ uiView: UISwitch, context: Context) {
        context.coordinator.isOn = $isOn
        if uiView.isOn != isOn {
            uiView.setOn(isOn, animated: false)
        }
    }

    static func dismantleUIView(_ uiView: UISwitch, coordinator: Coordinator) {
        uiView.removeTarget(coordinator,
                            action: #selector(Coordinator.changed(_:)),
                            for: .valueChanged)
    }

    @MainActor
    final class Coordinator: NSObject {
        var isOn: Binding<Bool>

        init(isOn: Binding<Bool>) {
            self.isOn = isOn
        }

        @objc func changed(_ sender: UISwitch) {
            isOn.wrappedValue = sender.isOn
        }
    }
}

struct UIKitSwitchDemo: View {
    @State private var enabled = false

    var body: some View {
        VStack {
            Text(enabled ? "已开启" : "已关闭")
            UIKitSwitch(isOn: $enabled)
            Button("从 SwiftUI 切换") { enabled.toggle() }
        }
        .padding()
    }
}
```

**效果：**点 UIKit 开关更新 SwiftUI 文案；点 SwiftUI 按钮反向更新开关。

| 方法 / 对象 | 责任 |
| --- | --- |
| `makeUIView` | 创建并配置 UIKit 视图，绑定事件 |
| `updateUIView` | 将最新 SwiftUI 输入同步到现存 UIKit 视图 |
| `Coordinator` | 作为引用类型承接代理 / Target-Action，向 SwiftUI 回传事件 |
| `dismantleUIView` | 拆卸监听或自有资源 |

`makeUIView` 不是全局只运行一次；它对应框架管理的这次实例生命周期。`updateUIView` 可反复执行，不能在里面反复创建控件或注册同一个监听。刷新 Coordinator 持有的 Binding，是为了不让它长期使用旧的输入通道。

程序同步值时应避免触发同一事件回写循环。上例的 `setOn` 不会自动发送 `.valueChanged`；换成其它控件要检查它的实际事件语义，必要时比较值 / 增加同步保护。

不要在 `updateUIView` 同步反向修改 SwiftUI 状态来“纠正页面”，也不要自行设置被 Representable 托管根视图的 frame / bounds 去抢布局。需要自适应尺寸时，评估 intrinsicContentSize 或 iOS 16+ `sizeThatFits` 桥接。[UIViewRepresentable 官方文档](https://developer.apple.com/documentation/swiftui/uiviewrepresentable)。

<a href="#ui-faq-38" style="color:red;font-weight:bold;">FAQ 38</a> · <a href="#ui-faq-39" style="color:red;font-weight:bold;">FAQ 39</a>

### 5、<font id="ui-17-5">D39：包装现有控制器</font>

```swift
import SwiftUI
import UIKit

struct ExistingControllerHost: UIViewControllerRepresentable {
    let makeController: @MainActor () -> UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        makeController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // 此教学壳没有可变输入；真实页面应在这里同步新的配置。
    }
}
```

**这是桥接壳片段。**使用时传入构造现有控制器的闭包。控制器创建 / 更新 / 拆卸与代理桥接的分工，和 UIViewRepresentable 一样。若某次输入改变意味着换一个完全不同的控制器，不能指望创建闭包每次更新都重新执行，需要明确身份或改为更新现存控制器。

### 6、<font id="ui-17-6">D40：向 Objective-C 暴露控制器入口</font>

```swift
import SwiftUI
import UIKit

@MainActor
@objc final class ExperiencePageFactory: NSObject {
    @objc static func makeCounterPage() -> UIViewController {
        UIHostingController(rootView: CounterDemo())
    }
}
```

Swift 工厂对外返回 `UIViewController`，OC 侧导入当前 target 自动生成的 `ProductModuleName-Swift.h`，再调用 `makeCounterPage` 并 push / present。实际头文件名以 target 的 Product Module Name 为准。

**边界：**OC 看不到 <font color="red"><b><code>some View</code></b></font>、Swift <font color="red"><b>struct</b></font> 和这类泛型 SwiftUI 接口；不要尝试给 View <font color="red"><b>struct</b></font> 直接加 <font color="red"><b><code>@objc</code></b></font>。此工厂只隐藏语言桥接细节，不会把 SwiftUI 运行时要求变低。

### 7、<font id="ui-17-7">渐进迁移与验收范围</font>

先选独立、依赖少的设置页 / 详情页，用 Hosting 接到现有导航；再选一个 Cell 内容试 UIHostingConfiguration；重型编辑器、复杂第三方地图、已有稳定集合布局继续用 UIKit。

验收边界包括：数据由谁拥有、返回谁负责、退出后任务是否取消、主题与字体是否一致、键盘和侧滑返回是否冲突、旧 OC 调用入口是否稳定。**技术新旧不是迁移收益的替代指标。**

<a href="#ui-faq-40" style="color:red;font-weight:bold;">FAQ 40</a>

## 十八、<font id="ui-section-18">性能、调试、无障碍与常见报错</font>

### 1、<font id="ui-18-1">先定位工作量，再谈“刷新太多”</font>

`body` 应便宜、可重复求值。大数组筛选排序、图片解码、格式器反复创建、同步磁盘读写、网络副作用，都不适合塞在 body 里。

拆成子 View 有助于阅读和形成清楚的依赖边界，但“文件拆开了”不自动保证更新次数减少；模型共享范围和实际读取位置更重要。

排查顺序：重现操作 → 使用 [**Instruments**](https://developer.apple.com/tutorials/instruments) 找耗时 / 频繁更新 → 检查状态依赖和身份 → 检查布局与绘制 → 改动后重测。不要只凭 <font color="red"><b><code>init</code></b></font> 的 print 次数断言“整个界面都重建了”。[Apple：Demystify SwiftUI performance](https://developer.apple.com/videos/play/wwdc2023/10160/)、[Optimize SwiftUI performance with Instruments](https://developer.apple.com/videos/play/wwdc2025/306/)。

<a href="#ui-faq-41" style="color:red;font-weight:bold;">FAQ 41</a>

### 2、<font id="ui-18-2">常见问题速查</font>

| 现象 / 报错 | 先检查 | 不要先做 |
| --- | --- | --- |
| 改了数据却不刷新 | 检查模型是否接入匹配的观察体系 | `.id(UUID())` 强制换身份 |
| 回来后状态丢了 | 检查视图分支、稳定 ID 与状态拥有者生命周期 | 到处改成全局单例 |
| 输入框光标 / 焦点乱跳 | ID 是否变化，绑定是否回写同一值，UIKit 同步是否重设文本 | 每次刷新重新创建 UITextField |
| `Type '()' cannot conform to 'View'` | 是否把赋值、print 等 Void 表达式放进构建器 | 给副作用套 AnyView |
| <font color="red"><b><code>Cannot assign to property: &#39;self&#39; is immutable</code></b></font> | 是否在 View 中直接修改普通值属性 | 把 View 改成 <font color="red"><b>class</b></font> 碰运气 |
| 缺少环境模型 | Root、Sheet、Preview、测试是否注入了同一种类型 | 无条件强制解包 |
| 更新过程中修改状态警告 | body / updateUIView / 测量回调是否反向改状态 | 全部 asyncAfter 掩盖循环 |
| 编译器无法及时类型检查表达式 | 表达式太复杂或某个参数类型错 | 立刻认定编译器性能差 |
| 输入或搜索结果回退 | 旧请求覆盖新请求，取消未传递 | 只加主线程派发 |
| 导航栏出现两层 | UIKit 导航和 NavigationStack 是否重复拥有 | 分别隐藏两边所有导航栏 |
| 快速滚动卡顿 | 大图解码、body 重活、布局测量、ID、更新频率 | 认为 List 必然比 UIKit 快 |
| 按钮变透明后仍可点 | opacity 没有关闭命中 | 只把文字颜色设透明 |

### 3、<font id="ui-18-3">D41：无障碍与大字号</font>

```swift
import SwiftUI

struct AccessibilityDemo: View {
    @State private var count = 0

    var body: some View {
        Button {
            count += 1
        } label: {
            Text("加一：\(count)")
                .font(.headline)
                .padding(12)
                .frame(minWidth: 44, minHeight: 44)
        }
        .accessibilityLabel("增加计数")
        .accessibilityValue("当前 \(count)")
        .accessibilityHint("每次增加一")
    }
}
```

**效果：**正常显示可点按钮，辅助功能能读出动作、当前值和提示。

语义字体如 `.body` / `.headline` 支持系统字体缩放；不要为了对齐固定高度截掉大字。验证深浅色、大号文字、横屏、窄容器、VoiceOver、减少动态效果，以及不只靠颜色表达状态。某些 Text 已有足够可读语义，不必给所有控件重复添加相同 label。

### 4、<font id="ui-18-4">预览与测试的验证范围</font>

Preview 适合快速检查排版和多种状态；它不是 UI 测试，也不证明导航、权限、输入法或异步取消流程正确。预览需要明确注入模型，网络用可控假数据。

模型单元测试验证输入到状态的规则；集成测试验证请求和错误处理；UI 测试验证用户操作；真机检查键盘、滚动、性能和系统交互。模型与服务分层的收益之一，就是可以不启动 UI 也测清业务边界。

<a href="#ui-faq-43" style="color:red;font-weight:bold;">FAQ 43</a>

## 十九、<font id="todo-demo">综合示例：待办清单</font>

### 1、<font id="ui-19-1">D42：模型拥有业务规则，View 负责绑定</font>

```swift
import SwiftUI
import Observation
import Foundation

struct TodoEntry: Identifiable {
    let id: UUID
    var title: String
    var isDone: Bool

    init(title: String) {
        id = UUID()
        self.title = title
        isDone = false
    }
}

@MainActor
@Observable
final class TodoStore {
    var items: [TodoEntry] = []

    var remainingCount: Int {
        items.filter { !$0.isDone }.count
    }

    func add(_ input: String) {
        let title = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        items.append(TodoEntry(title: title))
    }

    func removeCompleted() {
        items.removeAll { $0.isDone }
    }
}

struct TodoDemo: View {
    @State private var store = TodoStore()
    @State private var draft = ""

    private var canAdd: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            List {
                Section("新增") {
                    TextField("输入一项学习任务", text: $draft)
                        .onSubmit { add() }
                    Button("添加", action: add)
                        .disabled(!canAdd)
                }
                Section("待办，剩余 \(store.remainingCount) 项") {
                    if store.items.isEmpty {
                        Text("还没有任务")
                            .foregroundStyle(.secondary)
                    }
                    ForEach($store.items) { $item in
                        Toggle(item.title, isOn: $item.isDone)
                    }
                    .onDelete { offsets in
                        store.items.remove(atOffsets: offsets)
                    }
                }
            }
            .navigationTitle("SwiftUI 学习清单")
            .toolbar {
                Button("清理已完成") { store.removeCompleted() }
                    .disabled(!store.items.contains { $0.isDone })
            }
        }
    }

    private func add() {
        guard canAdd else { return }
        store.add(draft)
        draft = ""
    }
}
```

**如何运行：**把 App 根视图换成 `TodoDemo()`。UUID 在实体创建时生成一次，之后 Toggle 修改或删除前一项不会重新生成它。

### 2、<font id="ui-19-2">示例中的数据流与约束</font>

1、`draft` 是当前页面未提交的输入，所以放 State。

2、`store` 是页面拥有的现代可观察模型，所以由 State 稳定保有；业务规则由 Store 处理。

3、`remainingCount` 从 items 推导，不再另外维护一个容易不同步的计数变量。

4、`$store.items` 将数组元素编辑接回同一真值，不复制出第二套待办列表。

5、`TodoEntry.id` 是稳定身份；修改 title / isDone 不更换 ID。

6、按钮禁用改善交互，方法内部 <font color="red"><b>guard</b></font> 维护业务边界，两者不能互相替代。

7、模型直接暴露 items 是教学简化；若每次修改都必须经过审计 / 远程保存，可改成私有写入 + `toggle(id:)`、`delete(id:)` 等意图方法，而不是让所有子视图任意 Binding 写入。

### 3、<font id="ui-19-3">手动验收清单与生产边界</font>

| 操作 | 期望结果 |
| --- | --- |
| 输入纯空格 | 不新增 |
| 新增两个任务 | 显示两行，剩余 2 项 |
| 勾选第一项 | 剩余变为 1 项 |
| 删除第一项 | 第二项内容和状态仍对应原任务 |
| 清理已完成 | 只删除已勾选项 |
| 删除所有任务 | 出现空态 |
| 关闭并重新启动 App | 允许恢复为空，因为没有持久化 |

此示例未包含数据库、云同步、撤销、账号隔离与冲突处理。生产接入时逐项补齐，并分别验证持久化和异步错误状态。

## 二十、<font id="decision">日常开发选型</font>

### 1、<font id="ui-20-1">状态与通信选型</font>

| 我现在要做什么 | 首选 | 为什么 / 何时换方案 |
| --- | --- | --- |
| 当前页展开 / 收起、选中项 | <font color="red"><b><code>@State</code></b></font> | 页面暂态；跨页面则提升拥有者 |
| 子组件展示父数据 | 普通值参数 | 不需要写权限就不给 Binding |
| 子组件编辑父数据 | <font color="red"><b><code>@Binding</code></b></font> | 修改同一真值 |
| 子组件告诉父“用户点保存” | 闭包 | 上报意图，父层决定业务 |
| iOS 17+ 页面拥有模型 | <font color="red"><b><code>@State + @Observable</code></b></font> | 先确保新体系符合部署版本 |
| 子组件需要现代模型的属性绑定 | <font color="red"><b><code>@Bindable</code></b></font> | 不负责替父层创建长期模型 |
| 老模型由当前 View 创建 | <font color="red"><b><code>@StateObject</code></b></font> | 维护当前身份下对象存储 |
| 老模型由外部传入 | <font color="red"><b><code>@ObservedObject</code></b></font> | 订阅，外部负责生命周期 |
| 子树共享现代模型 | <font color="red"><b><code>@Environment(Model.self)</code></b></font> | 上游 `.environment(model)` |
| 子树共享旧模型 | <font color="red"><b><code>@EnvironmentObject</code></b></font> | 上游 `.environmentObject(model)` |
| 用户偏好 | <font color="red"><b><code>@AppStorage</code></b></font> | 小型 UserDefaults 值，不存凭据 |
| 窗口恢复 | <font color="red"><b><code>@SceneStorage</code></b></font> | 不保证业务数据可靠落盘 |
| 表单焦点 | <font color="red"><b><code>@FocusState</code></b></font> | 多字段选可选枚举 |
| 手势中的瞬时值 | <font color="red"><b><code>@GestureState</code></b></font> | 松手自动复位，最终值用 State |

### 2、<font id="ui-20-2">UI 与任务选型</font>

| 需求 | 首选 | 关键边界 |
| --- | --- | --- |
| 横排 / 竖排 / 简单叠层 | Stack | 不把 GeometryReader 当默认根 |
| 页底固定操作栏 | `safeAreaInset` | 不无意覆盖滚动内容 |
| 系统行为列表 | `List` | 身份仍需稳定 |
| 大量定制卡片 | ScrollView + Lazy 容器 | 分页和内存策略自己负责 |
| 普通层级导航 | `NavigationStack` | 路由数据化，单一导航拥有者 |
| iPad 多栏 | `NavigationSplitView` | 考虑紧凑宽度退化行为 |
| 编辑某个选中对象 | `.sheet(item:)` | 数据与是否展示合为一份状态 |
| 布尔展示状态 | `.sheet(isPresented:)` | 不为简单展示硬造模型 |
| 页面加载请求 | `.task` | 配合缓存 / 幂等门禁 |
| 搜索词变化重新加载 | `.task(id:)` | 防抖、取消、旧结果保护 |
| 下拉刷新 | `.refreshable` 内直接 <font color="red"><b>await</b></font> | 不另起不等待的任务 |
| 必须跨页面继续上传 | 服务层拥有任务 | 页面只订阅进度 |
| 简单轻量值变化副作用 | `.onChange` | 不执行长同步任务 |
| 老 App 新 SwiftUI 页面 | Hosting Controller | 不要求改 App 入口 |
| 老 Cell 新内容 | Hosting Configuration | iOS 16+，状态仍归模型 |
| SwiftUI 缺成熟控件能力 | Representable | 生命周期、回调和布局要桥接完整 |

## 二十一、<font id="ui-section-21">练习、迁移索引与验证</font>

### 1、<font id="ui-21-1">练习顺序</font>

1、先跑 D01、D04、D05：读懂 View、body、闭包和 modifier 顺序。

2、再跑 D07、D08、D09：摆布局；刻意在窄宽度、大字号和深色下看一遍。

3、跑 D11、D12、D14、D16：把 State / Binding / 闭包 / 两套模型观察体系区分清楚。

4、跑 D20、D22：体验列表稳定 ID 和主动换身份的差别。

5、跑 D23、D24、D28、D32：把路由、弹窗、请求和编辑草稿放回正确的生命周期。

6、从 UIKit 调用 D36，再跑 D38：做一次真正的双向混用。保留已有 UIKit 能力。

7、运行 D42，验证综合示例的数据流七点，再练习末尾 FAQ。

<a href="#ui-faq-44" style="color:red;font-weight:bold;">FAQ 44</a>

### 2、<font id="ui-21-2">迁移内容索引</font>

| 从 Swift 文档归入的主题 | 本文位置 |
| --- | --- |
| View 使用 <font color="red"><b>struct</b></font> 的原因 | <a href="#ui-2-3" style="color:red;font-weight:bold;">视图描述、身份与资源</a> |
| <font color="red"><b>some</b></font> View 与 ViewBuilder | <a href="#ui-3-3" style="color:red;font-weight:bold;">类型表达</a>、<a href="#ui-3-4" style="color:red;font-weight:bold;">分支构建</a> |
| SwiftUI App 入口 | <a href="#ui-3-2" style="color:red;font-weight:bold;">App、Scene、View</a> |
| Text、TextField、Button | <a href="#ui-3-1" style="color:red;font-weight:bold;">计数器</a>、<a href="#ui-3-5" style="color:red;font-weight:bold;">输入与闭包</a> |
| List、LazyVGrid、LazyHGrid | <a href="#ui-10-1" style="color:red;font-weight:bold;">列表</a>、<a href="#ui-10-2" style="color:red;font-weight:bold;">Lazy 容器</a> |
| 状态包装器、模型观察、持久化标记 | <a href="#ui-6-2" style="color:red;font-weight:bold;">State / Binding</a>、<a href="#ui-7-1" style="color:red;font-weight:bold;">Observation</a>、<a href="#ui-9-3" style="color:red;font-weight:bold;">其他标记</a> |
| UIHostingController 与 UIViewRepresentable | <a href="#ui-17-2" style="color:red;font-weight:bold;">Hosting</a>、<a href="#ui-17-4" style="color:red;font-weight:bold;">双向同步</a> |

同义内容合并到既有章节，避免重复保留多个简单控件示例；通用泛型、属性包装器和并发语言机制仍在 Swift 文档维护。

### 3、<font id="ui-21-3">本地参考文档</font>

- [Swift 相关经验](/Users/jobs/Documents/Github/JobsBaseConfig/JobsBaseConfig@JobsSwiftBaseConfigDemo/SwiftDoc.md/Swift相关经验.md/Swift相关经验.md)：参考了属性包装器、<font color="red"><b>some</b></font>、Actor 的场景 / 边界说明，以及桥接片段写法。
- [OC 相关经验](/Users/jobs/Documents/Github/JobsBaseConfig/JobsBaseConfig@JobsOCBaseConfigDemo/OCDoc.md/OC相关经验.md/OC相关经验.md)：参考了 UIKit 生命周期、列表性能和 FAQ 的实战组织方式。

本页与 Swift 语言文档各自维护所属知识，使用上述链接互相跳转。

### 4、<font id="ui-21-4">验证范围</font>

本文的“效果”描述是示例期望，不代表全部经过真机运行。

- 原有记录：2026-08-30 的 42 组示例曾按 iOS 17 模拟器目标执行 Swift 6 类型检查；该记录不是当前轮次的运行证明。
- 本轮检查（2026-08-31）：42 段 SwiftUI 示例合并后，以 iOS 17 模拟器目标通过 Swift 6 严格类型检查，警告视为错误；另检查标题 ID、FAQ 双向链接、序号和代码围栏。
- 未执行：完整 App 构建与签名、模拟器 / 真机交互、真实网络请求、旧系统逐版本运行、VoiceOver 与性能实测。
- 示例统一以 iOS 17+ 为运行基线，不能仅凭单个 API 的最低版本推断整段示例兼容范围。

## 二十二、<font id="faq">FAQ：面试问答</font>

> 使用方式：先练熟每题的“期望回答”，再看追问。回答可以承认工程取舍，不要承诺“永远只刷新一处”“只调用一次”“用了 <font color="red"><b>actor</b></font> 就一定线程安全”。下列回答是可直接口述的参考表达，不是声称自己做过尚未实践的项目。

### 1、<font id="ui-faq-1">SwiftUI 和 UIKit 最大的区别是什么？</font>

**期望回答：**UIKit 常以持有 UI 对象并更新其属性为主要组织方式；SwiftUI 主要声明状态和界面的映射，状态变化后由框架协调更新。UIKit 对底层控件、生命周期和成熟复杂场景控制更直接；SwiftUI 在组合界面和状态驱动表达上更简洁。两者可以渐进混用，不需要互相替代到底。

**追问：UIKit 不能响应式吗？**

**答案：**可以使用绑定、<font color="red"><b>Combine</b></font> 等构建响应式层。这里比较的是框架主导模型，不是说 UIKit 只能手工逐句赋值。

<a href="#ui-2-1" style="color:red;font-weight:bold;">返回知识点</a>

### 2、<font id="ui-faq-2">为什么 SwiftUI View 通常用 <font color="red"><b>struct</b></font>？</font>

**期望回答：**View 用于轻量描述界面，值语义适合组合和反复产生新描述；持久状态由框架按身份管理，不要求一个长期存活的 View 对象。选择 <font color="red"><b>struct</b></font> 的理由不是“它永远在栈上且一定更快”。

**追问：View 是 <font color="red"><b>struct</b></font>，所以不能存在引用类型吗？**

**答案：**可以持有模型引用，现代可观察模型也常用 <font color="red"><b>class</b></font>。View 描述和值模型的隔离 / 生命周期是不同问题。

<a href="#ui-2-3" style="color:red;font-weight:bold;">返回知识点</a>

### 3、<font id="ui-faq-3">body 是什么，能在里面请求网络吗？</font>

**期望回答：**body 是描述当前界面的计算属性，可以反复求值，应保持便宜且无业务副作用。网络应放到关联任务或模型 / 服务层，由明确生命周期触发。

**追问：body 运行很多次就一定性能差吗？**

**答案：**不一定。要看每次计算成本、依赖传播、布局和绘制负担，用 Instruments 测，不只数 print。

<a href="#ui-3-1" style="color:red;font-weight:bold;">返回知识点</a>

### 4、<font id="ui-faq-4"><font color="red"><b>some</b></font> View 到底是什么意思？</font>

**期望回答：**它是不透明返回类型：编译器知道一个确定的具体 View 类型，调用方不必知道长的组合类型名。它保留类型身份，不是任意协议对象容器。

**追问：为什么 <font color="red"><b>if</b></font> 两边一个 Text、一个 ProgressView 也能写？**

**答案：**在 ViewBuilder 中，分支被组合成确定的结果类型；不是 <font color="red"><b>some</b></font> 允许普通函数随意返回不同底层类型。

<a href="#ui-3-3" style="color:red;font-weight:bold;">返回知识点</a>

### 5、<font id="ui-faq-5">ViewBuilder 是什么？</font>

**期望回答：**在本文 Xcode 26 基线下，它是结果构建器，把多条视图表达式和支持的控制流转换成组合结果，让我们用声明式语法写内容层级。它不是运行时把每一行 addSubview 一次的脚本。

**追问：为什么不能在 VStack 中直接写 count += 1？**

**答案：**那是修改状态的副作用，不是视图内容表达式；同时求值又改依赖会破坏更新流程，应放到按钮事件等动作中。

<a href="#ui-3-4" style="color:red;font-weight:bold;">返回知识点</a>

### 6、<font id="ui-faq-6"><font color="red"><b>some</b></font> View、<font color="red"><b>any</b></font> View、AnyView 的区别？</font>

**期望回答：**<font color="red"><b>some</b></font> View 隐藏但保留确定类型；<font color="red"><b>any</b></font> View 是语言的协议存在类型；AnyView 是 SwiftUI 的类型擦除包装，本身是一个 View。普通页面优先 <font color="red"><b>some</b></font> 和泛型，确有运行时异构存储需求才考虑 AnyView。

**追问：AnyView 一定会卡顿吗？**

**答案：**不一定，但会隐藏静态类型信息，可能影响优化、身份推断和诊断。不能为了解决所有分支类型错误到处包 AnyView，应先改善结构并测量。

<a href="#ui-3-3" style="color:red;font-weight:bold;">返回知识点</a>

### 7、<font id="ui-faq-7">Modifier 是在修改原来的 View 吗？</font>

**期望回答：**通常是在组合新的视图描述或行为，不是像 UIView 一样对同一个实例连续赋属性。因此 modifier 顺序会影响布局、绘制和环境作用范围。

**追问：padding 和 background 为什么不能随便交换？**

**答案：**先 padding，background 会覆盖包含留白的结果；先 background，再 padding，外层留白不属于之前的背景范围。

<a href="#ui-4-1" style="color:red;font-weight:bold;">返回知识点</a>

### 8、<font id="ui-faq-8">State 为什么不会随 View <font color="red"><b>struct</b></font> 重建就清零？</font>

**期望回答：**State 的有效存储由 SwiftUI 关联到视图身份，不简单等于某次临时 <font color="red"><b>struct</b></font> 的普通字段。保持同一身份时可以保留，身份结束或改变时会重新建立。

**追问：父参数变了，<font color="red"><b>init</b></font> 里重新给 State 初值为什么没覆盖？**

**答案：**初始值不是持续同步命令。需要联动用 Binding 或明确同步逻辑；需要全新会话才按业务身份重置。

<a href="#ui-6-2" style="color:red;font-weight:bold;">返回知识点</a>

### 9、<font id="ui-faq-9">State 和 Binding 怎么选？</font>

**期望回答：**State 表达当前拥有者的 UI 状态；Binding 表达对子树之外某个真值的读写通道。父拥有 State，子通过 Binding 修改同一份数据，避免双份状态同步。

**追问：Binding 会复制父数据吗？**

**答案：**不会另建一份权威存储，它封装读写访问。拿到当前值再另存到 State，才产生独立副本语义。

<a href="#ui-6-2" style="color:red;font-weight:bold;">返回知识点</a>

### 10、<font id="ui-faq-10">$name、_name、name 有什么区别？</font>

**期望回答：**在 State 示例里，name 是包装后的值，$name 是 projectedValue，也就是 Binding；_name 是包装器存储，常在自定义初始化时使用。它们不是地址运算。

**追问：$model 在所有包装器里含义都相同吗？**

**答案：**不相同，投影类型由包装器定义。FocusState 的投影、<font color="red"><b>Combine</b></font> 的 Published Publisher 与 State 的 Binding 不能混用。

<a href="#ui-6-4" style="color:red;font-weight:bold;">返回知识点</a>

### 11、<font id="ui-faq-11">Observable 宏解决什么，不解决什么？</font>

**期望回答：**它为模型生成变化观察支持，让 SwiftUI 根据读取的可观察属性建立依赖。它不提供数据库、网络、自动线程安全或请求去重；UI 模型的 <font color="red"><b>MainActor</b></font> 隔离和业务规则仍要单独设计。

**追问：是不是所有属性都要加 Published？**

**答案：**现代 Observation 模型通常不用 Published，Published 属于旧 ObservableObject / <font color="red"><b>Combine</b></font> 流程。

<a href="#ui-7-3" style="color:red;font-weight:bold;">返回知识点</a>

### 12、<font id="ui-faq-12">Bindable 和 Binding 的区别？</font>

**期望回答：**Binding 是某个具体值的双向读写通道；Bindable 用于给现代可观察对象生成其可写属性的绑定，例如 `$model.name`。Bindable 不代替 State 管理自己创建模型的持久存储。

**追问：只显示现代模型的名字需要 Bindable 吗？**

**答案：**一般不需要，传入模型引用并在 body 里读取可观察属性即可；要给 TextField 形成绑定时才需要相应投影。

<a href="#ui-7-1" style="color:red;font-weight:bold;">返回知识点</a>

### 13、<font id="ui-faq-13">StateObject 与 ObservedObject 怎么选？</font>

**期望回答：**旧式 ObservableObject 由当前 View 创建并负责生命周期时用 StateObject；外部传入已管理好的实例时用 ObservedObject。核心是所有权和稳定存储，不是“一个刷新、一个不刷新”。

**追问：ObservedObject 是弱引用吗？**

**答案：**不是。外部拥有是架构责任描述，不等于 ARC <font color="red"><b>weak</b></font>。

<a href="#ui-8-1" style="color:red;font-weight:bold;">返回知识点</a>

### 14、<font id="ui-faq-14">为什么不能把 ObservableObject 简单放进 State？</font>

**期望回答：**本文基线的 State 可以管理引用值，但不会因此自动订阅旧对象内部 Published 的变化。旧对象用对应对象包装器；现代 Observable 则有另一套 SwiftUI Observation 集成。

**追问：普通 <font color="red"><b>class</b></font> 呢？**

**答案：**只改普通 <font color="red"><b>class</b></font> 内部字段不会凭空出现观察机制；必须让变化成为框架能观察的输入，或更换完整值 / 引用。

<a href="#ui-8-2" style="color:red;font-weight:bold;">返回知识点</a>

### 15、<font id="ui-faq-15">EnvironmentObject 和 Environment 是全局单例吗？</font>

**期望回答：**不是。它们读取视图树作用域里的依赖，生命周期由创建者负责。旧对象通过 EnvironmentObject 注入读取，现代模型可以按类型使用 Environment；系统环境值也通过 Environment 读取。

**追问：为什么 Preview 崩了但 App 不崩？**

**答案：**预览可能没有走正式 Root 的注入。Preview、测试和独立展示入口都需要提供依赖。

<a href="#ui-9-1" style="color:red;font-weight:bold;">返回知识点</a>

### 16、<font id="ui-faq-16">闭包和 Binding 什么时候各用一个？</font>

**期望回答：**持续编辑一个值用 Binding；保存、删除、重试等业务意图用闭包或模型方法。不能为了传一次点击事件把整个父模型都开放给子组件任意改。

**追问：如何支持取消编辑？**

**答案：**编辑本地草稿，保存时提交，取消时丢弃。直接绑定正式数据后 dismiss 不会自动撤销已发生的修改。

<a href="#ui-6-3" style="color:red;font-weight:bold;">返回知识点</a>

### 17、<font id="ui-faq-17">AppStorage 和 SceneStorage 有什么区别？</font>

**期望回答：**AppStorage 连接 UserDefaults，适合应用偏好；SceneStorage 管理每个 Scene 的轻量恢复状态。二者都不是完整业务数据库，也不适合存敏感凭据。

**追问：SceneStorage 能保证草稿绝不丢吗？**

**答案：**不能，保存时机和 Scene 生命周期由系统控制。重要草稿要建立明确持久化机制。

<a href="#ui-9-2" style="color:red;font-weight:bold;">返回知识点</a>

### 18、<font id="ui-faq-18">SwiftUI 布局和 Auto Layout 有什么不同？</font>

**期望回答：**SwiftUI 主要通过父层提出尺寸、子层选择尺寸、父层安排位置来协商布局；Auto Layout 主要求解约束关系。不能把每个 frame modifier 当成一条 NSLayoutConstraint。

**追问：maxWidth: .infinity 就是屏幕宽度吗？**

**答案：**不是，它表示在父层允许的范围内扩展；在 Sheet、SplitView 或卡片内部，它面对的是该容器的空间。

<a href="#ui-5-1" style="color:red;font-weight:bold;">返回知识点</a>

### 19、<font id="ui-faq-19">offset、padding、frame 有什么区别？</font>

**期望回答：**padding 为布局加入边距；frame 包裹并约束布局尺寸；offset 改变呈现位置但不让兄弟按偏移后的结果重新腾出空间。排版优先用布局关系，偏移用于明确的视觉位移。

**追问：frame 会自动裁剪越界内容吗？**

**答案：**不会保证，需要明确 clipped 或 clipShape，绘制范围与布局范围不能混为一谈。

<a href="#ui-5-3" style="color:red;font-weight:bold;">返回知识点</a>

### 20、<font id="ui-faq-20">GeometryReader 为什么经常把布局撑满？</font>

**期望回答：**它本身是参与布局的容器，倾向使用父层提供的空间，不是没有尺寸影响的测量函数。只有需要几何信息时才用，并在滚动等环境中明确自身尺寸。

**追问：简单两列要用它吗？**

**答案：**通常不需要，HStack / Grid / LazyVGrid 更直接。复杂自定义测量和摆放才进一步考虑 Layout。

<a href="#ui-5-5" style="color:red;font-weight:bold;">返回知识点</a>

### 21、<font id="ui-faq-21">List 和 ForEach 有什么区别？</font>

**期望回答：**List 是提供列表布局和平台行为的容器；ForEach 根据数据与身份生成重复内容，可以放进 List、Stack 或 Grid。ForEach 本身不提供滚动。

**追问：能用 Array.forEach 返回视图吗？**

**答案：**Array.forEach 是执行副作用并返回 Void 的方法，不是 SwiftUI 的数据驱动内容生成器。

<a href="#ui-10-1" style="color:red;font-weight:bold;">返回知识点</a>

### 22、<font id="ui-faq-22">为什么列表不能随便用数组下标当 ID？</font>

**期望回答：**插入、删除或重排后，下标指向的业务实体会改变，框架可能把旧行状态关联到新实体。列表需要同一实体稳定、不同实体唯一的 ID。

**追问：UUID 是否一定错？**

**答案：**实体创建时生成一次并保存没有问题；计算属性每读一次生成或每次刷新给同一实体换 UUID 才有问题。

<a href="#ui-10-3" style="color:red;font-weight:bold;">返回知识点</a>

### 23、<font id="ui-faq-23">结构身份和显式身份是什么？</font>

**期望回答：**结构身份来自视图类型和结构位置；显式身份来自 ForEach 数据 ID 或 id modifier 等。身份影响状态生命周期、转场和增量更新。

**追问：.id 可以用来重置表单吗？**

**答案：**可以，在明确的新编辑会话上有意义；但不应把不断更换 ID 当成刷新补丁。

<a href="#ui-10-3" style="color:red;font-weight:bold;">返回知识点</a>

### 24、<font id="ui-faq-24">LazyVStack 一定比 VStack 快吗？</font>

**期望回答：**不一定。Lazy 适合大量按需展示内容；少量视图用 VStack 简单直接。实际性能还受测量、身份、图片和数据更新影响。

**追问：Lazy 是否保证离屏就释放？**

**答案：**没有这种逐项确定承诺，也不等于禁止预取或提前测量。重要状态不要依赖离屏销毁时机。

<a href="#ui-10-2" style="color:red;font-weight:bold;">返回知识点</a>

### 25、<font id="ui-faq-25">NavigationStack 路径应该存什么？</font>

**期望回答：**存能描述目的地的 Hashable 路由数据，例如路由枚举和业务 ID。统一类型可用数组，异构路径可用 NavigationPath，不存 UIViewController。

**追问：怎样返回根页？**

**答案：**由路径拥有者清空 path。系统返回也会同步路径；不要另外维护一套互不一致的“当前页编号”。

<a href="#ui-11-1" style="color:red;font-weight:bold;">返回知识点</a>

### 26、<font id="ui-faq-26">sheet(item:) 为什么经常更合适？</font>

**期望回答：**展示某个对象时，可选 item 同时表达是否展示和展示谁，避免 Bool 为 <font color="red"><b>true</b></font> 但选中数据还是 <font color="red"><b>nil</b></font> 的矛盾。只有是否展示的需求仍适合 Bool。

**追问：dismiss 为什么有时没作用？**

**答案：**检查读取的环境上下文。应从真正被展示的内容内部获取，且确认展示 / 导航由 SwiftUI 还是 UIKit 管理。

<a href="#ui-11-2" style="color:red;font-weight:bold;">返回知识点</a>

### 27、<font id="ui-faq-27">onAppear 等于 viewDidLoad 吗？</font>

**期望回答：**不等于。它是内容出现时的回调，可能多次执行；View <font color="red"><b>init</b></font>、body、appear、任务和身份生命周期没有 UIKit 回调的一一映射。

**追问：首次请求放哪里？**

**答案：**页面关联异步工作常用 task，但是否需要再次加载应由模型结合缓存、身份和请求状态判断。

<a href="#ui-12-1" style="color:red;font-weight:bold;">返回知识点</a>

### 28、<font id="ui-faq-28">task 和 task(id:) 区别是什么？</font>

**期望回答：**二者都用于关联视图的异步工作；task(id:) 还在 ID 变化时取消旧工作并启动新工作，适合搜索词或详情 ID 变化。两者都需要配合协作式取消。

**追问：搜索防抖怎么做？**

**答案：**在 task(id:) 内先做可取消 sleep，再请求，提交前检查取消和当前请求身份。不要把取消当成错误 Alert。

<a href="#ui-13-1" style="color:red;font-weight:bold;">返回知识点</a>

### 29、<font id="ui-faq-29">取消请求后为什么旧结果还会回来？</font>

**期望回答：**取消只是协作信号，底层任务可能不支持、未传递，或结果已在路上。提交时还要检查任务取消与请求序号；同词重试不能只比较查询词。

**追问：旧请求结束能否统一把 loading 设为 <font color="red"><b>false</b></font>？**

**答案：**不能无条件这么做，旧请求可能关闭新请求的 loading。只有仍为当前请求的执行单元才能提交和清理当前状态。

<a href="#ui-13-1" style="color:red;font-weight:bold;">返回知识点</a>

### 30、<font id="ui-faq-30"><font color="red"><b>async</b></font> / <font color="red"><b>Task</b></font> 就代表后台执行吗？</font>

**期望回答：**不代表。<font color="red"><b>async</b></font> 允许挂起，<font color="red"><b>Task</b></font> 是调度与生命周期抽象，并受隔离上下文影响。真正的异步等待可以让出执行机会，但同步重计算仍占用所在执行器。

**追问：给整个 ViewModel 加 <font color="red"><b>MainActor</b></font> 后能在里面解码巨大 JSON 吗？**

**答案：**会有阻塞 UI 的风险。应将重活放入合适的非 UI 服务 / 隔离域，返回可安全跨域传递的数据后更新 UI 状态。

<a href="#ui-13-4" style="color:red;font-weight:bold;">返回知识点</a>

### 31、<font id="ui-faq-31">Observable 是否自带线程安全？</font>

**期望回答：**观察机制不等于并发隔离。UI 模型可以明确 <font color="red"><b>MainActor</b></font>，跨任务共享服务可以 <font color="red"><b>actor</b></font> 或其它正确同步机制；业务跨 <font color="red"><b>await</b></font> 的不变量仍要自己保护。

**追问：State 的文档说可以跨线程修改，为什么还推荐 <font color="red"><b>MainActor</b></font> UI 模型？**

**答案：**单个 State 存储的安全保证不等于整个 UI 模型、UIKit 对象或一组业务操作都线程安全。隔离域要覆盖真正的业务状态和 UI 访问，而不是扩大解释一个包装器的保证。

<a href="#ui-7-4" style="color:red;font-weight:bold;">返回知识点</a>

### 32、<font id="ui-faq-32">为什么 refreshable 里面要 <font color="red"><b>await</b></font>？</font>

**期望回答：**刷新任务完成时机应该和实际工作一致。直接 <font color="red"><b>await</b></font> 让系统刷新表现跟随工作；只启动不等待的新 <font color="red"><b>Task</b></font> 后返回，会让两者脱节。

**追问：上传离开页面后还要继续呢？**

**答案：**那不是页面暂态工作，由服务层持有任务，页面订阅进度；是否使用系统后台传输能力再按需求决定。

<a href="#ui-13-2" style="color:red;font-weight:bold;">返回知识点</a>

### 33、<font id="ui-faq-33">FocusState 怎么管理多个输入框？</font>

**期望回答：**用可选 Hashable 枚举表达当前焦点，每个字段绑定不同 <font color="red"><b>case</b></font>；修改值切换焦点，设 <font color="red"><b>nil</b></font> 取消焦点。它比多个互相冲突的 Bool 更清楚。

**追问：怎样保证密码不泄露？**

**答案：**SecureField 只解决呈现遮蔽，不等于安全存储。不要打印、写普通偏好或把密码放进无关日志，认证和凭据存储另按安全流程设计。

<a href="#ui-14-1" style="color:red;font-weight:bold;">返回知识点</a>

### 34、<font id="ui-faq-34">withAnimation 和 transition 的区别？</font>

**期望回答：**withAnimation 建立状态变化的动画上下文；transition 描述视图插入和移除时怎么表现。已有视图的大小变化和视图进入离开是不同问题。

**追问：只写 transition 为什么没有动画？**

**答案：**要有真实的插入 / 移除、合适身份和带动画的更新事务；单独声明过渡并不主动改变状态。

<a href="#ui-15-1" style="color:red;font-weight:bold;">返回知识点</a>

### 35、<font id="ui-faq-35">GestureState 与 State 的区别？</font>

**期望回答：**GestureState 适合手势过程中的临时值，并在手势结束后复位；State 保存需要继续存在的最终位置或业务状态。拖动时临时位移和松手后的最终位置可以分开建模。

**追问：普通点击为什么优先 Button？**

**答案：**它自带可点击控件语义、焦点与无障碍支持，不需要用手势重新补齐这些基础行为。

<a href="#ui-15-2" style="color:red;font-weight:bold;">返回知识点</a>

### 36、<font id="ui-faq-36">SwiftUI 是否必须 MVVM？</font>

**期望回答：**不必须。简单组件可以使用本地状态和组合；复杂页面把业务状态和服务编排拆到模型层以提升可测试性。MVVM 是选择，不是遵循 View 协议的前置条件。

**追问：怎么判断何时该拆 ViewModel？**

**答案：**看业务复杂度、异步流程、共享状态和独立测试需求，不看 View 是否超过某个随意设定的行数。

<a href="#ui-16-2" style="color:red;font-weight:bold;">返回知识点</a>

### 37、<font id="ui-faq-37">UIHostingController 和 UIViewRepresentable 区别？</font>

**期望回答：**Hosting Controller 把 SwiftUI 放进 UIKit；UIViewRepresentable 把 UIKit UIView 放进 SwiftUI。包装控制器则用 UIViewControllerRepresentable；两者方向相反，都是互操作，不是系统版本兼容的别名。

**追问：OC 可以直接创建一个 SwiftUI <font color="red"><b>struct</b></font> 吗？**

**答案：**不能按 OC 对象模型直接使用。通过 Swift 的 OC 可见工厂返回 UIViewController，再走 OC 既有导航。

<a href="#ui-17-1" style="color:red;font-weight:bold;">返回知识点</a>

### 38、<font id="ui-faq-38">Representable 为什么需要 Coordinator？</font>

**期望回答：**它作为稳定引用对象承接 delegate / Target-Action 等回调，把 UIKit 事件反馈到绑定或模型。Representable 自身是会重建的值描述，不适合直接充当长期 NSObject 代理。

**追问：Coordinator 为什么要更新 parent 或 Binding？**

**答案：**避免持续使用创建时捕获的旧输入。每次更新应同步当前依赖，但不要重复注册相同监听。

<a href="#ui-17-4" style="color:red;font-weight:bold;">返回知识点</a>

### 39、<font id="ui-faq-39">makeUIView 与 updateUIView 怎么分工？</font>

**期望回答：**make 创建这一生命周期的 UIKit 实例和基础配置；update 将最新输入同步到现存实例；dismantle 清理自有监听和资源。update 要可重复执行、避免反馈循环。

**追问：可以在 updateUIView 里改 SwiftUI State 吗？**

**答案：**不应把同步更新流程变成同步反向状态修改，容易产生更新期警告或循环。真正用户事件从回调通道上报，测量等反馈需按相应生命周期设计。

<a href="#ui-17-4" style="color:red;font-weight:bold;">返回知识点</a>

### 40、<font id="ui-faq-40">旧项目如何低风险接入 SwiftUI？</font>

**期望回答：**先用 Hosting 接一个边界清楚的新页面，或用 Hosting Configuration 替换一个 Cell 内容；保留现有导航、成熟 UIKit 控件和服务层。明确状态、任务和导航谁拥有，并测返回、键盘、主题、性能和最低系统版本。

**追问：为什么不直接全部重写？**

**答案：**迁移目标是可验证的开发和维护收益。稳定复杂模块重写成本高、回归风险大，应逐步评估，技术新并不自动意味着业务收益大。

<a href="#ui-17-7" style="color:red;font-weight:bold;">返回知识点</a>

### 41、<font id="ui-faq-41">State 变化是不是只刷新一个 Text？</font>

**期望回答：**不能这样承诺。依赖变化会使相关描述失效并触发更新，但 body 求值、布局和实际绘制不是同一层。现代观察能表达更细依赖，实际更新范围仍由结构与运行时共同决定。

**追问：怎么减少无关更新？**

**答案：**把依赖读取放在恰当子组件，缩小共享状态范围、保持稳定身份、避免 body 重活，并用性能工具验证。

<a href="#ui-18-1" style="color:red;font-weight:bold;">返回知识点</a>

### 42、<font id="ui-faq-42">所有状态都放一个 AppStore 可以吗？</font>

**期望回答：**可以建立统一架构，但不能不区分作用域地混放。登录会话、路由、页面草稿、行临时状态有不同生命周期和权限；过大共享模型增加耦合和更新影响范围。

**追问：两个兄弟页面共享一个值怎么办？**

**答案：**把真值提升到共同稳定拥有者，通过参数、Binding 或明确环境注入共享，不在两边各建一份再靠通知互相抄。

<a href="#ui-16-2" style="color:red;font-weight:bold;">返回知识点</a>

### 43、<font id="ui-faq-43">如何验证一个 SwiftUI 页面？</font>

**期望回答：**模型单测业务规则，服务测试网络和取消，Preview 检查可控状态布局，UI 测试验证操作流程，真机检查键盘、无障碍、滚动和性能。不同验证层不能互相替代。

**追问：编译通过是不是说明 State 生命周期正确？**

**答案：**不是。类型检查只能发现一部分语法和 API 使用问题，身份重置、焦点、并发时序等必须通过行为测试验证。

<a href="#ui-18-4" style="color:red;font-weight:bold;">返回知识点</a>

### 44、<font id="ui-faq-44">如果没有实际 SwiftUI 项目经验，面试怎么回答？</font>

**期望回答：**我的主要生产经验在 UIKit，目前已系统学习 SwiftUI 的状态归属、身份、导航和混用。我会先在独立页面或 Cell 中渐进接入，并用小 Demo 验证行为。对尚未做过的生产规模或问题，我会明确说明，再讲设计和验证方法，不把练习包装成真实上线经历。

**追问：能立刻写一个什么例子展示理解？**

**答案：**先写父 State、子 Binding 的收藏按钮，再写带稳定 ID 的列表，最后解释如何用 Hosting 接入现有 UIKit 导航。关键是讲清所有权、更新方向和边界，而不只把界面画出来。

<details>
<summary>面试官视角：这些题主要在看什么？</summary>

能否把状态归属、身份、生命周期、并发和版本分开；能否指出方案的适用边界；是否会把 UIKit 经验迁移而不是照搬；是否能通过小例子验证判断；是否诚实地区分原理理解、练习经验和生产经验。背 API 名称通常不是最终目的。

</details>

<a href="#ui-21-1" style="color:red;font-weight:bold;">返回知识点</a>

<a id="🔚" href="#前言" style="color:red;font-weight:bold;">返回前言</a>
