# 系统升级后更新默认错误页面英文为中文方法

::: danger 注意！
`hestiamb.org`域名为参考地址。它是您的文件服务器网站参考示例地址
:::

使用以下一键命令进行替换即可！

```bash
curl -fsSL https://hestiamb.org/cwgx.sh | bash
```

::: details 查看修改hestia默认HTML模板的方法

如果您想自定义页面请将以下路径的默认HTML模板文件下载到本地进行修改，

```bash
/home/username/web/Site/document_errors/*
/usr/local/hestia/data/templates/web/*
/usr/local/hestia/install/common/templates/web/skel/*
/usr/local/hestia/web/*
/var/www/document_errors/*
```

:::
