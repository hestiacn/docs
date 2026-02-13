#!/bin/bash
# Hestia 控制面板智能卸载脚本
# 完整文档请访问：https://docs.hestiacp.com/

# ========================================================
# 配置区域
# ========================================================

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 用户运行"
    exit 1
fi

# 主路径
HESTIA="/usr/local/hestia"
LOG="/root/hst_uninstall_$(date +%Y%m%d%H%M).log"
BACKUP_DIR="/root/hst_backup_$(date +%Y%m%d%H%M)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 全局变量
declare -A COMPONENTS  # 存储组件状态
VERSION="unknown"
SERVERS=""  # 存储 serverinfo 命令输出

# ========================================================
# 核心函数定义
# ========================================================

# 日志函数
log() {
    echo -e "${GREEN}[*]${NC} $1" | tee -a "$LOG"
}

error() {
    echo -e "${RED}[!]${NC} $1" | tee -a "$LOG"
}

warning() {
    echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG"
}

info() {
    echo -e "${BLUE}[i]${NC} $1" | tee -a "$LOG"
}

# 确认函数
ask() {
    echo -n -e "${YELLOW}[?]${NC} $1 [y/N]: "
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# 检查组件是否安装
check_component() {
    local comp_type="$1"
    local comp_name="$2"
    
    if [[ -v COMPONENTS["${comp_type}:${comp_name}"] ]]; then
        return 0  # 组件已安装
    else
        return 1  # 组件未安装
    fi
}

# 添加组件到列表
add_component() {
    local comp_type="$1"
    local comp_name="$2"
    COMPONENTS["${comp_type}:${comp_name}"]="installed"
}

# 安全移除函数（带备份）
safe_remove() {
    local target="$1"
    local backup_subdir="$2"
    local desc="${3:-$1}"
    
    if [ -e "$target" ]; then
        # 创建备份
        if [ -n "$backup_subdir" ]; then
            mkdir -p "$BACKUP_DIR/$backup_subdir"
            cp -rp "$target" "$BACKUP_DIR/$backup_subdir/" 2>/dev/null && \
                log "已备份: $desc"
        fi
        
        # 执行移除
        rm -rf "$target" && \
            log "已移除: $desc"
        return 0
    else
        return 1
    fi
}

# 从 hestia.conf 检测版本号
detect_version() {
    if [ -f "$HESTIA/conf/hestia.conf" ]; then
        local version=$(grep "^VERSION=" "$HESTIA/conf/hestia.conf" 2>/dev/null | cut -d\' -f2)
        if [ -n "$version" ]; then
            echo "$version"
            return 0
        fi
    fi
    echo "unknown"
}

# ========================================================
# 智能检测函数
# ========================================================

# 检测已安装的组件
detect_components() {
    log "正在检测已安装的组件..."
    
    # 从 hestia.conf 读取配置
    if [ -f "$HESTIA/conf/hestia.conf" ]; then
        source "$HESTIA/conf/hestia.conf"
        
        # Web 系统
        if [ -n "$WEB_SYSTEM" ]; then
            add_component "web" "$WEB_SYSTEM"
            if [ "$WEB_SYSTEM" = "apache2" ] && [ -n "$PROXY_SYSTEM" ]; then
                add_component "proxy" "$PROXY_SYSTEM"
            fi
        fi
        
        # 数据库系统
        if [ -n "$DB_SYSTEM" ]; then
            IFS=',' read -ra DB_ARRAY <<< "$DB_SYSTEM"
            for db in "${DB_ARRAY[@]}"; do
                add_component "db" "${db}"
            done
        fi
        
        # FTP 系统
        if [ -n "$FTP_SYSTEM" ]; then
            add_component "ftp" "$FTP_SYSTEM"
        fi
        
        # DNS 系统
        if [ -n "$DNS_SYSTEM" ]; then
            add_component "dns" "$DNS_SYSTEM"
        fi
        
        # 邮件系统
        if [ -n "$MAIL_SYSTEM" ]; then
            add_component "mail" "$MAIL_SYSTEM"
            
            if [ -n "$ANTIVIRUS_SYSTEM" ]; then
                add_component "antivirus" "$ANTIVIRUS_SYSTEM"
            fi
            
            if [ -n "$ANTISPAM_SYSTEM" ]; then
                add_component "antispam" "$ANTISPAM_SYSTEM"
            fi
            
            if [ -n "$IMAP_SYSTEM" ]; then
                add_component "imap" "$IMAP_SYSTEM"
            fi
            
            if [ "$SIEVE_SYSTEM" = "yes" ]; then
                add_component "sieve" "enabled"
            fi
        fi
        
        # 防火墙
        if [ -n "$FIREWALL_SYSTEM" ]; then
            add_component "firewall" "$FIREWALL_SYSTEM"
        fi
        
        # Webmail
        if [ -n "$WEBMAIL_SYSTEM" ]; then
            add_component "webmail" "$WEBMAIL_SYSTEM"
        fi
        
        # API
        if [ "$API" = "yes" ]; then
            add_component "api" "enabled"
        fi
        
        # Web Terminal
        if [ "$WEB_TERMINAL" = "true" ]; then
            add_component "webterminal" "installed"
        fi
    fi
    
    # 运行 hestia 命令获取更详细信息
    if [ -f "$HESTIA/bin/hestia" ]; then
        SERVERS=$("$HESTIA/bin/hestia" serverinfo 2>/dev/null)
    fi
    
    # 检测额外可能安装的组件
    detect_extra_components
}

# 检测额外组件
detect_extra_components() {
    # 检测 PHP 版本
    for phpdir in /etc/php/*; do
        if [ -d "$phpdir" ] && [[ "$phpdir" =~ /etc/php/[0-9]+\.[0-9]+$ ]]; then
            php_ver=$(basename "$phpdir")
            add_component "php" "$php_ver"
        fi
    done
    
    # 检测 phpMyAdmin
    if [ -d "/usr/share/phpmyadmin" ] || [ -d "/etc/phpmyadmin" ]; then
        add_component "phpmyadmin" "installed"
    fi
    
    # 检测 phpPgAdmin
    if [ -d "/usr/share/phppgadmin" ] || [ -d "/etc/phppgadmin" ]; then
        add_component "phppgadmin" "installed"
    fi
    
    # 检测 Roundcube
    if [ -d "/var/lib/roundcube" ] || [ -d "/etc/roundcube" ]; then
        add_component "roundcube" "installed"
    fi
    
    # 检测 Node.js (Web Terminal)
    if [ -d "/usr/lib/node_modules/hestia-web-terminal" ] || \
       systemctl is-enabled hestia-web-terminal 2>/dev/null | grep -q "enabled"; then
        add_component "webterminal" "installed"
        add_component "nodejs" "installed"
    fi
    
    # 检测 Rclone
    if command -v rclone &>/dev/null; then
        add_component "rclone" "installed"
    fi
    
    # 检测 Restic
    if command -v restic &>/dev/null; then
        add_component "restic" "installed"
    fi
}

# 显示检测到的组件
show_components() {
    if [ ${#COMPONENTS[@]} -gt 0 ]; then
        info "检测到以下组件："
        
        # Web 相关
        if check_component "web" "nginx" || check_component "web" "apache2"; then
            echo "  • Web 服务器:"
            check_component "web" "nginx" && echo "    - Nginx"
            check_component "web" "apache2" && echo "    - Apache2"
            check_component "proxy" "nginx" && echo "    - Nginx 代理"
        fi
        
        # PHP 相关
        for key in "${!COMPONENTS[@]}"; do
            if [[ "$key" == php:* ]]; then
                php_ver="${key#php:}"
                echo "  • PHP $php_ver"
            fi
        done
        
        # 数据库相关
        if check_component "db" "mysql" || check_component "db" "mariadb" || \
           check_component "db" "pgsql"; then
            echo "  • 数据库:"
            check_component "db" "mysql" && echo "    - MySQL"
            check_component "db" "mariadb" && echo "    - MariaDB"
            check_component "db" "pgsql" && echo "    - PostgreSQL"
            check_component "phpmyadmin" "installed" && echo "    - phpMyAdmin"
            check_component "phppgadmin" "installed" && echo "    - phpPgAdmin"
        fi
        
        # 邮件相关
        if check_component "mail" "exim4"; then
            echo "  • 邮件系统:"
            echo "    - Exim4"
            check_component "imap" "dovecot" && echo "    - Dovecot"
            check_component "antivirus" "clamav-daemon" && echo "    - ClamAV"
            check_component "antispam" "spamassassin" && echo "    - SpamAssassin"
            check_component "antispam" "spamd" && echo "    - Spamd"
            check_component "sieve" "enabled" && echo "    - Sieve 过滤器"
            check_component "roundcube" "installed" && echo "    - Roundcube Webmail"
        fi
        
        # 其他服务
        if check_component "ftp" "vsftpd" || check_component "ftp" "proftpd"; then
            echo "  • FTP 服务器:"
            check_component "ftp" "vsftpd" && echo "    - VSFTPD"
            check_component "ftp" "proftpd" && echo "    - ProFTPD"
        fi
        
        check_component "dns" "bind9" && echo "  • DNS 服务器: Bind9"
        check_component "firewall" "iptables" && echo "  • 防火墙: iptables"
        check_component "firewall" "fail2ban" && echo "    - Fail2Ban"
        check_component "api" "enabled" && echo "  • API: 已启用"
        check_component "webterminal" "installed" && echo "  • Web 终端: 已安装"
        check_component "rclone" "installed" && echo "  • Rclone: 已安装"
        check_component "restic" "installed" && echo "  • Restic: 已安装"
        
        echo
    else
        warning "未检测到已安装的组件，将执行基本清理"
    fi
}

# ========================================================
# 智能卸载函数（根据检测结果执行）
# ========================================================

# 停止服务（只停止检测到的服务）
stop_detected_services() {
    log "停止检测到的服务..."
    
    # 总是停止 Hestia 服务
    systemctl stop hestia 2>/dev/null
    systemctl disable hestia 2>/dev/null
    
    # 根据检测到的组件停止服务
    for key in "${!COMPONENTS[@]}"; do
        local type="${key%%:*}"
        local name="${key#*:}"
        
        case "$type" in
            web|proxy)
                case "$name" in
                    nginx) systemctl stop nginx 2>/dev/null ;;
                    apache2) systemctl stop apache2 2>/dev/null ;;
                esac
                ;;
            db)
                case "$name" in
                    mysql|mariadb)
                        systemctl stop mysql 2>/dev/null
                        systemctl stop mariadb 2>/dev/null
                        ;;
                    pgsql)
                        systemctl stop postgresql 2>/dev/null
                        ;;
                esac
                ;;
            ftp)
                case "$name" in
                    vsftpd) systemctl stop vsftpd 2>/dev/null ;;
                    proftpd) systemctl stop proftpd 2>/dev/null ;;
                esac
                ;;
            dns)
                systemctl stop bind9 2>/dev/null
                systemctl stop named 2>/dev/null
                ;;
            mail)
                systemctl stop exim4 2>/dev/null
                systemctl stop postfix 2>/dev/null
                ;;
            imap)
                systemctl stop dovecot 2>/dev/null
                ;;
            antivirus)
                systemctl stop clamav-daemon 2>/dev/null
                ;;
            antispam)
                if dpkg -l | grep -q "spamassassin"; then
                    systemctl stop spamassassin 2>/dev/null
                elif dpkg -l | grep -q "spamd"; then
                    systemctl stop spamd 2>/dev/null
                fi
                ;;
            firewall)
                systemctl stop fail2ban 2>/dev/null
                ;;
            webterminal)
                systemctl stop hestia-web-terminal 2>/dev/null 2>/dev/null
                ;;
        esac
    done
    
    # 停止 PHP-FPM 服务
    for key in "${!COMPONENTS[@]}"; do
        if [[ "$key" == php:* ]]; then
            php_ver="${key#php:}"
            systemctl stop "php${php_ver}-fpm" 2>/dev/null
        fi
    done
}

# 核心卸载函数（总是执行）
remove_core_components() {
    log "移除核心组件..."
    
    # 1. 用户数据
    remove_user_data
    
    # 2. Hestia 核心文件
    safe_remove "$HESTIA" "hestia_core" "Hestia 核心文件"
    
    # 3. 配置目录
    safe_remove "/etc/hestia" "config" "Hestia 配置"
    safe_remove "/etc/hestiacp" "config" "Hestiacp 配置"
    
    # 4. 日志目录
    safe_remove "/var/log/hestia" "logs" "Hestia 日志"
    
    # 5. 系统集成
    remove_system_integration
    
    # 6. 数据库
    remove_databases
}

# 移除用户数据
remove_user_data() {
    log "移除用户数据..."
    
    if [ -f "$HESTIA/data/users.conf" ]; then
        users=$(grep 'USER=' "$HESTIA/data/users.conf" | cut -f2 -d\' | tr '\n' ' ')
        for user in $users; do
            log "处理用户: $user"
            
            # 移除用户目录
            safe_remove "/home/$user" "users" "用户目录 /home/$user"
            
            # 移除系统用户
            if id "$user" &>/dev/null; then
                userdel -r "$user" 2>/dev/null && \
                    log "已删除系统用户: $user"
            fi
        done
    fi
    
    # 移除 Hestia 系统用户
    for sysuser in admin hestia hestiaweb hestiamail; do
        if id "$sysuser" &>/dev/null; then
            userdel -r "$sysuser" 2>/dev/null && \
                log "已删除系统用户: $sysuser"
        fi
    done
    
    # 移除 hestia-users 组
    if getent group hestia-users >/dev/null; then
        groupdel hestia-users 2>/dev/null && \
            log "已删除用户组: hestia-users"
    fi
}

# 移除系统集成
remove_system_integration() {
    log "移除系统集成..."
    
    # 计划任务
    if crontab -u root -l 2>/dev/null | grep -q hestia; then
        crontab -u root -l | grep -v hestia | crontab -u root - 2>/dev/null && \
            log "已清理 root crontab"
    fi
    
    safe_remove "/etc/cron.d/hestia" "cron" "Hestia cron 任务"
    safe_remove "/etc/cron.daily/hestia" "cron" "Hestia 每日任务"
    safe_remove "/etc/cron.hourly/hestia" "cron" "Hestia 每小时任务"
    
    # Systemd 服务
    safe_remove "/etc/systemd/system/hestia.service" "systemd" "Hestia systemd 服务"
    safe_remove "/lib/systemd/system/hestia.service" "systemd" "Hestia systemd 服务"
    systemctl daemon-reload 2>/dev/null
    
    # 环境变量
    safe_remove "/etc/profile.d/hestia.sh" "config" "Hestia 环境变量"
    sed -i '/hestia/d' /root/.bashrc 2>/dev/null
}

# 移除数据库
remove_databases() {
    log "清理数据库..."
    
    # MySQL/MariaDB
    if check_component "db" "mysql" || check_component "db" "mariadb"; then
        if command -v mysql &>/dev/null; then
            mysql -e "DROP DATABASE IF EXISTS hestia;" 2>/dev/null
            mysql -e "DROP DATABASE IF EXISTS roundcube;" 2>/dev/null
            mysql -e "DROP USER IF EXISTS 'hestia'@'localhost';" 2>/dev/null
            log "已清理 MySQL/MariaDB 数据库"
        fi
    fi
    
    # PostgreSQL
    if check_component "db" "pgsql"; then
        if command -v psql &>/dev/null; then
            sudo -u postgres psql -c "DROP DATABASE IF EXISTS hestia;" 2>/dev/null
            sudo -u postgres psql -c "DROP USER IF EXISTS hestia;" 2>/dev/null
            log "已清理 PostgreSQL 数据库"
        fi
    fi
}

# 条件执行：Web 服务器配置
remove_web_config_if_installed() {
    if check_component "web" "nginx" || check_component "proxy" "nginx"; then
        log "清理 Nginx 配置..."
        
        safe_remove "/etc/nginx/conf.d/domains" "nginx" "Nginx 域名配置"
        safe_remove "/etc/nginx/conf.d/main" "nginx" "Nginx 主配置"
        
        # 移除特定配置文件
        for conf in phpmyadmin.inc phppgadmin.inc cloudflare.inc agents.conf; do
            safe_remove "/etc/nginx/conf.d/$conf" "nginx" "Nginx 配置 $conf"
        done
    fi
    
    if check_component "web" "apache2"; then
        log "清理 Apache 配置..."
        
        safe_remove "/etc/apache2/conf.d" "apache" "Apache 配置目录"
        safe_remove "/etc/apache2/sites-available" "apache" "Apache 站点配置"
        
        # 禁用 hestia-status 模块
        if [ -f "/etc/apache2/mods-available/hestia-status.conf" ]; then
            a2dismod hestia-status 2>/dev/null
            a2enmod status 2>/dev/null
        fi
    fi
}

# 条件执行：PHP 配置
remove_php_config_if_installed() {
    for key in "${!COMPONENTS[@]}"; do
        if [[ "$key" == php:* ]]; then
            php_ver="${key#php:}"
            log "清理 PHP $php_ver 配置..."
            
            # 移除 PHP-FPM 池配置
            safe_remove "/etc/php/$php_ver/fpm/pool.d/hestia.conf" "php" "PHP $php_ver FPM 配置"
            
            # 恢复 PHP 配置
            php_ini="/etc/php/$php_ver/fpm/php.ini"
            if [ -f "$php_ini" ]; then
                sed -i 's/date.timezone = .*/;date.timezone =/g' "$php_ini" 2>/dev/null
                sed -i 's/short_open_tag = On/short_open_tag = Off/g' "$php_ini" 2>/dev/null
            fi
        fi
    done
}

# 条件执行：邮件服务器配置
remove_mail_config_if_installed() {
    if check_component "mail" "exim4"; then
        log "清理邮件服务器配置..."
        
        safe_remove "/etc/exim4/domains" "exim" "Exim 域名配置"
        safe_remove "/etc/exim4/srs.conf" "exim" "Exim SRS 配置"
    fi
    
    if check_component "imap" "dovecot"; then
        safe_remove "/etc/dovecot/conf.d/hestia" "dovecot" "Dovecot Hestia 配置"
        safe_remove "/etc/dovecot/sieve" "dovecot" "Dovecot Sieve 配置"
    fi
    
    if check_component "antivirus" "clamav-daemon"; then
        safe_remove "/etc/clamav/clamd.conf" "clamav" "ClamAV 配置"
    fi
}

# 条件执行：数据库管理工具
remove_db_tools_if_installed() {
    if check_component "phpmyadmin" "installed"; then
        log "清理 phpMyAdmin..."
        safe_remove "/usr/share/phpmyadmin" "phpmyadmin" "phpMyAdmin 文件"
        safe_remove "/etc/phpmyadmin" "phpmyadmin" "phpMyAdmin 配置"
    fi
    
    if check_component "phppgadmin" "installed"; then
        log "清理 phpPgAdmin..."
        safe_remove "/usr/share/phppgadmin" "phppgadmin" "phpPgAdmin 文件"
        safe_remove "/etc/phppgadmin" "phppgadmin" "phpPgAdmin 配置"
    fi
}

# 条件执行：Roundcube
remove_roundcube_if_installed() {
    if check_component "roundcube" "installed"; then
        log "清理 Roundcube..."
        safe_remove "/var/lib/roundcube" "roundcube" "Roundcube 文件"
        safe_remove "/etc/roundcube" "roundcube" "Roundcube 配置"
    fi
}

# 条件执行：FTP 配置
remove_ftp_config_if_installed() {
    if check_component "ftp" "vsftpd"; then
        log "清理 VSFTPD 配置..."
        safe_remove "/etc/vsftpd.conf" "vsftpd" "VSFTPD 配置"
    fi
    
    if check_component "ftp" "proftpd"; then
        log "清理 ProFTPD 配置..."
        safe_remove "/etc/proftpd" "proftpd" "ProFTPD 配置"
    fi
}

# 条件执行：DNS 配置
remove_dns_config_if_installed() {
    if check_component "dns" "bind9"; then
        log "清理 Bind9 配置..."
        safe_remove "/etc/bind/named.conf" "bind" "Bind9 主配置"
        safe_remove "/etc/bind/named.conf.options" "bind" "Bind9 选项配置"
    fi
}

# 条件执行：防火墙配置
remove_firewall_config_if_installed() {
    if check_component "firewall" "fail2ban"; then
        log "清理 Fail2Ban 配置..."
        safe_remove "/etc/fail2ban/jail.local" "fail2ban" "Fail2Ban 配置"
        safe_remove "/etc/fail2ban/filter.d/hestia.conf" "fail2ban" "Fail2Ban Hestia 过滤规则"
    fi
}

# 条件执行：Web Terminal
remove_web_terminal_if_installed() {
    if check_component "webterminal" "installed"; then
        log "清理 Web Terminal..."
        systemctl stop hestia-web-terminal 2>/dev/null
        systemctl disable hestia-web-terminal 2>/dev/null
        safe_remove "/etc/systemd/system/hestia-web-terminal.service" "systemd" "Web Terminal 服务"
    fi
}

# 条件执行：Rclone 和 Restic
remove_tools_if_installed() {
    if check_component "rclone" "installed"; then
        log "移除 Rclone..."
        rm -f /usr/bin/rclone 2>/dev/null
        rm -rf /usr/local/bin/rclone 2>/dev/null
    fi
    
    if check_component "restic" "installed"; then
        log "移除 Restic..."
        rm -f /usr/bin/restic 2>/dev/null
        rm -rf /usr/local/bin/restic 2>/dev/null
    fi
}

# 条件执行：软件包移除
remove_packages_if_installed() {
    log "检查需要移除的软件包..."
    
    local packages=""
    
    # 基础包
    packages="hestia hestia-nginx hestia-php hestia-mariadb hestia-web-terminal"
    
    # 根据组件添加包
    for key in "${!COMPONENTS[@]}"; do
        local type="${key%%:*}"
        local name="${key#*:}"
        
        case "$type" in
            phpmyadmin) packages+=" phpmyadmin*" ;;
            phppgadmin) packages+=" phppgadmin*" ;;
            roundcube) packages+=" roundcube*" ;;
        esac
    done
    
    # 移除重复并过滤未安装的包
    local packages_to_remove=""
    for pkg in $packages; do
        if dpkg -l | grep -q "^ii.*${pkg%\\*}"; then
            packages_to_remove+=" $pkg"
        fi
    done
    
    if [ -n "$packages_to_remove" ]; then
        if ask "是否移除以下软件包？\n$(echo $packages_to_remove | tr ' ' '\n' | sed 's/^/  - /')"; then
            apt-get remove --purge -y $packages_to_remove 2>/dev/null
            apt-get autoremove -y 2>/dev/null
            apt-get autoclean -y 2>/dev/null
            log "已移除软件包"
        fi
    else
        log "未找到需要移除的 Hestia 软件包"
    fi
}

# 条件执行：APT 源移除
remove_apt_sources_if_installed() {
    log "清理 APT 软件源..."
    
    # Hestia 源（总是尝试移除）
    safe_remove "/etc/apt/sources.list.d/hestia.list" "apt" "Hestia APT 源"
    safe_remove "/etc/apt/sources.list.d/hestia-src.list" "apt" "Hestia 源码源"
    
    # 条件移除其他源
    if check_component "web" "nginx" || check_component "proxy" "nginx"; then
        safe_remove "/etc/apt/sources.list.d/nginx.list" "apt" "Nginx APT 源"
    fi
    
    if check_component "web" "apache2"; then
        safe_remove "/etc/apt/sources.list.d/apache2.list" "apt" "Apache2 APT 源"
    fi
    
    # 检查是否有 PHP 组件
    for key in "${!COMPONENTS[@]}"; do
        if [[ "$key" == php:* ]]; then
            safe_remove "/etc/apt/sources.list.d/php.list" "apt" "PHP APT 源"
            break
        fi
    done
    
    apt-get update 2>/dev/null
}

# 最终清理（总是执行）
final_cleanup() {
    log "执行最终清理..."
    
    # 临时文件
    find /tmp -name "*hestia*" -type f -delete 2>/dev/null
    find /tmp -name "*hst-*" -type f -delete 2>/dev/null
    
    # root 目录文件
    rm -f /root/hestia* 2>/dev/null
    rm -f /root/.hestia* 2>/dev/null
    
    # 清理备份目录中的 hestia 相关文件
    find /backup -name "*hestia*" -type f -delete 2>/dev/null 2>/dev/null
    
    # 恢复 hosts 文件
    if [ -n "$(grep hestia /etc/hosts 2>/dev/null)" ]; then
        sed -i '/hestia/d' /etc/hosts 2>/dev/null
    fi
    
    log "清理完成"
}

# ========================================================
# 主程序流程
# ========================================================

# 初始化
declare -A COMPONENTS
mkdir -p "$BACKUP_DIR"

# 检查 Hestia 是否安装
if [ ! -d "$HESTIA" ]; then
    error "Hestia 控制面板未安装！"
    exit 1
fi

# 获取版本
VERSION=$(detect_version)

# 显示欢迎信息
echo "========================================="
echo "      Hestia 控制面板智能卸载程序"
echo "          版本: $VERSION"
echo "========================================="
echo
warning "警告：这将彻底移除 Hestia 控制面板及所有相关数据！"
echo

# 检测组件
detect_components
show_components

# 确认操作
if ! ask "确定要继续卸载吗？"; then
    echo "卸载已取消。"
    exit 0
fi

# 开始卸载
log "开始智能卸载过程..."
log "日志文件: $LOG"
log "备份目录: $BACKUP_DIR"
echo

# 执行卸载流程（智能条件执行）
stop_detected_services
remove_core_components
remove_web_config_if_installed
remove_php_config_if_installed
remove_mail_config_if_installed
remove_db_tools_if_installed
remove_roundcube_if_installed
remove_ftp_config_if_installed
remove_dns_config_if_installed
remove_firewall_config_if_installed
remove_web_terminal_if_installed
remove_tools_if_installed
remove_apt_sources_if_installed
remove_packages_if_installed
final_cleanup

# 完成信息
echo
log "========================================="
log "        智能卸载完成！"
log "========================================="
echo
log "已根据检测结果移除了以下组件："
for key in "${!COMPONENTS[@]}"; do
    type="${key%%:*}"
    name="${key#*:}"
    echo "  - ${type}: ${name}"
done | sort
echo

if [ -d "$BACKUP_DIR" ]; then
    info "备份文件保存在: $BACKUP_DIR"
    backup_count=$(find "$BACKUP_DIR" -type f | wc -l)
    if [ "$backup_count" -gt 0 ]; then
        info "已备份 $backup_count 个文件"
    fi
fi

echo
warning "注意：以下系统软件包可能仍然保留（如需移除请手动操作）："
echo "  基础服务: apt-get remove --purge nginx apache2"
echo "  数据库: apt-get remove --purge mysql-* mariadb-* postgresql-*"
echo "  邮件服务: apt-get remove --purge exim4 dovecot-*"
echo "  PHP: apt-get remove --purge php-*"
echo "  其他: apt-get remove --purge nodejs rclone restic"
echo
log "建议重启系统以确保所有更改生效。"
echo
log "感谢您使用 Hestia 控制面板！"