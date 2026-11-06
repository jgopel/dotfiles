# shellcheck shell=bash

choice=$(printf '%s\n' 'Two columns' 'Scrolling' 'Dwindle' 'Monocle' | noctalia dmenu -p 'Workspace layout') || exit 0
case "$choice" in
    'Two columns') layout=two-column ;;
    'Scrolling') layout=scrolling ;;
    'Dwindle') layout=dwindle ;;
    'Monocle') layout=monocle ;;
    *) exit 0 ;;
esac
hyprctl eval "set_workspace_layout(\"$layout\")"
