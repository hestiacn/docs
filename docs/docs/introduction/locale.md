# Debian 13 (Trixie) 终端切换语言 & 换源

## 一、适用环境

- **系统**：Debian 13 (Trixie)
- **权限**：root
- **目标**：
  1. 终端 locale 设为 `zh_CN.UTF-8`（可按需改为其他 locale）
  2. apt 源切换到自定义镜像

---

## 二、操作步骤

### 步骤 1：备份并禁用旧的 apt 源

**背景**：Debian 13 默认 `/etc/apt/sources.list` 可能是旧 `.list` 格式，或与新格式 `.sources` 重复。

```bash
mv /etc/apt/sources.list /etc/apt/sources.list.bak
```

**说明**：

- 改名为 `.bak`，禁用旧格式源
- 保留备份，方便回滚

---

### 步骤 2：设置 apt 镜像

**背景**：Debian 13 使用 `mirror+file:` 机制，镜像地址存放在 `/etc/apt/mirrors/` 下。

```bash
echo "https://mirrors.huaweicloud.com/debian" > /etc/apt/mirrors/debian.list
echo "https://mirrors.huaweicloud.com/debian-security" > /etc/apt/mirrors/debian-security.list
```

**说明**：

- `debian.list`：主源
- `debian-security.list`：安全源
- 上面的地址是**官方源**；可替换为任意镜像

**常见镜像**：

| 镜像 | 地址 | 备注 |
|------|------|------|
| Debian 官方 | `deb.debian.org` | 全球 CDN |
| 中科大 | `mirrors.ustc.edu.cn` | 中国 |
| 清华 | `mirrors.tuna.tsinghua.edu.cn` | 中国 |
| 阿里云 | `mirrors.aliyun.com` | 中国 |
| 腾讯云 | `mirrors.cloud.tencent.com` | 中国 |
| 华为云 | `mirrors.huaweicloud.com` | 中国 |
| Kernel.org | `mirror.rackspace.com` | 美国 |
| LeaseWeb | `mirror.leaseweb.com` | 欧洲 |

---

### 步骤 3：启用目标 locale

**背景**：`/etc/locale.gen` 中所有 locale 默认被注释，需取消注释。

#### 3.1 Debian 13 支持多少语言

**Debian 13 (Trixie) 的 locale 支持（实测）**：

| 项 | 值 |
|----|-----|
| 总 locale 数（`/usr/share/i18n/SUPPORTED`） | **509** |
| 覆盖语言数 | **210** |
| UTF-8 变体 | **327** |
| 非 UTF-8 变体 | **182** |
| `/etc/locale.gen` 可选 | **510** |

**说明**：

- **`/usr/share/i18n/SUPPORTED`**：完整支持列表，只读
- **`/etc/locale.gen`**：可编辑的副本，取消注释后跑 `locale-gen` 生成

**统计命令**：

```bash
# 总行数
wc -l /usr/share/i18n/SUPPORTED

# 覆盖语言数
cut -d' ' -f1 /usr/share/i18n/SUPPORTED | cut -d'.' -f1 | cut -d'@' -f1 | cut -d'_' -f1 | sort -u | wc -l

# UTF-8 变体
grep "UTF-8" /usr/share/i18n/SUPPORTED | wc -l

# 非 UTF-8 变体
grep -v "UTF-8" /usr/share/i18n/SUPPORTED | wc -l

# /etc/locale.gen 里可选
grep -cE "^# [a-z]" /etc/locale.gen

# 已启用
grep -cE "^[a-z]" /etc/locale.gen
```

#### 3.2 查看所有可用 locale

```bash
# 完整列表
cat /usr/share/i18n/SUPPORTED

# /etc/locale.gen 里的可选项
cat /etc/locale.gen

# 某语言的所有变体
grep "zh_" /etc/locale.gen
grep "^en_" /etc/locale.gen
grep "^ja_" /etc/locale.gen
```

#### 3.3 常用 locale

| Locale | 语言 |
|--------|------|
| `en_US.UTF-8` | English (United States) |
| `en_GB.UTF-8` | English (United Kingdom) |
| `zh_CN.UTF-8` | 简体中文 |
| `zh_TW.UTF-8` | 繁體中文 |
| `ja_JP.UTF-8` | 日本語 |
| `ko_KR.UTF-8` | 한국어 |
| `de_DE.UTF-8` | Deutsch |
| `fr_FR.UTF-8` | Français |
| `es_ES.UTF-8` | Español |
| `ru_RU.UTF-8` | Русский |
| `pt_BR.UTF-8` | Português (Brasil) |
| `ar_SA.UTF-8` | العربية |
| `it_IT.UTF-8` | Italiano |
| `nl_NL.UTF-8` | Nederlands |
| `pl_PL.UTF-8` | Polski |
| `tr_TR.UTF-8` | Türkçe |
| `vi_VN.UTF-8` | Tiếng Việt |
| `th_TH.UTF-8` | ไทย |
| `uk_UA.UTF-8` | Українська |
| `hi_IN.UTF-8` | हिन्दी |

#### 3.4 启用 locale

**以 `zh_CN.UTF-8` 为例**：

```bash
sed -i 's/^# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
```

**说明**：

- 取消 `zh_CN.UTF-8 UTF-8` 前面的 `#`
- 如需其他 locale（如 `en_US.UTF-8`、`ja_JP.UTF-8`），替换对应行即可

**同时启用多个 locale**：

```bash
sed -i 's/^# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
```

**验证**：

```bash
grep zh_CN /etc/locale.gen
```

**应看到**：

```
zh_CN.UTF-8 UTF-8      ← 没有 #
```

---

### 步骤 4：生成 locale

```bash
locale-gen
```

**预期输出**：

```
Generating locales (this might take a while)...
  zh_CN.UTF-8... done
Generation complete.
```

**验证**：

```bash
locale -a | grep zh_CN
```

**应看到**：

```
zh_CN.utf8
```

---

### 步骤 5：设置默认 locale

```bash
update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8
```

**说明**：

- 写入 `/etc/default/locale`
- **仅对新登录会话生效**

**验证**：

```bash
cat /etc/default/locale
```

**应看到**：

```
LANG=zh_CN.UTF-8
LC_ALL=zh_CN.UTF-8
```

---

### 步骤 6：重新登录使 locale 生效

```bash
exit
```

**重新登录**，然后验证：

```bash
locale
```

**应看到**：

```
LANG=zh_CN.UTF-8
LC_CTYPE="zh_CN.UTF-8"
LC_NUMERIC="zh_CN.UTF-8"
...
LC_ALL=zh_CN.UTF-8
```

---

### 步骤 7：更新软件源并升级

```bash
apt update && apt upgrade -y
```

**预期输出**：

```
Hit:1 https://mirrors.huaweicloud.com/debian trixie InRelease
...
All packages are up to date.
```

---

## 三、完整命令（一次性执行）

```bash
# 1. 备份并禁用旧源
mv /etc/apt/sources.list /etc/apt/sources.list.bak

# 2. 设置镜像（示例：官方源）
echo "https://mirrors.huaweicloud.com/debian" > /etc/apt/mirrors/debian.list
echo "https://mirrors.huaweicloud.com/debian-security" > /etc/apt/mirrors/debian-security.list

# 3. 启用 zh_CN.UTF-8
sed -i 's/^# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen

# 4. 生成 locale
locale-gen

# 5. 设置默认 locale
update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8

# 6. 重新登录
exit
```

**重新登录后**：

```bash
# 7. 验证
locale
locale -a | grep zh_CN
cat /etc/default/locale

# 8. 更新系统
apt update && apt upgrade -y
```

---

## 四、验证清单

| 项 | 命令 | 预期 |
|----|------|------|
| locale 生成 | `locale -a \| grep zh_CN` | `zh_CN.utf8` |
| 默认 locale | `cat /etc/default/locale` | `#LANG=zh_CN.UTF-8` |
| 当前 locale | `locale` | 全部 `zh_CN.UTF-8` |
| apt 源 | `apt update` | 连接的镜像 |
| 系统 | `apt upgrade -y` | 最新 |
| 支持 locale 数 | `wc -l /usr/share/i18n/SUPPORTED` | 509 |
| 覆盖语言数 | `cut ... \| sort -u \| wc -l` | 210 |
| UTF-8 变体 | `grep "UTF-8" /usr/share/i18n/SUPPORTED \| wc -l` | 327 |

---

## 五、常见问题

### Q1：`locale` 仍为 `C.UTF-8`

**原因**：当前会话未重新加载 locale。

**解决**：

```bash
source /etc/default/locale
locale
```

或 `exit` 后重新登录。

### Q2：`locale-gen` 报 "command not found"

**原因**：未安装 `locales` 包。

**解决**：

```bash
apt install -y locales
locale-gen
```

### Q3：`locale -a` 中没有目标 locale

**原因**：`/etc/locale.gen` 里对应行被注释。

**解决**：

```bash
sed -i 's/^# <locale> <charset>/<locale> <charset>/' /etc/locale.gen
locale-gen
```

例如：

```bash
sed -i 's/^# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
```

### Q4：`apt update` 连不上源

**原因**：镜像地址写错，或网络问题。

**解决**：

```bash
cat /etc/apt/mirrors/debian.list
cat /etc/apt/mirrors/debian-security.list
curl -I https://deb.debian.org/debian/dists/trixie/Release
```

### Q5：想恢复旧源

```bash
mv /etc/apt/sources.list.bak /etc/apt/sources.list
```

### Q6：如何查看支持多少语言

```bash
# 总 locale 数
wc -l /usr/share/i18n/SUPPORTED

# 覆盖语言数
cut -d' ' -f1 /usr/share/i18n/SUPPORTED | cut -d'.' -f1 | cut -d'@' -f1 | cut -d'_' -f1 | sort -u | wc -l

# UTF-8 变体
grep "UTF-8" /usr/share/i18n/SUPPORTED | wc -l

# 非 UTF-8 变体
grep -v "UTF-8" /usr/share/i18n/SUPPORTED | wc -l

# /etc/locale.gen 可选
grep -cE "^# [a-z]" /etc/locale.gen

# 已启用
grep -cE "^[a-z]" /etc/locale.gen

# 某语言所有变体
grep "^zh_" /usr/share/i18n/SUPPORTED
```