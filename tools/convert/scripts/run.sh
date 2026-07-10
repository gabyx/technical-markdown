#!/usr/bin/env bash

format="$1"
[ -z "$format" ] && format="json"

rootDir=$(git rev-parse --show-toplevel)

filters="$rootDir/tools/convert/filters"
export LUA_PATH="$filters/?;$filters/?.lua;$LUA_PATH"
export PYTHONPATH="$filters"

pandoc "--fail-if-warnings" \
    "--verbose" \
    "--toc" \
    "--data-dir=convert" \
    "--defaults=pandoc-dirs.yaml" \
    "--defaults=pandoc-general.yaml" \
    "--defaults=pandoc-html.yaml" \
    "--defaults=pandoc-filters.yaml" \
    -t "$format" \
    -o test.json \
    content.md

if [ "$format" = "json" ]; then
    prettier --write test.json &>/dev/null
fi
