# shellcheck shell=bash

# Nix substitutes only non-secret configuration and executable paths.
set -u
account=''
names=()
references=()
skip_arguments=()
@configuration@
op='@op@'
timeout='@timeout@'

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
        # Keep prompts on the terminal, but never print or persist the session token.
        # --foreground lets op read the terminal while timeout bounds stalled requests.
    elif ! session=$("$timeout" --foreground --kill-after=2s 60s "$op" signin --account "$account" --raw); then
        reason='1Password sign-in failed, was cancelled, or timed out'
    fi
}

inject_secrets() {
    local index name reference failure value
    # sign_in populates this local; the session never enters the editor's environment.
    local session=''

    # Ctrl-C should cancel authentication/retrieval, not prevent the editor opening.
    # A caught (rather than ignored) signal still reaches the foreground op process.
    trap ':' INT
    sign_in

    for index in "${!names[@]}"; do
        name=${names[$index]}
        reference=${references[$index]}
        failure=$reason
        if [[ -z $failure && -z $reference ]]; then
            failure='secret reference is not configured'
        fi
        if [[ -z $failure ]]; then
            if value=$(
                if [[ -n $session ]]; then
                    export OP_SESSION="$session"
                fi
                "$timeout" --foreground --kill-after=2s 10s "$op" read --account "$account" "$reference" 2>/dev/null
                ) && [[ -n $value ]]; then
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
