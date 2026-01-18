#!/bin/bash
# 定义Hestia二进制目录
HESTIA_BIN="/usr/local/hestia/bin"

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
    curl -fsSL -o "$HESTIA_BIN/v-update-sys-ver" "https://hestiamb.org/v-update-sys-ver" || {
        echo "错误：v-update-sys-ver 下载失败" >&2
        return 1
    }
    
    curl -fsSL -o "$HESTIA_BIN/v-update-sys-version" "https://hestiamb.org/update.sh" || {
        echo "错误：v-update-sys-version 下载失败" >&2
        return 1
    }

    # 新增备份清理脚本下载
    curl -fsSL -o "$HESTIA_BIN/v-purge-backups" "https://hestiamb.org/v-purge-backups.sh" || {
        echo "错误：v-purge-backups 下载失败" >&2
        return 1
    }
}
download_files || exit 1

# 设置权限和所有权
echo "配置文件权限..."
chmod -v 755 "$HESTIA_BIN/v-update-sys-ver" \
             "$HESTIA_BIN/v-update-sys-version" \
             "$HESTIA_BIN/v-purge-backups" && \
chmod -R 755 "$HESTIA_BIN" && \
chown -R root:root "$HESTIA_BIN" || {
    echo "错误：权限设置失败" >&2
    exit 1
}

# 配置定时任务 (双任务配置)
declare -A CRON_JOYS=(
    ["系统更新"]="20 5 * * * sudo $HESTIA_BIN/v-update-sys-version"
    ["备份清理"]="20 5 * * * sudo $HESTIA_BIN/v-purge-backups"
)

echo "处理定时任务..."
temp_cron=$(mktemp) || { echo "创建临时文件失败" >&2; exit 1; }
crontab -u hestiaweb -l > "$temp_cron" 2>/dev/null
modified=0

for job_name in "${!CRON_JOYS[@]}"; do
    cron_exp="${CRON_JOYS[$job_name]}"
    
    if grep -qF "$cron_exp" "$temp_cron"; then
        echo "✓ 已存在定时任务: $job_name"
    else
        echo "↑ 添加定时任务: $job_name"
        echo "$cron_exp" >> "$temp_cron"
        modified=1
    fi
done

if [[ $modified -eq 1 ]]; then
    if crontab -u hestiaweb "$temp_cron"; then
        echo "定时任务更新成功"
        # 跨平台cron服务重启
        if [[ -f /etc/redhat-release ]]; then
            systemctl restart crond
        else
            systemctl restart cron
        fi
        [[ $? -eq 0 ]] && echo "服务状态: cron已重启" || echo "警告: cron重启失败，需手动检查"
    else
        echo "错误：定时任务写入失败" >&2
        rm -f "$temp_cron"
        exit 1
    fi
else
    echo "提示：无定时任务变更"
fi

rm -f "$temp_cron"

echo "所有操作已完成"