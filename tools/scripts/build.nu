#!/usr/bin/env nu

# Build tasks for `src/techmd`, ported from `src/techmd/build.gradle.kts`.
#
# Standalone Nushell script: `nu tools/scripts/build.nu <subcommand>`.
# See `docs/superpowers/specs/2026-07-01-build-nu-port-design.md`.
#
# Tools are provided externally (Nix dev shell / your environment) and invoked
# by bare name from PATH: pandoc, python, lessc, browser-sync, latexmk.
# The Gradle `initBuild` (yarn install) and `defineEnvironment` tasks are
# intentionally dropped.

# ---------------------------------------------------------------------------
# Logging  --  simple colored log helpers, written to stderr.
# Namespaced as `log <level>` (Nu already has a builtin `debug` command).
# `log debug` only prints when TECHMD_DEBUG is truthy (1/true/yes/on).
# ---------------------------------------------------------------------------

def debug-enabled [] {
    ($env.TECHMD_DEBUG? | default "false" | str downcase) in ["1" "true" "yes" "on"]
}

def "log info" [msg: string] {
    print --stderr $"🌻 (ansi blue_bold)INFO (ansi reset) ($msg)"
}
def "log warn" [msg: string] {
    print --stderr $"🌻 (ansi yellow_bold)WARN (ansi reset) ($msg)"
}
def "log error" [msg: string] {
    print --stderr $"🌻 (ansi red_bold)ERROR(ansi reset) ($msg)"
}
def "log debug" [msg: string] {
    if (debug-enabled) {
        print --stderr $"🌻 (ansi magenta_bold)DEBUG(ansi reset) ($msg)"
    }
}

def print-cmd [cmd: list<string>] {
    print $"Cmd: ($cmd | str join ' ')"
}

const tooling_input = ["tools/**"]

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

# Resolve all project paths from the repo root.
#
# Reproduces the Gradle `TECHMD_CONVERT_DIR` / `TECHMD_TOOLS_DIR` env overrides
# (empty string falls back to the default, matching `getEnvDirOrDefault`).
def repo-paths [] {
    let root = (^git rev-parse --show-toplevel | str trim)

    let tools_default = $root | path join "tools"
    let convert_default = $root | path join "tools/convert"

    let tools_env = $env.TECHMD_TOOLS_DIR? | default ""
    let convert_env = $env.TECHMD_CONVERT_DIR? | default ""

    let tools_dir = (if $tools_env == "" { $tools_default } else { $tools_env })
    let convert_dir = (if $convert_env == "" { $convert_default } else { $convert_env })

    let build_dir = $env.TECHMD_OUTPUT_DIR? | default ($root | path join ".output/build/techmd")
    let build_dir_tex = $build_dir | path join "output-tex"
    let project_dir = $root | path join "src/techmd"
    let project_name = $env.TECHMD_PROJECT_NAME? | default "techmd"

    let filters = $convert_dir | path join "filters"
    let lua_path = $"($filters)/?;($filters)/?.lua;($env.LUA_PATH? | default '')"
    let pythonpath = $"($filters):($env.PYTHONPATH? | default '')"

    return {
        root: $root
        project_dir: $project_dir
        tools_dir: $tools_dir
        convert_dir: $convert_dir
        build_dir: $build_dir
        build_dir_tex: $build_dir_tex
        project_name: $project_name
        filters: $filters
        lua_path: $lua_path
        pythonpath: $pythonpath
    }
}

# ---------------------------------------------------------------------------
# Incremental (mtime) helpers  --  see spec §9.
# NOTE: The caching logic is implemented but its invocation is commented out in
# every task for now, so tasks always run.
# ---------------------------------------------------------------------------

def has-glob [p: string] {
    ($p | str contains "*") or ($p | str contains "?") or ($p | str contains "[")
}

# Expand a list of files / directories / globs into a flat list of existing
# file paths.
def files-of [patterns: list<string>] {
    $patterns | each {|p|
        let t = $p | path type
        if $t == "dir" {
            (glob ($p | path join "**/*") | where {|f| ($f | path type) == "file"})
        } else if $t == "file" {
            [$p]
        } else {
            (glob $p | where {|f| ($f | path type) == "file"})
        }
    } | flatten
}

def up-to-date [inputs: list<string>, outputs: list<string>, task: string] {
    mut inputs = [...$inputs ...$tooling_input]
    if (up-to-date-impl $inputs $outputs) {
        log info $"($task): up to date"
        return true
    } else {
        return false
    }
}

# True iff all concrete outputs exist and no input is newer than any output.
def up-to-date-impl [inputs: list<string>, outputs: list<string>] {
    for p in $outputs {
        if (not (has-glob $p)) and (not ($p | path exists)) {
            return false
        }
    }

    let outs = (files-of $outputs)
    if ($outs | is-empty) {
        log debug "Output empty."
        return false
    }

    let ins = (files-of $inputs)
    if ($ins | is-empty) {
        log debug "Inputs empty."
        return true
    }

    let in_max = $ins | each {|f| ls $f | get 0.modified } | math max
    let out_min = $outs | each {|f| ls $f | get 0.modified } | math min

    # log debug $"in_max:($in_max) <= ($out_min) empty."
    ($in_max <= $out_min)
}

# ---------------------------------------------------------------------------
# Pandoc
# ---------------------------------------------------------------------------

# Build the pandoc argument list, mirroring `makePandocArgs` from the Gradle
# `PandocTask` (argument order preserved).
def pandoc-args [
    export_type: string
    verbose: bool
    fail_if_warning: bool
    p: record
] {
    mut latex_args = []

    if $export_type in ["latex" "pdf"] {
        $latex_args = [
            "-M" $"latex-include-paths=($p.convert_dir)/includes/"
            "-M" $"latex-include-paths=($p.project_dir)/"
        ]
    }

    if $export_type == "pdf" {
        $latex_args = $latex_args | append [
            "--pdf-engine-opt=-r" $"--pdf-engine-opt=($p.tools_dir)/.latexmkrc"
            $"--pdf-engine-opt=-outdir=($p.build_dir_tex)"
        ]
    }

    [
        ...(if $fail_if_warning { ["--fail-if-warnings"] } else { [] })
        ...(if $verbose { ["--verbose"] } else { [] })
        $"--data-dir=($p.convert_dir)"
        $"--resource-path=($p.convert_dir)"
        "--defaults=pandoc-dirs.yaml"
        "--defaults=pandoc-general.yaml"
        $"--defaults=pandoc-($export_type).yaml"
        "--defaults=pandoc-filters.yaml" ...$latex_args
        $"--log=($p.build_dir)/pandoc-($export_type).log"
    ]
}

# Run pandoc for the given export type.
def run-pandoc [
    desc: string
    input_file: string
    output_file: string
    export_type: string
    verbose: bool
    fail_if_warning: bool
    additional_args: list<string>
] {
    let p = (repo-paths)

    mkdir $p.build_dir
    if $export_type in ["pdf" "latex"] {
        mkdir $p.build_dir_tex
    }

    let inputs = [
        $input_file
        ($p.project_dir | path join "chapters/**/*.md")
        ($p.project_dir | path join "chapters/**/*.html")
        ($p.project_dir | path join "chapters/**/*.tex")
        ($p.project_dir | path join "files/**/*")
        ($p.project_dir | path join "literature/**/*")
        ($p.convert_dir | path join "**/*")
    ]
    if (up-to-date $inputs [$output_file] "run-pandoc") {
        return
    }

    let base = (pandoc-args $export_type $verbose $fail_if_warning $p)
    let all_args = $base | append $additional_args | append ["-o" $output_file $input_file]

    # Env, corrected per spec §8.1 (Gradle used the non-standard `PYTHON_PATH`
    # and never set `LUA_PATH`; `tools/convert/scripts/run.sh` has the correct
    # form, mirrored here).
    log info $"Executing Pandoc: '($desc)'"
    log debug $"PYTHONPATH: '($p.pythonpath)'"
    log debug $"LUA_PATH: '($p.lua_path)'"

    let cmd = ["pandoc" ...$all_args]
    print-cmd $cmd

    cd $p.project_dir
    with-env {
        TECHMD_ROOT_DIR: $p.project_dir
        PYTHONPATH: $p.pythonpath
        LUA_PATH: $p.lua_path
    } {
        ^$cmd
    }

    log info " =============================================="
    log info $" =  Pandoc Build: '($desc)' successful!"
    log info " =============================================="
    let sz = ls $output_file | get 0.size
    log info $"Outfile: '($output_file)', size: ($sz)"
}

# ---------------------------------------------------------------------------
# Task workers  (each `def "main <x>"` delegates to `task-<x>`)
# ---------------------------------------------------------------------------

# compileLess: compile main.less -> convert/css/main.css
def task-compile-less [] {
    let p = (repo-paths)
    let src_dir = $p.convert_dir | path join "css/src"
    let main_less = $src_dir | path join "main.less"
    let css_file = $p.convert_dir | path join "css/main.css"

    let inputs = [$main_less] | append ($src_dir | path join "*.less")
    if (up-to-date $inputs [$css_file] "compile-less") {
        return
    }

    log info $"Executing less compilation: '($main_less)' -> '($css_file)'"
    cd $p.project_dir
    ^lessc $"--include-path=($src_dir)" $main_less $css_file
}

# copyLess (buildCSS): copy convert/css/main.css -> build/css
def task-copy-less [] {
    task-compile-less

    let p = repo-paths
    let css_file = $p.convert_dir | path join "css/main.css"
    let dst = $p.build_dir | path join "css/main.css"

    if (up-to-date [$css_file] [$dst] "copy-less") {
        return
    }

    log info $"Executing copy-less: '($css_file)' -> '($dst)'"

    cd $p.project_dir
    mkdir $dst
    cp $css_file $dst
}

# copyAssets: copy src/techmd/files -> build/files
def task-copy-assets [] {
    let p = (repo-paths)
    let src = $p.project_dir | path join "files"
    let dst = $p.build_dir | path join "files"

    if (up-to-date [$src] [$dst] "copy-assets") {
        return
    }

    log info $"Copying '($src)' -> '($dst)"
    if ($dst | path exists) { rm -rf $dst }
    mkdir $p.build_dir
    cp -r $src $p.build_dir
}

# convert-tables: run the table conversion python script.
def task-convert-tables [] {
    let p = (repo-paths)
    let script = $p.convert_dir | path join "scripts/convert-tables.py"
    let config = $p.project_dir | path join "includes/convert-tables.json"

    let inputs = (
        [$script]
        | append ($p.project_dir | path join "chapters/tables/**/*.html")
        | append ($p.project_dir | path join "chapters/tables/**/*.md")
    )
    let outputs = [
        ($p.project_dir | path join "chapters/tables-tex/**/*.tex")
    ]
    if (up-to-date $inputs $outputs "convert-tables") {
        log info "convert-tables: up to date"
        return
    }

    cd $p.project_dir
    with-env {
        TECHMD_ROOT_DIR: $p.project_dir
        PYTHONPATH: $p.pythonpath
        LUA_PATH: $p.lua_path
    } {
        (^python $script
            --root-dir $p.project_dir
            --data-dir $p.convert_dir
            --config $config
            --parallel)
    }
}

# transform-math: includes/Math.html -> includes/generated/Math.tex,
# keeping only lines that start with a backslash.
def task-transform-math [] {
    let p = (repo-paths)
    let src = $p.project_dir | path join "includes/Math.html"
    let out_dir = $p.project_dir | path join "includes/generated"
    let out = $out_dir | path join "Math.tex"

    if (up-to-date [$src] [$out] "transform-math") {
        return
    }

    mkdir $out_dir
    let content = (open --raw $src
        | lines
        | where {|l| $l | str starts-with "\\" }
        | str join "\n")
    $"($content)\n" | save --force $out
}

# build-html: md -> html
def task-build-html [] {
    task-convert-tables
    task-copy-less
    task-copy-assets

    let p = (repo-paths)
    let input = $p.project_dir | path join "Content.md"
    let output = $p.build_dir | path join "Content.html"
    run-pandoc "md -> html" $input $output "html" true true ["--toc"]
}

# build-pdf-tex: md -> latex -> pdf
def task-build-pdf [] {
    task-convert-tables
    task-transform-math

    let p = (repo-paths)
    let input = $p.project_dir | path join "Content.md"
    let output = $p.build_dir | path join "Content.pdf"
    run-pandoc "md -> latex -> pdf" $input $output "pdf" false true []
}

def task-build-latex [] {
    task-convert-tables
    task-transform-math

    let p = (repo-paths)
    let input = $p.project_dir | path join "Content.md"
    let output = $p.build_dir | path join "output-tex/input.tex"
    run-pandoc "md -> latex -> pdf" $input $output "latex" false true []
}

# view-html: serve the built HTML with live reload.
# Config path corrected per spec §8.2 (real location under tools/gradle).
def task-view-html [] {
    let p = (repo-paths)
    let config = $p.tools_dir | path join "gradle/browser-sync-config.js"
    let html = $p.build_dir | path join "Content.html"

    cd $p.project_dir
    (^browser-sync start
        --server
        --config $config
        --files $html
        --files "**/*.css"
        --startPath "build"
        --index "Content.html")
}

# package-html: copy the built site into docs/html-package/<name>.
def task-package-html [] {
    task-build-html

    let p = (repo-paths)
    let dst = $p.root | path join "docs/html-package" $p.project_name

    let inputs = [
        ($p.build_dir | path join "Content.html")
        ($p.build_dir | path join "css/**/*")
        ($p.build_dir | path join "files/**/*")
    ]
    let outputs = [
        ($dst | path join "Content.html")
    ]
    if (up-to-date $inputs $outputs "package-html") {
        return
    }

    mkdir $dst

    let content = $p.build_dir | path join "Content.html"
    if ($content | path exists) { cp $content $dst }

    let css = $p.build_dir | path join "css"
    if ($css | path exists) {
        let css_dst = $dst | path join "css"
        if ($css_dst | path exists) { rm -rf $css_dst }
        cp -r $css $dst
    }

    let files = $p.build_dir | path join "files"
    if ($files | path exists) {
        let files_dst = $dst | path join "files"
        if ($files_dst | path exists) { rm -rf $files_dst }
        cp -r $files $dst

        # exclude files/generated/**
        let gen = $files_dst | path join "generated"
        if ($gen | path exists) { rm -rf $gen }
    }
}

# ---------------------------------------------------------------------------
# CLI subcommands
# ---------------------------------------------------------------------------

def "main compile-less" [] { task-compile-less }
def "main copy-less" [] { task-copy-less }
def "main copy-assets" [] { task-copy-assets }
def "main convert-tables" [] { task-convert-tables }
def "main transform-math" [] { task-transform-math }
def "main build-html" [] { task-build-html }
def "main build-pdf" [] { task-build-pdf }
def "main build-latex" [] { task-build-latex }
def "main view-html" [] { task-view-html }
def "main package-html" [] { task-package-html }

# List available tasks.
def main [] {
    print "Technical Markdown build tasks (ported from build.gradle.kts):"
    print ""
    print "  compile-less     Compile main.less -> convert/css/main.css"
    print "  copy-less        Copy compiled CSS into the build dir"
    print "  copy-assets      Copy files/ into the build dir"
    print "  convert-tables   Convert HTML/MD tables to .tex"
    print "  transform-math   Extract \\ macros from Math.html -> Math.tex"
    print "  build-html       md -> html"
    print "  build-pdf        md -> latex -> pdf"
    print "  build-latex      md -> latex"
    print "  view-html        Serve built HTML with browser-sync"
    print "  package-html     Copy built site into docs/html-package/techmd"
    print ""
    print "Usage: nu tools/scripts/build.nu <task>"
}
