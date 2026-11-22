#!/usr/bin/env bash
# sched_ext eBPF 排程器即時狀態 (Nord + Nerd Font)
# 常駐顯示：啟用的 scheduler 名稱；點擊顯示詳細遙測

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/theme.sh"

# 1. Read active sched_ext scheduler (if enabled)
scx_state="$(cat /sys/kernel/sched_ext/state 2>/dev/null || echo disabled)"
scx_name="eevdf"
scx_color="$C_MUTED"
if [[ "$scx_state" == "enabled" ]]; then
    raw_ops="$(cat /sys/kernel/sched_ext/root/ops 2>/dev/null || echo scx)"
    scx_name="${raw_ops#scx_}"
    scx_name="${scx_name%%_*}"
    scx_color="$C_OK"
fi

# 點擊顯示詳細遙測
if [[ "${BLOCK_BUTTON:-}" == "1" ]]; then
    notify-send "󰘚 sched_ext 排程器遙測" \
"狀態        : ${scx_state}
排程器      : ${scx_name}
(raw ops)   : $(cat /sys/kernel/sched_ext/root/ops 2>/dev/null || echo N/A)"
fi

full="$(fmt_block "󰘚" "$scx_name" "$scx_color" "$C_ICON")"
short="$full"

emit_block "$full" "$short"
