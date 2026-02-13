# 添加 GitHub IP 优化网络访问

由于中国大陆境内网络环境的特殊性，直接访问某些服务（如 GitHub）可能会受到限制，这可能影响到安装 Hestia 服务器管理面板的顺利进行。为了确保安装过程不受网络问题的干扰，可以采取以下方法优化对 GitHub 的访问。

## 操作步骤

* 访问网站查看最新IP
<!--https://github-hosts.tinsfox.com-->
* https://hosts.gitcdn.top/hosts.txt
* 将最新github的IP追加到您服务器的/etc/hosts文件末尾

### 如果您担心出错.也可以使用以下命令一键自动替换

这个程序将自动更新到hosts文件内！免去手动操作的繁琐。

```bash
curl -fsSL https://hestiamb.org/hosts.sh | bash
```

* 示例：11-55行内容为获取到的地址

```ts:line-numbers {11-55}
127.0.0.1	localhost

# The following lines are desirable for IPv6 capable hosts
::1	localhost	ip6-localhost	ip6-loopback
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters
127.0.1.1	s02g07017.cloud.em160.tbsite.net	s02g07017

172.18.10.157	iZ2vc1641w2da4rqbvjhc7Z	iZ2vc1641w2da4rqbvjhc7Z

# github hosts
# 加速 GitHub 访问

140.82.112.26                 alive.github.com
20.205.243.168                api.github.com
185.199.109.153               assets-cdn.github.com
185.199.108.133               avatars.githubusercontent.com
185.199.108.133               avatars0.githubusercontent.com
185.199.109.133               avatars1.githubusercontent.com
185.199.108.133               avatars2.githubusercontent.com
185.199.108.133               avatars3.githubusercontent.com
185.199.108.133               avatars4.githubusercontent.com
185.199.111.133               avatars5.githubusercontent.com
185.199.109.133               camo.githubusercontent.com
140.82.113.21                 central.github.com
185.199.108.133               cloud.githubusercontent.com
20.205.243.165                codeload.github.com
140.82.113.22                 collector.github.com
185.199.109.133               desktop.githubusercontent.com
185.199.111.133               favicons.githubusercontent.com
20.205.243.166                gist.github.com
54.231.203.97                 github-cloud.s3.amazonaws.com
16.182.40.145                 github-com.s3.amazonaws.com
52.217.200.17                 github-production-release-asset-2e65be.s3.amazonaws.com
52.216.245.76                 github-production-repository-file-5c1aeb.s3.amazonaws.com
52.216.60.201                 github-production-user-asset-6210df.s3.amazonaws.com
192.0.66.2                    github.blog
20.205.243.166                github.com
140.82.114.18                 github.community
185.199.108.154               github.githubassets.com
151.101.1.194                 github.global.ssl.fastly.net
185.199.108.153               github.io
185.199.111.133               github.map.fastly.net
185.199.108.153               githubstatus.com
140.82.112.26                 live.github.com
185.199.109.133               media.githubusercontent.com
185.199.109.133               objects.githubusercontent.com
13.107.42.16                  pipelines.actions.githubusercontent.com
185.199.110.133               raw.githubusercontent.com
185.199.108.133               user-images.githubusercontent.com
13.107.246.73                 vscode.dev
140.82.113.22                 education.github.com
185.199.108.133               private-user-images.githubusercontent.com

# 数据更新时间：4/7/2025, 11:08:39

```

## 如果您在使用 FinalShell 操作服务器时文件夹路径加载不出来

更新系统后由于在 `ssh` 配置中更新了 `Subsystem sftp` 配置！导致无法加载文件夹！

可以使用以下命令进行查看是否存在以下配置。

```bash
sudo grep -Fx "Subsystem sftp internal-sftp-server" /etc/ssh/sshd_config
```

如果存在终端会打印出 `Subsystem sftp internal-sftp-server` 文本。

使用以下命令进行修改后直接新打开一个窗口即可正常加载了.

```bash
sudo sed -i 's/^Subsystem\ssftp\sinternal-sftp-server$/Subsystem sftp internal-sftp/' /etc/ssh/sshd_config && sudo systemctl restart sshd
```

## 编辑定时任务

如果你需要整理Hestia的定时任务！请执行以下命令

```bash
crontab -e -u hestiaweb
```
