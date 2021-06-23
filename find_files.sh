#!/bin/bash
set -uo pipefail  # No -e to support write to canary file after cancel

PREVIEW_COMMAND=${FIND_FILES_PREVIEW_COMMAND:-'cat'}
PREVIEW_WINDOW=${FIND_FILES_PREVIEW_WINDOW_CONFIG:-'50%'}
CANARY_FILE=${CANARY_FILE:-'/tmp/canaryFile'}
PATHS=("$@")

FZF_VER=$(fzf --version)
FZF_VER_MAJ=$(echo "$FZF_VER" | cut -d. -f1)
FZF_VER_MIN=$(echo "$FZF_VER" | cut -d. -f2)
if [[ $FZF_VER_MAJ -eq 0 && $FZF_VER_MIN -lt 27 ]]; then
    PREVIEW_WINDOW='right:50%'
fi

callfzf () {
    rg \
        --files \
        --hidden \
        --glob '!**/.git/' \
        "${PATHS[@]}" \
    | fzf \
        --multi \
        --preview "$PREVIEW_COMMAND" \
        --preview-window "$PREVIEW_WINDOW" \
    | tee /tmp/lastOutput
}

VAL=$(callfzf)
if [[ -z "$VAL" ]]; then
    echo canceled
    echo "1" > "$CANARY_FILE"
    exit 1
else
    echo "$VAL" > "$CANARY_FILE"
fi
