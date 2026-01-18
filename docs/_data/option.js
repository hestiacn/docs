export const options = [
	{
        flag: 'port',
        label: '管理端口',
        description: '设置Hestia使用的HTTPS面板端口,默认为8083.此为必选项!',
        type: 'text',
		required: 'true',
        default: '8083',
    },
    {
        flag: 'lang',
        label: '面板WEB语言',
        description: '请选择适合您的WEB界面语言.若不进行选择.系统将默认使用英文.',
        type: 'select',
		default: 'en',
		options: [
			{ label: 'Shqip (Albanian)', value: 'sq' },
			{ label: 'العربية (Arabic)', value: 'ar' },
			{ label: 'Հայերեն (Armenian)', value: 'hy' },
			{ label: 'Azərbaycan (Azerbaijani)', value: 'az' },
			{ label: 'বাংলা (Bengali)', value: 'bn' },
			{ label: 'Bosanski (Bosnian)', value: 'bs' },
			{ label: 'Български (Bulgarian)', value: 'bg' },
			{ label: 'Català (Catalan)', value: 'ca' },
			{ label: 'Hrvatski (Croatian)', value: 'hr' },
			{ label: 'Čeština (Czech)', value: 'cs' },
			{ label: 'Dansk (Danish)', value: 'da' },
			{ label: 'Nederlands (Dutch)', value: 'nl' },
			{ label: 'English', value: 'en' },
			{ label: 'Suomi (Finnish)', value: 'fi' },
			{ label: 'Français (French)', value: 'fr' },
			{ label: 'ქართული (Georgian)', value: 'ka' },
			{ label: 'Deutsch (German)', value: 'de' },
			{ label: 'Ελληνικά (Greek)', value: 'el' },
			{ label: 'Magyar (Hungarian)', value: 'hu' },
			{ label: 'Bahasa Indonesia (Indonesian)', value: 'id' },
			{ label: 'Italiano (Italian)', value: 'it' },
			{ label: '日本語 (Japanese)', value: 'ja' },
			{ label: '한국어 (Korean)', value: 'ko' },
			{ label: 'Kurdî (Sorani Kurdish)', value: 'ku' },
			{ label: 'Norsk (Norwegian)', value: 'no' },
			{ label: 'فارسی (Persian)', value: 'fa' },
			{ label: 'Polski (Polish)', value: 'pl' },
			{ label: 'Português (Portuguese)', value: 'pt' },
			{ label: 'Português do Brasil (Brazilian Portuguese)', value: 'pt-br' },
			{ label: 'Română (Romanian)', value: 'ro' },
			{ label: 'Русский (Russian)', value: 'ru' },
			{ label: 'Српски (Serbian)', value: 'sr' },
			{ label: '简体中文 (Chinese Simplified)', value: 'zh-cn' },
			{ label: 'Slovenčina (Slovak)', value: 'sk' },
			{ label: 'Español (Spanish)', value: 'es' },
			{ label: 'Svenska (Swedish)', value: 'sv' },
			{ label: 'ไทย (Thai)', value: 'th' },
			{ label: '繁體中文 (Chinese Traditional)', value: 'zh-tw' },
			{ label: 'Türkçe (Turkish)', value: 'tr' },
			{ label: 'Українська (Ukrainian)', value: 'uk' },
			{ label: 'اردو (Urdu)', value: 'ur' },
			{ label: 'Tiếng Việt (Vietnamese)', value: 'vi' }
		],
	},
	{
		flag: 'hostname',
		label: '服务器主机名',
		description: '请设置WEB端服务器主机名.请遵循如下格式输入：demo.example.com 此为必须项!',
		type: 'text',
		default: '',
	},
	{
		flag: 'email',
		label: '电子邮件',
		description: '请输入管理员帐户电子邮件,用于服务器配置异常通知提醒,此为必须项!',
		type: 'text',
		default: '',
	},
	{
		flag: 'password',
		label: '密码',
		description: '设置管理员帐户密码.不设置将随机生成.',
		type: 'text',
		default: '',
	},
    {
        flag: 'nopublicip',
        label: '不使用公网 IP', 
        description: '启用后，安装程序将不会检测到外部服务器 IP(用于 NAT 或内部网络).',
        default: 'no',
    },
	{
		flag: 'apache',
		label: 'Apache2',
		description: 'Apache2是一个功能强大.高度可配置.广泛支持的开源Web服务器.用于提供网站托管服务.支持Web应用程序.实现负载均衡和缓存等.',
		default: 'yes',
	},
	{
        flag: 'phpfpm',
        label: 'PHP-FPM',
        description: 'PHP-FPM 是一个 FastCGI 进程管理器,用于执行 PHP 脚本.',
        default: 'yes'
    },
    {
        flag: 'multiphp',
        label: 'MultiPHP',
        description: '允许选择安装多个 PHP 版本.默认安装 PHP 8.2,不勾选安装后可通过 CLI 命令或 web 管理面板安装需要的版本.',
        default: 'yes'
    },
    {
        flag: 'vsftpd',
        label: 'VSFTPD',
        description: 'VSFTPD是一个安全、高速、稳定的FTP服务器软件.特别适用于Linux系统.用于在服务器与用户之间提供安全、快速的文件传输服务.',
        default: 'yes'
    },
    {
        flag: 'proftpd',
        label: 'ProFTPD',
        description: 'ProFTPD是一款高级模块化FTP服务器.支持通过LDAP进行用户身份验证和授权.',
        default: 'no'
    },
    {
        flag: 'named',
        label: 'BIND',
        description: 'BIND（Berkeley Internet Name Domain）是一个流行的 DNS 名称服务器软件,对于需要自定义 DNS 设置的服务器集群来说是必选项.',
        default: 'yes'
    },
    {
        flag: 'mysql',
        label: 'MariaDB',
        description: 'MariaDB 是 MySQL 的一个分支,提供了与 MySQL 兼容的特性和一些附加功能和改进.',
        default: 'yes'
    },
    {
        flag: 'mysql-classic',
        label: 'MySQL 8',
        description: 'MySQL 8 提供了易于设置.操作和缩放的功能.享受高级安全性.相同区域或区域冗余高可用性以及高达 99.99% 的服务级别协议 (SLA).',
        default: 'no'
    },
    {
        flag: 'postgresql',
        label: 'PostgreSQL',
        description: 'PostgreSQL 是一种强大的开源对象关系数据库系统,广泛应用于金融服务.制造业.零售业和物流等众多领域,可帮助开发者维护数据的完整性,更轻松地管理各种大小的工作负载.',
        default: 'no'
    },
	{
		flag: 'exim',
		label: 'Exim',
		description: 'Exim 是一个消息传输代理（MTA）,用于路由.传递和接收电子邮件消息.它允许从网络或本地程序通过 SMTP 发送电子邮件.',
		default: 'yes'
	},
	{
		flag: 'dovecot',
		label: 'Dovecot',
		description: 'Dovecot 是一个开源的 IMAP 和 POP3 电子邮件服务器软件,为 Linux 系统提供电子邮件服务.它以其安全性.易用性.速度和低资源消耗而著称.',
		default: 'yes'
	},
	{
		flag: 'sieve',
		label: 'Sieve 自定义规则',
		description: 'Sieve 是一种电子邮件过滤语言,允许管理员使用脚本来创建复杂的邮件过滤规则.这些规则可以用于检测敏感数据,并阻止其发送到网络外部,也可以用于行业或业务特定的内容过滤.',
		default: 'no'
	},
	{
		flag: 'clamav',
		label: 'ClamAV',
		description: 'ClamAV 是一个开源的跨平台电子邮件安全软件,用于检测电子邮件和其他文件中的病毒.',
		default: 'yes'
	},
	{
		flag: 'spamassassin',
		label: 'SpamAssassin',
		description: 'SpamAssassin 是一个用于识别和过滤垃圾邮件的开源工具.它通过检查邮件的标头.正文和发件人信息,应用一系列规则来评估邮件是否是垃圾邮件.',
		default: 'yes'
	},
	{
        flag: 'firewall',
        label: 'firewall',
        description: '使用firewall进行防火墙规则管理,增强系统安全性.',
        default: 'yes'
    },
    {
        flag: 'fail2ban',
        label: 'Fail2Ban',
        description: 'Fail2Ban可以自动检测和封禁尝试使用无效身份验证信息的用户,如SSH.FTP等.',
        default: 'yes'
    },
    {
        flag: 'quota',
        label: '硬盘配额',
        description: '为系统用户设置磁盘空间配额,限制硬盘使用空间.',
        default: 'no'
    },
    {
        flag: 'api',
        label: 'Hestia API',
        description: '启用Hestia的内部API,允许其他系统或服务与之交互.',
        default: 'yes'
    },
    {
        flag: 'interactive',
        label: '交互运行安装',
        description: '在安装过程中启用交互式模式,以便用户能够响应提示和选择.',
        default: 'yes'
    },
    {
        flag: 'force',
        label: '强制安装',
        description: '强制覆盖任何现有的配置和文件,进行安装.在RHEL 红帽系列发行版上建议勾选需要此选项.覆盖默认admin的配置',
        default: 'no'
    },
];
