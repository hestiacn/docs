# 安装 Hestia 服务器面板 - 必知事项

如果您是服务器新手或初次接触` Hestia`，请仔细阅读以下内容，以便快速了解` Hestia `服务器面板。

如需进一步了解，请查看👁️[入门](/docs/introduction/getting-started) <i class="fas fa-eye"></i>

## 安装前须知

Hestia 控制面板采用一次性固化安装机制。安装完成后，无法对已排除的组件进行增删操作。若需调整组件配置，需重新安装操作系统并重新执行 Hestia 系统的安装流程。PHP 版本的选择独立于组件配置体系，可随时调整。

### 在同一台服务器上，以下组件组合存在互斥性，不可共存安装

- 数据库服务：MySQL 8 与 MariaDB 只能二选一（二者均为关系型数据库管理系统，端口及驱动冲突）；
- FTP服务：ProFTPD 与 VSFTPD 不可同时启用（均默认占用21端口，且服务逻辑层存在冲突风险）。

## 内存方案选择

### 小内存主机方案（适用于 1-2GB 以下内存配置）

- **执行精简安装命令**：（数据库 + Hestia 控制面板）

```bash
bash hst-install.sh --exim no --dovecot no --clamav no --spamassassin no
```

![Alt text](/images/noinstiall.webp)
该配置将跳过邮件服务组件，显著降低内存占用。

### 大内存主机全功能部署（推荐 4GB 以上内存）

- **注意**：Debian 系统暂不支持 `--mysql8 yes` 参数，建议选择其他数据库。详情请查看：[MySQL 8 不支持 Debian 12](https://forum.hestiacp.com/t/error-mysql-8-does-not-support-bookworm-debian-12-why/14869)
![Alt text](/images/twoinstall.webp)
- **Ubuntu 用户提示**：若遇“同名账户存在”提示，可添加 `--force` 参数组件强制覆盖（1.9.3+ 版本已加入管理员账户自由设定，通常无需手动干预）。
![Alt text](/images/yesinastall.webp)
大内存环境建议启用完整组件栈，享受全功能一体化管理体验。

## 特别提示

- **中国境内服务器**：不支持自建邮件服务（不支持` 25 `端口）。如需自建邮件系统，请考虑使用以下主机商：
- [JustHost.ru](https://justhost.ru)
- [JustHost.com](https://justhost.com)

- **问题咨询**：如有疑问，请在中文论坛发布帖子，或在英文官方论坛查找资料。在英文论坛请不要使用中文发布任何内容.请使用英文提问以获得更快回复。
- 本站配套建立了探针文件！如果您需要请点此<a href='/tz.html' target='_blank' rel='noopener noreferrer'>查看</a>. 或访问<a href='/tz.php' target='_blank' rel='noopener noreferrer'> tz.php </a>下载.If you need the English version, please visit<a href='https://codeberg.org/hestiacn/tz/raw/branch/main/en.php' target='_blank' rel='noopener noreferrer'>english version</a>view

- 你可以使用以下命令将它下载到服务器的`/var/www/html`文件目录,完成后您直接访问服务器`IP/tz.php`即可访问该文件！

```bash
curl -fsSL https://hestiamb.org/tz.sh | bash
```
