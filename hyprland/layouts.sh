# shellcheck shell=bash

choice=$(printf '%s\n' 'Two columns' 'Scrolling' 'Dwindle' 'Monocle' | noctalia dmenu -p 'Workspace layout') || exit 0
case "$choice" in
'Scrolling') layout=scrolling ;;
'Two columns') layout=two-column ;;
'Dwindle') layout=dwindle ;;
'Monocle') layout=monocle ;;
*) exit 0 ;;
esac
hyprctl eval "set_workspace_layout(\"$layout\")"
