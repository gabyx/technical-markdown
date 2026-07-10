#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2015,SC1091
# =============================================================================
# TechnicalMarkdown
#
# @date Sun Mar 06 2022
# @author Gabriel Nützi, gnuetzi@gmail.com
# =============================================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/common/log.sh"
. "$DIR/common/general.sh"
. "$DIR/common/platform.sh"
. "$DIR/common/packages.sh"

set -e
set -u
set -o pipefail

function installShellformat() {
    printInfo "Install shellformat ..."

    if [ "$os" != "ubuntu" ] &&
        [ "$os" != "alpine" ]; then
        die "Shellformat for '$os' not implemented."
    fi

    local url
    url=$(curl --silent "https://api.github.com/repos/mvdan/sh/releases/latest" |
        grep "browser_download_url" |
        grep "linux" |
        grep "$arch" |
        head -n 1 |
        sed -E -e 's@.*:\s*"(.*)".*@\1@')

    sudo curl -fsSL "$url" -o /usr/local/bin/shfmt &&
        sudo chmod +x /usr/local/bin/shfmt || return 1

    version=$(
        set +o pipefail # stupid head terminates early...
        shfmt --version | head -1 | sed -E "s|.* ([0-9]+\.[0-9]+\.[0-9]+).*|\1|"
    ) && printInfo "Version 'shfmt': '$version'" ||
        die "Could not check version 'shfmt'."

    return 0
}

function installShellcheck() {
    printInfo "Install shellcheck ..."

    if [ "$os" != "ubuntu" ] &&
        [ "$os" != "alpine" ]; then
        die "Shellcheck for '$os' not implemented."
    fi

    [ "$arch" = "amd64" ] && local arch="x86_64"
    [ "$arch" = "arm64" ] && local arch="aarch64"

    local url
    url=$(curl --silent "https://api.github.com/repos/koalaman/shellcheck/releases/latest" |
        grep "browser_download_url" |
        grep "linux" |
        grep "$arch" |
        grep "tar.xz" |
        head -n 1 |
        sed -E -e 's@.*:\s*"(.*)".*@\1@')

    local T
    T=$(mktemp)
    curl -fsSL "$url" -o "$T" &&
        sudo tar -xf "$T" --strip-components=1 -C /usr/local/bin/ &&
        sudo chmod +x /usr/local/bin/shellcheck &&
        rm -rf "$T" || return 1

    version=$(
        set +o pipefail # stupid head terminates early...
        shellcheck --version | grep "version" | head -1 | sed -E "s|.* ([0-9]+\.[0-9]+\.[0-9]+).*|\1|"
    ) &&
        printInfo "Version 'shellcheck': '$version'" ||
        die "Could not check version 'shellcheck'."

    return 0
}

function installEncodingTools() {
    installPackages "$os" file \
        --ubuntu php-iconv recode \
        --alpine php7-iconv recode \
        --brew iconv recode
}

function installBinaryTools() {
    installPackages "$os" file \
        --ubuntu bsdmainutils \
        --alpine hexdump \
        --brew util-linux file
}

function installManTools() {
    installPackages "$os" \
        --ubuntu man-db \
        --alpine man-db

    if [ "$os" = "alpine" ]; then
        sudo apk add man-db || return 1
        # Install all docs (stupid) :-)
        sudo apk list -I | sed -rn '/-doc/! s/([a-z-]+[a-z]).*/\1/p' |
            xargs -tI {} sudo apk add {}-doc || true
    fi
}

os="$1"
# osRelease="$2"
arch=$(getPlatformArch)

installShellcheck || die "Could not setup 'shellcheck'."
installShellformat || die "Could not setup 'shellformat'."
# installEncodingTools || die "Could not setup encoding tools."
# installBinaryTools || die "Could not setup binary tools."
# installManTools || die "Could not setup 'man' tools."
