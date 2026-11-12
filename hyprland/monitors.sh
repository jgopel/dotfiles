# shellcheck shell=bash

# In clamshell mode, leaving the laptop panel enabled strands workspaces on an
# invisible screen. Disable it only while an external display can take over;
# undocking must not leave the session without a usable output. Reconcile
# current lid and output state rather than interpreting event order: dock
# outputs can settle after a lid or hotplug event. Home Manager's session hooks
# own retries; this helper owns the panel policy and leaves external monitor
# configuration alone.

lid_states=(/proc/acpi/button/lid/*/state)
[[ -r ${lid_states[0]} ]] || exit 0

closed=false
if grep -q closed "${lid_states[@]}"; then
    closed=true
fi

# The display called FALLBACK is Hyprland's virtual output when no real screen
# is enabled. It must not prevent restoring the laptop panel after undocking
# with the lid closed.
monitors=$(hyprctl -j monitors all | jq '[.[] | select(.name != "FALLBACK")]')
updates=$(jq -r --argjson closed "$closed" '
    def internal: .name | test("^(eDP|LVDS|DSI)-");
    ($closed and any(.[];
        (internal | not) and .disabled == false and .width > 0 and .height > 0
    )) as $disable |
    .[] | select(internal) | select(.disabled != $disable) |
    "hl.monitor({ output = \(.name | tojson), disabled = \($disable) })"
' <<<"$monitors")
while IFS= read -r update; do
    [[ -n $update ]] || continue
    reply=$(hyprctl eval "$update")
    if [[ $reply != ok ]]; then
        printf '%s\n' "$reply" >&2
        exit 1
    fi
done <<<"$updates"
