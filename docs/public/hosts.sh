#!/bin/bash

# 定义变量
HOSTS_URL="https://github-hosts.tinsfox.com/hosts"
BACKUP_FILE="/etc/hosts.bak.$(date +%Y%m%d%H%M%S)"
TMP_FILE=$(mktemp)

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# 错误处理
rollback() {
    echo -e "\n${RED}错误：正在回滚...${NC}"
    [ -f "$BACKUP_FILE" ] && sudo cp -f "$BACKUP_FILE" /etc/hosts
    [ -f "$BACKUP_FILE" ] && sudo rm -f "$BACKUP_FILE"
    [ -f "$TMP_FILE" ] && rm -f "$TMP_FILE"
    exit 1
}
trap rollback ERR

check_root() {
    [ "$(id -u)" -ne 0 ] && {
        echo -e "${RED}错误：请使用sudo或root运行${NC}"
        exit 100
    }
}

install_curl() {
    command -v curl &> /dev/null && return
    
    echo -e "${YELLOW}自动安装curl...${NC}"
    
    if grep -qEi "(redhat|centos)" /etc/*-release; then
        (command -v dnf && dnf install -y curl) || 
        (command -v yum && yum install -y curl) || {
            echo -e "${RED}请手动安装curl：yum install curl${NC}"
            exit 101
        }
    elif grep -qi "debian" /etc/*-release; then
        apt-get update && apt-get install -y curl || {
            echo -e "${RED}请手动安装curl：apt install curl${NC}"
            exit 102
        }
    else
        echo -e "${RED}不支持的Linux发行版${NC}"
        exit 103
    fi
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
        echo -e "${RED}无效hosts文件：无有效记录${NC}"
        return 1
    fi
}

clean_old_hosts() {
    echo -e "\n${GREEN}清理旧记录...${NC}"
    
    # 清理所有历史记录块（支持多版本格式）
    sudo sed -i '/^# github hosts/,/^# 数据更新时间/d' /etc/hosts
    sudo sed -i '/^# GitHub Hosts Start/,/^# GitHub Hosts End/d' /etc/hosts
    sudo sed -i '/^# 以下为自动生成的GitHub加速记录/,/^$/d' /etc/hosts
    
    # 清理可能存在的空行
    sudo sed -i '/^$/N;/^\n$/D' /etc/hosts
}

main() {
    check_root
    install_curl

    # 获取新数据
    echo -e "\n${GREEN}下载最新hosts数据...${NC}"
    if ! curl -sSL "$HOSTS_URL" > "$TMP_FILE"; then
        echo -e "${RED}下载失败，检查网络连接${NC}"
        exit 1
    fi

    # 验证内容
    if ! validate_hosts; then
        exit 2
    fi

    # 备份原文件
    echo -e "\n${GREEN}创建备份：${YELLOW}$BACKUP_FILE${NC}"
    cp -f /etc/hosts "$BACKUP_FILE"

    clean_old_hosts

    # 标准化写入格式
    echo -e "\n${GREEN}写入新记录...${NC}"
    {
        echo -e "\n# GitHub Hosts Start"
        echo "# 以下记录由GitHub Hosts更新脚本自动生成"
        echo "# 项目地址：https://github.com/tinsfox/github-hosts"
        grep -v '^#' "$TMP_FILE" | sed -e '/^$/d' -e 's/#.*//' | awk 'NF'
        echo -e "\n# 数据更新时间：$(date '+%Y-%m-%d %H:%M:%S')"
        echo "# GitHub Hosts End"
    } | sudo tee -a /etc/hosts >/dev/null

    # 最终验证
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
}

main