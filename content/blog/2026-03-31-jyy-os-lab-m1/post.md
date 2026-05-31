
学习 jyy 老师的 [2026 年度 OS 课程][1], 开始完成老师布置的各 lab. 这篇 blog 记录我完成第一个
lab 的过程.


# lab 简介与背景

## 简介

> M1: 迷宫游戏 (labyrinth)
>
> 计算机世界有趣的地方在于，你可以动手构建任何你认为应该可以实现的东西。我们的热身实验是一个很像 “Online Judge” 中做过的题目，只不过是一个真正有意义的 “实用工具”：一个命令行迷宫游戏，帮助你熟悉基本的命令行参数解析和 UNIX 命令行工具的 “基本约定”。

这 lab 一上来就直击灵魂. 不像那些枯燥的 "Hello World", 老师直接扔了个 "迷宫游戏" 热身赛,
表面看像OJ老题 (走迷宫找出口. jyy 也是 OI 退役选手, 懂), 但升级成命令行实用工具,
专治命令行参数解析恐惧症. 想想看: `./labyrinth -m map.txt -s seed -p player_pos`
这种 UNIX 范儿的参数轰炸, 解析完还能生成随机迷宫, AI 对手, 瞬间从菜鸟变老司机.
蒋老师这招高明. 借游戏入门底层约定，顺便让你体会 **"计算机世界，你想造啥就造啥"** 的自由感.

## 背景

> 1. 背景
>
> Rogue-like 游戏可以追溯到 1980 年的《Rogue》，这是一款在 UNIX 系统上运行的文字冒险游戏。在那个图形界面还未普及的年代，程序员们用 ASCII 字符创造了一个充满想象力的世界：
>
> #image("https://jyywiki.cn/OS/img/rouge1980.webp")
>
> 既然是 “文字冒险”，就少不了最基本的命令行命令。在 UNIX 系统中，命令行终端 (Terminal) 是用户与系统交互的基本界面。当你打开终端时，系统会启动一个 Shell 程序来解析和执行平时我们熟悉的命令，如 ls、cd、pwd 等，例如：
>
> ```
> cowsay -f dragon "Hello OS!"
> ```
>
> 会把
>
> ```
> argv = {"cowsay", "-f", "dragon", "Hello OS!", NULL}
> ```
>
> 传递给 cowsay 程序的 main 函数，程序解析参数并在终端 (模拟器) 上画出下面的 ASCII Art：
>
> #image("https://jyywiki.cn/OS/img/cowsay.webp")
>
> 在这个实验里，我们将构建一个命令行版本的 “游戏后端”，用于支持一个多人对战的 Rogue-like 游戏，并且熟悉命令行工具的命令行解析。这是一个程序本身无状态的后端服务，每运行一次程序就对应了一次用户操作，执行完就会退出，而所有的游戏状态都保存在文件中。这种设计让游戏系统非常灵活——通过实现游戏 “前端”，玩家可以在同一台机器上进行多人游戏，甚至扩展成网络对战模式。

我直接上 Grok 帮我解读了. lab 文档还是很通俗易懂的, 非常喜欢 jyy 老师布置 lab 的行事风格.

> 背景部分纯干货，带我穿越回80年代《Rogue》时代：没GPU，全靠ASCII艺术硬扛！终端Shell解析cowsay -f dragon "Hello OS!"，argv数组一塞，龙哥就吐字萌翻天（图片太逗了）。这lab的核心是无状态后端神设计：每次跑程序=一次用户操作，状态全存文件，退出就拜拜。为什么牛？本地多人轮流玩（一人一终端），扩展网络战零门槛，简直是“微服务鼻祖”！jyy老师不愧是老江湖，用游戏包装CLI哲学，让我一边敲代码一边想：UNIX哲学原来这么rogue（流氓）有趣，未来我也要这么设计工具，low-key装逼~ 😎

# lab 内容与分析

## 正文

来到 lab 正文要求部分.

> 🗒️ 实验要求：实现 labyrinth 命令行迷宫游戏
>
> 你需要实现一个命令行工具 labyrinth，它可以从文件加载迷宫地图，显示玩家位置，并支持玩家在迷宫中移动。除了基本功能外，你还需要实现命令行参数解析、错误处理以及连通性检查等功能。

## 分析

这个实验要求还是比较简单的. 直接让 MiniMax M2.7 给我列了个 [PLAN.md][2] (节选):

```
## 1. 任务理解

根据 `main.c` 后端代码和 M1 实验描述，前端 `game.py` 需要实现：
- 两名玩家（玩家0、玩家1）使用 **WASD**（玩家0）和 **HJKL**（玩家1）在同一终端窗口中控制各自的角色
- 通过调用 `labyrinth` 命令行工具更新游戏状态
- 每次移动后刷新屏幕显示最新的迷宫状态

### 后端工具行为分析（来自 main.c）

| 命令 | 行为 |
|------|------|
| `labyrinth -m map.txt -p 0` | 打印地图（玩家0视角） |
| `labyrinth -m map.txt -p 0 --move up` | 移动玩家0向上，返回0成功，1失败 |
| `labyrinth -m map.txt -p 1 --move down` | 移动玩家1向下 |

- 移动成功后，`labyrinth` 会**原地修改 map.txt**（覆盖写入）
- 返回值通过 `subprocess.returncode` 判断成功/失败
- 地图文件需要预先包含玩家标记（`0`、`1`），或不包含时自动放置到第一个空地

...
```

然后就开始编写了, 后端用 C 语言 (即提及到的 labyrinth 程序), 前端比较自由, lab 没做要求,
我索性用简单易用的 Python 写了. 

## 框架与流程

程序流程 (main 函数)

命令行解析 → 参数校验 → 加载地图 → 连通性检查 → [移动玩家] → [保存地图] / 打印地图

| 步骤 | 功能 |
|------|------|
| 命令行解析 | getopt_long 处理 -m, -p, --move, --version |
| 参数校验 | 检查地图文件、玩家ID有效性 |
| 加载地图 | 解析文件，记录玩家位置 |
| 连通性检查 | DFS/BFS 验证所有非墙格子连通 |
| 移动逻辑 | 边界/障碍/碰撞检测，更新位置 |

核心函数

| 函数 | 作用 |
|------|------|
| load_map() | 从文件加载地图，检测玩家位置 |
| check_connectivity() | 深度优先搜索验证地图连通性 |
| is_valid_move() | 验证移动合法性（边界、障碍、碰撞） |
| make_move() | 执行移动，更新网格和玩家坐标 |
| find_first_empty() | 查找第一个空格子 |
| print_map() | 输出地图 |

## 实现完成主要代码

后端实现完成的代码已经传到我的 [GitHub repo][3] 中了. `main.c` 的关键代码:

### 数据结构定义

```c
typedef struct {
    char grid[MAX_ROWS][MAX_COLS];
    int rows;
    int cols;
    int player_positions[MAX_PLAYERS][2]; // [row, col] for each player ID
} Map;
```

- grid: 二维字符数组存储地图，#=墙，.=空地，0-9=玩家
- player_positions: 记录每个玩家（0-9）的坐标，支持多玩家

### 命令行解析

```c
static struct option long_options[] = {
    {"map", required_argument, 0, 'm'},
    {"player", required_argument, 0, 'p'},
    {"move", required_argument, 0, 0},
    {"version", no_argument, 0, 'v'},
    {0, 0, 0, 0}
};
while ((opt = getopt_long(argc, argv, "m:p:v", long_options, &option_index)) != -1) {
    switch (opt) {
        case 'm': map_file = optarg; break;
        case 'p': player_id = atoi(optarg); break;
        case 0:  // 长选项处理
            if (strcmp(long_options[option_index].name, "move") == 0)
                move_direction = optarg;
            break;
    }
}
```

使用 getopt_long 支持短选项（-m）和长选项（--map）两种形式。

### 地图加载

```c
int load_map(const char *filename, Map *map) {
    FILE *f = fopen(filename, "r");
    // ...
    while (fgets(line, sizeof(line), f) != NULL && row < MAX_ROWS) {
        line[strcspn(line, "\n")] = 0;  // 去除换行符
        
        // 验证字符合法性
        if (c != '#' && c != '.' && (c < '0' || c > '9'))
            return -1;
        
        // 记录玩家位置
        if (c >= '0' && c <= '9') {
            int pid = c - '0';
            map->player_positions[pid][0] = row;
            map->player_positions[pid][1] = i;
        }
        strcpy(map->grid[row], line);
        row++;
    }
}
```

逐行读取文件，验证格式，同时记录所有玩家数字对应的坐标位置。

### 连通性检查（DFS）

```c
bool check_connectivity(Map *map) {
    bool visited[MAX_ROWS][MAX_COLS] = {false};
    int stack[MAX_ROWS * MAX_COLS][2];
    int stack_top = 0;
    
    // 找起点
    for (int i = 0; i < map->rows && start_row == -1; i++)
        for (int j = 0; j < map->cols; j++)
            if (map->grid[i][j] != '#') { start_row = i; start_col = j; }
    
    // DFS
    stack[stack_top++] = {start_row, start_col};
    visited[start_row][start_col] = true;
    
    int directions[4][2] = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}};
    while (stack_top > 0) {
        int r = stack[--stack_top][0];
        int c = stack[stack_top][1];
        for (int d = 0; d < 4; d++) {
            int nr = r + directions[d][0];
            int nc = c + directions[d][1];
            if (nr >= 0 && nr < map->rows && nc >= 0 && nc < map->cols &&
                !visited[nr][nc] && map->grid[nr][nc] != '#')
                visited[nr][nc] = true;
        }
    }
    
    // 检查是否所有可达格子都被访问过
    for (int i = 0; i < map->rows; i++)
        for (int j = 0; j < map->cols; j++)
            if (map->grid[i][j] != '#' && !visited[i][j])
                return false;
    return true;
}
```

手动实现 DFS（用数组模拟栈），检查迷宫所有空格是否连通。

### 移动验证与执行

```c
// 验证移动合法性
bool is_valid_move(Map *map, int player_id, const char *direction) {
    int dr = 0, dc = 0;
    if (strcmp(direction, "up") == 0)    dr = -1;
    else if (strcmp(direction, "down") == 0)  dr = 1;
    else if (strcmp(direction, "left") == 0)  dc = -1;
    else if (strcmp(direction, "right") == 0) dc = 1;
    
    int nr = r + dr, nc = c + dc;
    
    // 检查边界
    if (nr < 0 || nr >= map->rows || nc < 0 || nc >= map->cols) return false;
    // 检查目标是否为墙
    if (map->grid[nr][nc] == '#') return false;
    // 检查目标是否有其他玩家
    for (int i = 0; i < MAX_PLAYERS; i++)
        if (i != player_id && map->player_positions[i][0] == nr ...)
            return false;
    return true;
}
// 执行移动
bool make_move(Map *map, int player_id, const char *direction) {
    map->grid[r][c] = '.';                    // 旧位置变空
    map->grid[nr][nc] = '0' + player_id;      // 新位置放玩家
    map->player_positions[player_id][0] = nr;
    map->player_positions[player_id][1] = nc;
    return true;
}
```

验证和执行分离，验证通过后才修改地图数据。

### 地图保存

```c
if (move_direction != NULL) {
    // 移动后写回文件
    FILE *f = fopen(map_file, "w");
    for (int i = 0; i < map.rows; i++)
        fprintf(f, "%s\n", map.grid[i]);
    fclose(f);
} else {
    print_map(&map);  // 无移动则仅打印
}
```

移动操作完成后直接覆盖原文件保存状态。

# 前端分析与实现

## 实现选择与取舍

lab 讲义中给出了针对前端实现的两条路线:

> 🎮 本地双人对战：两名玩家使用不同的按键 (WASD/HJKL) 在同一个终端窗口中控制各自的角色。前端程序会自动调用 labyrinth 命令行工具来更新游戏状态，并在每次移动后刷新屏幕显示最新的迷宫状态。
> 🌐 网络多人对战：在这种模式下，服务器会为每个 ssh 连接的玩家自动分配 ID，每个玩家可以看到所有其他玩家在迷宫中的位置。服务器会序列化和处理所有玩家的移动请求，确保游戏状态的一致性。

我选择了 "本地双人对战" 这条路线, 主要是网络对战的实现上, 一来可能会很复杂困难,
二来自己缺乏网络编程经验.

## 整体架构

```
game.py
├── 依赖模块: subprocess, sys, os, termios, tty, select, atexit, signal
├── 数据层   → 调用 ./labyrinth 读写地图文件
├── 输入层   → termios raw mode + select 非阻塞读取键盘
└── 渲染层   → ANSI escape code 彩色输出
```

## 核心函数

| 函数 | 职责 |
|------|------|
| labyrinth_call(args) | 封装 subprocess 调用，返回 (returncode, stdout, stderr) |
| load_map(path) | 调用 labyrinth -m map.txt -p 0 获取地图文本 |
| move_player(path, pid, direction) | 调用 labyrinth --move 执行移动 |
| colorize(text) | 逐字符着色：墙壁黄、玩家0绿、玩家1蓝、空地白 |
| show_map(text, msg) | ANSI 清屏 + 渲染地图 + 显示操作提示 |
| validate_connectivity(text) | BFS 验证地图连通性（辅助函数，未在主循环调用） |
| game_loop(map_path) | 主循环：捕获按键 → 移动 → 刷新显示 |
| main() | 入口：参数校验、labyrinth 可执行性检查 |

## 控制方案

- 玩家0（绿色）：W/A/S/D 对应 上/左/下/右
- 玩家1（蓝色）：K/H/J/L 对应 上/左/下/右
- 退出：Q

所有按键映射存储在 P0_KEYS、P1_KEYS 字典中，主循环查表驱动。

## 关键技术细节

1. 非阻塞输入：使用 termios.tcsetattr + tty.setcbreak 切换终端为 cbreak 模式，select.select() 检测按键，无需 curses 依赖
2. 屏幕刷新：ANSI \033[2J 清屏 + \033[H 光标归位，逐帧重绘
3. 安全退出：atexit.register + signal.signal(SIGINT/SIGTERM) 双保险恢复终端设置
4. 超时保护：subprocess.run(timeout=5) 防止 labyrinth 永久阻塞

## 相关代码

见 [game.py][4]. 代码逻辑基本清晰明了, 此处不再赘述.

# 游戏地图的生成

本游戏需要手动提供地图文件. 鉴于地图生成也是电脑随机完成的, 我也基于 Python
做了个地图生成脚本 [create_map.py][5], 同时也给出了用这个脚本程序生成的部分 txt 文件,
详见 [repo][3].

# 总结

这个 lab 中 jyy 还提到 testkit 这个测试框架, 可以基于此测试并验证自己的程序是否按照预期方式工作.
但鉴于 OJ 仅面向 NJU 学生开放, 我把蒋老师的 lab framework 也 clone 了下来, 但实在不知如何使用,
故先放下测试部分. (TODO: 抽空向 jyy 请教这个 testkit 该如何使用...)

[1]: https://jyywiki.cn/OS/2026/labs/M1.md
[2]: https://github.com/srcres258/jyy-os-2026-lab/blob/master/M1/PLAN.md
[3]: https://github.com/srcres258/jyy-os-2026-lab/blob/master/M1
[4]: https://github.com/srcres258/jyy-os-2026-lab/blob/master/M1/game.py
[5]: https://github.com/srcres258/jyy-os-2026-lab/blob/master/M1/create_map.py
