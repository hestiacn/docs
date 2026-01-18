# 本地 PHP

HestiaCP RPM Edition 所使用的 PHP 解释器来源于安装该面板的软件仓库。
HestiaCP RPM Edition 可以选择使用 Remi 仓库中的 PHP，或者所谓的本地 PHP 仓库中的 PHP。

如果需要更全面的功能，请在安装面板时放弃 `uselocalphp yes` 选项，改用 `uselocalphp no` 选项进行安装。

虽然本地 PHP 在扩展集上稍显有限，但占用的磁盘空间较少，并且引入的 RPM 包也更少。对于大多数 CMS（如 Wordpress、Drupal 等）构建来说，这已经足够使用。

值得一提的是，针对这种 PHP 类型，我们还开发了一个用于管理已连接扩展的图形界面。

## PHP 扩展管理图形界面

要启用图形界面，请以管理员身份进入面板设置，并选择“附加组件”选项卡。

![ext_modules_step2](/images/ext_modules_step2.png)

在打开的网页上，需要激活 **php_brepo_modules** 模块。

![local_php_step1](/images/local_php_1.png)

在模块名称右侧会出现一个菜单项——`修改`。

点击链接 `修改` 后，将会弹出一个窗口，供您选择需要重新配置扩展的 PHP 版本。

![local_php_step2](/images/local_php_2.png)

这里会显示服务器上安装的所有本地 PHP 版本。要配置模块，请点击 PHP 版本右侧的齿轮图标（<i class="fa-solid fa-gear icon-purple"></i>），然后选择菜单中的 `修改模块列表` 项 <i class="fa-solid fa-gear icon-purple"></i>。

接着会打开扩展选择页面。

![local_php_step3](/images/local_php_3.png)

这里列出了已安装的扩展。已启用的扩展会以勾选标记显示。
您可以取消模块名称前的勾选标记，或者反之勾选上，然后点击 `保存` 以更改所选 PHP 版本的扩展配置，或者点击 `返回` 以取消更改。