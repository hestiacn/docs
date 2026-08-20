#!/bin/bash

# ======================================================== #
#
# Hestia Control Panel Installation Routine
# Automatic OS detection wrapper
# https://www.hestiacp.com/
#
# Currently Supported Operating Systems:
#
# Debian 11, 12, 13
# Ubuntu 22.04, 24.04 26.04 LTS
#
# ======================================================== #

# 检查是否以root用户身份执行脚本
if [ "x$(id -u)" != 'x0' ]; then
    echo '错误：此脚本只能由root用户执行'
    exit 1
fi

# 检查是否存在admin用户账户
if [ ! -z "$(grep ^admin: /etc/passwd)" ] && [ -z "$1" ]; then
    echo "错误：存在admin用户"
    echo
    echo '请先删除admin用户再继续。'
    echo '如果您想自动执行此操作，请使用-f选项运行安装程序：'
    echo "示例：bash $0 --force"
    exit 1
fi

# 检查是否存在admin用户组
if [ ! -z "$(grep ^admin: /etc/group)" ] && [ -z "$1" ]; then
    echo "错误：存在admin用户组"
    echo
    echo '请先删除admin用户组再继续。'
    echo '如果您想自动执行此操作，请使用-f选项运行安装程序：'
    echo "示例：bash $0 --force"
    exit 1
fi

# 检测操作系统
if [ -e "/etc/os-release" ] && [ ! -e "/etc/redhat-release" ]; then
    type=$(grep "^ID=" /etc/os-release | cut -f 2 -d '=')
    if [ "$type" = "ubuntu" ]; then
        # 检查lsb_release是否已安装
        if [ -e '/usr/bin/lsb_release' ]; then
            release="$(lsb_release -s -r)"
            VERSION='ubuntu'
        else
            echo "lsb_release当前未安装，请安装它："
            echo "apt-get update && apt-get install lsb-release"
            exit 1
        fi
    elif [ "$type" = "debian" ]; then
        release=$(cat /etc/debian_version | grep -o "[0-9]\{1,2\}" | head -n1)
        VERSION='debian'
    else
		type="NoSupport"
	fi
else
	type="NoSupport"
fi

no_support_message() {
	echo "****************************************************"
	echo "您的操作系统 (OS) 不受支持"
	echo "Hestia 控制面板。官方支持的版本:"
	echo "****************************************************"
	echo "  Debian 11, 12, 13"
	echo "  Ubuntu 22.04, 24.04, 26.04 LTS"
	echo ""
	exit 1
}

if [ "$type" = "NoSupport" ]; then
	no_support_message
fi

ensure_utf8_locale() {
	local locale_file="/etc/default/locale"

	if locale | grep -qi 'utf-8'; then
		return
	fi

	echo "[ * ] 正在启用 UTF-8 语言环境支持（使用 C.UTF-8）"
	if ! locale-gen C.UTF-8; then
		echo "[ ! ] 生成 C.UTF-8 语言环境失败，保持现有语言环境不变"
		return
	fi

	if ! update-locale LANG=C.UTF-8; then
		echo "[ ! ] 更新 $locale_file 文件中的 LANG 变量失败，保持现有语言环境不变"
		return
	fi

	export LANG=C.UTF-8
}

ensure_utf8_locale

check_wget_curl() {
	# Check wget
	if [ -e '/usr/bin/wget' ]; then
		wget -q https://hestiamb.org/install/hst-install-$type.sh -O hst-install-$type.sh
		if [ "$?" -eq '0' ]; then
			bash hst-install-$type.sh "$@"
			exit
		else
			echo "错误：hst-install-$type.sh 下载失败."
			exit 1
		fi
		# fi
	fi

	# Check curl
	if [ -e '/usr/bin/curl' ]; then
		curl -s -O https://hestiamb.org/install/hst-install-$type.sh
		if [ "$?" -eq '0' ]; then
			bash hst-install-$type.sh "$@"
			exit
		else
			echo "错误：hst-install-$type.sh 下载失败."
			exit 1
		fi
		# fi
	fi
}

# 在继续下载之前，请检查支持的操作系统
# 如果检测到不支持的操作系统，则抛出错误消息。
if [[ "$release" =~ ^(11|12|13|22.04|24.04|26.04)$ ]]; then
	check_wget_curl "$@"
else
	no_support_message
fi
 
exit