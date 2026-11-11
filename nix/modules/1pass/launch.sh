# shellcheck shell=bash

# Nix substitutes only non-secret configuration and executable paths.
set -u
account=''
cache_key=''
names=()
references=()
skip_arguments=()
@configuration@
op='@op@'
timeout='@timeout@'
coreutils='@coreutils@/bin'
flock='@flock@'

prepare_environment() {
    local name argument skip

    # NixOS's setgid wrapper is needed for desktop app integration.
    if [[ -x /run/wrappers/bin/op ]]; then
        op=/run/wrappers/bin/op
    fi

    unset ONEPASSWORD_WARNING
    for name in "${names[@]}"; do
        # Do not silently use stale keys inherited from the old session exports.
        unset "$name"
    done

    if [[ ! -t 0 || ! -t 2 ]]; then
        interactive=false
    fi
    for argument in "$@"; do
        [[ $argument == -- ]] && break
        for skip in "${skip_arguments[@]}"; do
            if [[ $argument == "$skip" ]]; then
                interactive=false
            fi
        done
    done

    if [[ $interactive == false ]]; then
        reason='skipped for a noninteractive invocation'
    elif [[ -z $account ]]; then
        reason='1Password account is not configured'
    elif [[ ! -x $op ]]; then
        reason='1Password CLI is unavailable'
    fi
}

cached_sign_in() (
    # Keep the session and lock out of the editor, and never cache API keys.
    umask 077
    runtime_dir=${XDG_RUNTIME_DIR:-/run/user/$UID}
    if [[ ! -d $runtime_dir || ! -O $runtime_dir || -L $runtime_dir ]] ||
    [[ $("$coreutils/stat" -c %a "$runtime_dir") != 700 ]]; then
        printf '%s\n' 'Secrets: no private runtime directory; this sign-in will not be cached.' >&2
        "$timeout" --foreground --kill-after=2s 60s "$op" signin --account "$account" --raw
        return
    fi

    cache_dir=$runtime_dir/onepassword
    "$coreutils/mkdir" -p -m 700 "$cache_dir" || return 1
    [[ -O $cache_dir && ! -L $cache_dir && $("$coreutils/stat" -c %a "$cache_dir") == 700 ]] || return 1
    cache_file=$cache_dir/$cache_key

    # Serialize sign-ins so simultaneous launches reuse the first one's session.
    exec {lock_fd}>"$cache_file.lock" || return 1
    "$flock" -w 75 "$lock_fd" || return 1
    cached_session=${OP_SESSION-}
    if [[ -f $cache_file ]]; then
        [[ -O $cache_file && ! -L $cache_file && $("$coreutils/stat" -c %a "$cache_file") == 600 ]] || return 1
        cached_session=$(<"$cache_file")
    fi

    session_arguments=()
    if [[ -n $cached_session ]]; then
        session_arguments=(--session "$cached_session")
    fi

    # op validates the token and prompts only when needed; its normal expiry applies.
    if ! token=$("$timeout" --foreground --kill-after=2s 60s "$op" signin --account "$account" "${session_arguments[@]}" --raw); then
        "$coreutils/rm" -f "$cache_file"
        return 1
    fi
    if [[ -n $token ]]; then
        temporary=$("$coreutils/mktemp" "$cache_file.XXXXXX") || return 1
        trap '"$coreutils/rm" -f "$temporary"' EXIT
        printf '%s' "$token" >"$temporary" || return 1
        "$coreutils/mv" -f "$temporary" "$cache_file" || return 1
    else
        # Desktop integration authenticates without returning a session token.
        "$coreutils/rm" -f "$cache_file"
    fi
    printf '%s' "$token"
)

sign_in() {
    local reference accounts configured=false

    for reference in "${references[@]}"; do
        if [[ -n $reference ]]; then
            configured=true
        fi
    done
    if [[ -n $reason || $configured == false ]]; then
        return
    fi

    # signin offers account setup on a fresh machine. Never start that from an editor.
    if ! accounts=$("$timeout" --foreground --kill-after=2s 10s "$op" account list --format=json </dev/null 2>/dev/null); then
        reason='1Password account discovery failed or timed out'
    elif [[ ${accounts//[[:space:]]/} == '[]' ]]; then
        reason='no 1Password accounts are configured on this system'
    elif ! session=$(cached_sign_in); then
        reason='1Password sign-in failed, was cancelled, or timed out'
    fi
}

inject_secrets() {
    local index name reference failure value
    # sign_in populates this local; the session never enters the editor's environment.
    local session=''
    local -a session_arguments=()

    # Ctrl-C should cancel authentication/retrieval, not prevent the editor opening.
    # A caught (rather than ignored) signal still reaches the foreground op process.
    trap ':' INT
    sign_in
    if [[ -n $session ]]; then
        session_arguments=(--session "$session")
    fi

    for index in "${!names[@]}"; do
        name=${names[$index]}
        reference=${references[$index]}
        failure=$reason
        if [[ -z $failure && -z $reference ]]; then
            failure='secret reference is not configured'
        fi
        if [[ -z $failure ]]; then
            if value=$("$timeout" --foreground --kill-after=2s 10s "$op" read --account "$account" "${session_arguments[@]}" "$reference" 2>/dev/null) && [[ -n $value ]]; then
                export "$name=$value"
            else
                failure='secret retrieval failed or timed out'
            fi
            unset value
        fi
        if [[ -n $failure ]]; then
            warnings+=("Secrets: $name was not injected — $failure.")
        fi
    done
    trap - INT

    if [[ ${#names[@]} == 0 ]]; then
        warnings+=('Secrets: injection skipped — no secret references configured for this command.')
    fi
}

launch_editor() {
    local editor_pid status=0

    if [[ ${#warnings[@]} == 0 ]]; then
        exec "$program" "$@"
    fi

    printf -v ONEPASSWORD_WARNING '%s\n' "${warnings[@]}"
    export ONEPASSWORD_WARNING
    if [[ $interactive == false ]]; then
        printf '%s' "$ONEPASSWORD_WARNING" >&2
        exec "$program" "$@"
    fi

    # Keep the editor in the terminal's foreground process group, with stdin intact.
    # A waiting parent lets us warn after the editor restores the terminal, without
    # ever interpreting an editor failure as a reason to launch it a second time.
    "$program" "$@" <&0 &
    editor_pid=$!
    trap 'kill -INT "$editor_pid" 2>/dev/null || true' INT
    trap 'kill -TERM "$editor_pid" 2>/dev/null || true' TERM
    trap 'kill -HUP "$editor_pid" 2>/dev/null || true' HUP
    wait "$editor_pid" || status=$?
    # A signal can interrupt wait before the editor has finished cleaning up.
    if kill -0 "$editor_pid" 2>/dev/null; then
        status=0
        wait "$editor_pid" || status=$?
    fi
    printf '%s' "$ONEPASSWORD_WARNING" >&2
    exit "$status"
}

program=$1
shift
interactive=true
reason=''
warnings=()

prepare_environment "$@"
inject_secrets
launch_editor "$@"
