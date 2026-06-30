#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e
set -u

ROOT_DIR=$(git rev-parse --show-toplevel)
. "$ROOT_DIR/tools/ci/general.sh"

function main() {
    cd "$ROOT_DIR"

    # We link config files to the root directory.
    # To make IDE formatting setups work and also
    # such that we do not need to configure all formatters
    # in `treefmt-nix`.

    ci::print_info "Linking configs files to root '$ROOT_DIR'."

    rm -rf ".prettierrc.yaml" || true
    ln -s "tools/configs/prettier/prettierrc.yaml" ".prettierrc.yaml"

    rm -rf ".typos.toml" || true
    ln -s "tools/configs/typos/typos.toml" ".typos.toml"

    rm -rf ".yamllint.yaml" || true
    ln -s "tools/configs/yamllint/yamllint.yaml" ".yamllint.yaml"
}

main "$@"
