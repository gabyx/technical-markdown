#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091
# =============================================================================
# TechnicalMarkdown
#
# @date Sun Mar 06 2022
# @author Gabriel Nützi, gnuetzi@gmail.com
# =============================================================================

# shellcheck disable=SC2154,SC2086
function _print() {
    local color="$1"
    local flags="$2"
    local header="$3"
    shift 3

    local hasColor="0"
    if [ "${FORCE_COLOR:-}" != 1 ]; then
        [ -t 1 ] && hasColor="1"
    else
        hasColor="1"
    fi

    if [ "$hasColor" = "0" ] || [ "${LOG_COLORS:-}" = "false" ]; then
        local msg
        msg=$(printf '%b\n' "$@")
        msg="${msg//$'\n'/$'\n'   }"
        echo $flags -e "-- $header$msg"
    else
        local s=$'\033' e='[0m'
        local msg
        msg=$(printf "%b\n" "$@")
        msg="${msg//$'\n'/$'\n'   }"
        echo $flags -e "${s}${color}-- $header$msg${s}${e}"
    fi
}
function printInfo() {
    _print "[0;94m" "" "" "$@"
}

function printWarning() {
    _print "[0;31m" "" "WARN: " "$@" >&2
}

function printPrompt() {
    _print "[0;32m" "-n" "" "$@" >&2
}

function printError() {
    _print "[0;31m" "" "ERROR: " "$@" >&2
}

function die() {
    printError "$@"
    exit 1
}
