set positional-arguments
set shell := ["bash", "-cue"]
root_dir := `git rev-parse --show-toplevel`
flake_dir := root_dir / "tools/nix"
output_dir := root_dir / ".output"
build_dir := output_dir / "build"

mod nix "./tools/just/nix.just"
mod changelog "./tools/just/changelog.just"

# Default target if you do not specify a target.
default:
    just --list --unsorted

# Enter the default Nix development shell and execute the command `"$@`.
develop *args:
    just nix::develop "default" "$@"

# Format the project.
format *args:
    "{{root_dir}}/tools/scripts/setup-config-files.sh"
    nix run --accept-flake-config {{flake_dir}}#treefmt -- "$@"

# Setup the project.
setup *args:
    cd "{{root_dir}}" && ./tools/scripts/setup.sh


# Run commands over the ci development shell.
ci *args:
    just nix::develop "ci" "$@"

[group('general')]
clean:
   rm -rf .output

# Lint the project.
[group('general')]
lint *args:
    echo "TODO: Not implemented"

# Build the module.
[group('general')]
build *args:
    echo "TODO: Not implemented"

# Test the project.
[group('general')]
test *args:
    echo "TODO: Not implemented"

# Run the markdown render services.
[group('general')]
serve *args:
    #!/usr/bin/env bash
    nix run --show-trace -L "{{flake_dir}}#serve" -- -U "$@"
