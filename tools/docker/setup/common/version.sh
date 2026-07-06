#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2059
# =============================================================================
# TechnicalMarkdown
#
# @date Sun Mar 06 2022
# @author Gabriel Nützi, gnuetzi@gmail.com
# =============================================================================

# Compare $1 and $2 as version strings with operation $3.
function versionCompare() {
    cmd="
import sys
from semver import cmp
sys.exit(0 if cmp(\"$1\", \"$2\", \"$3\", loose=False) else 1)
"
    ~/python-envs/default/bin/python -c "$cmd" || return 1
    return 0
}

# Checks a version "$2" to be in ["$3", "$4").
function assertVersionMinMax() {
    local what="$1"
    local version="$2"
    local min="$3"
    local max="${4:-}"

    versionCompare "$version" ">=" "$min" ||
        die "Version '$what': '$version' expected to be >= '$min'."

    if [ -n "$max" ]; then
        versionCompare "$version" "<" "$max" ||
            die "Version '$what': '$version' expected to be < '$max'."
    fi
}

# Checks a version "$1" to be exactly "$2".
function assertVersionExact() {
    local what="$1"
    local version="$2"
    local expected="$3"

    if [ "$version" != "$expected" ]; then
        die "Version '$what': '$version' expected to be '$expected'."
    fi
}
