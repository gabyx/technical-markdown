#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091
# shellcheck disable=SC2154,SC2086

function ci::_print() {
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
function ci::print_info() {
    ci::_print "[0;94m" "" "" "$@"
}

function ci::print_warning() {
    ci::_print "[0;31m" "" "WARN: " "$@" >&2
}

function ci::print_error() {
    ci::_print "[0;31m" "" "ERROR: " "$@" >&2
}

function ci::die() {
    ci::print_error "$@"
    exit 1
}

function ci::is_running() {
    [ "${CI:-}" = "true" ] || return
}

function ci::setup_githooks() {
    local root_dir
    root_dir=$(git rev-parse --show-toplevel)

    if git -C "$root_dir" hooks --version &>/dev/null; then
        if [ "$(git -C "$root_dir" config --local githooks.registered)" != "true" ]; then
            git -C "$root_dir" hooks install
        else
            ci::print_info "Githooks already installed."
        fi
    fi
}
