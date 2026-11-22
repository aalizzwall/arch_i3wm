#!/usr/bin/env bash
# 電池電量 + 即時功耗瓦數 (Nord + Nerd Font；左鍵健康度與循環次數)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/theme.sh
source "${SCRIPT_DIR}/lib/theme.sh"

BAT="/sys/class/power_supply/BAT0"
[[ -d "$BAT" ]] || exit 0

status="$(cat "${BAT}/status" 2>/dev/null || echo Unknown)"
cap="$(cat "${BAT}/capacity" 2>/dev/null || echo 0)"
(( cap > 100 )) && cap=100

watt_str=""
if [[ -r "${BAT}/power_now" ]]; then
    p_uw="$(cat "${BAT}/power_now" 2>/dev/null || echo 0)"
    watt_str="$(awk -v p="$p_uw" 'BEGIN { if (p > 100000) printf "%.1fW", p / 1000000 }')"
elif [[ -r "${BAT}/current_now" && -r "${BAT}/voltage_now" ]]; then
    c_ua="$(cat "${BAT}/current_now" 2>/dev/null || echo 0)"
    v_uv="$(cat "${BAT}/voltage_now" 2>/dev/null || echo 0)"
    watt_str="$(awk -v c="$c_ua" -v v="$v_uv" 'BEGIN {
        w = (c < 0 ? -c : c) * v / 1e12;
        if (w >= 0.2) printf "%.1fW", w;
    }')"
fi

if [[ "${BLOCK_BUTTON:-}" == "1" ]]; then
    acpi_info="$(acpi -b 2>/dev/null || echo "$status ${cap}%")"
    cycles="$(cat "${BAT}/cycle_count" 2>/dev/null || echo N/A)"
    health="N/A"
    if [[ -r "${BAT}/charge_full" && -r "${BAT}/charge_full_design" ]]; then
        health="$(awk -v f="$(cat "${BAT}/charge_full")" -v d="$(cat "${BAT}/charge_full_design")" \
            'BEGIN { if (d > 0) printf "%.0f%%", (f / d) * 100; else print "N/A" }')"
    fi
    notify-send "󰁹 電池詳細狀態" \
"${acpi_info}
即時功耗 : ${watt_str:-0.0W}
電池健康 : ${health}  |  循環次數: ${cycles}"
fi

if [[ "$status" == "Discharging" ]]; then
    if (( cap >= 90 )); then icon="󰁹"
    elif (( cap >= 70 )); then icon="󰂀"
    elif (( cap >= 50 )); then icon="󰁾"
    elif (( cap >= 25 )); then icon="󰁼"
    else icon="󰁺"
    fi

    val_c="$C_FG"
    icon_c="$C_ICON"
    if (( cap <= 20 )); then
        val_c="$C_CRIT"; icon_c="$C_CRIT"
    elif (( cap <= 35 )); then
        val_c="$C_WARN"; icon_c="$C_WARN"
    fi
    txt="${cap}%${watt_str:+ -${watt_str}}"
    emit_block "$(fmt_block "$icon" "$txt" "$val_c" "$icon_c")" "$(fmt_block "$icon" "${cap}%" "$val_c" "$icon_c")"
elif [[ "$status" == "Charging" ]]; then
    txt="${cap}%${watt_str:+ +${watt_str}}"
    emit_block "$(fmt_block "󰂄" "$txt" "$C_OK" "$C_OK")" "$(fmt_block "󰂄" "${cap}%" "$C_OK" "$C_OK")"
else
    emit_block "$(fmt_block "󰚥" "${cap}%" "$C_FG" "$C_OK")"
fi
