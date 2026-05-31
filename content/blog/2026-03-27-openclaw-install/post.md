
# 前言

[OpenClaw][1] (前身[Clawdbot][2]) 是最近非常火爆的一款 personal AI assistant 工具.
由于OpenClaw的爆火, 网友给了其一个可爱的昵称 "小龙虾🦞". 它让即使不涉及程序设计的普通人
也有机会使用 AI 智能体, 并用其辅助自己的日常工作生活, 为自己的 daily routine 增加些许
计划与建议, 让日程安排更加井然有序, 自己的疑问与需求得到及时的解决.


但 OpenClaw 的安装过程也是非常复杂且繁琐的, 如果让没有涉猎计算机工作原理的电脑轻度使用者,
安装 OpenClaw, 整个过程是相当具有挑战性的 (哪怕对于我这种已经积累了许多编程经验的领域内人士,
也难避免碰了许多壁). 所以网上出现了很多 [OpenClaw 代安装服务][3], 包括 OpenClaw
的安装与[卸载][4]一条龙服务, 体现出普通人追求当代科技前沿领域为自己所用的迫切欲望与需求,
同时也难以避免闹出许多乌龙, 例如 "割韭菜" "AI模型提供商圈钱" 云云论调. 本博客仅从技术层面探讨
OpenClaw 的安装与使用细节 (基于自己实际经历), 不讨论此方面论调相关事项.

# 硬件环境

网上经验老道的 "养虾人" 会专门拿出闲置硬件平台, 并在其上运行 OpenClaw 进行 "养虾",
并形象地称呼这个用来专门运行 OpenClaw 的硬件平台为 ["虾笼"][5] (如同铁笼一般, 专门放置并
"养殖" OpenClaw). 有的人没有 "虾笼", 直接在自己的个人电脑上运行 OpenClaw,
但在个人电脑上运行 OpenClaw 是有风险的 (电脑病毒入侵/个人信息泄露), 且发生过网络安全案例,
如: [因为养殖 OpenClaw 导致个人隐私文件与数据泄露][6],
[安装 OpenClaw 时使用的安装包为病毒程序][7].
多所相关高校与单位已针对此类风险发布过[此类风险预警][8].
综上, 无论是对于刚入门 "龙虾养殖" 的新手, 还是对于经验老道的想玩玩 OpenClaw 的技术极客,
将 OpenClaw 运行在独立硬件平台 "虾笼" 上, 总是最有安全底线的方式.

为了独立硬件平台上运行 OpenClaw, 我使用一款在咸鱼上收得的一块废品工控机主板, 搭载
[Intel Celeron J1900 处理器][9], 我为这块主板配置了 8 GB RAM. (最近电脑硬件 DIY
领域正值极暗时刻, 各种配件疯狂涨价, 大家看好自己的钱包呀, 不要盲目跟风追求极致品质!
要量力而行.)

(遗憾: 这块主板不支持直插 DC 电源接口, 害得我另费购买了电源适配模块, -50 RMB...)

# 安装系统

根据以往经验, 我选择 [Arch Linux][10] 作为操作系统. 自费了一块 U 盘做 Live 系统 (再
-40 RMB, 最近存储价格上天了). 从[官方镜像页][11]下载 iso 镜像
(我选择了[国内源][12]以加快下载速度). 不要忘记检查一下 SHA256 checksum, 并与官方
checksum 对比, 避免潜在网络安全风险 (养 OpenClaw 必须时刻防范网络安全风险. 近期
[axiom 投毒事件][13], 外加上文提到的各类病毒事件, 一再警醒我们加强防范).

为主板连接电源, 键盘与屏幕, 打开主板电源. 需要先设置 BIOS. (**避坑**: 提前检查主板 BIOS
电池是否余有电量. 若 BIOS 电池亏电会导致主板断电后 BIOS 失效, 恢复出厂设置,
包括安装系统时所做的引导条目也将一并失效! 为避免后续遇到麻烦, 提前用万用表测量一下电池电压,
因我是购买的二手主板, 因此遇到了此情况, 特此记录以避坑.) 主板上电后狂按 DEL 键进入 BIOS
界面. 几个重要设置项:

- 关闭 Secure Boot.

- 将 Restore AC Power Loss 项设为 Power On. (主板接电后自动上电.
  如果要将主板部署为长期使用的服务器则需要开启.)

- 调整 Boot 设备顺序. 确保 USB 排在硬盘之前.

设置完成后保存并 reboot. 从 USB 进入 Arch Linux Live. 随后按照
[Arch Linux 官方安装指南][14]所述步骤依次进行即可, 在硬盘上安装 Arch Linux.
注意除 root 用户外, 最好添加一个普通权限用户 (防止任意程序均运行在 root 用户,
**做好权限管理**, 防范网络攻击), 同时加入 wheel 用户组, 设置好 sudo 权限分配,
确保能够通过 sudo 以 root 权限运行程序.

# 安装 OpenClaw

进入刚安装好的 Arch Linux 系统. 需要注意安装 OpenClaw 前, 需先确保系统上安装了 Node.js
(OpenClaw 的 dependency). 参照 [Arch Linux Wiki][15], 为 Arch Linux 安装 Node.js.
一般情况下安装 [`nodejs`][16] 软件包即可:

```shell
sudo pacman -S nodejs
```

根据 [OpenClaw 官方文档][17], 使用一行命令安装并设置好 OpenClaw:

```shell
curl -fsSL https://openclaw.ai/install.sh | bash
```

整个过程是交互式的, 我全程跟着[官方文档][18]进行操作, 其中某些选项暂时留空
(如社交平台的接入暂时留空, 下文讲述如何接入).

需要注意安装完成 OpenClaw 后, 检查 `openclaw` 是否存在于 Shell 的 `PATH` 环境变量中;
如果不存在, 需要自己编辑 Shell profile 文件将其加入 `PATH` (因为经常需要敲 `openclaw`
命令, 加入 `PATH` 省事). 然后验证[一切是否正常工作][19].

# 安装 Clawhub 及必装插件

ClawHub 是 OpenClaw Skills 分发, 托管的生态平台; 就像手机应用商店是诸多手机 APP
的生态平台一样, 可将 Clawhub 理解为 OpenClaw 官方的 "技能市场" 或 "插件商店".
OpenClaw 通过搜索并下载 ClawHub 上的 Skills (技能), 可以干更多更复杂的活儿.

> ClawHub 的核心作用与功能：
>
> - 扩展 AI 能力：通过在 ClawHub 安装技能，OpenClaw 可以学会特定的操作，例如搜索网页、处理 Markdown、控制浏览器、读写本地文件或调用第三方 API（如 GitHub、Slack 等）。
> - 技能管理：用户可以通过 ClawHub CLI（命令行工具）直接搜索、安装、更新或卸载这些技能。
> - 安全与评价体系：ClawHub 页面通常包含“Security Scan”安全扫描标签，帮助用户识别技能是否存在恶意代码或敏感权限索取。
> - 中国镜像站：为了解决国内访问和下载限速问题，OpenClaw 已官宣与火山引擎（字节跳动旗下）共建 ClawHub 中国镜像站。 

如 [Clawhub 官网首页][20]所示, 通过以下命令安装 Clawhub:

```shell
npx clawhub@latest install sonoscli
```

安装完成后, 再通过 Clawhub 为 OpenClaw 安装常用的 skills. 在这方面我直接咨询了
[Grok][21], 可以作为参考, 根据个人需求安装必要的 skills 即可. (不要安装过多, 避免臃肿,
过多的 skills 可能导致 token 消耗速率增大, 造成不必要资金浪费.)

全部完成以后, 通过浏览器进入 OpenClaw 管理面板 (默认网址是 `http://localhost:18789/`)
并登入, 查看自己的 OpenClaw 是否正常工作, 自己选择的 LLM 是否正确.

# 接入社交平台

将 OpenClaw 接入社交平台的过程可直接参照[官方文档][22], 我目前主要接入 [Telegram][23]
和 [Feishu][24] 这两个平台. 其中我推荐 Telegram 平台, Telegram 支持 commands,
可直接远程操纵 OpenClaw 后台功能, 如 LLM 切换, sessions 管理, 状态查询, etc. 相比
Feishu 而言, Feishu 没有这些功能.

另: 本来我也想将 OpenClaw 接入[微信][24], 但步骤繁琐, 且不知为何我的手机微信提示
"当前版本微信不支持该功能", 因此作罢.

# 实际测试与使用

Telegram 实际使用时, 效果不错, 基本上能完成个人日常人物, 满足日常需求.

#image("https://files.seeusercontent.com/2026/04/03/uwN7/1.jpg", width: 50%)

#image("https://files.seeusercontent.com/2026/04/03/6naX/2.jpg", width: 50%)

#image("https://files.seeusercontent.com/2026/04/03/2Hsn/3.jpg", width: 50%)

在 Feishu 上使用时, OpenClaw 也能正常回应, 但有时陷入卡顿, 甚至失去连接与响应,
故只作为次要选择, 日常还是用 Telegram.

#image("https://files.seeusercontent.com/2026/04/03/m5bS/4.jpg", width: 50%)

#image("https://files.seeusercontent.com/2026/04/03/Zmo9/5.jpg", width: 50%)

目前我使用 OpenClaw 仅停留在入门层级 (购买的 token 太少, 节省使用; 且日常需求不多,
只提问 crucial 的问题), 故尚无客观的, 完整的针对 OpenClaw 的评价. 后续若有更多 OpenClaw
使用感想, 再另行撰文吧.

[1]: https://openclaw.ai/
[2]: https://clawdbot.you/
[3]: https://www.21jingji.com/article/20260309/herald/763cb0f461b6fbd9d89bc83b046c4ee6.html
[4]: https://www.cls.cn/detail/2308840
[5]: https://zhuanlan.zhihu.com/p/2019802477860534201
[6]: https://news.cctv.cn/2026/03/15/ARTI7ODnGAK3f5Fd28t4c9c2260315.shtml
[7]: https://www.52pojie.cn/thread-2099090-1-1.html
[8]: https://www.hebuet.edu.cn/info/1045/71553.htm
[9]: https://www.intel.cn/content/www/cn/zh/products/sku/78867/intel-celeron-processor-j1900-2m-cache-up-to-2-42-ghz/specifications.html
[10]: https://archlinux.org/
[11]: https://archlinux.org/download/
[12]: https://mirrors.aliyun.com/archlinux/iso/2026.04.01/
[13]: https://www.secrss.com/articles/89004
[14]: https://wiki.archlinuxcn.org/wiki/%E5%AE%89%E8%A3%85%E6%8C%87%E5%8D%97
[15]: https://wiki.archlinuxcn.org/wiki/Node.js
[16]: https://archlinux.org/packages/?name=nodejs
[17]: https://docs.openclaw.ai/zh-CN/start/getting-started
[18]: https://docs.openclaw.ai/zh-CN/install
[19]: https://docs.openclaw.ai/zh-CN/install#%E5%AE%89%E8%A3%85%E5%90%8E
[20]: https://clawhub.ai/
[21]: https://grok.com/share/c2hhcmQtMw_25d3a9c7-c5ec-4a19-8f07-ec14e089ccb3?rid=7d896223-33c5-4b5e-9724-ee31aeb79b5d
[22]: https://docs.openclaw.ai/zh-CN/channels
[23]: https://docs.openclaw.ai/channels/telegram
[24]: https://docs.openclaw.ai/zh-CN/channels/feishu
