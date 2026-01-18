# PHP CLI选择器

PHP CLI选择器将系统的 `/usr/bin/php` 链接替换为一个工具，该工具会分析HestiaCP用户的配置文件，并启动为用户安装的PHP版本。

例如：

```bash
# readlink -f /usr/bin/php
/usr/bin/hestiacp-php-selector
```

默认情况下，PHP CLI选择器是禁用的，系统的PHP是系统软件包提供的标准PHP二进制文件。

要启用PHP CLI选择器，需要进入“服务器选项”->“选项”->“Web服务器”，找到“系统PHP”选择器，并在选择器下方勾选“使用PHP CLI选择器”复选框。

![php_cli_selector](/images/php_cli_selector.png)