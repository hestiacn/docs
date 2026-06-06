#!/bin/bash

HESTIA="/usr/local/hestia"
HESTIAS="$HESTIA/install/common/templates/web"
HESTIASM="$HESTIA/data/templates/web"

LOG_FILE="/var/log/hestia_version_check.log"

log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

find_earliest_user_dir() {
    local earliest_ctime=9999999999
    earliest_user_dir=""
    earliest_domain_dir=""

    local admin_dir="/home/admin"
    if [ -d "$admin_dir" ]; then
        if [ -d "$admin_dir/web" ]; then
            domain_count=$(find "$admin_dir/web/" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l)
            if [ "$domain_count" -eq 1 ]; then
                web_dir=$(find "$admin_dir/web/" -maxdepth 1 -mindepth 1 -type d -print -quit 2>/dev/null)
                earliest_user_dir="$admin_dir"
                earliest_domain_dir="$web_dir"
                return 0
            fi
        fi
    fi

    for dir in /home/*/; do
        if [ "$dir" = "/home/admin/" ]; then
            continue
        fi
        if [ -d "$dir" ]; then
            ctime=$(stat --format="%W" "$dir")
            if [ -d "$dir/web" ]; then
                domain_count=$(find "$dir/web/" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l)
                if [ "$domain_count" -eq 1 ]; then
                    web_dir=$(find "$dir/web/" -maxdepth 1 -mindepth 1 -type d -print -quit 2>/dev/null)
                    if [ "$ctime" -lt "$earliest_ctime" ]; then
                        earliest_ctime="$ctime"
                        earliest_user_dir="$dir"
                        earliest_domain_dir="$web_dir"
                    fi
                fi
            fi
        fi
    done

    if [ -z "$earliest_user_dir" ]; then
        log_message "错误：在/home/下未找到有效的用户目录。"
        exit 1
    fi
}

update_html_files() {
    local dir="$1"
    local success=0
    local total=0
    
    [ ! -d "$dir" ] && return
    
    for file in "50x.html" "403.html" "404.html" "410.html"; do
        ((total++))
        if curl -fsSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -o "${dir}/${file}" "https://hestiamb.org/web/skel/document_errors/${file}"; then
            ((success++))
        fi
    done
    
    if [ $total -gt 0 ]; then
        log_message "错误文档更新：${dir} 目录（成功 ${success}/4）"
    fi
}

update_domain_dirs() {
    log_message "开始更新域名错误文档..."
    local processed=0
    
    for user_dir in /home/*; do
        [ ! -d "$user_dir" ] && continue
        
        target_domain_dirs=$(find "$user_dir/web/" -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
        for target_domain_dir in $target_domain_dirs; do
            if [ -d "$target_domain_dir/document_errors" ]; then
                update_html_files "$target_domain_dir/document_errors"
                ((processed++))
            fi
        done
    done
    
    log_message "已处理 ${processed} 个域名的错误文档"
}

process_global_dirs() {
    log_message "更新系统级错误文档..."
    local global_dirs=(
        "/var/www/document_errors"
        "$HESTIAS/skel/document_errors" 
        "$HESTIA/web/error"
    )
    
    for dir in "${global_dirs[@]}"; do
        if [ -d "$dir" ]; then
            update_html_files "$dir"
        fi
    done
    
    if [ -d "/var/www/html" ]; then
        if curl -fsSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -o "/var/www/html/index.html" "https://hestiamb.org/web/unassigned/index.html"; then
            log_message "系统默认页已更新：/var/www/html/index.html"
        fi
    fi
}

extra_operations() {
    if [ -n "$earliest_domain_dir" ] && [ -d "$earliest_domain_dir" ]; then
        public_html_dir="${earliest_domain_dir}/public_html"
        if [ -d "$public_html_dir" ]; then
            if curl -fsSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -o "${public_html_dir}/index.html" "https://hestiamb.org/web/unassigned/index.html"; then
                log_message "管理面板默认页已更新：${public_html_dir}/index.html"
            fi
        fi
    fi
}

update_template_files() {
    local base_url="https://hestiamb.org/web"
    local hestia_data="$HESTIASM"
    local hestia_install="HESTIAS"

    declare -A template_map=(
        ["$hestia_data"]="skel/public_html:index.html
skel/document_errors:403.html 404.html 410.html 50x.html
suspend:index.html
unassigned:index.html"
        
        ["$hestia_install"]="skel/public_html:index.html
skel/document_errors:403.html 404.html 410.html 50x.html
suspend:index.html
unassigned:index.html"
    )

    log_message "开始更新模板文件..."
    local total_updated=0

    for base_dir in "${!template_map[@]}"; do
        while IFS= read -r line; do
            [ -z "$line" ] && continue
            IFS=':' read -r subdir files <<< "$line"
            subdir=$(echo "$subdir" | xargs)
            files=$(echo "$files" | xargs)
            
            target_dir="${base_dir}/${subdir}"
            mkdir -p "$target_dir"
            
            for file in $files; do
                if curl -fsSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -o "${target_dir}/${file}" "${base_url}/${subdir}/${file}"; then
                    ((total_updated++))
                fi
            done
        done <<< "${template_map[$base_dir]}"
    done

    log_message "模板文件更新完成（共更新 ${total_updated} 个文件）"
}

main() {
    log_message "脚本启动"
    find_earliest_user_dir
    update_domain_dirs
    process_global_dirs
    extra_operations
    update_template_files
    log_message "所有操作已完成"
}

main