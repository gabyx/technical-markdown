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

set -e
set -u
set -o pipefail

nonInteractive="false"
timeZone=""

# Parse all arguments.
function parseArgs() {

    local prev=""

    for p in "$@"; do
        if [ "$p" = "--non-interactive" ]; then
            true
        elif [ "$prev" = "--non-interactive" ]; then
            nonInteractive="true"
        elif [ "$p" = "--time-zone" ]; then
            true
        elif [ "$prev" = "--time-zone" ]; then
            timeZone="$p"
        else
            echo "Wrong argument '$p' !"
            return 1
        fi
        prev="$p"
    done

    return 0
}

parseArgs "$@"

getPlatformOS
os="$PLATFORM_OS"
osDist="$PLATFORM_OS_DIST"

printInfo "Configuring time zone '$timeZone' ..."

if [ "$os" = "linux" ] &&
    [ "$osDist" = "ubuntu" ]; then

    [ "$nonInteractive" = "true" ] &&
        [ -z "$timeZone" ] &&
        die "Argument '--time-zone' not set."

    echo "Configure time zone to $timeZone"
    if [ "$(cat '/etc/timezone')" != "$timeZone" ]; then
        if [ -n "$timeZone" ]; then
            ln -snf "/usr/share/zoneinfo/$timeZone" /etc/localtime && echo "$timeZone" >/etc/timezone
            dpkg-reconfigure -f noninteractive tzdata
        else
            dpkg-reconfigure tzdata
        fi
    fi

elif [ "$os" = "linux" ] &&
    [ "$osDist" = "alpine" ]; then

    if [ -z "$timeZone" ]; then
        mess=$(
            echo -e "Enter the time zone. Visit" \
                "\n'https://manpages.ubuntu.com/manpages/impish/man3/DateTime::TimeZone::Catalog.3pm.html'" \
                "\nfor a list. : "
        )
        read -srp "$mess"
        echo
    fi

    echo "Configure time zone to $timeZone"
    if [ "$(cat '/etc/timezone')" != "$timeZone" ]; then
        ln -snf "/usr/share/zoneinfo/$timeZone" /etc/localtime && echo "$timeZone" >/etc/timezone
    fi

else
    die "Operating system not supported:" "$os"
fi
