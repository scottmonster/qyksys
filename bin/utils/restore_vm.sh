#!/usr/bin/env bash

set -euo pipefail

# Purpose: Restore VM to last snapshot, preserving original running state
# Usage: restore_vm.sh

readonly target="Debian13-qyksys"

# Get last snapshot
last_snapshot="$(virsh snapshot-list "$target" --leaves | awk 'NR>2 {print $1}' | tail -n 2 | head -n 1)"

if [ -z "$last_snapshot" ]; then
    printf "Error: No snapshots found for %s\n" "$target" >&2
    exit 1
fi

# Save current state
current_state="$(virsh domstate "$target")"
was_running=false

if [ "$current_state" = "running" ]; then
    was_running=true
    printf "VM is running. Destroying before snapshot revert...\n"
    virsh destroy "$target"
fi

# Revert to snapshot
if [ "$was_running" = true ]; then
    printf "Restoring snapshot '%s' and starting VM...\n" "$last_snapshot"
    virsh snapshot-revert "$target" "$last_snapshot" --running
else
    printf "Restoring snapshot '%s' (VM will remain stopped)...\n" "$last_snapshot"
    virsh snapshot-revert "$target" "$last_snapshot"
fi

printf "Snapshot restore complete\n"