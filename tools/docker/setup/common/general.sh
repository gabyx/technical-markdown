#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091
# =========================================================================================
# TechnicalMarkdown
#
# General functionality
#
# @date 15.6.2021
# @author Gabriel Nützi, gnuetzi@gmail.com
# =========================================================================================

tempDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$tempDIR/log.sh"
unset tempDIR

# Joins an array '$1' with a delimiter '$2'.
function joinArray {
    local -n arr="$1"
    local d="${2-}"
    local f="${arr[0]}"
    local l=("${arr[@]:1}")
    printf "%s" "$f" "${l[@]/#/$d}"
}

function runWithSudo() {
    if command -v sudo &>/dev/null; then
        sudo "$@" || return 1
    else
        "$@" || return 1
    fi

    return 0
}

# Checks a file "$1" to have the expected checksum "$2"
function assertChecksum() {
    local file="$1"
    local expected="$2"
    local sum

    sum=$(runWithSudo md5sum "$file" | cut -d " " -f 1) ||
        die "Could not get checksum '$file'."
    [ "$sum" = "$expected" ] ||
        die "Checksum of '$file' is '$sum' but not expected '$expected'."

    return 0
}

function haveHomebrew() {
    command -v brew &>/dev/null || return 1
    return 0
}

function installCertificate() {
    local os="$1"
    local cert="$2"

    if [ "$os" = "ubuntu" ]; then
        true
    elif [ "$os" = "alpine" ]; then
        runWithSudo apk add ca-certificates || die "Could not install 'ca-certificates'."
    else
        die "Operating system not supported:" "$os"
    fi

    runWithSudo cp "$cert" "/usr/local/share/ca-certificates/" || die "Could not copy certificate '$2'."
    runWithSudo update-ca-certificates || die "Failed to update certificates."

    return 0
}
