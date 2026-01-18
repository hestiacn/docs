# 备份与恢复

## 如何将用户迁移到新服务器？

当前的恢复功能支持由 VestaCP 和 HestiaCP 生成的备份。

1. 在旧服务器上创建用户备份。

```bash
v-backup-user username
```

2. 将生成的 tarball 复制到新服务器并放置在 `/backup` 中。

```bash
scp /backup/username.2020.01.01-00-00.tar root@host.domain.tld:/backup/
```

3. 在新服务器上恢复备份。可以通过更改命令中的用户名恢复到不同的用户。

```bash
v-restore-user username username.2020.01.01-00-00.tar
```

不存在的用户账户将被创建。

## 哪些备份可以恢复？

目前 HestiaCP 仅支持恢复以下备份：

1. HestiaCP
2. VestaCP
3. Cpanel
4. DirectAdmin

## 如何编辑备份数量？

要编辑备份数量，请参阅 [软件包](../user-guide/packages) 和 [用户](../user-guide/users) 文档。需要创建或编辑软件包，并将其分配给所需用户。

## 磁盘空间不足无法执行备份

出于安全考虑，Hestia 在创建备份时会考虑用户磁盘使用量的 2 倍。因此，在开始备份之前，我们会检查用户剩余的磁盘使用量。如果遇到此错误，可以通过以下方法之一解决：

- 减少每个用户保存的备份数量。
- 将备份移动到远程存储。
- 将备份文件夹移动到不同的驱动器。
- 将用户拆分为多个用户。
- 从备份中排除某些文件夹或邮件帐户。

## zstd 和 gzip 有什么区别？

zstd 由 Facebook 开发，作为 gzip 的替代品。在我们的测试中发现，与 gzip 相比，zstd 的速度显著提高，磁盘空间使用量也更低。

有关更多信息，请参见 [zstd 仓库](https://github.com/facebook/zstd) 。

## 最佳压缩比是多少？

数字越高，压缩比越好。在我们的测试中发现，zstd 级别 3 的磁盘空间与级别 9 相似，但速度更快。zstd 级别 11 的时间大致相同，但尺寸更小。高于 19 的级别永远不应使用，因为此时 zstd 会变得非常慢。

## 当前支持哪些协议？

目前支持的备份协议有：

- FTP
- SFTP
- Rclone，支持多达 50 种不同的云存储提供商。[参阅其文档](https://rclone.org) 。

## 如何设置 FTP 备份服务器？

通过 SSH 登录并以 root 用户身份运行以下命令：

```bash
v-add-backup-host 'ftp' 'remote.ftp-host.tld' 'backup-user' 'p4ssw0rd' '/path-backups/' 'port'
```

### 如何设置 SFTP 备份服务器

::: warning

请注意密码以**明文**形式存储在服务器上。它们仅对 root 用户可见，但如果想使用更安全的身份验证方法，请使用公钥和私钥。

:::

通过 SSH 登录并以 root 用户身份运行以下命令：

```bash
v-add-backup-host 'sftp' 'remote.ftp-host.tld' 'backup-user' 'p4ssw0rd' '/path-backups/' 'port'
```

如果使用公钥和私钥（推荐）：

```bash
v-add-backup-host 'sftp' 'remote.ftp-host.tld' 'backup-user' '/root/id_rsa' '/path-backups/' 'port'
```

## 如何设置 Rclone

::: tip
初始配置只能通过命令行完成。之后可以通过 Web 面板更新设置。
:::

首先，[下载 Rclone](https://rclone.org/downloads/) 。最简单的方法是运行以下命令：

```bash
sudo -v
curl https://rclone.org/install.sh | sudo bash
```

下载和安装完成后，以 root 用户身份运行 `rclone config` ，然后选择选项 `n` 。按照屏幕上的说明操作，完成后保存。

要验证是否按预期工作，请运行以下命令：

```bash
echo "test" > /tmp/backuptest.txt
rclone cp /tmp/backuptest.txt $HOST:$FOLDER/backuptest.txt
rclone lsf $HOST:$FOLDER
```

查看文件是否已上传：

```bash
rclone delete $HOST:$FOLDER/backuptest.txt
```

配置保存后，可以使用以下命令设置 Hestia：

```bash
v-add-backup-host 'rclone' 'remote-name' '' '' 'Bucket or Folder name' ''
```

::: tip
每个端点的配置可能有所不同！请确保在依赖它之前测试其工作状态。要验证其工作状态，请运行

```bash
v-backup-user admin
```

:::

例如：

```bash
rclone config

当前远程：

名称 类型
==== ====
r2 s3
```

要使用 “R2” 端点，请使用以下命令：

```bash
v-add-backup-host 'rclone' 'r2' '' '' 'folder'
```

对于 Blackblaze，请使用以下命令：

```bash
v-add-backup-host 'rclone' 'b2' '' '' 'hestiacp'
```

## 设置增量备份

在用户软件包中启用增量备份。

![alt text](/images/package1.png)

编辑 `default` 软件包方案!

![alt text](/images/package2.png)

### 使用 Rclone

从 1.9 版本开始，我们在 Hestia 安装中默认包含 Rclone。以 root 用户身份运行 `rclone config` ，然后选择选项 `n` 。按照屏幕上的说明操作，完成后保存。

运行以下命令：

```bash
v-add-backup-host-restic 'rclone:target:/folder/' '30' '8' '5' '3' '-1'
```

```bash
v-backup-users-restic
```

或

```bash
v-backup-user-restic username
```

::: warning
首次运行此命令时会初始化一个新的 restic 存储库。同时会在 /usr/local/hestia/data/users/{users}/restic.conf 中生成一个加密密钥。请确保将此文件备份到其他地方，以防服务器被入侵或用户被删除。没有这个 “密钥”，我们不提供任何恢复用户数据的方法。这就是为什么我们始终建议保留原始备份。
:::

### 其他方法

只要 Restic 支持，其他方法也受支持。但是，由于我们以 root 用户身份运行命令，因此无法预先提供密钥 / 密码等。这就是为什么与其他方法相比，Rclone 更受青睐！

## 如何更改默认备份文件夹

出于安全考虑，不允许使用符号链接。要更改默认备份文件夹，可以执行以下操作：

1. 确保备份文件夹当前设置为 `/backup` 。
2. 如果其中包含内容，请删除并重新创建。可以使用 FTP 客户端或在控制台中输入 `mkdir /backup` 。
3. 使用 `mount` 将所需文件夹挂载到 `/backup` ：

```bash
mount --bind /path/to/new/backup/folder /backup
```

要永久解决问题，应在 `fstab` 中添加记录，以便在系统启动时挂载此文件夹：

1. 打开 `/etc/fstab` 。
2. 在末尾添加以下行：

```bash
/path/to/new/backup/folder /backup none defaults,bind 0 0
```

3. 保存文件。

## 如何解压 .zstd 文件

请按照以下说明操作，或使用 [7z](https://7-zip.org) 解压 .zst 文件。

### 如何在 Windows 上使用 zstd.exe 解压 domain_data.tar.zst

1. 下载并解压 `zstd.exe`。它可在 [zstd GitHub](https://github.com/facebook/zstd/releases/) 上获得。如果您不能访问 `GitHub` 请[加速GitHub](../introduction/github)后再访问
2. 要解压备份，请使用以下命令：

```bash
{zstd 所在目录}\zstd.exe -d {文件所在目录}\{文件}.tar.zst
```

例如：

```bash
C:\Users\{用户}\Downloads\zstd-v1.4.4-win64\zstd.exe -d c:\Users\{用户}\Downloads\admin.2021-06-27_05-48-23\web\{域名}\domain_data.tar.zst
```

输出：

```bash
C:\Users\{用户}\Downloads\admin.2021-06-27_05-48-23\web\{域名}\domain_data.tar.zst: 61440 字节
```

3. 使用您喜欢的程序解压生成的 tarball，就完成了。

在这种情况下，tar 被输出到：

```bash
C:\Users\{用户}\Downloads\admin.2021-06-27_05-48-23\web\{域名}\domain_data.tar
```
