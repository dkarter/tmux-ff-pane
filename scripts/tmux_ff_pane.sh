#!/usr/bin/env bash

if ! command -v fzf-tmux &> /dev/null; then
    return
fi

tmux_panes() {
    local window_name_width
    window_name_width=$(tmux list-panes -s -F '#W' | gwc -L)

    local command_width
    command_width=$(tmux list-panes -s -F '#{pane_current_command}' | gwc -L)

    local panes
    panes=$(tmux list-panes -s -F '#{window_index} #W #{pane_index} #{pane_current_command} #{pane_current_path}')

    local blue="\033[0;34m"
    local green="\033[0;32m"
    local reset="\033[0;39m"

    awk -v s="%s:%-${window_name_width}s ${green}%s:%-${command_width}s${reset} ${blue}%s${reset}\n" '{ printf s,$1,$2,$3,$4,$5 }' <<<"$panes"
}

fzf_tmux_select_pane() {
    local selected
    selected=$(cat | fzf-tmux --ansi --no-sort -p)

    [[ -z "$selected" ]] && return

    local win_id pane_id

    read -r win_id pane_id <<<"$(sed 's/ \+/ /g' <<<"$selected" | awk -F '[: ]' '{ print $1,$3 }')"

    tmux select-window -t "$win_id"; tmux select-pane -t "$pane_id"
}

tmux_panes | fzf_tmux_select_pane
