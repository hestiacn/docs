# 操作系统升级

::: danger 警告
在升级操作系统之前，请务必进行备份！ 我们不为损坏的操作系统安装提供支持。 我们仅提供此页面来提供有关升级过程中可能出现的 Hestia 问题的信息。
:::

## Debian 与 Ubuntu 系统升级

::: warning 温馨提示
确保验证 MariaDB 是否在新操作系统支持的版本上运行。 如果不是这种情况，请在升级操作系统之前将 MariaDB 版本更新到支持的版本！
:::

完成备份后，将 Hestia 更新到最新支持的版本：

```bash
apt update && apt upgrade -y
```

按照系统说明升级您的操作系统。 完成后，请确保检查`/etc/apt/sources.list.d`中的更新源配置是否正确。 如果是，请保存退出并再次运行`apt update && apt Upgrade -y`

## Debian 9 stretch 升级到 Debian 10 Buster

### 换源

```bash
# 备份原有的软件源配置文件
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo cp -r /etc/apt/sources.list.d/ /etc/apt/sources.list.d.bak/

# 将软件源配置中的 'stretch' (Debian 9) 替换为 'buster' (Debian 10)
sudo sed -i 's/stretch/buster/g' /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null

# 使用 grep 过滤出所有包含 "buster" 的行，确认新源是否成功更换
sudo grep -r "buster" /etc/apt/sources.list /etc/apt/sources.list.d/

# 使用 grep 检查软件源是否还存在 "stretch"（应该没有结果）
sudo grep -r "stretch" /etc/apt/sources.list /etc/apt/sources.list.d/

# 更新软件包列表，下载升级所需的软件包，并执行完整的系统升级 
# 对于跨版本升级，必须使用 apt full-upgrade 来正确处理依赖关系。
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
```

由于`Hestia`于`2019`年基于`VestaCP`开发.并未在之前的版本测试所以不支持该版本！所有此部分资料请自行搜索解决方案！

## Debian 10 Buster 到 Debian 11 Bullseye

### 换源

```bash
# 备份原有的软件源配置文件
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo cp -r /etc/apt/sources.list.d/ /etc/apt/sources.list.d.bak/

# 将软件源配置中的 'buster' (Debian 10) 替换为 'bullseye' (Debian 11)
sudo sed -i 's/buster/bullseye/g' /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null

# 使用 grep 过滤出所有包含 "bullseye" 的行，确认新源是否成功更换
sudo grep -r "bullseye" /etc/apt/sources.list /etc/apt/sources.list.d/

# 使用 grep 检查软件源是否还存在 "buster"（应该没有结果）
sudo grep -r "buster" /etc/apt/sources.list /etc/apt/sources.list.d/

# 更新软件包列表，下载升级所需的软件包，并执行完整的系统升级 
# 对于跨版本升级，必须使用 apt full-upgrade 来正确处理依赖关系。
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
```

::: tip `upgrade`与`full-upgrade`的注意事项
在 `Debian/Ubuntu` 系统升级中，`apt upgrade` 会安全地更新所有已安装的包，但不会安装新的依赖或移除过时的包。`apt full-upgrade` 则更彻底，它会智能地处理依赖关系的变化，包括必要时移除一些与其他新包冲突的旧包。执行完 `upgrade` 后再次执行 `full-upgrade` 是一个确保系统完全升级到新状态的好习惯。
:::

### SHA512 密码加密

```bash
sed -i "s/obscure yescrypt/obscure sha512/g" /etc/pam.d/common-password
```

### Exim4 配置

```bash
rm -f /etc/exim4/exim4.conf.template
cp -f /usr/local/hestia/install/deb/exim/exim4.conf.4.94.template /etc/exim4/exim4.conf.template
```

（注意：模板版本号可能需要根据实际情况调整）

### ProFTPD

#### 问题说明

在新版本 `ProFTPD` 中 `IdentLookups` 指令已被移除。保留此指令会导致服务启动错误，需要注释掉配置文件中的相关行。

#### 快速修改

```bash
# 注释掉 IdentLookups 指令
sudo sed -i 's/^IdentLookups/\/\/ IdentLookups/' /etc/proftpd/proftpd.conf

# 重启 ProFTPD 服务
sudo systemctl restart proftpd
```

注释掉 `/etc/proftpd/proftpd.conf` 文件中注释掉[第29行](https://gitee.com/mirrors_hestiacp/hestiacp/blob/main/install/deb/proftpd/proftpd.conf#L29),参考如下:
::: details 查看代码

```ts:line-numbers {29}
ServerName                      "FTP"
ServerIdent                     on "FTP Server ready."
ServerAdmin                     root@localhost
DefaultServer                   on
DefaultRoot                  ~ !adm

Include /etc/proftpd/tls.conf

<IfModule mod_vroot.c>
    VRootEngine                 on
    VRootAlias                  /etc/security/pam_env.conf etc/security/pam_env.conf
</IfModule>

AuthPAMConfig                   proftpd
AuthOrder                       mod_auth_pam.c* mod_auth_unix.c
UseReverseDNS                   off
User                            proftpd
Group                           nogroup
MaxInstances                    20
UseSendfile                     off
LogFormat                       default "%h %l %u %t \"%r\" %s %b"
LogFormat                       auth    "%v [%P] %h %t \"%r\" %s"
ListOptions                     -a
RequireValidShell               off
PassivePorts                    12000 12100

<Global>
  Umask                         002
  // IdentLookups                  off # 新版本 ProFTPD 中已移除 IdentLookups 指令，故注释以避免错误
  AllowOverwrite                yes
  <Limit ALL SITE_CHMOD>
    AllowAll
  </Limit>
</Global>
```

:::

## Debian 11 Bullseye 升级至 Debian 12 Bookworm

### 换源

```bash
# 备份原有的软件源配置文件
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo cp -r /etc/apt/sources.list.d/ /etc/apt/sources.list.d.bak/

# 将软件源配置中的 'bullseye' (Debian 11) 替换为 'bookworm' (Debian 12)
sudo sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null

# 添加 non-free-firmware 组件
sudo sed -i 's/non-free)/non-free non-free-firmware)/g; s/non-free /non-free non-free-firmware /g' /etc/apt/sources.list

# 使用 grep 过滤出所有包含 "bookworm" 的行，确认新源是否成功更换
sudo grep -r "bookworm" /etc/apt/sources.list /etc/apt/sources.list.d/

# 使用 grep 检查软件源是否还存在 "bullseye"（应该没有结果）
sudo grep -r "bullseye" /etc/apt/sources.list /etc/apt/sources.list.d/

# 更新软件包列表，下载升级所需的软件包，并执行完整的系统升级
# 对于跨版本升级，必须使用 apt full-upgrade 来正确处理依赖关系。
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
```

### Exim 配置

```bash
rm -f /etc/exim4/exim4.conf.template
cp -f /usr/local/hestia/install/deb/exim/exim4.conf.4.95.template /etc/exim4/exim4.conf.template
```

（注意：模板版本号可能需要根据实际情况调整）

## Debian 12 Bookworm 升级至 Debian 13 Trixie

### Exim 配置

待完善

### 换源

```bash
# 备份原有的软件源配置文件
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo cp -r /etc/apt/sources.list.d/ /etc/apt/sources.list.d.bak/

# 将软件源配置中的 'bookworm' (Debian 12) 替换为 'trixie' (Debian 13)
sudo sed -i 's/bookworm/trixie/g' /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null

# 使用 grep 过滤出所有包含 "trixie" 的行，确认新源是否成功更换
sudo grep -r "trixie" /etc/apt/sources.list /etc/apt/sources.list.d/

# 使用 grep 检查软件源是否还存在 "bookworm"（应该没有结果）
sudo grep -r "bookworm" /etc/apt/sources.list /etc/apt/sources.list.d/

# 更新软件包列表，下载升级所需的软件包，并执行完整的系统升级
# 对于跨版本升级，必须使用 apt full-upgrade 来正确处理依赖关系。
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
```

## Ubuntu 18.04 Bionic 升级到 Ubuntu 20.04 Focal

### 自动升级

```bash
# 安装升级工具（如果尚未安装）
sudo apt install update-manager-core -y

# 更新系统
sudo apt update && sudo apt upgrade -y

# 开始升级到24.04
sudo do-release-upgrade
```

由于`Hestia`于`2019`年基于`VestaCP`开发.并未在之前的版本测试所以不支持该版本！所有此部分资料请自行搜索解决方案！

## Ubuntu 20.04 Focal 到 Ubuntu 22.04 Jammy

::: tip
请验证MariaDB至少运行在10.6版本。如果不是，请先在当前操作系统中升级到该版本！之后，注释掉`/etc/apt/sources.list.d/mariadb.list`中的相关行，然后升级操作系统。
:::

### 自动升级

```bash
# 安装升级工具（如果尚未安装）
sudo apt install update-manager-core -y

# 更新系统
sudo apt update && sudo apt upgrade -y

# 开始升级到24.04
sudo do-release-upgrade
```

### SHA512密码加密

```bash
sed -i "s/obscure yescrypt/obscure sha512/g" /etc/pam.d/common-password
```

### Exim4配置

```bash
rm -f /etc/exim4/exim4.conf.template
cp -f /usr/local/hestia/install/deb/exim/exim4.conf.4.94.template /etc/exim4/exim4.conf.template
```

（注意：模板版本号可能需要根据实际情况调整）

### ProFTPD

#### 问题说明

在新版本 `ProFTPD` 中 `IdentLookups` 指令已被移除。保留此指令会导致服务启动错误，需要注释掉配置文件中的相关行。

#### 快速修改

```bash
# 注释掉 IdentLookups 指令
sudo sed -i 's/^IdentLookups/\/\/ IdentLookups/' /etc/proftpd/proftpd.conf

# 重启 ProFTPD 服务
sudo systemctl restart proftpd
```

注释掉 `/etc/proftpd/proftpd.conf` 文件中注释掉[第29行](https://gitee.com/mirrors_hestiacp/hestiacp/blob/main/install/deb/proftpd/proftpd.conf#L29),参考如下:
::: details 查看代码

```ts:line-numbers {29}
ServerName                      "FTP"
ServerIdent                     on "FTP Server ready."
ServerAdmin                     root@localhost
DefaultServer                   on
DefaultRoot                  ~ !adm

Include /etc/proftpd/tls.conf

<IfModule mod_vroot.c>
    VRootEngine                 on
    VRootAlias                  /etc/security/pam_env.conf etc/security/pam_env.conf
</IfModule>

AuthPAMConfig                   proftpd
AuthOrder                       mod_auth_pam.c* mod_auth_unix.c
UseReverseDNS                   off
User                            proftpd
Group                           nogroup
MaxInstances                    20
UseSendfile                     off
LogFormat                       default "%h %l %u %t \"%r\" %s %b"
LogFormat                       auth    "%v [%P] %h %t \"%r\" %s"
ListOptions                     -a
RequireValidShell               off
PassivePorts                    12000 12100

<Global>
  Umask                         002
  // IdentLookups                  off # 新版本 ProFTPD 中已移除 IdentLookups 指令，故注释以避免错误
  AllowOverwrite                yes
  <Limit ALL SITE_CHMOD>
    AllowAll
  </Limit>
</Global>
```

:::

## Ubuntu 22.04 Jammy 到 Ubuntu 24.04 Noble

::: warning 温馨提示
请验证MariaDB至少运行在11.4版本。如果不是，请先在当前操作系统中升级到该版本！之后，注释掉`/etc/apt/sources.list.d/mariadb.list`中的相关行，然后升级操作系统。
:::

### 自动升级

```bash
# 安装升级工具（如果尚未安装）
sudo apt install update-manager-core -y

# 更新系统
sudo apt update && sudo apt upgrade -y

# 开始升级到24.04
sudo do-release-upgrade
```

### Exim4配置

```bash
rm -f /etc/exim4/exim4.conf.template
cp -f /usr/local/hestia/install/deb/exim/exim4.conf.4.95.template /etc/exim4/exim4.conf.template
```

（注意：模板版本号可能需要根据实际情况调整）

## 旧版本

我们尚未测试从 Ubuntu 16.04 到 Ubuntu 20.04 或 Debian 8 Jessy 到 Debian 10 的升级方案！感谢你对hestia的支持！
