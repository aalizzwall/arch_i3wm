#!/usr/bin/env bash
# 磁碟可用空間監控 (Nord + Nerd Font；左鍵顯示磁碟使用概覽)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/theme.sh
source "${SCRIPT_DIR}/lib/theme.sh"

DIR="${BLOCK_INSTANCE:-/}"

if [[ "${BLOCK_BUTTON:-}" == "1" ]]; then
    df_info="$(df -h -x tmpfs -x devtmpfs -x overlay -x squashfs 2>/dev/null | awk 'NR==1 || /^\// {printf "%-14s %6s / %-6s (%s)\n", $6, $4, $2, $5}')"
    notify-send "󰋊 磁碟空間概覽" "$df_info"
fi

read -r avail use_pct < <(df -h --output=avail,pcent "$DIR" 2>/dev/null | awk 'NR==2 {gsub(/%/, "", $2); print $1, $2}')
[[ -z "$avail" || ! "$use_pct" =~ ^[0-9]+$ ]] && exit 0

free_pct=$(( 100 - ${use_pct:-0} ))
val_c="$C_FG"
icon_c="$C_ICON"
if (( free_pct < 10 )); then
    val_c="$C_CRIT"; icon_c="$C_CRIT"
elif (( free_pct < 20 )); then
    val_c="$C_WARN"; icon_c="$C_WARN"
fi

emit_block "$(fmt_block "󰋊" "$avail" "$val_c" "$icon_c")"
