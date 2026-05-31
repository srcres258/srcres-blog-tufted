
此处收集个人平时可能用到的一些 GDB 常用调试命令, 以备随时查阅.


# 使用前提

编译程序时需添加调试信息 `-g`（推荐 `-g -O0`），例如：

```
gcc -g -o prog prog.c
```

启动 GDB：

```
gdb ./prog
# 或 gdb --args ./prog arg1 arg2
# 或 gdb -tui ./prog （启用文本界面 TUI）
```

# 入门级别（基础操作，适合新手日常调试）

这些命令覆盖启动、运行、断点、单步执行、查看变量和退出等最常用场景。

**启动与退出**
- `gdb ./prog`：启动 GDB 并加载程序
- `run` / `r [参数]`：运行程序（可带命令行参数）
- `quit` / `q`：退出 GDB
- `kill`：终止当前运行的程序

**断点管理**
- `break` / `b main` 或 `b 文件:行号` 或 `b 函数名`：设置断点
- `info breakpoints` / `i b`：查看所有断点
- `delete` / `d [断点号]`：删除断点（无参数删除所有）
- `disable/enable [断点号]`：禁用/启用断点
- `clear [行号/函数]`：清除指定位置的断点

**运行控制与单步**
- `continue` / `c`：继续运行直到下一个断点
- `next` / `n`：执行下一行（不进入函数，step over）
- `step` / `s`：执行下一行（进入函数，step into）
- `finish` / `fin`：运行直到当前函数返回
- `until` / `u [行号]`：运行直到指定行或退出循环

**查看信息**
- `print` / `p 变量` 或 `p 表达式`：打印变量/表达式值（支持 C 表达式）
- `backtrace` / `bt` 或 `where`：显示调用栈（堆栈回溯）
- `frame` / `f [帧号]`：切换到指定栈帧
- `list` / `l [行号]`：显示源代码

**其他基础**
- `help [命令]`：显示帮助
- `apropos 关键词`：搜索相关命令

入门建议：先用 `break main` 设置入口断点，`run` 运行，遇到问题用 `bt` 看栈、`p` 看变量、`n/s` 单步。

# 进阶级别（条件断点、观察点、内存检查等）

这些命令帮助处理更复杂的调试场景，如变量变化监控、内存查看、寄存器等。

**条件断点与观察点（Watchpoints）**
- `break 位置 if 条件`：条件断点（例如 `b 10 if x > 5`）
- `condition 断点号 条件`：为已有断点添加/修改条件
- `watch 变量/表达式`：设置观察点（变量值变化时停止）
- `awatch`：读写观察点；`rwatch`：只读观察点
- `info watchpoints`：查看观察点

**自动显示与格式化输出**
- `display /格式 表达式`：每次停止时自动打印（例如 `display/x var`）
- `undisplay [编号]`：取消自动显示
- `print /格式 表达式`：格式化打印（如 `/x` 十六进制、`/d` 十进制、`/s` 字符串、`/c` 字符）
- `x /nfu 地址`：检查内存（n=数量，f=格式如 x/d/s，u=单位如 b/h/w/g）

**栈与线程**
- `backtrace full`：显示栈帧及局部变量
- `info args`：显示当前函数参数
- `info locals`：显示当前函数局部变量
- `info threads`：查看线程
- `thread [线程号]`：切换线程

**修改执行**
- `set var 变量 = 值`：修改变量值
- `return [值]`：强制当前函数返回（可指定返回值）
- `jump 行号/地址`：跳转执行到指定位置

**TUI 文本界面（推荐）**
- `tui enable` 或启动时 `gdb -tui`：进入 TUI 模式（Ctrl+x a 切换）
- `layout src/asm/split/regs`：切换布局（源码/汇编/拆分/寄存器）
- `focus src/asm/regs`：切换焦点窗口

进阶建议：用条件断点减少无关暂停，用 `watch` 监控关键变量变化，用 `x` 检查指针/内存错误。

# 专家级别（高级特性、反汇编、脚本、底层调试）

这些适合复杂程序、多线程、逆向、性能分析或自动化调试。

**反汇编与底层**
- `disassemble` / `disas [函数/地址]`：反汇编函数或范围
- `stepi` / `si`、`nexti` / `ni`：单步汇编指令（step into/over）
- `info registers` / `i r`：查看寄存器（`info all-registers` 更多）
- `set {类型}地址 = 值`：直接修改内存（如 `set {int}0xaddr = 5`）

**高级断点与命令列表**
- `break *地址`：在机器地址设置断点
- `commands 断点号`：为断点附加命令列表（`silent` 静默、`continue` 等，`end` 结束）
- `catch [signal/throw 等]`：捕获信号、异常等事件
- `tbreak`：临时断点（命中一次后自动删除）

**逆向调试与历史**
- `reverse-step` / `rs`、`reverse-next` / `rn` 等：反向单步（需支持记录）
- `record` / `record full`：开启执行记录（然后可逆向调试）
- `checkpoint` / `restart`：检查点保存/恢复状态

**多线程与信号**
- `thread apply all 命令`：对所有线程执行命令
- `handle 信号`：控制信号处理（如 `handle SIGINT nopass`）
- `info inferiors`：查看多个调试目标

**脚本与自定义**
- `source 脚本文件`：加载 GDB 脚本（.gdbinit 自动加载）
- `define 命令名`：自定义新命令（`end` 结束）
- `set pagination off`：关闭分页（适合脚本）
- `set print pretty on`：美化结构体打印
- `set logging on`：日志记录 GDB 输出

**其他专家特性**
- `info functions/variables/types`：查看程序符号
- `maintenance` 命令组：底层维护（如内存检查）
- `python` / `guile`：嵌入 Python 等脚本扩展
- `attach PID`：附加到运行中的进程
- `core-file 核心转储`：调试崩溃转储文件

专家建议：结合 `.gdbinit` 自定义环境；用 `commands` 自动化断点行为；对于多线程/复杂程序，熟练 TUI + 寄存器 + 反汇编；大型项目可结合 `valgrind` 或其他工具互补。

# 备注

- 大多数命令可缩写到不冲突的前几个字母（如 `info break` → `i b`）。
- `Ctrl + L`：刷新屏幕（TUI 乱码时有用）。
- `set args ...`：在 GDB 内设置运行参数。
- 内存泄漏/段错误常用：`bt` + `p` + `x` 检查指针。
- 更多细节始终可用 `help` 或官方文档（`info gdb` 在系统中）。
