#!/bin/bash
user_dirs=$(find /home/ -maxdepth 1 -mindepth 1 -type d)
if [ -z "$user_dirs" ]; then
    echo "错误：没有找到任何用户目录。"
    exit 1
fi
for user_dir in $user_dirs; do
    username=$(basename "$user_dir")
    conf_web="$user_dir/conf/web"
    if [ ! -d "$conf_web" ]; then
        echo "警告：$conf_web 不存在，跳过 $username"
        continue
    fi
    domain_dirs=$(find "$conf_web" -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
    
    if [ -z "$domain_dirs" ]; then
        echo "警告：在 $conf_web 下没有找到域名目录。"
        continue
    fi
    for domain_dir in $domain_dirs; do
        domain=$(basename "$domain_dir")
        if [ ! -f "$domain_dir/apache2.conf" ]; then
            echo "跳过 $domain_dir：没有 apache2.conf"
            continue
        fi
        proxy_override_conf="${domain_dir}/apache2.conf_ProxyOverride"
        ssl_conf="${domain_dir}/apache2.ssl.conf_ProxyOverride"
        echo 'ProxyErrorOverride On' > "$proxy_override_conf"
        rm -f "$ssl_conf"
        cd "$domain_dir"
        ln -sf "apache2.conf_ProxyOverride" "apache2.ssl.conf_ProxyOverride"
        cd - > /dev/null
        echo "✅ 为 $domain ($domain_dir) 创建了 ProxyErrorOverride 配置"
    done
done

echo "正在重载 Apache..."
systemctl reload apache2

if systemctl is-active --quiet apache2; then
    echo "Apache 已成功重载"
else
    echo "Apache 重载失败，请检查配置"
    systemctl status apache2 --no-pager
fi

echo ""
echo "已创建的配置文件："
find /home -name "*_ProxyOverride" 2>/dev/null | sort

echo ""
echo "配置文件内容："
for conf in $(find /home -path "*/conf/web/*" -name "apache2.conf_ProxyOverride" 2>/dev/null); do
    echo "--- $conf ---"
    cat "$conf"
done