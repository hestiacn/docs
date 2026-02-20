import nav from "./nav";
const BUILD_YEAR = new Date().getFullYear();
export default {
	markdown: {
		codeCopyButtonTitle: '复制'
	  },
	lang: 'zh-CN',
	title: 'HestiaCP中文站 | 开源服务器控制面板',
	description: 'HestiaCP 中文文档 - 开源 Linux 服务器控制面板，支持 Debian/Ubuntu/RHEL系列 系统，提供 Nginx+PHP+MySQL 全栈解决方案，包含 Web 服务配置、SSL 证书管理、邮件服务和域名管理等功能。',
	cleanUrls: false,
	head: [
		['script', {}, `(function(){function updateYear(){var el=document.getElementById('dynamicYear');if(el){var year=new Date().getFullYear();el.textContent!==year.toString()&&(el.textContent=year);}}document.readyState==='loading'?document.addEventListener('DOMContentLoaded',updateYear):updateYear();setInterval(updateYear,3600000);})();`],
		['meta', {name: 'viewport',content: 'width=device-width, initial-scale=1.0, viewport-fit=cover'}],
		['meta', { name: 'theme-color', content: '#b7236a' }],
		['meta', { name: 'keywords', content: 'HestiaCP中文,服务器控制面板,Linux服务器管理,开源Web面板,Nginx配置工具' }],
		['link', { rel: 'icon', sizes: 'any', href: '/favicon.ico' }],
		['link', { rel: 'icon', type: 'image/svg+xml', sizes: '16x16', href: '/logo.svg' }],
		['link', { rel: 'apple-touch-icon', sizes: '180x180', href: '/apple-touch-icon.png' }],
		['link', { rel: 'manifest', href: '/site.webmanifest' }],
		['script', { defer: true,src: 'https://cloud.umami.is/script.js','data-website-id': '3ece9ced-95d4-4b95-9cdd-95e6c30f351f'}],
	],

  themeConfig: {
    logo: "/logo.svg",
    siteTitle: 'Hestia服务器控制面板',
    nav: nav,
	socialLinks: [
		{ icon: 'github', link: 'https://github.com/hestiacp/hestiacp' },
		{ icon: 'twitter', link: 'https://twitter.com/HestiaPanel' },
		{ icon: 'facebook', link: 'https://www.facebook.com/hestiacp' },
	],
    search: {
      provider: 'local',
      options: {
        placeholder: '搜索文档',
        minMatchCharLength: 1,
        threshold: 0.2,
        distance: 5000,
        keys: ['title', 'content', 'headers'],
        tokenize: (text) => {
          const tokens = []
          const chineseChars = text.match(/[\u4e00-\u9fa5]/g) || []
          const englishWords = text.match(/[a-zA-Z0-9]+/g) || []
          return [...chineseChars, ...englishWords]
        },
        translations: {
          button: { buttonText: '搜索文档' },
          modal: {
            noResultsText: '未找到相关内容',
            resetButtonTitle: '清除搜索条件',
            footer: {
              selectText: '选择',
              navigateText: '切换',
              closeText: '关闭',
            },
          },
        },
      },
    },
    sidebar: { '/docs/': sidebarDocs() },
    outlineTitle: "内容导航",
    lightModeSwitchTitle: '切换到白天模式',
		darkModeSwitchTitle: '切换到夜晚模式',
		editLink: {//'https://github.com/hestiacn/docs/edit/main/docs/:path',
			pattern: 'https://cnb.cool/hestiamb/docs/-/blob/master/docs/:path',
			text: '在 微信开发平台 上编辑此页面',
		},
		footer: {
		  message: '根据<a href="https://gitee.com/mirrors_hestiacp/hestiacp/raw/main/LICENSE" target="_blank"><img src="https://img.shields.io/badge/License-GPLv3-red.svg?labelColor=b7236a" alt="http3" style="display: inline-block !important; height: 20px; margin: -4px 0 0 3px; vertical-align: middle;"></a> 协议发布 | <a href="https://http3.wcode.net/?q=hestiamb.org" target="_blank"><img src="https://img.shields.io/badge/https-%E6%9C%AC%E7%AB%99%E6%94%AF%E6%8C%81HTTP3-2ECC71?labelColor=b7236a" alt="http3" style="display: inline-block !important; height: 20px; margin: -4px 0 0 3px; vertical-align: middle;"></a>',
		  copyright: '版权所有 © 2019-<span id="dynamicYear">' + BUILD_YEAR + '</span> <a href="https://hestiacp.com" target="_blank"><img src="https://img.shields.io/badge/Hestia-%E6%9C%8D%E5%8A%A1%E5%99%A8%E6%8E%A7%E5%88%B6%E9%9D%A2%E6%9D%BF-006BFF?labelColor=b7236a" alt="http3" style="display: inline-block !important; height: 20px; margin: -4px 0 0 3px; vertical-align: middle;"></a>'
		},
		sidebarMenuLabel: '目录',
		darkModeSwitchLabel: '深浅模式',
		returnToTopLabel:'返回顶部',
		lastUpdated: {
		text: '最后更新于',
		formatOptions: {dateStyle: 'full',timeStyle: 'medium',timeZone: 'Asia/Hong_Kong',},},
    docFooter: {
      prev: "上一页",
      next: "下一页",
    },
  },
};

/** @returns {import("vitepress").DefaultTheme.SidebarItem[]} */
function sidebarDocs() {
	return [
		{
			text: '介绍',
			collapsed: false,
			items: [
				{ text: '开始', link: '/docs/introduction/getting-started' },
				{ text: '部署建议', link: '/docs/introduction/best-practices' },
				{ text: 'hestia面板介绍', link: '/docs/introduction/hestia' },
				{ text: '更新默认错误页面', link: '/docs/introduction/defaultpage' },
			],
		},
		{
			text: '用户指南',
			collapsed: false,
			items: [
				{ text: '帐户', link: '/docs/user-guide/account' },
				{ text: '备份', link: '/docs/user-guide/backups' },
				{ text: '定时任务', link: '/docs/user-guide/cron-jobs' },
				{ text: '数据库', link: '/docs/user-guide/databases' },
				{ text: 'DNS', link: '/docs/user-guide/dns' },
				{ text: '文件管理器', link: '/docs/user-guide/file-manager' },
				{ text: '邮件域', link: '/docs/user-guide/mail-domains' },
				{ text: '通知', link: '/docs/user-guide/notifications' },
				{ text: 'Packages', link: '/docs/user-guide/packages' },
				{ text: '统计查看', link: '/docs/user-guide/statistics' },
				{ text: '用户', link: '/docs/user-guide/users' },
				{ text: '添加网站', link: '/docs/user-guide/web-domains' },
				{ text: '开启演示模式', link: '/docs/introduction/demo' },
				{ text: '常见错误', link: '/docs/introduction/faq' },
				{ text: 'Debian 13连接被拒绝', link: '/docs/introduction/debian' },
				{ text: '常用命令归档', link: '/docs/community/archive' },
			],
		},
		{
			text: '服务器管理',
			collapsed: false,
			items: [
				{ text: '备份和恢复', link: '/docs/server-administration/backup-restore' },
				{ text: '配置', link: '/docs/server-administration/configuration' },
				{ text: '自定义主题', link: '/docs/server-administration/customisation' },
				{ text: '数据库设置 & 数据库管理 ', link: '/docs/server-administration/databases' },
				{ text: 'DNS集群 & DNS安全扩展', link: '/docs/server-administration/dns' },
				{ text: '电子邮件', link: '/docs/server-administration/email' },
				{ text: '文件管理器', link: '/docs/server-administration/file-manager' },
				{ text: '防火墙', link: '/docs/server-administration/firewall' },
				{ text: '操作系统升级', link: '/docs/server-administration/os-upgrades' },
				{ text: 'Hestia API ', link: '/docs/server-administration/rest-api' },
				{ text: '服务器配置SSL证书', link: '/docs/server-administration/ssl-certificates' },
				{ text: 'Web模板和缓存及PHP模块安装', link: '/docs/server-administration/web-templates' },
				{ text: 'hestia自带命令故障排除', link: '/docs/server-administration/troubleshooting' },
			],
		},
		{
			text: '开发者文档',
			collapsed: false,
			items: [
			{ text: '构建包', link: '/docs/contributing/building' },
			{ text: '开发', link: '/docs/contributing/development' },
			{ text: '文档', link: '/docs/contributing/documentation' },
			{ text: '测试', link: '/docs/contributing/testing' },
			{ text: '快速安装应用程序', link: '/docs/contributing/quick-install-app' },
			{ text: '翻译', link: '/docs/contributing/translations' },
			],
		},
		{
			text: '社区贡献',
			collapsed: false,
			items: [
				{ text: 'Hestia Nginx 缓存', link: '/docs/community/hestia-nginx-cache' },
				{ text: '为 php 扩展 Ioncube 安装程序',link: '/docs/community/ioncube-hestia-installer' },
				{ text: '自动脚本安装 Hestia面板 生成器', link: '/docs/community/install-script-generator' },
			],
		},
		{
			text: '应用程序接口',
			collapsed: false,
			items: [
				{ text: '应用程序接口示例', link: '/docs/reference/api' },
			],
		},
		{
			text: '命令行界面操作介绍',
			collapsed: false,
			items: [
				  { text: '命令行介绍', link: '/docs/reference/cli-intro' },
				  { text: '命令行速查表', link: '/docs/reference/cli-cheatsheet' },
				  { text: 'Hestia中的RRD', link: '/docs/reference/rrd' },
				  { text: '防火墙系列命令', link: '/docs/reference/firewall' },
				  { text: '邮箱管理系列命令 ', link: '/docs/reference/mailmanagement' },
				  { text: '软件包系列命令 ', link: '/docs/reference/softwarepackage' },
				  { text: '自签名证书系列命令 ', link: '/docs/reference/selfsignedcertificate' },
				  { text: '目录系列命令 ', link: '/docs/reference/directory' },
				  { text: '服务器系列命令 ', link: '/docs/reference/server' },
				  { text: '文件系列命令 ', link: '/docs/reference/document' },
				  { text: '文件管理器系列命令 ', link: '/docs/reference/filemanager' },
				  { text: '文件夹系列命令 ', link: '/docs/reference/folder' },
				  { text: '搜索系列命令 ', link: '/docs/reference/search' },
				  { text: '恢复系列命令 ', link: '/docs/reference/recover' },
				  { text: '密钥系列命令', link: '/docs/reference/key' },
				  { text: '备份和恢复备份系列命令 ', link: '/docs/reference/backup' },
				  { text: '哈希值系列命令 ', link: '/docs/reference/hash' },
				  { text: '用户管理系列命令 ', link: '/docs/reference/useradministration' },
				  { text: 'WEB网站所有配置文件系列命令 ', link: '/docs/reference/website' },
				  { text: '更新ssl证书系列命令 ', link: '/docs/reference/renewsslcertificate' },
				  { text: 'SSH系列命令 ', link: '/docs/reference/ssh' },
				  { text: 'PHP系列命令 ', link: '/docs/reference/php' },
				  { text: 'phpMyAdmin单点登录 ', link: '/docs/reference/phpMyAdmin' },
				  { text: 'mysql和pgsql数据库系列命令', link: '/docs/reference/database' },
				  { text: 'apache和nginx系列命令 ', link: '/docs/reference/apacheandnginx' },
				  { text: 'ip地址系列命令', link: '/docs/reference/ip' },
				  { text: 'Hetia面板系列命令', link: '/docs/reference/hetiapanel' },
				  { text: 'FTPS系列命令 ', link: '/docs/reference/ftps' },
				  { text: 'DNS系列命令', link: '/docs/reference/dns' },
				  { text: '定时任务系列命令 ', link: '/docs/reference/cron' },
				  { text: 'API系列命令 ', link: '/docs/reference/apis' },
				  { text: '2FA令牌系列命令 ', link: '/docs/reference/2FAtoken' },
				  { text: '开发调试报告 ', link: '/docs/reference/bug' },
			],
		},
		{
			text: '扩展(RHEL系)',
			collapsed: false,
			items: [
				{ text: 'PHP CLI选择器', link: '/docs/extensions/php-cli-selector' },
				{ text: '扩展模块', link: '/docs/extensions/extended-modules' },
				{ text: '本地PHP配置', link: '/docs/extensions/local-php' },
			],
		},
	];
}



