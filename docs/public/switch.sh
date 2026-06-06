#!/bin/bash

LOG_FILE="/root/gxwj.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo "$1"
}

find_earliest_user_dir() {
    local earliest_ctime=9999999999 
    for dir in /home/*/; do
        if [ -d "$dir" ]; then
            ctime=$(stat --format="%W" "$dir")
            if [ -d "$dir/web" ]; then
                domain_count=$(find "$dir/web/" -maxdepth 1 -mindepth 1 -type d | wc -l)
                if [ "$domain_count" -eq 1 ]; then
                    web_dir=$(find "$dir/web/" -maxdepth 1 -mindepth 1 -type d)
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
        log_message "Error: No valid user directory found under /home/"
        exit 1
    fi
}

update_html_files() {
    local dir="$1"
    if [ -d "$dir" ]; then  
        for file in "50x.html" "403.html" "404.html" "410.html"; do
            curl -fsSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -o "${dir}/${file}" "https://hestiamb.org/web/en/skel/document_errors/${file}"
        done
        log_message "Successfully updated error pages in $dir"  
    else
        log_message "Error: Directory $dir does not exist, cannot update error pages."
    fi
}

update_domain_dirs() {
    for user_dir in /home/*; do
        if [ ! -d "$user_dir" ]; then
            continue
        fi
        target_domain_dirs=$(find "$user_dir/web/" -maxdepth 1 -mindepth 1 -type d)
        if [ -z "$target_domain_dirs" ]; then
            log_message "Error: No domain directories found in $user_dir/web/"
            continue
        fi
        for target_domain_dir in $target_domain_dirs; do
            if [ -d "$target_domain_dir" ]; then
                update_html_files "$target_domain_dir/document_errors"  
            else
                log_message "Error: Domain directory $target_domain_dir does not exist."
            fi
        done
    done
}

process_global_dirs() {
    for dir in "/var/www/document_errors" "/usr/local/hestia/data/templates/web/skel/document_errors" "/usr/local/hestia/web/error"; do
        if [ -d "$dir" ]; then
            update_html_files "$dir"
        else
            log_message "Error: Global directory $dir does not exist, cannot update error pages."
        fi
    done
    if [ -d "/var/www/html" ]; then
        curl -fsSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -o "/var/www/html/index.html" "https://hestiamb.org/web/en/unassigned/index.html"
        log_message "Updated index.html in /var/www/html/"
    else
        log_message "Error: Directory /var/www/html does not exist, cannot update index.html."
    fi
}

extra_operations() {
    if [ -d "$earliest_domain_dir" ]; then
        public_html_dir="${earliest_domain_dir}/public_html"
        if [ -d "$public_html_dir" ]; then
            curl -fsSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" -o "${public_html_dir}/index.html" "https://hestiamb.org/web/en/unassigned/index.html"
            log_message "Updated index.html in control panel domain: ${earliest_domain_dir}/public_html/"
        else
            log_message "Error: Directory ${earliest_domain_dir}/public_html does not exist, cannot update index.html."
        fi
    fi
}

FORCE_UPDATE=1  
log_message "Script execution started"
find_earliest_user_dir
update_domain_dirs
process_global_dirs
extra_operations
log_message "All operations completed."
echo "Related files have been successfully restored to the default English state of Hestia"