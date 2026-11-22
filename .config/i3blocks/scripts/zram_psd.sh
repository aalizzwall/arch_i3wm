#!/usr/bin/env bash
# 條件顯示：zram0 壓縮用量 + psd (Brave RAM OverlayFS) 差分大小 (Nord + Nerd Font)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/theme.sh
source "${SCRIPT_DIR}/lib/theme.sh"

parts=()

# 1. zram0 統計（超過 5 MiB 才顯示）
if [[ -r /sys/block/zram0/mm_stat ]]; then
    read -r orig compr _ < /sys/block/zram0/mm_stat
    if (( orig >= 5242880 )); then
        zram_txt="$(awk -v o="$orig" -v c="$compr" 'BEGIN {
            om = o / 1048576; cm = c / 1048576;
            ratio = (c > 0) ? o / c : 0;
            if (om >= 1024) printf "%.1fG→%.0fM(%.1fx)", om/1024, cm, ratio;
            else            printf "%.0fM→%.0fM(%.1fx)", om, cm, ratio;
        }')"
        zc="$C_FG"
        (( orig >= 4294967296 )) && zc="$C_WARN"
        parts+=("$(fmt_block "󰿠" "$zram_txt" "$zc" "$C_ICON")")
    fi
fi

# 2. psd (Brave RAM OverlayFS) 真實 RAM 差分用量
psd_mb=""
upper_dir="$(awk '$3 == "overlay" && $2 ~ /brave/ {
    n = split($4, opts, ",");
    for (i = 1; i <= n; i++) {
        if (opts[i] ~ /^upperdir=/) {
            sub(/^upperdir=/, "", opts[i]);
            print opts[i];
            exit;
        }
    }
}' /proc/mounts 2>/dev/null || true)"

if [[ -n "$upper_dir" && -d "$upper_dir" ]]; then
    kb="$(du -sk "$upper_dir" 2>/dev/null | awk '{print $1}' || echo 0)"
    psd_mb=$(( kb / 1024 ))
else
    for ov in "/run/user/${UID}/psd/"*-brave-rw; do
        if [[ -d "$ov" ]]; then
            kb="$(du -sk "$ov" 2>/dev/null | awk '{print $1}' || echo 0)"
            psd_mb=$(( kb / 1024 ))
            break
        fi
    done
fi

if [[ -n "$psd_mb" ]]; then
    pc="$C_FG"
    pic="$C_ICON"
    if (( psd_mb >= 1024 )); then
        pc="$C_CRIT"; pic="$C_CRIT"
    elif (( psd_mb >= 512 )); then
        pc="$C_WARN"; pic="$C_WARN"
    fi
    parts+=("$(fmt_block "󰖟" "${psd_mb}M" "$pc" "$pic")")
fi

if [[ "${BLOCK_BUTTON:-}" == "1" ]]; then
    swap_out="$(swapon --show --noheadings 2>/dev/null || echo '無啟用 swap')"
    tmpfs_free="$(df -h "/run/user/${UID}" 2>/dev/null | awk 'NR==2 {print $4 " 可用 (" $5 " 已用)"}')"
    notify-send "󰿠 zram & Brave RAM 狀態" \
"Swap / zram:
${swap_out}
Brave RAM 差分: ${psd_mb:-未啟用} MiB (tmpfs ${tmpfs_free:-N/A})"
fi

(( ${#parts[@]} == 0 )) && exit 0

joined="$(IFS=' '; printf '%s' "${parts[*]}")"
emit_block "$joined"
