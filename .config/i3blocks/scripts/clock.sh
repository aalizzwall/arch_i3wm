#!/usr/bin/env bash
# 精簡時鐘 (Nord + Nerd Font；左鍵顯示完整時間與月曆)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/theme.sh
source "${SCRIPT_DIR}/lib/theme.sh"

if [[ "${BLOCK_BUTTON:-}" == "1" ]]; then
    full_now="$(date '+%Y-%m-%d (%a) %H:%M:%S')"
    cal_out="$(cal 2>/dev/null || true)"
    notify-send "󰥔 ${full_now}" "${cal_out}"
fi

now_txt="$(date '+%m-%d %H:%M')"
emit_block "$(fmt_block "󰥔" "$now_txt" "$C_FG" "$C_ICON")"
