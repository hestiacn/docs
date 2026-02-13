# Debian 13 服务器 SSH 安全配置指南

---

## 一、解决 SSH 循环要求密码问题

**适用场景**：新安装的 Debian 13 服务器，使用密码登录时无限循环或被直接断开。

**问题原因**：Debian 13 已弃用 `ChallengeResponseAuthentication` 参数，改用 `KbdInteractiveAuthentication`，且默认未正确启用密码认证链。

**解决方案**：SSH 进入服务器（或通过 VNC/控制台），执行以下命令：

```bash
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/;s/^#\?PasswordAuthentication.*/PasswordAuthentication yes/;s/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/;s/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config && systemctl restart ssh
```

**执行结果**：
- ✅ 允许 root 用户登录
- ✅ 启用密码认证
- ✅ 适配 Debian 13 新认证机制
- ✅ 兼容旧版 SSH 客户端
- ✅ SSH 服务自动重启

**验证命令**：
```bash
ssh root@服务器IP -p 22
```
输入密码，应正常登录。

---

## 二、升级为密钥认证（禁用密码登录）

### 2.1 服务器端：切换为密钥认证模式

在**已经通过密码登录的 SSH 会话**中执行：

```bash
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/;s/^#\?PasswordAuthentication.*/PasswordAuthentication no/;s/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/;s/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/;s/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config && systemctl restart ssh
```

**配置变更说明**：
- 🔒 `PermitRootLogin prohibit-password`：仅允许 root 使用密钥登录
- 🔒 `PasswordAuthentication no`：关闭密码认证
- 🔒 `KbdInteractiveAuthentication no`：关闭交互式键盘认证
- 🔑 `PubkeyAuthentication yes`：开启公钥认证

---

### 2.2 客户端：生成密钥对

**本地终端（Windows PowerShell / macOS / Linux）执行**：

```bash
ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)-$(date +%Y%m%d)"
```

**参数说明**：
- `-t ed25519`：使用更安全、更快的 Ed25519 算法
- `-C`：添加注释，便于识别密钥来源

**交互说明**：
- 密钥存储路径：直接回车使用默认路径 `~/.ssh/id_ed25519`
- 密码短语：直接回车设置为空（如需更高安全性可自行设置）

**生成文件**：
- `~/.ssh/id_ed25519`：**私钥，严禁泄露**
- `~/.ssh/id_ed25519.pub`：公钥，需部署至服务器

---

### 2.3 查看公钥内容

```bash
cat ~/.ssh/id_ed25519.pub
```

输出示例：
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFyXQxRZ9zqX5X5Q5X5Q5X5Q5X5Q5X5Q5X5Q5X5Q5X5Q user@host-20240214
```

**完整复制整行内容**（包括 `ssh-ed25519` 前缀和末尾注释）。

---

### 2.4 服务器端：部署公钥

在**已登录的服务器 SSH 会话**中执行：

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "此处粘贴您复制的公钥内容" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

**权限说明**：
- `~/.ssh` 目录：**700**（drwx------）
- `~/.ssh/authorized_keys` 文件：**600**（-rw-------）
- 任何权限偏差都会导致 SSH 拒绝加载密钥

**验证部署**：
```bash
cat ~/.ssh/authorized_keys
```
应显示您刚才写入的公钥内容。

---

### 2.5 客户端：测试密钥登录

**新开本地终端**，执行：

```bash
ssh root@服务器IP -p 22
```

**预期结果**：
- ✅ 直接登录成功，**不再询问密码**
- ❌ 如仍提示输入密码，说明密钥认证未生效，请检查：
  - 服务器端 `sshd_config` 配置是否正确加载
  - `authorized_keys` 文件权限是否为 600
  - 公钥内容是否完整、无换行问题

---

### 2.6 客户端配置（FinalShell 用户）

如使用 FinalShell 客户端：

1. 新建会话或编辑现有会话
2. 认证方式选择 **Public Key**
3. 私钥文件：导入 `C:\Users\用户名\.ssh\id_ed25519`
4. 用户名：`root`
5. 端口：`22`（如未修改）
6. 保存并连接

---

## 三、配置文件最终状态验证

### 查看 SSH 实际运行配置

```bash
sshd -T | grep -E "permitrootlogin|pubkeyauthentication|passwordauthentication|kbdinteractive|authorizedkeysfile"
```

**预期输出（密钥认证模式）**：
```
permitrootlogin prohibit-password
pubkeyauthentication yes
passwordauthentication no
kbdinteractiveauthentication no
authorizedkeysfile .ssh/authorized_keys .ssh/authorized_keys2
```

---

## 四、故障排查手册

| 现象 | 可能原因 | 解决方案 |
|------|--------|--------|
| 密码登录无限循环 | KbdInteractiveAuthentication 未启用 | 执行第一节配置命令 |
| 密钥登录仍提示密码 | authorized_keys 权限错误 | `chmod 600 ~/.ssh/authorized_keys` |
| 密钥登录提示 Permission denied | 公钥未正确写入 | 检查 `cat ~/.ssh/authorized_keys` |
| SSH 服务无法重启 | 配置文件语法错误 | `sshd -t` 检查语法 |
| Windows 密钥权限错误 | NTFS 权限过松 | 重新生成密钥（自动设置正确权限） |

---

## 五、安全建议

1. **密钥即身份**：私钥等同于服务器 root 密码，务必妥善保管
2. **定期轮换**：建议每 6-12 个月更换一次密钥对
3. **多密钥管理**：不同设备使用不同密钥对，便于吊销
4. **备份策略**：服务器 `~/.ssh/authorized_keys` 应纳入备份体系
5. **审计跟踪**：定期检查 `/var/log/auth.log` 或 `journalctl -u ssh` 监控登录行为

---
