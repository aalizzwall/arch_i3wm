#!/usr/bin/env bash
# 零依賴純 /proc/stat CPU 使用率 + 即時頻率 (Nord + Nerd Font)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/theme.sh
source "${SCRIPT_DIR}/lib/theme.sh"

STATE_FILE="/dev/shm/i3blocks_cpu_state_${UID}"

read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
total=$(( user + nice + system + idle + iowait + irq + softirq + steal ))
busy=$(( total - idle - iowait ))

pct=0
if [[ -r "$STATE_FILE" ]]; then
    read -r prev_total prev_busy < "$STATE_FILE" || true
    dt=$(( total - ${prev_total:-0} ))
    db=$(( busy - ${prev_busy:-0} ))
    if (( dt > 0 )); then
        pct=$(( db * 100 / dt ))
        (( pct < 0 )) && pct=0
        (( pct > 100 )) && pct=100
    fi
fi
printf '%s %s\n' "$total" "$busy" > "$STATE_FILE"

freq_ghz="$(awk '
    { sum += $1; n++ }
    END { if (n > 0) printf "%.1fG", (sum / n) / 1000000; else print "" }
' /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null || true)"

if [[ "${BLOCK_BUTTON:-}" == "1" ]]; then
    gov="$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor 2>/dev/null || echo N/A)"
    aspm="$(grep -o '\[[^]]*\]' /sys/module/pcie_aspm/parameters/policy 2>/dev/null || echo N/A)"
    uv="$(grep -E '^undervolt (0|1) ' /etc/intel-undervolt.conf 2>/dev/null | tr '\n' '; ' || echo 'N/A')"
    notify-send "󰻠 CPU 效能狀態" \
"Usage    : ${pct}% (${freq_ghz:-N/A})
Governor : ${gov}  |  ASPM: ${aspm}
Undervolt: ${uv}"
fi

val_c="$C_FG"
icon_c="$C_ICON"
if (( pct >= 85 )); then
    val_c="$C_CRIT"; icon_c="$C_CRIT"
elif (( pct >= 60 )); then
    val_c="$C_WARN"; icon_c="$C_WARN"
fi

val_txt="$(printf '%2d%%%s' "$pct" "${freq_ghz:+ $freq_ghz}")"
emit_block "$(fmt_block "󰻠" "$val_txt" "$val_c" "$icon_c")" "$(fmt_block "󰻠" "${pct}%" "$val_c" "$icon_c")"
