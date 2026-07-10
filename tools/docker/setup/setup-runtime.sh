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

set -u
set -e
set -o pipefail

function setup() {
    local cacheFile="$TECHMD_SETUP_DIR/.setup-runtime-done"

    if [ -f "$cacheFile" ]; then
        printInfo "Setup runtime already done." \
            "Existing file '$cacheFile'."
        return 0
    fi

    # Set docker socket permissions
    if [ -S /var/run/docker.sock ]; then
        printInfo "Setting user group on docker socket '/var/run/docker.sock'."
        local user
        user=$(whoami) || die "Could not get user name."
        sudo chown "$user:$user" /var/run/docker.sock ||
            die "Could not set permissions."
    fi

    # Install python modules...
    if [ -f "/container-setup/python.add-requirements" ]; then
        local defaultPython

        defaultPython="$(cd && pwd)/python-envs/default/bin/python"
        local pythonExe="${PYTHON_ENV:-$defaultPython}"

        printInfo "Installing additional python modules."
        "$pythonExe" -m pip install -r "/container-setup/python.add-requirements" ||
            die "Could not install python modules."
    fi

    # Create history file in mounted directory.
    if [ -d ~/.shell ]; then
        # Link the initial history file to it, if it isn't already.
        if [ ! -f ~/.zsh_history ] || [ ! -L ~/.zsh_history ]; then
            printInfo "Linking zsh history to '~/.shell/.zsh_history'."
            rm ~/.zsh_history &>/dev/null || true
            touch ~/.shell/.zsh_history &&
                ln -s ~/.shell/.zsh_history ~/.zsh_history || {
                printError "Could not create link '~/.shell/.zsh_history'. "
            }
        fi
    fi

    # Synchronize git identity from host config
    gitConfigHost="$TECHMD_SETUP_DIR/.gitconfig-host"
    if [ -f "$gitConfigHost" ]; then
        printInfo "Synchronizing Git user/email from '.gitconfig-host'."
        hostName=$(git config -f "$gitConfigHost" user.name)
        hostEmail=$(git config -f "$gitConfigHost" user.email)

        git config --global user.name "$hostName"
        git config --global user.email "$hostEmail"
    fi

    # Timezone setup.
    if [ -n "${TIME_ZONE:-}" ]; then
        "$TECHMD_SETUP_DIR/setup-time-zone.sh" \
            "--non-interactive" \
            --time-zone "$TIME_ZONE" || die "Could not setup timezone."
    fi

    echo "setup-runtime.sh successful" >"$cacheFile"
    printInfo "Container setup successful."

    return 0
}

setup 2>&1 | tee "$TECHMD_SETUP_DIR/.setup-runtime.log"

exec "$@"
