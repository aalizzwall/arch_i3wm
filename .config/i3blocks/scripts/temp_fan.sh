#!/usr/bin/env bash
# 真實 CPU 封裝溫度 + 條件展開 Intel GPU 頻率與 Apple SMC 風扇轉速 (Nord + Nerd Font)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/theme.sh
source "${SCRIPT_DIR}/lib/theme.sh"

GPU_SHOW_MHZ=600   # GPU >= 600 MHz 才展開顯示
FAN_SHOW_RPM=2500  # 風扇 >= 2500 RPM 才展開顯示

# 1. 真實 CPU 溫度
temp_c=""
for tz in /sys/class/thermal/thermal_zone*; do
    [[ -r "${tz}/type" && -r "${tz}/temp" ]] || continue
    if [[ "$(cat "${tz}/type")" == "x86_pkg_temp" ]]; then
        temp_c="$(( $(cat "${tz}/temp") / 1000 ))"
        break
    fi
done
if [[ -z "$temp_c" ]]; then
    for hw in /sys/class/hwmon/hwmon*; do
        [[ -r "${hw}/name" && -r "${hw}/temp1_input" ]] || continue
        name="$(cat "${hw}/name")"
        if [[ "$name" == "coretemp" || "$name" == "k10temp" || "$name" == "zenpower" ]]; then
            temp_c="$(( $(cat "${hw}/temp1_input") / 1000 ))"
            break
        fi
    done
fi
if [[ -z "$temp_c" && -r /sys/class/thermal/thermal_zone0/temp ]]; then
    temp_c="$(( $(cat /sys/class/thermal/thermal_zone0/temp) / 1000 ))"
fi

# 2. Intel GPU 即時頻率 (MHz)
gpu_mhz=""
for g in /sys/class/drm/card*/gt_cur_freq_mhz; do
    if [[ -r "$g" ]]; then
        gpu_mhz="$(cat "$g" 2>/dev/null || true)"
        break
    fi
done

# 3. Apple SMC 風扇轉速
fan_rpm=""
for f in /sys/devices/platform/applesmc.768/fan1_input /sys/devices/platform/applesmc.768/hwmon/hwmon*/fan1_input; do
    if [[ -r "$f" ]]; then
        fan_rpm="$(cat "$f" 2>/dev/null || true)"
        break
    fi
done

if [[ "${BLOCK_BUTTON:-}" == "1" ]]; then
    gpu_max="$(cat /sys/class/drm/card*/gt_max_freq_mhz 2>/dev/null | head -n 1 || echo N/A)"
    notify-send " 散熱與 GPU 遙測" \
"CPU Pkg : ${temp_c:-N/A} °C
IntelGPU: ${gpu_mhz:-N/A} / ${gpu_max} MHz
Fan RPM : ${fan_rpm:-N/A} RPM"
fi

val_c="$C_FG"
icon_c="$C_ICON"
if [[ -n "$temp_c" ]] && (( temp_c >= 90 )); then
    val_c="$C_CRIT"; icon_c="$C_CRIT"
elif [[ -n "$temp_c" ]] && (( temp_c >= 75 )); then
    val_c="$C_WARN"; icon_c="$C_WARN"
fi

out="$(fmt_block "" "${temp_c:-?}°C" "$val_c" "$icon_c")"
short="$out"

if [[ -n "$gpu_mhz" ]] && (( gpu_mhz >= GPU_SHOW_MHZ )); then
    out+=" $(fmt_block "󰢮" "${gpu_mhz}M" "$C_INFO" "$C_ICON")"
fi

if [[ -n "$fan_rpm" ]] && (( fan_rpm >= FAN_SHOW_RPM )); then
    fan_k="$(awk -v r="$fan_rpm" 'BEGIN { printf "%.1fk", r / 1000 }')"
    fan_c="$C_WARN"
    (( fan_rpm >= 4000 )) && fan_c="$C_HIGH"
    out+=" $(fmt_block "󰈐" "$fan_k" "$fan_c" "$fan_c")"
fi

emit_block "$out" "$short"
