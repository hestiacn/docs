#!/bin/bash

WEB_ROOT="${WEB_ROOT:-/var/www/html}"
LOG_DIR="/var/log/apache2"
MAX_DAYS=7

mkdir -p "$WEB_ROOT"
chown root:root "$WEB_ROOT"
chmod 755 "$WEB_ROOT"

mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/download_$(date +%Y%m%d).log"

RANDOM_NAME=$(openssl rand -hex 8)
RANDOM_FILE="${WEB_ROOT}/${RANDOM_NAME}.php"

START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
echo "${START_TIME} - 开始下载探针文件" >> "$LOG_FILE"

if curl -fsSL --max-time 30 -o "$RANDOM_FILE" "https://codeberg.org/hestiacp/tz/raw/branch/main/cn.php"; then
    chmod 644 "$RANDOM_FILE"

    PUBLIC_IP=$(curl -s --max-time 5 icanhazip.com || \
               curl -s --max-time 5 ipinfo.io/ip || \
               curl -s --max-time 5 api.ipify.org)

    END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    echo "${END_TIME} - 下载成功，文件: $RANDOM_FILE" >> "$LOG_FILE"
    
    echo "提示：探针文件已部署，请通过网页浏览器访问："
    if [ -n "$PUBLIC_IP" ]; then
        echo "http://$PUBLIC_IP/$RANDOM_NAME.php"
    else
        echo "http://$(hostname -I | awk '{print $1}')/$RANDOM_NAME.php"
        echo "（注意：自动获取的可能是内网IP，若无法访问请手动替换为公网IP）"
    fi

    find "$WEB_ROOT" -name "*.php" -mtime +$MAX_DAYS -delete
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 下载失败" >> "$LOG_FILE"
    echo "错误：探针文件下载失败，请检查网络或链接"
    exit 1
fi