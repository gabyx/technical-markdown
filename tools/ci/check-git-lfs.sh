#!/usr/bin/env bash

set -u

ROOT_DIR=$(git rev-parse --show-toplevel)
. "$ROOT_DIR/tools/ci/general.sh"

ci::print_info "Checking Git LFS files..."

cd "$ROOT_DIR" || ci::die "Could not change directory."

git log -1 &>/dev/null || {
    # We do not have any commits yet.
    exit 0
}

if ! git lfs --version &>/dev/null; then
    ci::die "You need to install Git LFS." \
        "See 'https://pages.datascience.ch/sdsc-best-practices/documentation/docs/chapters/dev-enablement/hardware-setup/general#git--git-lfs-setup'."
fi

if [ "$(git config "filter.lfs.process")" = "" ] ||
    [ "$(git config "filter.lfs.smudge")" = "" ] ||
    [ "$(git config "filter.lfs.clean")" = "" ]; then
    ci::die "Git LFS seems installed but the filters are not configured correctly.\n$(git lfs env)" \
        "See 'https://pages.datascience.ch/sdsc-best-practices/documentation/docs/chapters/dev-enablement/hardware-setup/general#git--git-lfs-setup'."
fi

out=$(
    git lfs fsck 2>&1
)

#shellcheck disable=SC2181
if [ "$?" -ne 0 ]; then
    ci::die \
        "You committed files which should be in Git LFS but are not:" \
        "-- 'git lfs fsck' output:\n" \
        "$out" \
        "" \
        "Ensure the following to make this test pass:" \
        "" \
        "1. You need to install Git LFS on your system." \
        "   See 'https://pages.datascience.ch/sdsc-best-practices/documentation/docs/chapters/dev-enablement/hardware-setup/general#git--git-lfs-setup'." \
        "" \
        "2. You NEED to rewrite the history on your branch." \
        "   Do that by rebasing your branch on to the target branch with:" \
        "" \
        "   'git rebase -i \$(git merge-base HEAD origin/main)' and " \
        "   'git push --force-with-lease'" \
        "" \
        "   to upload all files to Git LFS and check again."
else
    ci::print_info "No Git LFS errors. All files in Git LFS!"
fi
