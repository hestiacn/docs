# Screen终端会话管理工具指南

## 🌈 什么是Screen？

**Screen** 是一款实用的终端会话管理工具，支持以下核心功能：

- 创建多个虚拟终端窗口并自由切换
- SSH断开后进程保持运行
- 随时重新连接并恢复历史会话
- 支持会话共享和协同操作

## 🌈 核心用法

### 📝 安装Screen

```bash
# Debian/Ubuntu
sudo apt install screen -y

# CentOS/RHEL
sudo yum install screen -y

# Arch Linux
sudo pacman -S screen
```

### 📝 启动新会话

```bash
screen -S hestia  # 创建名为"hestia"的会话
```

### 📝 后台运行进程

1. 在会话中运行命令（如 `ollama run deepseek-r1:7b`）
2. 使用快捷键分离会话：

```bash
Ctrl + A → D  # 分离会话（进程持续后台运行）
```

### 📝 恢复会话

```bash
screen -r hestia  # 通过名称恢复
screen -r 41964      # 通过会话ID恢复

# 查看所有会话列表
screen -ls
```

**输出示例：**

```bash
There is a screen on:
    41964.hestia (Detached)
1 Socket in /run/screen/S-root.
```

### 📝 关闭会话

在会话中执行以下任一操作：

```bash
exit   # 退出命令
Ctrl+D # 快捷键关闭
```

## 🌈 高级用法

### 📝 共享会话（协作模式）

```bash
# 用户A创建会话
screen -S shared_session

# 用户B加入会话
screen -x shared_session  # 双方可实时查看/操作同一终端
```

### 📝 会话锁定

```bash
Ctrl + A → X  # 设置密码锁定，输入系统密码后生效
```

### 📝 自定义配置

编辑 `~/.screenrc` 配置文件：

```bash
# 禁用启动信息
startup_message off

# 状态栏显示优化
caption always "%{= kw}%-w%{= gW}%n %t%{-}%+w"
```

## 🌈 Screen vs Tmux 对比

| 功能              | Screen | Tmux |
| :--: | :--: | :--: |
| 会话保持          | ✅      | ✅   |
| 多窗口管理        | ✅      | ✅   |
| 窗口分割          | ❌      | ✅   |
| 鼠标支持          | ❌      | ✅   |
| 配置灵活性        | 基础   | 强大 |
| 资源占用          | 轻量   | 较高 |

**选择建议：**

- 需要基础功能 → 选 **Screen**（预装/轻量）
- 需要高级功能 → 选 **Tmux**（分割窗口/插件支持）

---

## 🌈 结语

Screen 是 Linux 运维/开发的必备工具，特别适合：

- 长时间运行任务的进程保护
- 网络不稳定的远程连接场景
- 团队协作调试场景

掌握 Screen 可显著提升终端操作可靠性，让关键任务永不中断！🚀

> 提示：下次执行 `apt upgrade` 或 `pip install` 时，记得先用 `screen` 保护你的会话！

## **1. 安装中文语言包**

```bash
# 更新软件源
sudo apt update

# 安装中文语言包（简体中文）
sudo apt install locales fonts-wqy-zenhei fonts-wqy-microhei
```

---

## **2. 生成中文 locale**

```bash
# 编辑 locale 配置
sudo dpkg-reconfigure locales

# 在列表中找到以下选项（用空格选中）：
# - zh_CN.UTF-8 UTF-8
# - en_US.UTF-8 UTF-8 （可选，保留英文）

# 设置默认 locale 为 zh_CN.UTF-8
```

---

## **3. 设置环境变量**

编辑 `/etc/environment` 或用户配置文件（如 `~/.bashrc`）：

```bash
echo 'export LANG=zh_CN.UTF-8' | sudo tee -a /etc/environment
echo 'export LANGUAGE=zh_CN:en_US' | sudo tee -a /etc/environment
```

立即生效：

```bash
source /etc/environment
```

---

## **4. 验证配置**

```bash
# 查看当前 locale
locale

# 测试中文字符显示
echo "测试中文"
```

---

## **5. 若仍显示乱码**

- 确保终端工具（如 `putty`/`xterm`）的字符编码设置为 **UTF-8**
- 安装中文字体（若使用图形界面）：

```bash
sudo apt install fonts-noto-cjk
```
