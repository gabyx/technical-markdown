#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034
# =============================================================================
# TechnicalMarkdown
#
# @date Sun Mar 06 2022
# @author Gabriel Nützi, gnuetzi@gmail.com
# =============================================================================

function getPlatformOS() {
    PLATFORM_OS=""
    PLATFORM_OS_DIST=""
    PLATFORM_OS_VERSION=""

    if [[ $OSTYPE == "linux-gnu"* ]]; then
        PLATFORM_OS="linux"
    elif [[ $OSTYPE == "linux-musl"* ]]; then
        # Alpine linux
        PLATFORM_OS="linux"
    elif [[ $OSTYPE == "darwin"* ]]; then
        PLATFORM_OS="darwin"
    elif [[ $OSTYPE == "freebsd"* ]]; then
        PLATFORM_OS="freebsd"
    else
        die "Platform: '$OSTYPE' not supported."
    fi

    if [ "$PLATFORM_OS" = "linux" ]; then

        if [ "$(lsb_release -si 2>/dev/null)" = "Ubuntu" ]; then
            PLATFORM_OS_DIST="ubuntu"
            PLATFORM_OS_VERSION=$(grep "VERSION_CODENAME=" "/etc/os-release" |
                sed -E "s|.*=[\"']?(.*)[\"']?|\1|")
        elif grep -qE 'ID="?debian' "/etc/os-release"; then
            PLATFORM_OS_DIST="debian"
            PLATFORM_OS_VERSION=$(grep "VERSION_CODENAME=" "/etc/os-release" |
                sed -E "s|.*=[\"']?(.*)[\"']?|\1|")
        elif grep -qE 'ID="?alpine' "/etc/os-release"; then
            PLATFORM_OS_DIST="alpine"
            PLATFORM_OS_VERSION=$(grep "VERSION_ID=" "/etc/os-release" |
                sed -E 's|.*="?([0-9]+\.[0-9]+).*|\1|')
        elif grep -qE 'ID="?rhel' "/etc/os-release"; then
            PLATFORM_OS_DIST="redhat"
            PLATFORM_OS_VERSION=$(grep "VERSION_ID=" "/etc/os-release" |
                sed -E 's|.*="?([0-9]+\.[0-9]+).*|\1|')
        else
            die "Linux Distro '/etc/os-release' not supported currently:" \
                "$(cat /etc/os-release 2>/dev/null)"
        fi

        # Remove whitespaces
        PLATFORM_OS_DIST="${PLATFORM_OS_DIST// /}"
        PLATFORM_OS_VERSION="${PLATFORM_OS_VERSION// /}"

    elif [ "$PLATFORM_OS" = "darwin" ]; then

        PLATFORM_OS_DIST=$(sw_vers | grep 'ProductName' | sed -E 's/.*:\s+(.*)/\1/')
        PLATFORM_OS_VERSION=$(sw_vers | grep "ProductVersion" | sed -E 's/.*([0-9]+\.[0-9]+\.[0-9]+)/\1/g')
        # Remove whitespaces
        PLATFORM_OS_DIST="${PLATFORM_OS_DIST// /}"
        PLATFORM_OS_VERSION="${PLATFORM_OS_VERSION// /}"

    else
        die "Platform '$PLATFORM_OS' not supported currently."
    fi

    return 0
}

function getPlatformArch() {
    if uname -m | grep -q "x86_64" &>/dev/null; then
        echo "amd64"
        return 0
    elif uname -m | grep -q "aarch64" &>/dev/null; then
        echo "arm64"
        return 0
    elif uname -p | grep -q "arm64" &>/dev/null; then
        echo "arm64"
    else
        die "Architecture: '$(uname -m)' not supported."
    fi
}
