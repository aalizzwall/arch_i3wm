#!/usr/bin/env bash
# WirePlumber (wpctl) 音量控制 (Nord + Nerd Font；左/右鍵靜音，滾輪加減 5%)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/theme.sh
source "${SCRIPT_DIR}/lib/theme.sh"

case "${BLOCK_BUTTON:-}" in
    1|3) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    4)   wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    5)   wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
esac

read -r vol_pct muted < <(
    wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{
        printf "%d %s\n", int($2 * 100 + 0.5), ($3 == "[MUTED]" ? "1" : "0")
    }'
)
[[ -z "$vol_pct" ]] && exit 0

if [[ "$muted" == "1" ]]; then
    emit_block "$(fmt_block "󰝟" "MUTE" "$C_MUTED" "$C_MUTED")"
else
    if (( vol_pct >= 60 )); then
        icon=""
    elif (( vol_pct >= 20 )); then
        icon=""
    else
        icon=""
    fi
    val_c="$C_FG"
    (( vol_pct > 100 )) && val_c="$C_WARN"
    emit_block "$(fmt_block "$icon" "${vol_pct}%" "$val_c" "$C_ICON")"
fi
