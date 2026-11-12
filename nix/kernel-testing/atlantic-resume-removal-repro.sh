# shellcheck shell=bash
usage() {
    cat <<'EOF'
Usage: atlantic-resume-removal-repro [MODE] [--nm-unmanaged] [--wake-after SECONDS]

Modes:
  repro          (default) With the dock Ethernet up, suspend and remove the
                 NIC from resume_early. Expected: resume hangs, the DPM
                 watchdog warns after 60 s and panics after 120 s, and the
                 machine reboots 30 s later.
  control-down   The same with the interface down. Expected: resume finishes
                 and the NIC is gone until `echo 1 > /sys/bus/pci/rescan`.
  control-awake  No suspend: remove the NIC while it is up and running.
                 Expected: removal finishes normally.

Options:
  --nm-unmanaged       Tell NetworkManager to stop managing the interface and
                       bring it up (repro) or down (control-down) directly, so
                       NetworkManager cannot change its state around suspend.
  --wake-after SECONDS RTC alarm that ends the suspend (default 20).
EOF
}

die() {
    echo "error: $*" >&2
    exit 1
}

mode=repro
nm_unmanaged=0
wake_after=20
while (($#)); do
    case "$1" in
    repro | control-down | control-awake) mode="$1" ;;
    --nm-unmanaged) nm_unmanaged=1 ;;
    --wake-after)
        [[ "${2:-}" =~ ^[0-9]+$ ]] || die "--wake-after needs a number of seconds"
        wake_after="$2"
        shift
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        usage >&2
        exit 2
        ;;
    esac
    shift
done

((EUID == 0)) || die "run as root"

param=/sys/module/atlantic/parameters/repro_remove_on_resume
[[ -e "$param" ]] || die "$param is missing; boot the atlantic-resume-removal-repro specialisation, then attach the dock"

shopt -s nullglob
devices=(/sys/bus/pci/drivers/atlantic/0000:*)
((${#devices[@]} == 1)) || die "expected exactly one device bound to atlantic, found ${#devices[@]}"
dev="${devices[0]}"
pci="$(basename "$dev")"
ifaces=("$dev"/net/*)
((${#ifaces[@]} == 1)) || die "expected one network interface on $pci"
iface="$(basename "${ifaces[0]}")"

is_up() { (($(cat "/sys/class/net/$iface/flags") & 0x1)); }

echo "device:        $pci ($iface)"
echo "flags:         $(cat "/sys/class/net/$iface/flags") (IFF_UP=$(is_up && echo 1 || echo 0))"
echo "operstate:     $(cat "/sys/class/net/$iface/operstate")"
echo "runtime PM:    $(cat "$dev/power/runtime_status")"
echo "mem_sleep:     $(cat /sys/power/mem_sleep)"
echo "pm_async:      $(cat /sys/power/pm_async)"
grep -q '\[s2idle\]' /sys/power/mem_sleep || echo "warning: s2idle is not the selected sleep state" >&2
[[ "$(cat /sys/power/pm_async)" == 1 ]] || echo "warning: pm_async is off; wiphy resume will not be a second victim" >&2

if ((nm_unmanaged)); then
    nmcli device set "$iface" managed no
    if [[ "$mode" == control-down ]]; then
        ip link set "$iface" down
    else
        ip link set "$iface" up
    fi
fi

case "$mode" in
repro | control-awake) is_up || die "$iface must be up (try --nm-unmanaged)" ;;
control-down) ! is_up || die "$iface must be down: run 'ip link set $iface down' or use --nm-unmanaged" ;;
esac

marker="atlantic-resume-removal-repro: $mode run $$-$(date +%s) start on $pci ($iface)"
echo "$marker" >/dev/kmsg

if [[ "$mode" == control-awake ]]; then
    echo 1 >"$dev/remove"
    echo "Removal finished. Restore the NIC with: echo 1 > /sys/bus/pci/rescan"
    exit 0
fi

if [[ "$mode" == repro ]]; then
    cat <<'EOF'

This run is expected to hang resume and force a panic and reboot.
Save your work. After the reboot, collect evidence with:
  journalctl -b -1 -k | grep -E 'repro:|mutex-chain|DPM device timeout'
  ls /var/lib/systemd/pstore

Starting in 10 seconds; press Ctrl-C to abort.
EOF
    sleep 10
fi

suspend_count() { cat /sys/power/suspend_stats/success /sys/power/suspend_stats/fail; }
before="$(suspend_count)"
sync
# Never leave the hook armed: a later unrelated suspend would hang.
trap 'echo N >"$param" 2>/dev/null || true' EXIT
rtcwake -m no -s "$wake_after"
echo Y >"$param"
systemctl suspend

# systemctl may return before the system has suspended, so wait for a cycle.
for ((i = 0; i < wake_after + 120; i++)); do
    [[ "$(suspend_count)" != "$before" ]] && break
    sleep 1
done

echo
echo "Kernel messages from this run:"
dmesg | grep -F -A 100000 "$marker" | grep -E 'repro:|PM: suspend (entry|exit)' || true

if [[ "$(cat "$param")" == Y ]]; then
    die "the hook did not fire (no completed suspend/resume cycle); it has been disarmed"
fi

if [[ "$mode" == repro ]]; then
    die "UNEXPECTED: resume completed. Check the resume_early IFF_UP value and for a 'NAPI already disabled' line above"
fi

if [[ -e "/sys/bus/pci/devices/$pci" ]]; then
    echo "warning: $pci still exists after resume" >&2
else
    echo "$pci was removed and resume finished. Restore it with: echo 1 > /sys/bus/pci/rescan"
fi
if ((nm_unmanaged)); then
    echo "After rescanning, hand $iface back with: nmcli device set $iface managed yes"
fi
