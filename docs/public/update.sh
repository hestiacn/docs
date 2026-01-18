#!/bin/bash

# Hestia版本监控脚本
# 修正版本：1.1
# 更新说明：修复版本对比逻辑，优化日志输出方式

HESTIA="/usr/local/hestia"  
VERSION_FILE="/var/version.dat" 
TARGET_SCRIPT="$HESTIA/bin/v-update-sys-ver"
LOG_FILE="/var/log/hestia_version_check.log"

# 初始化日志文件
init_logging() {
    if ! touch "$LOG_FILE" 2>/dev/null; then
        echo "无法创建日志文件 $LOG_FILE" >&2
        exit 100
    fi
    chmod 600 "$LOG_FILE"
    log_message "========== 开始版本检测 =========="
}

# 安全日志记录函数（仅写入文件）
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# 严格模式获取版本号
get_current_version() {
    local conf_file="$HESTIA/conf/hestia.conf"
    
    if [ ! -f "$conf_file" ] || [ ! -r "$conf_file" ]; then
        log_message "致命错误：配置文件不可访问 $conf_file"
        exit 101
    fi
    
    local version_line=$(grep -m1 -E '^VERSION=['\''"]?[0-9]+\.[0-9]+\.[0-9]+' "$conf_file")
    if [ -z "$version_line" ]; then
        log_message "配置错误：未找到有效的VERSION定义"
        exit 102
    fi

    local version=$(echo "$version_line" | sed -E "s/^VERSION=['\"]?//;s/['\"]$//")
    
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_message "版本格式异常：'$version'"
        exit 103
    fi
    
    echo "$version"
}

# 增强版版本文件管理
manage_version_file() {
    # 处理首次运行的情况
    if [ ! -f "$VERSION_FILE" ]; then
        log_message "检测到版本文件不存在，开始初始化..."
        
        local version_dir=$(dirname "$VERSION_FILE")
        if ! mkdir -p "$version_dir" 2>/dev/null; then
            log_message "目录创建失败：$version_dir"
            exit 104
        fi

        local current_version=$(get_current_version)
        if ! echo "$current_version" > "$VERSION_FILE"; then
            log_message "文件写入失败：$VERSION_FILE"
            exit 105
        fi
        
        # 双重验证写入内容
        local verify_version=$(cat "$VERSION_FILE")
        if [ "$verify_version" != "$current_version" ]; then
            log_message "版本文件校验失败 (预期: $current_version 实际: $verify_version)"
            exit 106
        fi
        
        log_message "版本文件初始化成功：$current_version"
        echo "$current_version"  # 这是唯一的标准输出
        return
    fi

    # 处理已存在版本文件的情况
    local stored_version=$(cat "$VERSION_FILE" 2>/dev/null)
    if [[ ! "$stored_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_message "警告：版本文件损坏，尝试修复..."
        rm -f "$VERSION_FILE"
        echo $(manage_version_file)  # 递归调用
    else
        echo "$stored_version"
    fi
}

# 安全执行目标脚本
run_target_script() {
    log_message "检测到版本变更：$stored_ver => $current_ver"
    
    # 三重验证目标脚本
    if [ ! -f "$TARGET_SCRIPT" ]; then
        log_message "目标脚本不存在：$TARGET_SCRIPT"
        exit 107
    fi
    
    if [ ! -x "$TARGET_SCRIPT" ]; then
        log_message "执行权限缺失：$TARGET_SCRIPT"
        exit 108
    fi

    if ! head -n1 "$TARGET_SCRIPT" | grep -qE '^#!/bin/(bash|sh)'; then
        log_message "脚本解释器无效：$TARGET_SCRIPT"
        exit 109
    fi

    # 执行并记录输出
    log_message "开始执行更新脚本..."
    local output
    if output=$("$TARGET_SCRIPT" 2>&1); then
        log_message "脚本执行成功"
        log_message "输出内容：$output"
        # 更新版本记录
        if ! echo "$current_ver" > "$VERSION_FILE"; then
            log_message "警告：版本文件更新失败"
            exit 110
        fi
    else
        log_message "脚本执行失败，退出码：$?"
        log_message "错误输出：$output"
        exit 111
    fi
}

# 主程序流程
main() {
    init_logging
    
    # 获取版本信息（关键修改点）
    stored_ver=$(manage_version_file)
    current_ver=$(get_current_version)
    
    log_message "存储版本：$stored_ver"
    log_message "当前版本：$current_ver"
    
    if [ "$stored_ver" != "$current_ver" ]; then
        log_message "检测到版本更新"
        run_target_script
    else
        log_message "版本无变化"
    fi
               
    log_message "=========== 检测完成 ============="
}

# 异常处理
trap 'log_message "异常中断：收到信号 $?"; exit 255' SIGINT SIGTERM

# 执行入口
main