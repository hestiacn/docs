#!/bin/bash
# GitHub Hosts 更新脚本 - Linux / FreeBSD 通用版
# 功能：从 GitHub 下载最新的 hosts 文件并更新到 /etc/hosts
# 兼容：Debian/Ubuntu, RHEL/CentOS, FreeBSD
HOSTS_URL="https://hosts.gitcdn.top/hosts.txt"
BACKUP_FILE="/etc/hosts.bak.$(date +%Y%m%d%H%M%S)"
TMP_FILE=$(mktemp)

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
        echo "检测到 Linux 发行版: $OS"
    elif [ -f /etc/freebsd-version ] || [ "$(uname -s)" = "FreeBSD" ]; then
        OS="freebsd"
        OS_VERSION=$(freebsd-version -u | cut -d'-' -f1)
        echo "检测到 FreeBSD: $OS_VERSION"
    else
        echo "无法检测操作系统类型"
        exit 1
    fi
}

install_curl() {
    command -v curl >/dev/null 2>&1 && return 0
    
    echo -e "${YELLOW}正在安装 curl...${NC}"
    
    case "$OS" in
        debian|ubuntu)
            apt-get update && apt-get install -y curl
            ;;
        rhel|centos|fedora)
            if command -v dnf >/dev/null; then
                dnf install -y curl
            else
                yum install -y curl
            fi
            ;;
        freebsd)
            pkg install -y curl
            ;;
        *)
            echo -e "${RED}未知系统，请手动安装 curl${NC}"
            exit 1
            ;;
    esac
    
    command -v curl >/dev/null 2>&1 || {
        echo -e "${RED}curl 安装失败${NC}"
        exit 1
    }
}

rollback() {
    echo -e "\n${RED}错误：正在回滚...${NC}"
    
    if [ -f "$BACKUP_FILE" ]; then
        ${SUDO} cp -f "$BACKUP_FILE" /etc/hosts
        ${SUDO} rm -f "$BACKUP_FILE"
    fi
    [ -f "$TMP_FILE" ] && rm -f "$TMP_FILE"
    exit 1
}
trap rollback ERR

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        if command -v sudo >/dev/null 2>&1; then
            SUDO="sudo"
            echo -e "${YELLOW}使用 sudo 执行${NC}"
        else
            echo -e "${RED}需要 root 权限，请使用 sudo 或切换到 root 用户${NC}"
            exit 1
        fi
    else
        SUDO=""
        echo -e "${GREEN}以 root 身份运行${NC}"
    fi
}

clean_old_hosts() {
    echo -e "\n${GREEN}清理旧记录...${NC}"
    
    # 使用 awk 过滤掉 GitHub Hosts 块（跨平台兼容）
    ${SUDO} awk '
        /^# GitHub Hosts Start/ { skip = 1 }
        !skip { print }
        /^# GitHub Hosts End/ { skip = 0; next }
    ' /etc/hosts > /tmp/hosts_clean
    ${SUDO} awk '
        /^# github hosts/ { skip = 1 }
        !skip { print }
        /^# 以下为自动生成的GitHub加速记录/ { skip = 1 }
        /^$/ && skip { skip = 0; next }
    ' /tmp/hosts_clean > /tmp/hosts_clean2
    
    ${SUDO} cp /tmp/hosts_clean2 /etc/hosts
    rm -f /tmp/hosts_clean /tmp/hosts_clean2
}

validate_hosts() {
    local required_domains=(
        "github.com"
        "githubusercontent.com"
        "github.io"
        "githubassets.com"
    )

    for domain in "${required_domains[@]}"; do
        if ! grep -qE ".*${domain}" "$TMP_FILE"; then
            echo -e "${RED}验证失败：缺少关键域名 ${domain}${NC}"
            return 1
        fi
    done

    if grep -qE '^[^#]*[^[:space:]]' "$TMP_FILE"; then
        return 0
    else
        echo -e "${RED}无效 hosts 文件：无有效记录${NC}"
        return 1
    fi
}

fetch_hosts() {
    echo -e "\n${GREEN}下载最新 hosts 数据...${NC}"
    
    if ! curl -sSL "$HOSTS_URL" > "$TMP_FILE"; then
        echo -e "${RED}下载失败，请检查网络连接${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}下载完成${NC}"
}

main() {
    echo "========================================"
    echo "  GitHub Hosts 更新工具"
    echo "========================================"
    
    detect_os
    check_root
    install_curl
    
    fetch_hosts
    
    echo -e "\n${GREEN}验证下载的数据...${NC}"
    if ! validate_hosts; then
        echo -e "${RED}数据验证失败${NC}"
        exit 1
    fi
    echo -e "${GREEN}数据验证通过${NC}"

    echo -e "\n${GREEN}创建备份：${YELLOW}$BACKUP_FILE${NC}"
    ${SUDO} cp -f /etc/hosts "$BACKUP_FILE"

    # ✅ 使用修复后的清理函数
    clean_old_hosts

    echo -e "\n${GREEN}写入新记录...${NC}"
    {
        echo -e "\n# GitHub Hosts Start"
        echo "# 以下记录由 GitHub Hosts 更新脚本自动生成"
        echo "# 项目地址：https://github.com/tinsfox/github-hosts"
        echo "# 数据更新时间：$(date '+%Y-%m-%d %H:%M:%S')"
        echo "# -------------------------------------------------"
        grep -v '^#' "$TMP_FILE" | sed -e '/^$/d' -e 's/#.*//' | awk 'NF'
        echo -e "\n# GitHub Hosts End"
    } | ${SUDO} tee -a /etc/hosts >/dev/null

    echo -e "\n${GREEN}验证结果：${NC}"
    echo "--------------------------"
    if grep -A 50 '# GitHub Hosts Start' /etc/hosts | grep -q 'github.com'; then
        echo -e "${GREEN}更新验证成功${NC}"
        echo -e "新增记录数：${YELLOW}$(grep -vcE '^#|^$' "$TMP_FILE")${NC}"
    else
        echo -e "${RED}更新验证失败，正在回滚...${NC}"
        rollback
    fi
    echo "--------------------------"

    rm -f "$TMP_FILE"
    echo ""
    echo "========================================"
    echo "  /etc/hosts 文件内容（更新后）"
    echo "========================================"
    cat /etc/hosts
    echo "========================================"
    
    echo -e "\n${GREEN}✅ 完成！${NC}"
}

main