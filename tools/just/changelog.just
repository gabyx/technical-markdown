set positional-arguments
set shell := ["bash", "-cue"]

default:
    just --list --unsorted -f "{{source_file()}}"

# Generate the changelog in the range `<lastTag>..HEAD`
# Only the first-parent reachable commits are taken.
# See: https://github.com/git-chglog/git-chglog/issues/284
[group('aux')]
gen start="HEAD" end="" config="./tools/configs/git-cliff/config.toml" changelog="CHANGELOG.md":
    just nix::develop changelog \
        generate-changelog "{{start}}" "{{end}}" "{{config}}" "{{changelog}}"
