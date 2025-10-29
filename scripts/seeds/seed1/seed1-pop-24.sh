#!/usr/bin/env bash
# when: ! command -v potato && false



SCRIPT_SOURCE="${BASH_SOURCE[0]}"
SCRIPT_NAME="$(basename "$SCRIPT_PATH")"
echo "$SCRIPT_NAME ran"