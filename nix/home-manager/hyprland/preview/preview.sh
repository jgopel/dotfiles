# shellcheck shell=bash

state="${HYPRLAND_PREVIEW_STATE:-$HOME/.local/state/noctalia-preview}"

case "${1:-start}" in
    start)
        if [[ -z ${WAYLAND_DISPLAY:-} || ${HYPRLAND_PREVIEW:-} == 1 ]]; then
            echo 'Run hyprland-preview from your normal Wayland session.' >&2
            exit 1
        fi
        if [[ ! -r $HOME/.config/background ]]; then
            echo "Wallpaper not readable: $HOME/.config/background" >&2
            exit 1
        fi
        export HYPRLAND_PREVIEW_STATE="$state"
        mkdir -p "$state/home/.config/"{hypr,noctalia}
        install -m 644 "$HOME/.config/background" "$state/home/.config/background"
        install -m 644 "$HYPRLAND_PREVIEW_CONFIG" "$state/home/.config/hypr/hyprland.lua"
        install -m 644 "$HYPRLAND_PREVIEW_SHELL_CONFIG" "$state/home/.config/noctalia/config.toml"
        touch "$state/home/.config/hypr/hyprland-settings.lua"
        # Both Noctalia and its settings plugin have writable, preview-only
        # paths. Do not expose the real compositor config to plugin setup.
        export HOME="$state/home"
        export XDG_CONFIG_HOME="$HOME/.config" XDG_STATE_HOME="$HOME/.local/state" XDG_DATA_HOME="$HOME/.local/share"
        export XDG_CACHE_HOME="$HOME/.cache"
        unset NOCTALIA_CONFIG_HOME NOCTALIA_STATE_HOME NOCTALIA_DATA_HOME
        # Never load the installed Home Manager config: it starts real session
        # services. The overlay sources only the shared compositor settings.
        # Exclude every real KMS device; leave render nodes available for nested GL.
        # AQ_BACKEND is not supported by Aquamarine. NO_SD_VARS prevents Hyprland
        # from exporting the nested display into the host user manager.
        export AQ_DRM_DEVICES=/dev/null HYPRLAND_PREVIEW=1
        export HYPRLAND_NO_SD_VARS=1 HYPRLAND_NO_SD_NOTIFY=1
        export HYPRLAND_NO_SD_TARGET=1
        # Hyprland 0.56's executor ignores NO_SD_VARS when hasSession() is true,
        # even after DRM selection fails. Prevent libseat creating that session.
        export LIBSEAT_BACKEND=seatd SEATD_SOCK=/dev/null
        export QT_QPA_PLATFORM=wayland GDK_BACKEND=wayland
        export XDG_CURRENT_DESKTOP=Hyprland XDG_SESSION_DESKTOP=Hyprland DESKTOP_SESSION=Hyprland
        unset HYPRLAND_INSTANCE_SIGNATURE DISPLAY SESSION_MANAGER
        # flock owns the lock; children must not inherit it. The separate process
        # group lets session cleanup reap the shell and its helper children.
        exec flock --nonblock --conflict-exit-code 75 --close "$state/preview.lock" \
            setsid --fork --wait "$0" session
        ;;
    session)
        [[ ${HYPRLAND_PREVIEW:-} == 1 ]] || exit 1
        trap 'exit 130' INT
        trap 'exit 143' TERM
        # Ignore ancestors so cleanup does not signal this supervising shell.
        # Hyprland's forked helper can ignore TERM after the compositor exits.
        trap 'pkill -TERM -g "$$" -A || true; sleep 0.1; pkill -KILL -g "$$" -A || true' EXIT
        dbus-run-session --config-file="$HYPRLAND_DBUS_CONFIG" -- Hyprland --config "$HOME/.config/hypr/hyprland.lua"
        ;;
    *)
        echo 'Usage: hyprland-preview [start]' >&2
        exit 2
        ;;
esac
