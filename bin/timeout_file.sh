#!/usr/bin/env bash

# File Lock Script
# Purpose: Wait a specified time and then delete a file
# Usage: ./file_lock.sh <file_path> [time]
#   time format: 1h|1H (hours), 5m|5M (minutes), 600s|600S (seconds), 300 (seconds if no unit)

# set -x
set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly LOCK_DIR="/tmp"
readonly LOCK_FILE="${LOCK_DIR}/${SCRIPT_NAME}.lock"
readonly logfile="/tmp/${SCRIPT_NAME}.log"

usage(){
  cat <<'EOF'
Usage: file_lock.sh <file_path> [time]

Arguments:
  file_path         Path to an existing file to delete after waiting
  time              Optional time to wait (default: 0 seconds)
                    Formats: 1h|1H (hours), 5m|5M (minutes), 600s|600S (seconds)
                    If no unit provided, assumes seconds

Examples:
  file_lock.sh /tmp/myfile 5m      # Wait 5 minutes then delete
  file_lock.sh /tmp/myfile 2h      # Wait 2 hours then delete
  file_lock.sh /tmp/myfile 300     # Wait 300 seconds then delete
  file_lock.sh /tmp/myfile         # Delete immediately

Options:
  -h, --help        Show this help message
EOF
}

cleanup(){
  rm -f "$LOCK_FILE"
}

trap cleanup EXIT

check_already_running(){
  if [ -f "$LOCK_FILE" ]; then
    local pid
    pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
    
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      printf "Script %s is already running (PID: %s)\n" "$SCRIPT_NAME" "$pid"
      exit 0
    fi
  fi
  
  # Create lock file with current PID
  echo $$ > "$LOCK_FILE"
}

parse_time(){
  local time_str="$1"
  local number
  local unit
  local time_in_seconds
  
  # Extract number and unit using parameter expansion
  if [[ "$time_str" =~ ^([0-9]+)([hHmMsS]?)$ ]]; then
    number="${BASH_REMATCH[1]}"
    unit="${BASH_REMATCH[2]}"
  else
    printf "Error: Invalid time format '%s'\n" "$time_str" >&2
    printf "Valid formats: 1h, 5m, 600s, or plain number (seconds)\n" >&2
    exit 11
  fi
  
  # Convert to seconds based on unit
  case "$unit" in
    h|H)
      time_in_seconds=$((number * 3600))
      ;;
    m|M)
      time_in_seconds=$((number * 60))
      ;;
    s|S|"")
      time_in_seconds=$number
      ;;
    *)
      printf "Error: Unknown time unit '%s'\n" "$unit" >&2
      exit 22
      ;;
  esac
  
  echo "$time_in_seconds"
}

main(){
  local file_path
  local time_to_wait=0

  if [ -f "$logfile" ]; then
    rm -f "$logfile"
  fi
  exec >> "$logfile" 2>&1
  
  # Handle help flag
  if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit 0
  fi
  
  # Check if already running
  check_already_running
  
  # Parse arguments
  file_path="$1"
  
  if [ $# -ge 2 ]; then
    time_to_wait=$(parse_time "$2")
  fi
  
  # Verify file exists
  if [ ! -f "$file_path" ]; then
    printf "Error: File '%s' does not exist\n" "$file_path" >&2
    exit 33
  fi
  
  # Display what we're going to do
  printf "File: %s\n" "$file_path"
  printf "Wait time: %d seconds\n" "$time_to_wait"
  
  # Wait if time specified
  if [ "$time_to_wait" -gt 0 ]; then
    printf "Waiting %d seconds before deleting...\n" "$time_to_wait"
    sleep "$time_to_wait"
  fi
  
  # Delete the file
  if [ -f "$file_path" ]; then
    rm -f "$file_path"
    printf "Deleted: %s\n" "$file_path"
  else
    printf "File no longer exists: %s\n" "$file_path"
  fi
}

main "$@" 






