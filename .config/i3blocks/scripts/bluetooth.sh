#!/usr/bin/env bash
# 藍牙狀態監控 (Nord + Nerd Font；左鍵呼叫選單，右鍵開關電源)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/theme.sh
source "${SCRIPT_DIR}/lib/theme.sh"

case "${BLOCK_BUTTON:-}" in
    1) rofi-bluetooth & ;;
    3) if rfkill list bluetooth | grep -q 'Soft blocked: yes'; then
           rfkill unblock bluetooth
       else
           rfkill block bluetooth
       fi ;;
esac

if rfkill list bluetooth | grep -q 'Soft blocked: yes'; then
    emit_block "$(fmt_block "󰂲" "" "$C_MUTED" "$C_MUTED")"
else
    connected="$(bluetoothctl devices Connected 2>/dev/null | wc -l)"
    if (( connected > 0 )); then
        emit_block "$(fmt_block "󰂱" "$connected" "$C_FG" "$C_OK")"
    else
        emit_block "$(fmt_block "󰂯" "" "$C_ICON" "$C_ICON")"
    fi
fi
