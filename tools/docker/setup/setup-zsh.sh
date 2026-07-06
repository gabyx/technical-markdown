#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091
# =============================================================================
# TechnicalMarkdown
#
# @date Sun Mar 06 2022
# @author Gabriel Nützi, gnuetzi@gmail.com
# =============================================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/common/log.sh"

set -e
set -u
set -o pipefail

os="$1"

printInfo "Installing Zsh shell ..."

if [ "$os" = "ubuntu" ]; then
    sudo apt-get install -y zsh perl libncurses5-dev libncursesw5-dev jq
elif [ "$os" = "alpine" ]; then
    sudo apk add zsh perl jq util-linux
    # util-linux is removed after.
else
    die "Operating system '$os' not supported."
fi

# Config for general all shells
cat <<EOF >~/.zshenv
# Initial file
EOF

# Config for interactive shells
cp "$TECHMD_SETUP_DIR/shell/.zshrc" ~/.zshrc
chmod +x ~/.zshrc

# Copy p10k config.
cp "$TECHMD_SETUP_DIR/shell/.p10k.zsh" ~/.p10k.zsh
chmod +x ~/.p10k.zsh

# Start ZSH once to install all plugins.
# `</dev/null` because: https://github.com/zplug/zplug/issues/272#issuecomment-348393440
echo exit | script -qec zsh /dev/null ||
    die "Could not source '.zshrc'."
if [ "$os" = "alpine" ]; then
    sudo apk del util-linux
fi

# Place splash entry file
if [ "$os" = "ubuntu" ]; then
    sudo apt-get install -y figlet
elif [ "$os" = "alpine" ]; then
    sudo apk add figlet
else
    die "Operating system '$os' not supported."
fi
cp "$TECHMD_SETUP_DIR/shell/.shell-entry-splash.sh" ~/.shell-entry-splash.sh
chmod +x ~/.shell-entry-splash.sh
