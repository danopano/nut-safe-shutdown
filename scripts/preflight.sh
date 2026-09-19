#!/usr/bin/env bash
# Read-only NUT shutdown preflight collector.
#
# This script does not send commands, set variables, arm FSD, stop services,
# alter configuration, remove utility, or invoke killpower. Review output before
# sharing: this output is privacy-reduced, not fully sanitized. It avoids
# credentials, serial numbers, and UPS names where practical, but intentionally
# retains useful paths, models, permissions, usernames embedded in paths, and
# custom hook names. Review it before public sharing.

set -u

section() { printf '\n## %s\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }
run_version() {
    local label=$1
    shift
    printf '%s: ' "$label"
    "$@" 2>&1 | head -n 1 || printf 'unavailable\n'
}

section "Operating system"
if [[ -r /etc/os-release ]]; then
    awk -F= '/^(NAME|VERSION|VERSION_ID)=/ {print}' /etc/os-release
fi
uname -srmo 2>/dev/null || true
have systemd && run_version systemd systemd --version

section "NUT versions"
for tool in upsmon upsd upsdrvctl upsc upscmd usbhid-ups; do
    if have "$tool"; then
        run_version "$tool" "$tool" -V
    else
        printf '%s: not found\n' "$tool"
    fi
done

section "Configured drivers (privacy-reduced)"
ups_conf=${UPS_CONF:-/etc/nut/ups.conf}
if [[ -r "$ups_conf" ]]; then
    awk '
        /^[[:space:]]*\[/ {n++; printf "[ups-%d]\n", n; next}
        /^[[:space:]]*driver[[:space:]]*=/ {
            line=$0
            sub(/^[[:space:]]*/, "", line)
            print line
        }
    ' "$ups_conf"
else
    printf 'ups.conf not readable at expected path\n'
fi

section "Local UPS telemetry (serial numbers and names excluded where practical)"
if have upsc; then
    mapfile -t ups_names < <(upsc -l localhost 2>/dev/null || true)
    printf 'local UPS count: %d\n' "${#ups_names[@]}"
    index=0
    for ups_name in "${ups_names[@]}"; do
        index=$((index + 1))
        printf '[ups-%d]\n' "$index"
        upsc "${ups_name}@localhost" 2>/dev/null | awk -F': ' '
            $1 ~ /^(device\.mfr|device\.model|device\.type|driver\.name|driver\.version|ups\.status|ups\.delay\.shutdown|ups\.delay\.start|battery\.charge|battery\.runtime|input\.voltage|output\.voltage|ups\.load|ups\.power|ups\.realpower)$/ {print}
        '
        if have upscmd; then
            printf 'advertised instant commands:\n'
            upscmd -l "${ups_name}@localhost" 2>/dev/null |
                sed -E 's/^[[:space:]]+/  /' || true
        fi
    done
else
    printf 'upsc not found\n'
fi

section "FSD state"
if have upsmon; then
    upsmon -K >/dev/null 2>&1
    fsd_rc=$?
    case "$fsd_rc" in
        0) printf 'upsmon -K: exit 0 (power-down flag is set/valid)\n' ;;
        1) printf 'upsmon -K: exit 1 (power-down flag not set/valid)\n' ;;
        *) printf 'upsmon -K: exit %d (indeterminate; inspect locally)\n' "$fsd_rc" ;;
    esac
else
    printf 'upsmon not found\n'
fi

section "systemd shutdown-hook inventory"
hook_dirs=(
    /usr/lib/systemd/system-shutdown
    /lib/systemd/system-shutdown
    /etc/systemd/system-shutdown
)
seen='|'
for hook_dir in "${hook_dirs[@]}"; do
    [[ -e "$hook_dir" ]] || continue
    resolved=$(readlink -f -- "$hook_dir" 2>/dev/null || printf '%s' "$hook_dir")
    case "$seen" in
        *"|$resolved|"*) continue ;;
    esac
    seen="${seen}${resolved}|"
    printf 'directory: %s -> %s\n' "$hook_dir" "$resolved"
    while IFS= read -r -d '' entry; do
        if [[ -x "$entry" ]]; then
            stat -c '  executable: %A %U:%G %n' -- "$entry" 2>/dev/null || true
            if [[ -L "$entry" ]]; then
                printf '    target: %s\n' "$(readlink -- "$entry" 2>/dev/null || true)"
            fi
        fi
    done < <(find -L "$hook_dir" -maxdepth 1 -mindepth 1 -print0 2>/dev/null)
done

section "Service status (read-only)"
if have systemctl; then
    systemctl --no-pager --plain --no-legend list-units \
        'nut-driver@*.service' nut-server.service nut-monitor.service 2>&1 || true
else
    printf 'systemctl not found\n'
fi

section "Safety statement"
printf '%s\n' 'No instant command, variable write, FSD arm, service change, utility removal, or killpower action was requested by this script.'
