#!/bin/bash
# 定义Hestia二进制目录
HESTIA="/usr/local/hestia"
HESTIA_BIN="$HESTIA/bin"

# 确保PATH包含必要的目录
export PATH="/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# 检查是否以root权限运行
if [[ $EUID -ne 0 ]]; then
   echo "错误：本程序必须使用root权限运行" >&2
   exit 1
fi

# 创建目标目录（如果不存在）
mkdir -p "$HESTIA_BIN"

# 下载系统更新组件
echo "正在下载系统更新组件..."
download_files() {
    curl -fsSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -o "$HESTIA_BIN/v-update-sys-ver" "https://hestiamb.org/v-update-sys-verh" || {
        echo "错误：v-update-sys-ver 下载失败" >&2
        return 1
    }
    
    curl -fsSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -o "$HESTIA_BIN/v-update-sys-version" "https://hestiamb.org/update.sh" || {
        echo "错误：v-update-sys-version 下载失败" >&2
        return 1
    }

    curl -fsSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -o "$HESTIA_BIN/v-purge-backups" "https://hestiamb.org/v-purge-backups.sh" || {
        echo "错误：v-purge-backups 下载失败" >&2
        return 1
    }
}
download_files || exit 1

echo "配置文件权限..."

chmod 755 "$HESTIA_BIN"

chmod +x "$HESTIA_BIN/v-update-sys-ver" \
         "$HESTIA_BIN/v-update-sys-version" \
         "$HESTIA_BIN/v-purge-backups"

chown -R root:root "$HESTIA_BIN" || {
    echo "错误：权限设置失败" >&2
    exit 1
}

# 配置定时任务
echo "处理定时任务..."

# 🛠️ 每天 00:10 分执行
$HESTIA_BIN/v-add-cron-job 'admin' '10' '00' '*' '*' '*' "sudo $HESTIA_BIN/v-update-sys-version"
$HESTIA_BIN/v-add-cron-job 'admin' '10' '00' '*' '*' '*' "sudo $HESTIA_BIN/v-purge-backups"

# 验证任务是否添加成功
if crontab -u admin -l | grep -q "v-update-sys-version"; then
    echo "✓ 系统更新定时任务已添加"
else
    echo "⚠ 系统更新定时任务添加失败"
fi

if crontab -u admin -l | grep -q "v-purge-backups"; then
    echo "✓ 备份清理定时任务已添加"
else
    echo "⚠ 备份清理定时任务添加失败"
fi

# 重启 cron 服务
if [[ -f /etc/redhat-release ]]; then
    systemctl restart crond
else
    systemctl restart cron
fi

echo "所有操作已完成"