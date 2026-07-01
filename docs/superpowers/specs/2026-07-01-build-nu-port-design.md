# Design: Port `src/techmd/build.gradle.kts` to `tools/scripts/build.nu`

- **Date:** 2026-07-01
- **Author:** Gabriel Nützi (with Claude)
- **Status:** Proposed
- **Source of truth:** `src/techmd/build.gradle.kts` (the Gradle build being
  replaced)

## 1. Goal

Reimplement every Gradle task from `src/techmd/build.gradle.kts` as a function
(subcommand) in a single standalone Nushell script, `tools/scripts/build.nu`.

The port is **faithful/verbatim**: same commands, same arguments, same
environment variables, same working directories, same defaults files, same
task-dependency ordering, and the same incremental (up-to-date) semantics that
Gradle provided via `inputs`/`outputs`.

## 2. Non-goals / explicit exclusions

- **No tool installation.** The `node`/`pandoc`/`python` toolchain (and `lessc`,
  `browser-sync`, `latexmk`) is provided externally (Nix dev shell / the user's
  environment). The script never installs anything.
- **`initBuild` (Gradle `YarnTask`) is dropped.** It only ran
  `yarn install --modules-folder …`. Nothing replaces it.
- **`defineEnvironment` is dropped entirely.** No executable-existence checks,
  no `pandoc >= 2.14` version enforcement, no python `--version` check, no
  python/lua path existence checks. We trust the environment.

## 3. Decisions (locked)

| Question                                 | Decision                                                                                                                       |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Script location / invocation             | Standalone `tools/scripts/build.nu`, invoked as `nu tools/scripts/build.nu <subcommand>`. No `justfile` wiring in this change. |
| Output/build directory                   | `.output/build/techmd` (the new refurbish convention), replacing Gradle's `build/techmd`.                                      |
| `defineEnvironment` checks               | Dropped entirely.                                                                                                              |
| Incremental up-to-date                   | Yes — mtime-based, mirroring each task's `inputs`/`outputs`.                                                                   |
| Fidelity of the two latent Gradle quirks | Port **verbatim** (see §8).                                                                                                    |

## 4. Path model

Resolved once per invocation from the repo root:

- `root` = `git rev-parse --show-toplevel`
- `project_dir` = `{root}/src/techmd` (Gradle `project.projectDir`)
- `tools_dir` = `{root}/tools` (Gradle `TECHMD_TOOLS_DIR` default)
- `convert_dir` = `{root}/tools/convert` (Gradle `TECHMD_CONVERT_DIR` default;
  also `dataDir`/`resourceDir`)
- `build_dir` = `{root}/.output/build/techmd` (Gradle `project.buildDir`,
  relocated)
- `project_name` = `techmd`

All paths are absolute (matching Gradle's `file(...)` resolution). The Gradle
env overrides `TECHMD_CONVERT_DIR` / `TECHMD_TOOLS_DIR` /
`TECHMD_USE_SYSTEM_NODE` are also reproduced

## 5. Tool assumptions (all invoked by bare name from `PATH`)

`pandoc`, `python`, `lessc`, `browser-sync`, `latexmk`.

Rationale: Gradle sourced `lessc` and `browser-sync` from
`{buildDir}/node_modules/.bin` — a directory produced by the now-dropped
`initBuild`/yarn install. With no install step there is no such directory, so
these are resolved from `PATH` like the other externally-provided tools. This is
a direct consequence of the "no tool install" directive, not a discretionary
change.

## 6. Subcommands

Nu `main`-subcommand convention: `def "main <name>" []` is the CLI entry; each
delegates to a plain worker `def`. Bare `nu build.nu` (no arg) prints the task
list.

Dependencies are invoked by calling the dependency worker first. Because every
task is mtime-guarded, a dependency invoked twice in one run is cheap (it
short-circuits the second time).

| Subcommand       | Gradle task                 | Depends on (after dropping initBuild/defineEnvironment) |
| ---------------- | --------------------------- | ------------------------------------------------------- |
| `compile-less`   | `compileLess`               | —                                                       |
| `copy-less`      | `copyLess` (val `buildCSS`) | `compile-less`                                          |
| `copy-assets`    | `copyAssets`                | —                                                       |
| `convert-tables` | `convert-tables`            | —                                                       |
| `transform-math` | `transform-math`            | —                                                       |
| `build-html`     | `build-html`                | `convert-tables`, `copy-less`, `copy-assets`            |
| `build-pdf`      | `build-pdf-tex`             | `convert-tables`, `transform-math`                      |
| `build-jira`     | `build-jira`                | `convert-tables`, `transform-math`                      |
| `view-html`      | `view-html`                 | —                                                       |
| `package-html`   | `package-html`              | `build-html`                                            |

### 6.1 `compile-less`

- **Inputs:** `convert/css/src/main.less` + all `convert/css/src/*.less`
- **Output:** `convert/css/main.css`
- **Command:**
  `lessc --include-path={convert_dir}/css/src {main.less} {main.css}`
- **Working dir:** `project_dir`

### 6.2 `copy-less`

- **Input:** `convert/css/main.css` → **Output:** `build/css/main.css`
- Copy (create `build/css` as needed).

### 6.3 `copy-assets`

- **Input:** `project_dir/files/**` → **Output:** `build/files/**`
- Recursive copy of the `files/` tree.

### 6.4 `convert-tables`

- **Inputs:** `convert/scripts/convert-tables.py` +
  `chapters/tables/**/*.{html,md}`
- **Outputs:** `chapters/tables-tex/**/*.tex`
- **Command:**
  `python {convert}/scripts/convert-tables.py --root-dir {project_dir} --data-dir {convert_dir} --config {project_dir}/includes/convert-tables.json --parallel`
- **Env:** pandoc env (§7). **Working dir:** `project_dir`.

### 6.5 `transform-math`

- **Input:** `includes/Math.html` → **Output:** `includes/generated/Math.tex`
- Copy with rename `*.html` → `*.tex`; keep only lines that start with `\` (drop
  all others), matching the Gradle `filter { … startsWith("\\") }`.

### 6.6 `build-html` / `build-pdf` / `build-jira` (Pandoc)

Common Pandoc `inputs` (mtime): `Content.md`, `chapters/**/*.{md,html,tex}`,
`files/**/*`, `literature/**/*`, `{convert_dir}/**/*`.

|                      | `build-html`         | `build-pdf`          | `build-jira`         |
| -------------------- | -------------------- | -------------------- | -------------------- |
| exportType           | `html`               | `latex`              | `jira`               |
| output               | `build/Content.html` | `build/Content.pdf`  | `build/Content.jira` |
| `--verbose`          | yes                  | no                   | no                   |
| `--fail-if-warnings` | yes                  | yes                  | **no**               |
| extra args           | `--toc`              | latex extras (below) | —                    |

Argument order (from `makePandocArgs` + `setup`):

```
[--fail-if-warnings]            # when failIfWarning
[--verbose]                     # when verbose
--data-dir={convert_dir}
--resource-path={convert_dir}
--defaults=pandoc-dirs.yaml
--defaults=pandoc-general.yaml
--defaults=pandoc-<exportType>.yaml
--defaults=pandoc-filters.yaml
<latex extras, latex only>
--log={build_dir}/pandoc-<exportType>.log
<additionalArgs: --toc for html>
-o <outputFile> <inputFile>
```

Latex extras (inserted before `--log`, latex only):

```
-M latex-include-paths={convert_dir}/includes/
-M latex-include-paths={project_dir}/
--pdf-engine-opt=-r
--pdf-engine-opt={tools_dir}/.latexmkrc
--pdf-engine-opt=-outdir={build_dir}/output-tex
```

- **Executable:** `pandoc`. **Working dir:** `project_dir`. **Env:** §7.
- `--log` requires `{build_dir}` to exist; the script creates it first.
- Defaults files are passed by bare name; pandoc resolves them under
  `{--data-dir}/defaults/`, i.e. `tools/convert/defaults/`.

### 6.7 `view-html`

- **Executable:** `browser-sync` (from `PATH`). **Working dir:** `project_dir`.
- **Args (verbatim):**
  `start --server --config {project_dir}/tools/gradle/browser-sync-config.js --files {build/Content.html} --files **/*.css --startPath build --index Content.html`
- Long-running server; no mtime guard.

### 6.8 `package-html`

- **From:** `build_dir`, including `files/**`, `css/**`, `Content.html`;
  **excluding** `files/generated/**`.
- **Into:** `{root}/docs/html-package/{project_name}` (=
  `docs/html-package/techmd`).
- **Depends on:** `build-html`.

## 7. Pandoc / convert-tables environment (verbatim)

Starting from the current process environment, Gradle set (in
`createPandocSettings`):

- `TECHMD_ROOT_DIR = {project_dir}`
- `PYTHONPATH = <existing PYTHONPATH> ":" {convert_dir}/filters` (Java
  `path.separator` = `:` on Linux; a leading `:` when previously unset —
  reproduced verbatim.)

`LUA_PATH` is **not** set (Gradle logged it but never assigned it). `PYTHONPATH`
is **not** set (Gradle used the non-standard name `PYTHONPATH`). Both reproduced
verbatim per decision.

## 8. Verbatim-fidelity caveats (accepted)

These reproduce the original exactly and are therefore known-nonfunctional or
non-standard; kept intentionally:

1. **`PYTHONPATH` must be corrected to `PYTHONPATH`** as in the Gradle build.
   `tools/convert/scripts/run.sh` sets the correct

2. **`view-html` config path** does not use
   `src/techmd/tools/gradle/browser-sync-config.js`

## 9. Incremental (mtime) helper

DO write logic for caching but outcomment the function invocation for now!

```
def files-of  [patterns] -> list      # expand files/dirs/globs to existing file paths
def up-to-date [inputs, outputs] -> bool
```

`up-to-date` returns `true` iff: at least one output file exists, **all** output
patterns that name concrete files exist, and
`max(mtime(inputs)) <= min(mtime(outputs))`. If a task has no existing inputs,
existing outputs suffice. Each worker computes its declared inputs/outputs (per
§6) and returns early with a "up to date" notice when satisfied. `Copy`-type
tasks (`copy-less`, `copy-assets`, `transform-math`, `package-html`) use the
same guard.

## 10. Output / logging

Modest `print`s mirroring Gradle's `logger.quiet` lines: a per-task start line,
the Pandoc success banner, and the output-file size in MB for pandoc tasks.

## 11. CLI dispatch

- `nu tools/scripts/build.nu` → list available subcommands (Nu prints subcommand
  help for a bare `main`).
- `nu tools/scripts/build.nu <name>` → run that task (with its dependencies).

```

```
