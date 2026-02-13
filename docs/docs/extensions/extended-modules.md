# 扩展模块

::: tip 温馨提示
### 注意：本文档仅适用于 RHEL（Red Hat Enterprise Linux）系操作系统，请勿用于 Debian 系发行版。
:::

## 什么是模块

扩展模块允许扩展面板的功能。

## 如何管理模块

要访问扩展模块，请以 `admin` 用户身份进入 `服务器设置`：

![ext_modules_step1](/images/ext_modules_step1.png)

接下来在设置选择行中选择 `附加组件`：

![ext_modules_step2](/images/ext_modules_step2.png)

然后会打开一个页面，显示可用模块及其状态。

下面是一个示例页面，展示了一些演示模块：

![ext_modules_step3](/images/ext_modules_step3.png)

该页面包含以下信息：

- **模块 ID** - 模块的数字标识符
- **模块名称** - 模块的字符标识符
- **模块描述** - 模块的简要信息
- **状态** - 已启用(enabled)或已禁用(disabled)
- **依赖项** - 当前模块运行所需的必须启用的模块列表
- **配置** - 模块的附加设置（如有）

如果模块处于禁用状态，其状态将显示为 disabled。

要启用模块，请点击 <i class="fas fa-play"></i> 按钮；要禁用模块，请点击 <i class="fas fa-stop"></i> 按钮。

## 预安装模块列表

- **puppet_installer** - 安装 puppet，大多数模块需要 puppet 来更改系统配置，因此需要启用此模块。启用时，它会在系统中安装 puppet。
- **empty_module** - 空模块，其启用或禁用不会产生任何影响，是编写模块的示例。
- **passenger_manager** - 安装和配置 passenger 的模块。
- **php_brepo_modules** - 管理本地 PHP 扩展的模块。[界面说明](/docs/extensions/local-php.md)

## 从命令行管理模块

使用 `v-ext-modules` 工具来管理模块。

可用命令：

- **list** - 列出可用模块
- **enable module_name** - 启用模块
- **disable module_name** - 禁用模块
- **state module_name** - 模块状态

示例：

```bash
# v-ext-modules list csv
1,puppet_installer,"Added puppet support, needed for another modules","","",enabled
2,passenger_manager,Added passenger support for nginx,puppet_installer,yes,enabled
3,empty_module,Just empty module for storing max module id,"","",disabled
```

```bash
# v-ext-modules state passenger_manager
 ID  NAME               DESCR                              STATE    REQ               CONF 
 --  ----               -----                              -----    ---               ---- 
 2   passenger_manager  Added passenger support for nginx  enabled  puppet_installer  yes 
```

## passenger_manager

该模块用于添加对 passenger+nginx 的支持，以运行（目前仅限）ruby 应用。

### passenger_manager 配置

要配置该模块，请点击 `修改` 链接：

![ext_modules_step4](/images/ext_modules_step4.png)

会打开一个如下所示的页面：

![ext_modules_step5](/images/ext_modules_step5.png)

- **添加新的 ruby 路径** - 如果列表中尚无路径，请添加 ruby 解析器的二进制文件路径
- **Ruby 列表** - 可供选择的 ruby 解析器列表。要从列表中删除 ruby，请点击 <i class="fas fa-trash-can"></i> 图标。

启用 `passenger_manager` 后，用户在域名设置菜单中会出现 `passenger 设置` 按钮：

![ext_modules_step6](/images/ext_modules_step6.png)

点击该按钮会打开一个表单：

![ext_modules_step7](/images/ext_modules_step7.png)

在此处可以通过勾选 `为域名启用 passenger` 来激活域名的 passenger，并从列表中选择 ruby。

勾选 `在浏览器中启用日志记录` 可以在浏览器中输出应用错误日志，建议仅在应用配置期间启用。

应用安装示例：

假设有用户 `test2` 和域名 `ttt142.my.brp`，为其启用 passenger。

为其生成以下配置：

```bash
location / {
	passenger_base_uri /;
    passenger_app_root /home/test2/web/ttt142.my.brp/private;
    passenger_document_root /home/test2/web/ttt142.my.brp/public_html;
    passenger_startup_file config.rb;
	passenger_app_type rack;
}
```

在 `config.rb` 中放置应用启动指令：

```bash
# encoding: UTF-8
require './test'
run Sinatra::Application
```

并将主要应用放置在 `/home/test2/web/ttt142.my.brp/private` 目录中。

其余逻辑将放置在 `test.rb` 中，例如：

```bash
!/usr/bin/env ruby

require 'sinatra'
get '/' do
  "Hello #{Process.uid}"
end
```

静态文件应放置在 `/home/test2/web/ttt142.my.brp/public_html` 目录中，并从该目录中删除作为空白站点占位符创建的 `index.html` 文件。

此外，在 `/home/test2/web/ttt142.my.brp/private` 目录中创建 `Gemfile` 文件，并以用户身份执行：

```bash
bundle config set --local path 'vendor'
bundle install
```

或旧方式：

```bash
bundle install --path=vendor
```

用户需要安装所需的 gem。
