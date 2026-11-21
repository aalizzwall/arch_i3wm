#!/usr/bin/env bash
# systemd --user 服務監控 (Nord + Nerd Font；左鍵看即時日誌，右鍵重啟)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/theme.sh
source "${SCRIPT_DIR}/lib/theme.sh"

SERVICE="${BLOCK_INSTANCE:-}"
if [[ -z "$SERVICE" ]]; then
    emit_block "$(fmt_block "󰚩" "N/A" "$C_MUTED" "$C_MUTED")"
    exit 0
fi

case "${BLOCK_BUTTON:-}" in
    1) i3-sensible-terminal -e "journalctl --user -u $SERVICE -f" & ;;
    3) systemctl --user restart "$SERVICE" ;;
esac

# 若本機沒有此 unit 檔則安靜隱藏
LOAD_STATE="$(systemctl --user show -p LoadState --value "$SERVICE" 2>/dev/null || true)"
if [[ -z "$LOAD_STATE" || "$LOAD_STATE" == "not-found" ]]; then
    exit 0
fi

STATE="$(systemctl --user is-active "$SERVICE" 2>/dev/null || true)"
if [[ -z "$STATE" || "$STATE" == "unknown" ]]; then
    exit 0
fi

case "$STATE" in
    active)
        emit_block "$(fmt_block "󰚩" "UP" "$C_FG" "$C_OK")"
        ;;
    failed)
        emit_block "$(fmt_block "󰚩" "FAIL" "$C_CRIT" "$C_CRIT")"
        ;;
    inactive)
        emit_block "$(fmt_block "󰚩" "STOP" "$C_WARN" "$C_MUTED")"
        ;;
    *)
        emit_block "$(fmt_block "󰒓" "$STATE" "$C_HIGH" "$C_HIGH")"
        ;;
esac
