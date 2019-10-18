---
title: 'Linux窗口管理终极解决方案:tmux'
date: 2017-07-25 22:27:13
tags: [Linux, tmux, 窗口管理]
categories: [Tool]
---

## Linux窗口管理终极解决方案:tmux

tmux是terminal multiplexer的简称，也就是终端复用，一旦熟悉了tmux后，它就像一个加速器一样加速我们的工作效率。

### 基本概念

tmux的基本概念很简单，包含三种组成要素：

- 会话(session)

- 窗口(window)

- 面板(pane)


只需要记住三者之间的关系：用户可以创建多个会话，一个会话内可以创建多个窗口，一个窗口内可以创建多个面板。



### 常用命令和快捷键

#### 常用命令

| 命令                        | 描述                                                        |
| --------------------------- | ----------------------------------------------------------- |
| tmux ls                     | 列出所有会话                                                |
| tmux new -s basic           | 创建一个名为basic的会话                                     |
| tmux new -s basic -n editor | 创建一个名为basic的会话，并把该会话的第一个窗口命名为editor |
| tmux attach -t basic        | attach，连接到一个名为basic的会话                           |

#### 快捷键

| 快捷键                   | 描述                                                    |
| ------------------------ | ------------------------------------------------------- |
| PREFIX d                 | detach，将当前会话分离，让该会话在后台运行              |
| PREFIX c                 | 在当前会话新建一个窗口                                  |
| PREFIX ,                 | 对当前窗口重命名                                        |
| PREFIX 0...9             | 根据窗口的编号选择窗口                                  |
| PREFIX n                 | 跳转到下一个窗口                                        |
| PREFIX %                 | 把当前窗口垂直地一分为二，分割后的两个面板各占 50% 大小 |
| PREFIX "                 | 把当前窗口水平地一分为二，分割后的两个面板各占 50% 大小 |
| PREFIX 方向键            | 光标跳转到指定面板                                      |
| 按住PREFIX的同时按方向键 | 调整当前面板的大小                                      |
| PREFIX 空格键            | 切换面板布局                                            |
| PREFIX z                 | 最大化当前面板，再按一次还原                            |
| PREFIX !                 | 将当前面板从所属窗口分离出去，成为一个新的窗口          |
| PREFIX ?                 | 打印快捷键help                                          |

为什么要有PREFIX

由于我们的程序是在tmux环境里运行的，因此需要一种方式来告诉tmux当前所输入的命令是为了让tmux去执行而不是tmux里的应用程序去执行。

默认PREFIX是`Ctrl b`，觉得别扭的话可以在配置文件里自定义。

#### 复制到剪贴板

在开启鼠标支持的前提下，按住shift，鼠标左键选择文本，然后右键选择“复制”。



### 配置文件

在默认情况下，tmux 会在两个位置查找配置文件。首先查找 `/etc/tmux.conf` 作为系统配置，然后在当前用户的主目录下查找 `.tmux.conf` 文件（~/.tmux.conf 优先级更高）。如果这两个文件都不存在，tmux 就会使用默认配置。

#### 配置示例

```
# 按PREFIX R重新加载配置文件
bind R source-file ~/.tmux.conf \; display-message "Config reloaded.."

# 按PREFIX S在不同面板同步操作，再按一次取消同步
bind S setw synchronize-panes

# 状态栏
# 颜色
set -g status-bg black
set -g status-fg white

# 设置面板和活动面板的颜色
set -g pane-active-border-fg white
set -g pane-active-border-bg yellow
 
# 对齐方式
set-option -g status-justify centre
 
# 左下角
set-option -g status-left '#[bg=black,fg=green][#[fg=cyan]#S#[fg=green]]'
set-option -g status-left-length 20
 
# 窗口列表
setw -g automatic-rename on
set-window-option -g window-status-format '#[dim]#I:#[default]#W#[fg=grey,dim]'
set-window-option -g window-status-current-format '#[fg=cyan,bold]#I#[fg=blue]:#[fg=cyan]#W#[fg=dim]'
 
# 右下角
set -g status-right '#[fg=green][#[fg=cyan]%Y-%m-%d#[fg=green]]'

# 设置鼠标滚轮可用
set-window-option -g mode-mouse on

# 设置窗口活动通知
set-window-option -g monitor-activity on
set -g visual-activity on

```



### 自动化脚本

在日常开发中，我们经常需要打开各种各样的窗口，比如一个运行测试自动化脚本的窗口，一个查看应用运行日志的窗口，一个数据库窗口，难道每次都需要一个一个地打开各个窗口吗？自动化脚本就是让你一键拥有需要的所有窗口，并直接运行你想要的程序。

#### 脚本示例

```bash
# 创建新的会话basic，并detach
tmux new -s basic -d

# 列出常用工作路径
tmux send-keys -t basic 'sd -l' C-m

# 创建新的面板
tmux split-window -h -t basic

# 连接hyvpn
tmux send-keys -t basic:0.1 'cd ~/Downloads' C-m
tmux send-keys -t basic:0.1 'sudo openvpn hy-vpn.ovpn' C-m

# 创建新的窗口，命名为bl
tmux new-window -n bl -t basic

# ssh登录堡垒机
tmux send-keys -t basic:1 'ssh-add ~/.ssh/netease/id_rsa' C-m
tmux send-keys -t basic:1 'ssh -A bl' C-m

# attach会话
tmux attach -t basic
```

tmux采用c/s架构，有个后台server线程，send-keys就是向这个后台线程发送想让tmux执行的终端命令；`tmux send-keys -t basic:0.1 'cd ~/Downloads' C-m`表示向basic会话的第1个窗口的第2个面板发送打开`~/Downloads`文件夹的命令，`C-m`表示回车。

窗口、面板默认都是从0开始计数，也可以通过配置使其从1开始计数。

执行与上面类似的脚本，就可以一键拥有想要的开发环境。



### 进阶

以上内容已基本能够cover住日常工作需求，如需使用tmux更高级的功能，请参考：

《tmux: Productive Mouse-Free Development》中文版：https://aquaregia.gitbooks.io/tmux-productive-mouse-free-development_zh/content/index.html 