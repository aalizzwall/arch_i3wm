#!/usr/bin/env bash
# PSI (Pressure Stall Information) + Load Average 卡頓雷達 (Nord + Nerd Font)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/theme.sh
source "${SCRIPT_DIR}/lib/theme.sh"

read -r load1 load5 load15 _ < /proc/loadavg

get_psi() {
    local file="$1"
    [[ -r "$file" ]] || { echo "0.00"; return; }
    awk '/^some/ { for (i=1; i<=NF; i++) if ($i ~ /^avg10=/) { sub(/^avg10=/, "", $i); print $i; exit } }' "$file"
}

psi_cpu="$(get_psi /proc/pressure/cpu)"
psi_io="$(get_psi /proc/pressure/io)"
psi_mem="$(get_psi /proc/pressure/memory)"

if [[ "${BLOCK_BUTTON:-}" == "1" ]]; then
    top_procs="$(ps -eo pcpu,comm --sort=-pcpu --no-headers | head -n 5 | awk '{printf "  %5s%%  %s\n", $1, $2}')"
    notify-send "󰓅 系統負載與 PSI 卡頓偵測" \
"Load : ${load1} / ${load5} / ${load15}
PSI (10s stall):
  CPU: ${psi_cpu}%  |  IO: ${psi_io}%  |  MEM: ${psi_mem}%
Top CPU:
${top_procs}"
fi

read -r level tag < <(
    awk -v l="$load1" -v c="$psi_cpu" -v io="$psi_io" -v m="$psi_mem" '
    BEGIN {
        level = "ok"; tag = "";
        if (io + 0 >= 10 || m + 0 >= 10 || c + 0 >= 25) {
            level = "crit";
            if (m + 0 >= io + 0 && m + 0 >= 10) tag = sprintf("MEM:%.0f%%", m);
            else if (io + 0 >= 10)              tag = sprintf("IO:%.0f%%", io);
            else                                tag = sprintf("CPU:%.0f%%", c);
        } else if (io + 0 >= 3 || m + 0 >= 3 || c + 0 >= 10 || l + 0 >= 2.5) {
            level = "high";
            if (io + 0 >= 3)      tag = sprintf("IO:%.0f%%", io);
            else if (m + 0 >= 3)  tag = sprintf("MEM:%.0f%%", m);
        } else if (l + 0 >= 1.2) {
            level = "warn";
        }
        print level, tag;
    }'
)

case "$level" in
    crit) icon_c="$C_CRIT"; val_c="$C_CRIT" ;;
    high) icon_c="$C_HIGH"; val_c="$C_HIGH" ;;
    warn) icon_c="$C_WARN"; val_c="$C_WARN" ;;
    *)    icon_c="$C_ICON"; val_c="$C_FG" ;;
esac

full_txt="${load1}${tag:+ $tag}"
emit_block "$(fmt_block "󰓅" "$full_txt" "$val_c" "$icon_c")" "$(fmt_block "󰓅" "$load1" "$val_c" "$icon_c")"
