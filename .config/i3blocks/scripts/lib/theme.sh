#!/usr/bin/env bash
# Shared Nord theme palette and Pango formatting helpers for i3blocks

# Nord Palette
C_FG="#d8dee9"     # Snow Storm: normal values
C_ICON="#81a1c1"   # Frost: muted icon accent
C_MUTED="#616e88"  # Polar Night bright: dimmed / disabled
C_INFO="#88c0d0"   # Frost cyan: info / network
C_OK="#a3be8c"     # Aurora green: healthy / active
C_WARN="#ebcb8b"   # Aurora yellow: warning / elevated
C_HIGH="#d08770"   # Aurora orange: high load / thermal
C_CRIT="#bf616a"   # Aurora red: critical / failed

pango_escape() {
    local s="$1"
    s="${s//&/&amp;}"
    s="${s//</&lt;}"
    s="${s//>/&gt;}"
    printf '%s' "$s"
}

# fmt_block <icon> <text> [val_color] [icon_color]
fmt_block() {
    local icon="$1"
    local text="${2:-}"
    local val_color="${3:-$C_FG}"
    local icon_color="${4:-$C_ICON}"

    if [[ -n "$text" ]]; then
        printf "<span color='%s'>%s</span> <span color='%s'>%s</span>" \
            "$icon_color" "$icon" "$val_color" "$(pango_escape "$text")"
    else
        printf "<span color='%s'>%s</span>" "$icon_color" "$icon"
    fi
}

# emit_block <full_pango> [short_pango]
emit_block() {
    local full="$1"
    local short="${2:-$1}"
    printf '%s\n%s\n' "$full" "$short"
}
