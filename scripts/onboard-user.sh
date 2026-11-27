#!/bin/bash
# onboard-user.sh: CloudByte Solutions onboarding automation
# Author: Noam Batat Van Dien
# Created: 2026-11-25
# Purpose: Create a new user, set a temporary password, add them to a
#          team group, and force a password change on first login.
# Usage: sudo bash onboard-user.sh
# Usage: sudo bash onboard-user.sh --csv path/to/new-hires.csv
# Usage: sudo bash onboard-user.sh --dry-run
# Usage: sudo bash onboard-user.sh [--csv PATH] [--dry-run] --log

set -eo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "Error: this script must be run as root."
    echo "Try: sudo bash $0 $*"
    exit 1
fi

TEMP_PASSWORD="ChangeMe123!"
DRY_RUN=false
AUDIT_LOG_ENABLED=false
CSV_FILE=""

while [ $# -gt 0 ]; do
    case "$1" in
        --csv)
            CSV_FILE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --log)
            AUDIT_LOG_ENABLED=true
            shift
            ;;
        -h|--help)
            grep '^# Usage:' "$0" | sed 's/^# //'
            exit 0
            ;;
        *)
            echo "Error: unknown argument '$1'." >&2
            exit 1
            ;;
    esac
done
create_user() {
    local username="$1"
    local group="$2"
    local fullname="$3"
    if [ "$DRY_RUN" = true ]; then
        echo "[dry-run] would create $username in $group with temp password"
        return 0
    fi

if ! getent group "$group" >/dev/null 2>&1; then
    echo "Error: group '$group' does not exist."
    return 1
fi

if getent passwd "$username" >/dev/null 2>&1; then
    echo "Skip: user '$username' already exists."
    return 0
fi
    useradd -m -c "$fullname" "$username" || return 1
    echo "$username:$TEMP_PASSWORD" | chpasswd || return 1
    usermod -aG "$group" "$username" || return 1
    chage -d 0 "$username" || return 1

    if [ "$AUDIT_LOG_ENABLED" = true ]; then
        local timestamp
        timestamp=$(date "+%Y-%m-%d %H:%M:%S") || return 1
        printf '%s  created  %s  %s\n' "$timestamp" "$username" "$group" >> /var/log/cloudbyte-onboarding.log || return 1
    fi

echo "Created $username in group $group with temp password (must change on first login)."
}

if [ -n "$CSV_FILE" ]; then
    if [ ! -f "$CSV_FILE" ]; then
        echo "Error: CSV file '$CSV_FILE' not found."
        exit 3
    fi

    failures=0
    {
        read -r _header

        while IFS=, read -r u g f || [ -n "$u" ]; do
            [ -z "$u" ] && continue
            if ! create_user "$u" "$g" "$f"; then
                failures=$((failures + 1))
            fi
        done
    } < "$CSV_FILE"

    if [ "$failures" -gt 0 ]; then
        exit 4
    fi
    exit 0
else
    read -rp "Username: " username
    read -rp "Group: " group
    read -rp "Full name: " fullname
    create_user "$username" "$group" "$fullname"
fi
