#!/usr/bin/env bash
# shellcheck disable=SC1091
#
# Format all files.

set -e
set -u
set -o pipefail

. "tools/ci/general.sh"

if ! command -v "nix" &>/dev/null; then
    print_warn "! Tool 'nix' is not on your path." >&2
    exit 0
fi

FILES=()
readarray -t FILES < <(echo -n "$STAGED_FILES")

# shellcheck disable=SC2128
if [ "${#FILES[@]}" = "0" ]; then
    ci::print_info "No files to format."
    exit 0
fi

ci::print_info "Running 'treefmt'..."
nix run "./tools/nix#treefmt" -- "${FILES[@]}"
