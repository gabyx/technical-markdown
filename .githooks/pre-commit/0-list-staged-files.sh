#!/usr/bin/env bash
# List all staged files.
#
set -e
set -u
set -o pipefail

. "tools/ci/general.sh"

if [ -n "${STAGED_FILES:-}" ]; then
    ci::print_info "Staged files:" >&2

    for file in $STAGED_FILES; do
        echo "  - $file" >&2
    done
elif [ -n "${STAGED_FILES_FILE:-}" ]; then
    ci::print_info "Staged files:" >&2

    while read -rd $'\\0' file; do
        echo "  - $file" >&2
    done <"$STAGED_FILES_FILE"
fi
