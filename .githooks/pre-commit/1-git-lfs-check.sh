#!/usr/bin/env bash
# shellcheck disable=SC1091
#
# Format all files.

set -e
set -u
set -o pipefail

./tools/ci/check-git-lfs.sh
