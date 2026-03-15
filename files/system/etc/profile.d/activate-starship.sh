#!/usr/bin/env bash
# --- Helper utilities
_command_exists() {
    command -v "$1" >/dev/null 2>&1
}

_eval_if_available() {
    local binary="$1"
    shift
    if _command_exists "$binary"; then
        eval "$("$binary" "$@")"
    fi
}
# --- Activate Starship if available
_eval_if_available starship init bash
