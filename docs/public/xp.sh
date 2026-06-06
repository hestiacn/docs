#!/bin/bash

target_user_dir=""

for user_dir in /home/*/; do
    if [ -d "$user_dir/web" ]; then
        if [ -n "$(find "$user_dir/web" -mindepth 1 -type d -print -quit)" ]; then
            target_user_dir="$user_dir"
            break 
        fi
    fi
done

if [ -z "$target_user_dir" ]; then
    echo "错误：未找到包含 web 目录且 web 目录下有域名目录的用户目录。"
    exit 1
fi

target_domain_dir=$(find "$target_user_dir/web" -mindepth 1 -maxdepth 1 -type d | head -n 1)

if [ -z "$target_domain_dir" ]; then
    echo "错误：在 ${target_user_dir}web/ 下未找到域名目录。"
    exit 1
fi

curl -fsSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -o "${target_domain_dir}/document_errors/50x.html" "https://hestiamb.org/web/skel/document_errors/50x.html"
curl -fsSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -o "${target_domain_dir}/document_errors/403.html" "https://hestiamb.org/web/skel/document_errors/403.html"
curl -fsSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -o "${target_domain_dir}/document_errors/404.html" "https://hestiamb.org/web/skel/document_errors/404.html"
curl -fsSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -o "${target_domain_dir}/document_errors/410.html" "https://hestiamb.org/web/skel/document_errors/410.html"
curl -fsSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -o "${target_domain_dir}/public_html/index.html" "https://hestiamb.org/web/unassigned/index.html"