#!/usr/bin/env bash

set -e
set -u

ROOT_DIR=$(git rev-parse --show-toplevel)
. "$ROOT_DIR/tools/ci/general.sh"

function main() {
    "$ROOT_DIR/tools/scripts/setup-config-files.sh"

    ci::setup_githooks
}

main "$@"
