# The generated wrapper supplies the command and 1Password settings as Fish locals.
function __onepassword_launch --no-scope-shadowing
    set -l skip_reason
    set -l warnings
    set -lu ONEPASSWORD_WARNING
    for name in $names
        set -fu $name # Never pass a stale key from the parent environment.
    end

    if test -z "$account"
        set skip_reason '1Password account is not configured'
    else if not set -q names[1]
        set -a warnings 'Secrets: no secret references configured for this command.'
    end

    set -l biometric "$OP_BIOMETRIC_UNLOCK_ENABLED"
    if test -z "$biometric"
        set biometric false
        if test -z "$SSH_CONNECTION$SSH_TTY"; and test -n "$WAYLAND_DISPLAY$DISPLAY" -o (uname -s) = Darwin
            set biometric true
        end
    end

    set -l read_timeout 10s
    if test "$biometric" = true
        # op read requests desktop approval itself; don't use a manual session or prompt on dismissal.
        __onepassword_hide_sessions
        set read_timeout 60s
    else if test -z "$skip_reason"; and string match -qr . -- $references
        OP_BIOMETRIC_UNLOCK_ENABLED=$biometric __onepassword_signin $op "$account" $sign_in_attempts skip_reason
    end

    for i in (seq (count $names))
        set -l name $names[$i]
        set -l failure "$skip_reason"
        if test -z "$failure"; and test -z "$references[$i]"
            set failure 'secret reference is not configured'
        end
        if test -z "$failure"
            OP_BIOMETRIC_UNLOCK_ENABLED=$biometric $op $read_timeout read --account "$account" --no-newline "$references[$i]" | read -zl -d '' value
            set -l rc $pipestatus[1]
            if test $rc -eq 0; and test -n "$value"
                set -fx $name "$value"
                continue
            else if test $rc -eq 130
                set failure '1Password request cancelled'
                set skip_reason "$failure"
            else
                set failure 'secret retrieval failed or timed out'
            end
        end
        set -a warnings "Secrets: $name was not injected — $failure."
    end

    # The editor gets the requested secrets, not the credential used to retrieve them.
    __onepassword_hide_sessions
    if set -q warnings[1]
        set -x ONEPASSWORD_WARNING (string join \n -- $warnings | string collect)
    end
    $program $argv
    set -l program_status $status
    if set -q warnings[1]
        printf '%s\n' $warnings >&2
    end
    return $program_status
end

# On success, keep op's session in this shell. On failure, write the reason to the caller's variable.
function __onepassword_signin --no-scope-shadowing --argument-names op account attempts failure
    # Manual signin can prompt again even when this shell already has a usable session.
    $op 10s whoami --account "$account" </dev/null >/dev/null 2>&1
    switch $status
        case 0
            return 0
        case 124 130 137
            set $failure '1Password session check timed out or was interrupted'
            return 1
    end

    # Don't let signin start interactive account setup on a fresh machine.
    $op 10s account list --format=json </dev/null 2>/dev/null | read -zl accounts
    if test $pipestatus[1] -ne 0
        set $failure '1Password account discovery failed or was interrupted'
        return 1
    else if string match -qr '^\s*\[\s*\]\s*$' -- "$accounts"
        set $failure 'no 1Password accounts are configured on this system'
        return 1
    end

    for attempt in (seq $attempts)
        if test $attempt -gt 1
            printf 'Secrets: sign-in failed. Trying again (%d of %d). Ctrl-C to continue without secrets.\n' $attempt $attempts >&2
        end

        # A foreground pipeline lets Ctrl-C cancel the prompt without aborting the launcher.
        $op 60s signin --account "$account" | read -zl session_export
        set -l rc $pipestatus[1]
        switch $rc
            case 0
                # Let op choose its account-specific OP_SESSION_* name, as in eval "$(op signin)".
                eval "$session_export"
                return 0
            case 130
                set $failure '1Password sign-in cancelled'
            case 124 137
                set $failure '1Password sign-in timed out'
            case '*'
                # op uses 1 for generic sign-in failures and 7 for a rejected password (HTTP 401).
                if contains -- $rc 1 7; and test $attempt -lt $attempts
                    continue
                end
                set $failure "1Password sign-in failed (attempt $attempt, exit $rc)"
        end
        return 1
    end
end

function __onepassword_hide_sessions --no-scope-shadowing
    # Shadow the exports in the wrapper's scope; the user's Fish shell keeps them.
    for name in OP_SESSION (set --names --export | string match 'OP_SESSION_*')
        test "$name" = OP_SESSION_DELEGATION_ENABLED; and continue # CLI setting, not a token.
        set -fu $name
    end
end
