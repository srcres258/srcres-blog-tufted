
本博客记录我完成 [jyy 操作系统课程][1] [M2 lab][2] 的过程.


# lab 背景信息

> 操作系统为应用程序提供了 “一组对象” 和访问它们的 API。将各种类型的对象和 API 组合使用，造就了我们丰富多彩的应用程序世界。今天的操作系统都提供[任务管理器][3]工具监测程序运行状态，例如显示在一段时间内，各个程序 (进程、状态机) 的活跃程度、占用的内存等等。下面的图片展示了 Plasma Desktop 的任务管理器，能够显示系统资源的使用情况和进程的信息。

任务管理器是现代操作系统通常都会具有的一个系统组件 (如 Windows 的 [taskmgr][4]).
使用 Linux 的极客也会尝试在 Linux 上开发任务管理器程序, 甚至防止 Windows 的 taskmgr,
如我现在常用的 [Mission Center][5].

# lab 描述与分析

> 🗒️ 实验要求：实现 pstree 打印进程之间的树状的父子关系
>
> Linux 系统中可以同时运行多个程序。运行的程序称为进程。除了所有进程的根之外，每个进程都有它唯一的父进程，你的任务就是把这棵树在命令行中输出。你可以自由选择展示树的方式 (例如使用缩进表示父子关系)。

lab 给出了主要任务. 详细细节还要看后面:

> 总览
>
> `pstree [OPTION]…`
>
> 描述
>
> 把系统中的进程按照父亲-孩子的树状结构打印到终端。
>
> ```
>    -p 或 --show-pids: 打印每个进程的进程号。
>    -n 或 --numeric-sort: 按照 pid 的数值从小到大顺序输出一个进程的直接孩子。
>    -V 或 --version: 打印版本信息。
> ```
>
> 你可以在命令行中观察系统的 `pstree` 的执行行为 (如执行 `pstree -V`、`pstree --show-pids` 等)。这些参数可能任意组合，但你不需要处理单字母参数合并的情况，例如 `-np`。

这里要求 pstree 程序实现3种类型的参数. 针对每个参数, 结合 lab 的要求,
大致梳理一下我的相关思路:

1.  -p / --show-pids (打印进程号)

    实现思路：使用全局标志变量 show_pids 记录状态。

    在命令行解析时，通过 getopt_long() 检测到 -p 或 --show-pids 时，将 show_pids 置为 1。

    在打印进程时，根据该标志决定输出格式：

    - 若 show_pids == 0：直接打印进程名，如 systemd
    - 若 show_pids == 1：打印进程名+PID，如 systemd(1)

2. -n / --numeric-sort (按 PID 排序)

    实现思路：使用全局标志变量 numeric_sort 记录状态。

    在命令行解析时，检测到 -n 或 --numeric-sort 时，将 numeric_sort 置为 1。

    在构建进程树后、打印前，遍历每个进程的子进程列表，使用 qsort() 按 PID 数值进行升序排序。排序比较函数为 compare_pid()，返回值为子进程 A 的 PID 减去子进程 B 的 PID。

3. -V / --version (打印版本)

    实现思路：独立处理，无需全局状态。

    在 getopt_long() 的 switch 分支中，检测到 -V 或 --version 时：

    - 调用 print_version() 函数直接输出版本信息
    - 立即返回 0，终止程序执行

    由于版本信息无需访问进程列表，因此放在读取进程之前处理，效率最优。

# 实现过程

## 主程序

### 整体架构

程序主要分为以下几个模块：

1. 数据结构定义 — 定义进程结构体和全局变量
2. 进程读取 — 从 /proc 文件系统读取进程信息
3. 建树 — 根据父子关系构建进程树
4. 打印 — 按树状结构输出进程信息
5. 命令行解析 — 处理 -p、-n、-V 等选项

### 详细实现过程

#### 数据结构定义

```c
static int show_pids = 0;    // 控制是否显示 PID
static int numeric_sort = 0;  // 控制是否按 PID 排序
typedef struct Process {
    pid_t pid;              // 进程号
    pid_t ppid;             // 父进程号
    char comm[MAX_NAME_LEN]; // 进程名
    int nchildren;          // 子进程数量
    struct Process **children; // 子进程指针数组
} Process;
```

- 使用 `show_pids` 和 `numeric_sort` 两个全局标志变量记录选项状态
- `Process` 结构体包含进程的基本信息和子进程指针数组

#### 命令行参数解析

使用 `getopt_long()` 函数解析命令行参数：

```c
static struct option long_options[] = {
    {"show-pids", no_argument, 0, 'p'},
    {"numeric-sort", no_argument, 0, 'n'},
    {"version", no_argument, 0, 'V'},
    {"help", no_argument, 0, 'h'},
    {0, 0, 0, 0}
};
```

解析过程：

- `-p` / `--show-pids`：将 show_pids 置为 1
- `-n` / `--numeric-sort`：将 numeric_sort 置为 1
- `-V` / `--version`：调用 print_version() 打印版本后直接退出
- 无效选项：打印 usage 信息并返回错误码

#### 读取进程信息

`read_process_info()` 函数读取单个进程的信息：

- 读取 `/proc/<pid>/comm` 文件获取进程名
- 解析 `/proc/<pid>/stat` 文件获取 PID 和 PPID
  - 使用 `sscanf()` 解析格式：`pid (comm) state ppid`

`read_all_processes()` 函数遍历 `/proc` 目录：

- 使用 `opendir()` / `readdir()` 遍历 `/proc`
- 过滤出以数字命名的目录（进程 PID）
- 调用 `read_process_info()` 读取每个进程的信息

#### 构建进程树

`build_process_tree()` 函数完成树的构建：

1. 初始化子进程数组：为每个进程分配子进程指针数组
2. 建立父子关系：遍历所有进程，根据 `ppid` 找到父进程，将子进程加入父进程的 `children` 数组
3. 排序子进程（若启用）：调用 sort_children() 对每个父进程的子进程按 PID 排序

`sort_children()` 函数：

```c
if (parent->nchildren > 1 && numeric_sort) {
    qsort(parent->children, parent->nchildren, sizeof(Process *), compare_pid);
}
```

- 使用标准库 qsort() 函数排序
- compare_pid() 比较函数返回两进程 PID 的差值，实现升序排列

#### 查找根进程

`find_root()` 函数查找进程树的根节点：

1. 优先查找 PID 为 1 的进程（通常是 systemd）
2. 若未找到，查找 PPID 为 0 的进程
3. 若仍未找到，返回第一个进程作为兜底

#### 打印进程树

`print_tree_recursive()` 函数递归打印树状结构：

根节点打印：

- 根据 `show_pids` 决定格式
- `show_pids` == 0：输出 systemd
- `show_pids` == 1：输出 systemd(1)

子节点打印：

- 根据深度打印垂直线 `|` 作为前缀
- 打印连接符 `+--`
- 根据 `show_pids` 决定是否显示 PID

递归打印子节点：

- 对每个子进程，打印垂直连接线后递归调用

输出格式示例：

```
systemd
 +--systemd-journal-
 | +--greetd-
 | | +--fish-
```

#### 主函数流程

```c
int main(int argc, char *argv[]) {
    // 1. 解析命令行参数，设置 show_pids / numeric_sort
    // 2. 读取所有进程信息
    read_all_processes();
    // 3. 构建进程树（若 numeric_sort 启用则排序）
    build_process_tree();
    // 4. 查找根进程
    Process *root = find_root();
    // 5. 打印进程树
    print_tree(root);
    // 6. 释放内存
    free_processes();
    return 0;
}
```

### 命令行参数与功能的对应关系

| 参数 | 标志变量 | 作用位置 | 实现方式 |
|------|----------|----------|----------|
| `-p` / `--show-pids` | `show_pids` = 1 | `print_tree_recursive()` | 修改打印格式： `%s` → `%s(%d)` |
| `-n` / `--numeric-sort` | `numeric_sort` = 1 | `sort_children()` | 调用 `qsort()` 按 PID 排序 |
| `-V` / `--version` | 无需标志 | `main()` switch | 直接打印版本并退出 |

## 测试框架

### TestKit 框架概述

TestKit 是本 lab 提供的轻量级测试框架，核心功能包括：

- **自动注册测试用例**：通过宏和构造函数机制，无需手动管理
- **系统测试**：模拟命令行调用 `main()` 函数
- **输出捕获**：捕获程序的 stdout/stderr 输出
- **超时保护**：每个测试有 5 秒超时限制
- **环境变量控制**：`TK_RUN` 或 `TK_VERBOSE` 启用测试

### 文件结构与接入方式

根据我自己对于完成 lab 的规划，项目结构如下：

```
os2026/
├── testkit/              # 测试框架（上游提供）
│   ├── testkit.h         # 头文件：宏定义、数据结构
│   └── testkit.c         # 实现：测试运行器
├── pstree/
│   ├── pstree.c          # 主程序源码
│   ├── tests.c           # 测试用例代码（自己编写）
│   └── Makefile          # 构建配置（修改）
```

### Makefile 配置

#### 原始 Makefile

```makefile
NAME := pstree
export MODULE := M2

CC := gcc
CFLAGS := -Wall -Wextra -D_DEFAULT_SOURCE -I../testkit
```

关键配置：

- **`-I../testkit`**：添加 testkit 头文件搜索路径，使 `#include <testkit.h>` 能找到文件

#### 构建目标配置

```makefile
# 主程序
$(NAME): pstree.c
	$(CC) $(CFLAGS) -o $@ $<

# 测试程序：链接 testkit.c 和 pstree.c
$(NAME)-test: tests.c ../testkit/testkit.c pstree.c
	$(CC) $(CFLAGS) -o $@ tests.c ../testkit/testkit.c pstree.c
```

测试程序的编译方式：

- **包含 `pstree.c`**：将主程序代码直接编译进测试程序
- **链接 `../testkit/testkit.c`**：提供测试运行器实现
- **包含 `tests.c`**：提供测试用例定义

#### 测试目标配置

```makefile
test: $(NAME)-test
	TK_VERBOSE=1 ./$(NAME)-test
```

运行测试时设置环境变量`TK_VERBOSE=1`，TestKit 会输出详细结果。

### 测试用例编写（tests.c）

#### 头文件包含

```c
#include <testkit.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
```

`testkit.h` 提供了测试框架的核心宏和数据结构。

#### SystemTest 宏的使用

TestKit 提供两种测试宏：

- **`UnitTest`**：单元测试，直接执行测试函数
- **`SystemTest`**：系统测试，通过 `fork()` 调用 `main()` 函数

对于命令行程序，使用 `SystemTest` 更合适。

#### 测试用例示例

**基本功能测试**：

```c
SystemTest(basic_no_args,
           ((const char *[]){"./pstree"})) {
    tk_assert(result->exit_status == 0,
              "Basic pstree command should exit with status 0, got %d",
              result->exit_status);
    tk_assert(strlen(result->output) > 0,
              "Output should not be empty");
}
```

宏展开后的含义：

- **测试名称**：`basic_no_args`
- **执行命令**：`./pstree`（无参数）
- **断言检查**：
  - 退出码为 0
  - 输出不为空

**带参数的测试**：

```c
SystemTest(show_pids_short,
           ((const char *[]){"./pstree", "-p"})) {
    tk_assert(result->exit_status == 0,
              "pstree -p should exit with status 0, got %d",
              result->exit_status);
    tk_assert(strlen(result->output) > 0,
              "Output should not be empty");
    tk_assert(strstr(result->output, "(") != NULL,
              "Output should contain PIDs in parentheses");
}
```

**组合选项测试**：

```c
SystemTest(show_pids_and_numeric_sort,
           ((const char *[]){"./pstree", "-p", "-n"})) {
    tk_assert(result->exit_status == 0, ...);
    tk_assert(strlen(result->output) > 0, ...);
    tk_assert(strstr(result->output, "(") != NULL, ...);
}
```

**错误处理测试**：

```c
SystemTest(invalid_option,
           ((const char *[]){"./pstree", "--invalid-option"})) {
    tk_assert(result->exit_status != 0,
              "pstree with invalid option should exit with non-zero status");
    tk_assert(strstr(result->output, "usage") != NULL ||
   strstr(result->output, "Usage") != NULL ||
              strstr(result->output, "invalid") != NULL ||
              strstr(result->output, "Invalid") != NULL,
              "Output should mention invalid option or show usage");
}
```

#### tk_assert 断言宏

```c
#define tk_assert(cond, fmt, ...) \
    do { \
        if (!(cond)) { \
            fprintf(stderr, "Assertion failed: (%s)\n" \
                            "    In %s of %s:%d\n", \
                    #cond, __func__, __FILE__, __LINE__); \
            fprintf(stderr, "    " fmt, ##__VA_ARGS__); \
fprintf(stderr, "\n"); \
            abort(); \
        } \
    } while (0)
```

当条件为假时：
- 打印断言失败的表达式
- 打印所在函数、文件名、行号
- 打印自定义错误信息
- 调用 `abort()` 终止测试

### SystemTest 宏的工作原理

#### 宏展开机制

```c
#define SystemTest(name, argv_, ...) \
    __tk_testcase(name, \
        struct tk_result *result, stest, \
        .argc = sizeof(argv_) / sizeof(void *), \
        .argv = (const char **)argv_, \
        __VA_ARGS__)
```

`SystemTest(basic_no_args, ((const char *[]){"./pstree"}))` 展开后：

```c
__tk_testcase(basic_no_args,
    struct tk_result *result, stest,
    .argc = 1,
    .argv = (const char *[]){" ./pstree"})
```

#### `__tk_testcase` 内部宏

```c
#define __tk_testcase(name_, body_arg, test, ...) \
    static void TK_UNIQUE_NAME(name_)(body_arg); \
    \
    __attribute__((constructor)) \
    void TK_UNIQUE_NAME(reg##name_)() { \
        void tk_add_test(struct tk_testcase t); \
        tk_add_test( (struct tk_testcase) { \
            .enabled = 1, \
            .name = #name_, \
            .loc = __FILE__ ":" TK_TOSTRING(__LINE__),\
            .test = TK_UNIQUE_NAME(name_), \
  __VA_ARGS__ \
        } ); \
    } \
    \
    static void TK_UNIQUE_NAME(name_)(body_arg)
```

关键点：

1. **`__attribute__((constructor))`**：构造函数，在 `main()` 之前自动执行
2. **`tk_add_test()`**：注册测试用例到全局测试数组
3. **自动计算 argc**：根据 argv 数组长度确定参数个数

### TestKit 运行机制（testkit.c）

#### 测试注册

```c
void tk_add_test(struct tk_testcase t) {
    if (!getenv(TK_RUN) && !getenv(TK_VERBOSE)) {
        return;  // 未启用测试时不注册
    }
tests[ntests++] = t;  // 添加到测试数组
}
```

只有设置环境变量时，测试才会被注册。

#### 测试执行

```c
static int run_testcase(struct tk_testcase *t, char *buf) {
    pid_t child_pid = fork();
    if (child_pid == 0) {
        exit(main(t->argc, t->argv, environ));  // fork 后执行 main()
} else {
        waitpid(child_pid, &status, 0);
        t->stest(&(struct tk_result) {
            .exit_status = r,
            .output = buf,
        });  // 调用测试断言
    }
}
```

关键流程：

1. **`fork()` 创建子进程**
2. **子进程调用 `main(argc, argv)` 执行程序**
3. **父进程等待子进程结束**
4. **调用测试断言函数 `t->stest()` 验证结果**

#### 输出捕获

```c
FILE *fp = fmemopen(buf, TK_OUTPUT_LIMIT - 1, "w+");
setbuf(fp, NULL);
stdout = stderr = fp;  // 重定向 stdout/stderr 到内存缓冲区
```

将程序的 `printf()` 输出重定向到内存缓冲区，供后续断言检查。

### 测试运行流程

```
$ make test
    ↓
make pstree-test  # 编译测试程序
    ↓
执行 ./pstree-test
    ↓
main() 函数执行
    ↓
构造函数自动注册测试用例
    ↓
TestKit 检测到 TK_VERBOSE 环境变量
    ↓
fork() 创建子进程运行每个测试
    ↓
子进程调用 main() 并传入参数
    ↓
父进程捕获输出和退出码
    ↓
运行 tk_assert 断言
    ↓
输出测试结果
```

### 测试覆盖情况

| 测试名称 | 测试目标 | 断言内容 |
|----------|----------|----------|
| `basic_no_args` | 无参数运行 | 退出码=0，输出非空 |
| `show_pids_short` | `-p` 选项 | 退出码=0，输出含 `(` |
| `show_pids_long` | `--show-pids` | 退出码=0，输出含 `(`|
| `numeric_sort_short` | `-n` 选项 | 退出码=0，输出非空 |
| `numeric_sort_long` | `--numeric-sort` | 退出码=0，输出非空 |
| `version_short` | `-V` 选项 | 退出码=0，输出含 `pstree` |
| `version_long` | `--version` | 退出码=0，输出含 `pstree` |
| `show_pids_and_numeric_sort` | `-p -n` 组合 | 退出码=0，输出含 `(` |
| `all_options_long` | 长选项组合 | 退出码=0，输出含 `(` |
| `invalid_option` | 无效选项 | 退出码≠0，输出含 usage |

### 总结

TestKit 接入的关键步骤：

1. **Makefile 配置**：
- 添加 `-I../testkit` 包含路径
   - 编译测试程序时链接 `testkit.c` 和 `pstree.c`
   - 设置 `test` 目标运行 `TK_VERBOSE=1 ./pstree-test`

2. **编写测试用例**：
   - `#include <testkit.h>`
   - 使用 `SystemTest` 宏定义测试
   - 在测试体内使用 `tk_assert` 断言

3. **自动注册机制**：
   - 构造函数在 `main()` 前执行
   - `tk_add_test()` 将测试加入全局数组
   - 环境变量控制是否启用测试

# 实验总结

本次 jyy 操作系统课程 M2 实验成功实现了一个功能完整的 `pstree` 命令行工具，能够以树状结构展示 Linux 系
统中的进程父子关系。通过深入理解 `/proc` 文件系统，我设计了高效的进程信息读取机制，构建了基于 `Process`结构体的进程树数据模型，并实现了灵活的命令行参数解析系统，支持 `-p/--show-pids`（显示进程号）、`-n/--numeric-sort`（按 PID 排序）和 `-V/--version`（显示版本信息）等核心功能。

在实现过程中，我采用了模块化的设计思路：首先通过遍历 `/proc` 目录读取所有进程的 PID、PPID 和进程名信息
；然后根据父子关系构建进程树，其中根进程通常为 PID 1 的 systemd；接着根据用户指定的选项对子进程进行排序
并格式化输出。打印逻辑采用递归方式，通过缩进和连接符（如 `+--` 和 `|`）清晰地展现树状层次结构。

为了确保代码质量和功能正确性，我集成了课程提供的 TestKit 测试框架，编写了覆盖所有功能点和边界情况的系统测试用例，包括基本功能、单个选项、选项组合以及错误处理等场景。通过这套完整的测试体系，有效验证了程序在各种使用场景下的稳定性和正确性。

这个实验不仅加深了我对 Linux 进程管理和 `/proc` 文件系统的理解，也锻炼了我在系统编程、数据结构设计、命
令行工具开发和测试驱动开发等方面的实践能力，为后续更复杂的系统级编程奠定了坚实基础。

[1]: https://jyywiki.cn/OS/2026
[2]: https://jyywiki.cn/OS/2026/labs/M2.md
[3]: https://www.cyberciti.biz/tips/top-linux-monitoring-tools.html
[4]: https://en.wikipedia.org/wiki/Task_Manager_(Windows)
[5]: https://missioncenter.io/
