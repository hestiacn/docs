#!/bin/bash

REMOTE_BASE="https://hestiamb.org"
HESTIA_DIR="/usr/local/hestia"
TMP_DOWNLOAD_DIR="/tmp/hestia_update_sync"

mkdir -p "$TMP_DOWNLOAD_DIR/document_errors" "$TMP_DOWNLOAD_DIR/templates" "$TMP_DOWNLOAD_DIR/bin"

download_file() {
    local remote_url="$1"
    local local_path="$2"

    local fake_ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    
    echo -e "\033[1;33m[*] 正在拉取: $remote_url\033[0m"

    if curl -fsSL -A "$fake_ua" -e "$REMOTE_BASE" -o "$local_path" "$remote_url"; then
        if [ -s "$local_path" ]; then
            return 0
        fi
    fi
    echo -e "\033[0;31m[!] 错误: 文件 $remote_url 下载失败或文件大小为空！\033[0m"
    exit 1
}

for err_code in "50x" "403" "404" "410"; do
    download_file "$REMOTE_BASE/web/skel/document_errors/${err_code}.html" "$TMP_DOWNLOAD_DIR/document_errors/${err_code}.html"
done

download_file "$REMOTE_BASE/web/skel/public_html/index.html" "$TMP_DOWNLOAD_DIR/templates/index.html"
download_file "$REMOTE_BASE/web/suspend/index.html"       "$TMP_DOWNLOAD_DIR/templates/suspend_index.html"
download_file "$REMOTE_BASE/web/unassigned/index.html"    "$TMP_DOWNLOAD_DIR/templates/unassigned_index.html"
download_file "$REMOTE_BASE/awstats.tpl"                   "$TMP_DOWNLOAD_DIR/templates/awstats.tpl"

for bin_cmd in "v-add-sys-filemanager" "v-add-php-version" "v-list-sys-services" "v-update-web-domain-stat"; do
    download_file "$REMOTE_BASE/bin/${bin_cmd}" "$TMP_DOWNLOAD_DIR/bin/${bin_cmd}"
done

echo -e "\033[0;32m[*] 远程资源拉取成功，开始全自动分发……\033[0m"

for target_parent in "$HESTIA_DIR/install/common/templates/web/skel/document_errors" \
                     "$HESTIA_DIR/data/templates/web/skel/document_errors" \
                     "$HESTIA_DIR/web/error"; do
    mkdir -p "$target_parent"
    cp -f $TMP_DOWNLOAD_DIR/document_errors/*.html "$target_parent/"
done

mkdir -p "$HESTIA_DIR/install/common/templates/web/skel/public_html" "$HESTIA_DIR/data/templates/web/skel/public_html"
cp -f "$TMP_DOWNLOAD_DIR/templates/index.html" "$HESTIA_DIR/install/common/templates/web/skel/public_html/index.html"
cp -f "$TMP_DOWNLOAD_DIR/templates/index.html" "$HESTIA_DIR/data/templates/web/skel/public_html/index.html"

for page_type in "suspend" "unassigned"; do
    mkdir -p "$HESTIA_DIR/install/common/templates/web/${page_type}" "$HESTIA_DIR/data/templates/web/${page_type}"
    cp -f "$TMP_DOWNLOAD_DIR/templates/${page_type}_index.html" "$HESTIA_DIR/install/common/templates/web/${page_type}/index.html"
    cp -f "$TMP_DOWNLOAD_DIR/templates/${page_type}_index.html" "$HESTIA_DIR/data/templates/web/${page_type}/index.html"
done

for pkg_type in "deb" "rpm"; do
    mkdir -p "$HESTIA_DIR/install/${pkg_type}/templates/web/awstats"
    cp -f "$TMP_DOWNLOAD_DIR/templates/awstats.tpl" "$HESTIA_DIR/install/${pkg_type}/templates/web/awstats/awstats.tpl"
done

mkdir -p "$HESTIA_DIR/bin"
cp -f $TMP_DOWNLOAD_DIR/bin/v-* "$HESTIA_DIR/bin/"
chmod +x $HESTIA_DIR/bin/v-*

rm -rf "$TMP_DOWNLOAD_DIR"
echo -e "\033[0;32m[✓] 模板页面中文本地化更新完成！\033[0m"