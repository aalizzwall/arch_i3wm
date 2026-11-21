#!/usr/bin/env bash
# 精簡記憶體監控 (MemAvailable；常駐只顯示已用 GB，左鍵看詳細與 Top 5 RAM)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/theme.sh
source "${SCRIPT_DIR}/lib/theme.sh"

read -r total_kb avail_kb shmem_kb dirty_kb swap_t_kb swap_f_kb < <(
    awk '
        /^MemTotal:/     { t = $2 }
        /^MemAvailable:/ { a = $2 }
        /^Shmem:/        { sh = $2 }
        /^Dirty:/        { d = $2 }
        /^SwapTotal:/    { st = $2 }
        /^SwapFree:/     { sf = $2 }
        END { printf "%d %d %d %d %d %d\n", t+0, a+0, sh+0, d+0, st+0, sf+0 }
    ' /proc/meminfo
)

used_kb=$(( total_kb - avail_kb ))
(( used_kb < 0 )) && used_kb=0
pct=0
(( total_kb > 0 )) && pct=$(( used_kb * 100 / total_kb ))

if [[ "${BLOCK_BUTTON:-}" == "1" ]]; then
    top_mem="$(ps -eo rss,comm --sort=-rss --no-headers | head -n 5 | awk '{printf "  %6.0fM  %s\n", $1/1024, $2}')"
    summary="$(awk -v u="$used_kb" -v a="$avail_kb" -v t="$total_kb" -v sh="$shmem_kb" -v d="$dirty_kb" -v su="$((swap_t_kb - swap_f_kb))" 'BEGIN {
        printf "Used / Total : %.2fG / %.2fG (%d%%)\nAvailable    : %.2fG\nShmem/tmpfs  : %.0fM  |  Dirty: %.1fM\nSwap Used    : %.0fM",
            u/1048576, t/1048576, (t>0 ? u*100/t : 0), a/1048576, sh/1024, d/1024, su/1024
    }')"
    notify-send "󰍛 記憶體詳細遙測" "${summary}
Top RAM (RSS):
${top_mem}"
fi

val_c="$C_FG"
icon_c="$C_ICON"
if (( pct >= 92 )); then
    val_c="$C_CRIT"; icon_c="$C_CRIT"
elif (( pct >= 85 )); then
    val_c="$C_HIGH"; icon_c="$C_HIGH"
elif (( pct >= 75 )); then
    val_c="$C_WARN"; icon_c="$C_WARN"
fi

used_g="$(awk -v u="$used_kb" 'BEGIN { printf "%.1fG", u/1048576 }')"
emit_block "$(fmt_block "󰍛" "$used_g" "$val_c" "$icon_c")" "$(fmt_block "󰍛" "${pct}%" "$val_c" "$icon_c")"
