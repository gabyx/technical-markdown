#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091
# =============================================================================
# TechnicalMarkdown
#
# @date Sun Mar 06 2022
# @author Gabriel Nützi, gnuetzi@gmail.com
# =============================================================================

tempDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$tempDIR/log.sh"
. "$tempDIR/general.sh"
unset tempDIR

function parseInstallPackages() {
    local -n _deps="$1"
    local type="$2"
    shift 2

    haveHomebrew && type="brew"

    local add=false
    for p in "$@"; do

        if [ "$p" = "--$type" ]; then
            add=true
            continue
        elif echo "$p" | grep -q "^--"; then
            add=false
            continue
        fi

        [ "$add" = "true" ] && echo "Adding: $p" && deps+=("$p")

    done

    [ "${#deps[@]}" = "0" ] &&
        die "No packages given to install for '$type'."

    return 0
}

function getTempPackages() {
    local -n temp="$1"
    local os="$2"
    shift 2

    local deps=()
    parseInstallPackages deps "$os" "$@"

    if haveHomebrew; then
        list=$(
            brew list --cask
            brew list --formulae
        )
    elif [ "$os" = "ubuntu" ] ||
        [ "$os" = "debian" ]; then
        list=$(dpkg --get-selections | grep -v deinstall)
    elif [ "$os" = "alpine" ]; then
        list=$(apk info)
    elif [ "$os" = "redhat" ]; then
        list=$(yum list installed | cut -d' ' -f1)
    else
        die "OS '$os' not supported"
    fi

    for p in "${deps[@]}"; do
        if ! echo "$list" | grep -q "$p"; then
            temp+=("$p")
        fi
    done
}

# Simply install packages over the os package manager.
# shellcheck disable=SC2145
function installPackages() {
    local os="$1"
    shift
    local deps=()
    parseInstallPackages deps "$os" "$@"

    printInfo "Installing packages:" "$(printf " - '%s' \n" "${deps[@]}")"

    if haveHomebrew; then
        [ "${#deps[@]}" = "0" ] && return 0
        runWithSudo brew install "${deps[@]}" ||
            die "Could not install brew packages: ${deps[@]}"
    elif [ "$os" = "ubuntu" ] ||
        [ "$os" = "debian" ]; then
        [ "${#deps[@]}" = "0" ] && return 0
        runWithSudo apt-get install -y "${deps[@]}" ||
            die "Could not install packages: ${deps[@]}"
    elif [ "$os" = "alpine" ]; then
        [ "${#deps[@]}" = "0" ] && return 0
        runWithSudo apk add "${deps[@]}" ||
            die "Could not install packages: ${deps[@]}"
    elif [ "$os" = "redhat" ]; then
        [ "${#deps[@]}" = "0" ] && return 0
        runWithSudo yum install -y --disableplugin=subscription-manager "${deps[@]}" ||
            die "Could not install packages: ${deps[@]}"
    else
        die "OS '$os' not supported"
    fi

    return 0
}

# Simply uninstall packages over the os package manager.
# shellcheck disable=SC2145
function uninstallPackages() {
    local os="$1"
    shift

    local deps=()
    parseInstallPackages deps "$os" "$@"

    printInfo "Uninstalling packages:" "$(printf " - '%s' \n" "${deps[@]}")"

    if haveHomebrew; then
        [ "${#deps[@]}" = "0" ] && return 0

        runWithSudo brew uninstall "${deps[@]}" ||
            die "Could not uninstall brew packages: ${deps[@]}"
    elif [ "$os" = "ubuntu" ] ||
        [ "$os" = "debian" ]; then
        [ "${#deps[@]}" = "0" ] && return 0
        runWithSudo apt-get remove -y "${deps[@]}" ||
            die "Could not remove packages: ${deps[@]}"
    elif [ "$os" = "alpine" ]; then
        [ "${#deps[@]}" = "0" ] && return 0
        runWithSudo apk del "${deps[@]}" ||
            die "Could not remove packages: ${deps[@]}"
    elif [ "$os" = "redhat" ]; then
        [ "${#deps[@]}" = "0" ] && return 0
        runWithSudo yum remove -y --disableplugin=subscription-manager "${deps[@]}" ||
            die "Could not install packages: ${deps[@]}"
    else
        die "OS '$os' not supported"
    fi

    return 0
}
