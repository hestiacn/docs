#!/bin/bash

backup_dir="/backup"
current_month=$(date '+%Y-%m')
LOG_FILE="$backup_dir/v-purge-backups-${current_month}.log"

log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

cd "$backup_dir" || { log_message "错误：无法进入备份目录 $backup_dir"; exit 1; }
shopt -s nullglob
delete_count=0

log_message "════════开始清理备份文件════════"
declare -A processed_users

for user_tar in *.tar; do
  user_name="${user_tar%%.*}"
  if [[ -v processed_users[$user_name] ]]; then
    continue
  fi
  processed_users[$user_name]=1
  latest_backup=$(ls -t "${user_name}."*.tar 2>/dev/null | head -n 1)
  if [[ -n "$latest_backup" ]]; then
    log_message "保留最新备份: $latest_backup"
    old_backups=()
    for old_backup in ${user_name}.*.tar; do
      if [[ "$old_backup" != "$latest_backup" ]]; then
        old_backups+=("$old_backup")
      fi
    done
    if [[ ${#old_backups[@]} -gt 0 ]]; then
      log_message "删除以下旧备份文件:"
      for old_backup in "${old_backups[@]}"; do
        log_message " - $old_backup"
        rm -f "$old_backup"
        ((delete_count++))
      done
    else
      log_message "当前用户 $user_name 没有可删除的旧备份。"
    fi
  fi
done
shopt -u nullglob
log_message "共删除了 $delete_count 个旧备份文件。"
log_message "════════════清理完成════════════"