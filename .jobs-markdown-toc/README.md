# Markdown 动态目录过滤器

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#%E5%89%8D%E8%A8%80)
- [一、文件职责](#files)
- [二、安装与日常使用](#usage)
  - [2.1、仓库首次接入与首次提交](#first-adoption)
  - [2.2、日常编辑与新增文档](#daily-editing)
  - [2.3、拉取更新与本地还原](#pull-and-restore)
- [三、检查与预览](#checks)
- [四、卸载与兼容边界](#uninstall)

</details>
<!-- jobs-toc:end -->

---

## 🔥 <span id="前言">前言</span>

本目录保存当前仓库的目录过滤器和受控文档清单。本地使用 [**Typora**](https://typora.io/) 编辑时保留 `[toc]`；正常整文件暂存文档时，由 [**Git**](https://git-scm.com/docs/gitattributes#_filter) 自动生成默认收起的目录，检出后恢复标签。正文标题变化无需手工刷新目录。

| 操作 | Git 对象 / 暂存区 | 磁盘上的文档 |
| --- | --- | --- |
| 编辑并整文件暂存 | `clean` 生成 `<details>` 和按标题层级缩进的目录 | 保留 `[toc]` |
| `git pull` 写入更新后的受控文档 | 保留发布目录 | `smudge` 恢复 `[toc]` 并撤销自有标题包装 |
| 新克隆后尚未安装过滤器 | 保留发布目录 | 可能仍是发布目录；运行 `install` 一次恢复 |
| 拉取没有更新文档，或仅新增过滤器配置 | 不变 | Git 不保证重写现有文件；需要时运行 `restore` |

## 一、<span id="files">文件职责</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 文件 | 职责 |
| --- | --- |
| [MarkdownToc.mjs](./MarkdownToc.mjs) | 自包含转换、安装、验证与卸载入口。 |
| `manifest.json` | 仓库根相对路径清单；仅这些含有效目录标签的文档接入。 |
| `README.md` | 本目录用途、命令与维护边界。 |
| [tests/git-roundtrip.mjs](./tests/git-roundtrip.mjs) | 隔离本地 bare remote、发布端和接收端，实测暂存、拉取、检出与恢复保护。 |

需要 [**Node.js**](https://nodejs.org/) 20 或更新版本以及 Git，不需要 npm 安装依赖。每个仓库自带完整工具，不依赖其它项目或本机 Skills 目录。清单内路径以仓库根定位；命令从本目录执行也能定位到正确仓库。

## 二、<span id="usage">安装与日常使用</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

在本目录的终端执行一次安装，新克隆和 Node 路径变化后重新执行：

```shell
node ./MarkdownToc.mjs install
node ./MarkdownToc.mjs status
```

安装只配置本仓 `filter.jobs-markdown-toc.clean / smudge / required`，核对清单和有效 Git 属性，不改全局配置、hooks、分支或已暂存内容。安装会更新受控文档的修改时间，让 Git 重新检测新过滤器；未生成过目录的文档正文保持原样。恢复记录保存在本仓实际 Git 元数据目录中的 `jobs-markdown-toc.json`。

### 2.1、<span id="first-adoption">仓库首次接入与首次提交</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

仓库首次接入时，安装成功表示本机转换已启用，已有提交和暂存内容仍保持原样。先在 [**Sourcetree**](https://www.sourcetreeapp.com/) 审查本仓差异，再按下面的范围手动准备首次提交：

1、按 `manifest.json`，将**清单内全部文档整文件暂存**，包括正文未修改的旧文档及新增说明，让每份受控文档首次生成发布目录。

2、将根 `.gitattributes`、完整 `.jobs-markdown-toc/` 工具目录（脚本、清单和说明），以及本仓实际变更的兼容入口、测试或 CI 文件一并纳入同一待发布提交；保留无关改动，不使用“全部暂存”混入其它任务文件。

3、运行 `node ./MarkdownToc.mjs check`，核对全部清单的原始暂存内容。文件尚未暂存或仍是旧 `[toc]` 时会失败，按列出的路径整文件重新暂存后复查；通过后再由用户照常提交、推送。

工具不会替用户暂存、提交或推送。已接入仓库的新克隆安装一次后，按下面的日常流程处理改动文档。

### 2.2、<span id="daily-editing">日常编辑与新增文档</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

日常继续在 Typora 修改正文并保存，在 Sourcetree 中整文件暂存**改过的受控文档**，运行 `check` 后照常提交、推送。过滤器在暂存时工作，单独 push 不会重新生成已有提交。Git 差异视图显示发布形态，磁盘上的文档仍保留 `[toc]`。

不含有效 `[toc]` 的新文档不需要登记；新增或移动含标签文档时，增量更新清单和根 `.gitattributes` 的精确路径，再运行 `install` 与 `verify`，整文件暂存该文档及对应清单、属性改动后运行 `check`。父仓、子模块和嵌套 Git 分别维护，父仓清单不越界接管子仓。

### 2.3、<span id="pull-and-restore">拉取更新与本地还原</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

安装一次后照常在终端或 Sourcetree 拉取；Git 将更新的文档写入工作区时自动调用 `smudge`，无需每次手工刷新目录。`git fetch` 只取对象，不写工作文件；`git pull` 没有更新某份文档时也不会为它补跑过滤器。原始暂存内容与 `git show HEAD:README.md` 继续显示发布目录，不能用它们判断磁盘是否恢复。

新克隆不继承本仓的 local 配置，先运行本目录的 `install`，安装会同时将已有发布目录还原。已配置过滤器但磁盘遗留生成目录时，从本目录执行：

```shell
node ./MarkdownToc.mjs restore
node ./MarkdownToc.mjs verify
```

`restore` 只处理清单内当前磁盘内容的专属目录与标题包装，保留现有正文、未提交修改及暂存区。全部文件预检通过后才写入，重复运行无额外变化；损坏标记、符号链接和跨仓路径会停止。它不从 HEAD / 暂存区取旧正文，不改变 Git 配置。不要用强制检出、清空工作区或全仓重新暂存来补跑过滤器。非自有目录或缺少来源标记的手写目录不会被猜测删除。

新克隆落盘的发布目录与 `[toc]` 尺寸不同；仅转换磁盘内容可能留下旧索引状态缓存，出现 `git diff` 无正文差异、`status` 却显示修改，甚至阻止下一次拉取。本工具的 `install` / `restore` 会为内容经 Git 过滤后与已有索引完全相同的受控文件刷新状态缓存：加锁后先操作索引副本，验证全部暂存对象、文件模式、冲突阶段和用户标记未变，再写回缓存；未暂存内容、部分暂存、权限变化及特殊索引标记均不借机暂存。索引文件的二进制内容可能因缓存刷新变化，已暂存的实质内容保持原样。缓存刷新失败会报错；已还原的正文保留，排除索引锁或并发操作后重新运行。

拉取出现正文冲突时先按正常流程解决冲突，再检查本地形态与完整目录。过滤器不替代 Git 的冲突处理；Node 路径失效时重新安装，配置有外部改动则先核实来源，不能强盖配置。

## 三、<span id="checks">检查与预览</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

只读严格核对工作区全部受控文档已经保留 `[toc]`，并检查字节往返与幂等性；磁盘仍有生成目录时会报错并提示 `restore`：

```shell
node ./MarkdownToc.mjs verify
```

正常整文件暂存后，检查清单内原始暂存内容的目录是否与标题一致：

```shell
node ./MarkdownToc.mjs check
```

`check` 不会暂存文件；文件尚未加入索引、已删除或目录过期会列出路径并失败。只暂存部分行可能把目录和标题分开，必须整文件重新暂存后复查。平台网页编辑及未安装过滤器的其他电脑不会自动运行本机过滤器；已有 CI 可接入同一检查，不自动提交修复。

向标准输出展示一份文档的发布形态，参数是清单中的仓库根相对路径；省略参数优先选择根 README，其次清单第一份文档：

```shell
node ./MarkdownToc.mjs preview
```

在本目录运行隔离 Git 实验；测试只向临时本地 bare remote 提交和推送，不操作当前仓库的分支、索引、配置或真实远端：

```shell
node ./tests/git-roundtrip.mjs
```

2026-10-21 单仓实验：上述 15 组全部通过，覆盖真实拉取、无更新不重写、新克隆缓存刷新、分支检出、未提交与部分暂存保护、损坏标记、split index 和已有索引锁。另将模板原有 38 项回归用于当前工具，全部通过；本仓 10 份受控文档的严格本地检查与隔离索引检查通过。本轮未向 GitHub / Gitee 发布或扩大到其它仓库，平台网页渲染仍按实际平台单独验收。

## 四、<span id="uninstall">卸载与兼容边界</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

```shell
node ./MarkdownToc.mjs uninstall
```

卸载先验证全部受控文档，再恢复安装前的本仓配置，并在工作区保留最新折叠目录；不改暂存区、不提交、不推送。发现配置被其他操作改动会停止，避免覆盖；卸载后目录不再自动更新。终端显示操作结果，错误写入标准错误；过滤器的标准输出只包含文档。

代码围栏、缩进代码、注释中的 `[toc]` 不触发转换；标签大小写及合法多个目录位置原样保留。缺失锚点或旧 HTML 锚点不可靠时，发布形态增加可逆的非空 `span` 标题包装，检出会完整还原。转换不重新渲染正文，保留 BOM、换行和末尾换行；非法 UTF-8、损坏的生成标记、符号链接及跨仓清单会停止。

折叠语法依据 [**GitHub 官方文档**](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/organizing-information-with-collapsed-sections)及 [**GitLab 官方文档**](https://docs.gitlab.com/user/markdown/#collapsible-section)；[**Gitee**](https://gitee.com)和自建服务需按实际渲染效果验收，不能将本地预览当作所有平台已验证。

<a id="🔚" href="#前言">我是有底线的➤点我回到首页</a>
