#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091
# =============================================================================
# TechnicalMarkdown
#
# @date Sun Mar 13 2022
# @author Gabriel Nützi, gnuetzi@gmail.com
# =============================================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/common/log.sh"

set -u
set -e
set -o pipefail

function setupGithooks() {
    # Update githooks if possible.
    local gitRoot
    gitRoot=$(git rev-parse --show-toplevel 2>/dev/null || true)
    if [ -n "$gitRoot" ]; then

        local cacheFile="$TECHMD_SETUP_DIR/.setup-runtime-githooks-done"
        if [ -f "$cacheFile" ]; then
            printInfo "Setup Githooks already done." \
                "Existing file '$cacheFile'."
            return 0
        fi

        # Update Githooks in main repo.
        printInfo "Updating all Githooks in '$gitRoot'."
        git -C "$gitRoot" hooks shared update ||
            printError "Could not update shared Githooks in '$gitRoot'."

        # Update all hooks in submodules.
        printInfo "Updating all Githooks in submodules."
        git -C "$gitRoot" submodule foreach --recursive 'git hooks shared update' ||
            printError "Could not update shared Githooks in submodules."

        echo "Githooks successfully setup." >"$cacheFile" || true
    fi

    return 0
}

setupGithooks 2>&1 | tee -a "$TECHMD_SETUP_DIR/.setup-runtime.log"
