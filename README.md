# Technical Markdown

A markdown setup for technical documents, reports, theses & papers.

![](https://img.shields.io/badge/dependencies-docker%20%7C%20pandoc%20%7C%20python3%20%7C%20gradle%20%7C%20vscode-green)

**History rewritten**: Due to LFS mistakes, `main` branch was rewritten and a
reclone of this repository is needed.

**Note: A `docker` build setup has been implemented! Read more in
[here](#docker-build).**

Check the [`Changelog.md`](Changelog.md) for the latest changes.

![Demo](docs/Demo.png)

## Quick Intro

**This is a markdown setup demonstrating the power and use of markdown for
technical documents:**

- **fully automated conversion sequence** using [`gradle`](https://gradle.org) +
  [`pandoc`](https://github.com/jgm/pandoc) such that exporting
  ([content.md](https://raw.githubusercontent.com/gabyx/TechnicalMarkdown/master/content.md))
  is done in the background:
  - **export to PDF** with `pandoc` to `xelatex` using `latexmk`
    [See Output](docs/output/techmd/Content.pdf)
  - **export to HTML** with `pandoc` to `html`
    [See Output](https://gabyx.github.io/technical-markdown/docs/html-package/techmd/Content.html)
  - [todo] **export to PDF** with `pandoc` to `html` then to `chrome` with
    `pupeteer`

- **[pandoc filters](https://pandoc.org/filters.html)** for different AST
  (abstract syntax tree) conversions:
  - [own filters](https://github.com/gabyx/TechnicalMarkdown/tree/master/tools/convert/filters)
    with [panflute](https://github.com/sergiocorreia/panflute)
    [[doc](http://scorreia.com/software/panflute)]
  - [--crosscite](https://github.com/jgm/pandoc-citeproc)
    [[doc](https://github.com/jgm/pandoc-citeproc/blob/master/man/pandoc-citeproc.1.md)]
    for citing
  - [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref)
    [[doc](http://lierdakil.github.io/pandoc-crossref)] for cross referencing
  - [pandoc-include-files](https://github.com/pandoc/lua-filters/tree/master/include-files)
    [[doc](https://github.com/pandoc/lua-filters/tree/master/include-files/README.md)]
    for file transclusion

- Full-fledged [VS Code](https://code.visualstudio.com/) setup to write and
  style your document in one of the best IDEs (_nvim is better 😏_).

## Quick-Start

Execute the following in a shell:

```shell
./gradlew -t build-html
```

This will build the HTML output from its [markdown main file](content.md).

## Demo Project

There is also a demo showing a
[full thesis](https://github.com/gabyx/technical-markdown-demo) project.

## Rational

[Pandoc](https://github.com/jgm/pandoc) is awesome and the founder John
MacFarlane develops pandoc in a meticulous and principled style. The
documentation is pretty flawless and the community (including him) is really
helpful. That is why we rely heavily on pandoc.

1. We target the output formats `html5` and `latex`, because
   - HTML can be viewed in all browsers and web standards such as CSS3 etc. have
     become a major advantage and enables ridiculuous dynamic, interactive
     styling. Collapsable table of contents is just the beginning.
   - LaTeX enables to produce high quality output PDF (`xelatex`). Every proper
     book and distributed PDF is written and set in LaTeX.

2. The orchestration around calling `pandoc` is basically only a file watcher
   [`gradle`](https://gradle.org) which calls `pandoc` on file changes. We want
   as little as possible different tools to achieve the above output formats.
   That also means we _do not want_ to have lots of pre- and post-processing
   tasks aside from running `pandoc`. The main goal is, that users can write
   `markdown` as a **first-party solution** with some enhanced features enabled
   by `pandoc` itself. **Writting technical documents should become a breeze.**

3. The common agreement in the industry about using M$ Office for writting
   technical documentations as demonstrated here, is considered the most
   complete and utter bullshit you can adhere to. Certainly employees mostly
   must obey. The common argument is "people need to exchange documents and work
   on it". experiences, a lot of time and money is spent which gets never
   debated.

   **It's about high time** to turn into a direction which will likely become
   the standard. **Technical writters should really focus on the content they
   write and not focus on styling quirks and tricks.**

4. Every technical document writter probably knows about source code management
   (`git`). There you go with proper team work.

## Project Layout

The following directories of a single project in [`src`](src) (e.g.
[`src/techmd`](src/techmd)) are important for the content of the output:

- [`content.md`](content.md) : The main markdown document.
- [`chapters`](chapters) : All markdown source included in the
  [main markdown docucment](content.md).
- [`files`](files) : All additional files referenced in the markdown documents
  in [`chapters`](chapters).
- [`literature`](literature) : All bibliography/literature related files (e.g.
  [`bibliography.bib`](literature/bibliography.bib)).
- [`includes`](includes) : Special include files (e.g.
  [MathJax definitions](includes/Math.html)) and other project related build
  tooling files which act as input files to the `pandoc` build process.

The following directories are important for the styling of the output:

- [`tools/convert`](tools/convert) : The main _tools_ directory containing
  pandoc related output configs. It acts as pandocs
  [`data-dir`](https://pandoc.org/MANUAL.html#option--data-dir). See
  [env. variables](#environment-variables) in docker builds.
  - [`tools/convert/defaults`](tools/convert/defaults) : `pandoc` defaults .
  - [`tools/convert/includes`](tools/convert/includes) : `pandoc` templates in
    for HTML and PDF output settings.
  - [`tools/convert/css`](tools/convert/css) CSS styling for HTML output.
  - [`tools/convert/filters`](tools/convert/filters) : `pandoc` filters in for
    modifying `pandoc`s abstract syntax tree.
  - [`tools/convert/scripts`](tools/convert/scripts) : Some workaround scripts
    for converting tables based on a config file in

## Dependencies

If you have `docker`, you should directly open this project in VS Code with the
provided `.devcontainer` setup which gives you a hassle free experience. See
[Docker Setup](#docker-build) for more information. Building on a native system,
you need the following dependencies:

### Gradle

For the Gradle build tool you need a working [Java runtime](https://java.com).
On Linux and macOS you can do:

```shell
brew install java
```

You should not need to install Gradle, since everything is setup by the
checked-in `gradlew` Gradle wrapper.

### Yarn

So far `yarn` is not required on the system and handled by the dependent Gradle
task `yarnSetup`. If you experience problems with having the node modules not
correctly setup, use

```shell
cd tools
../build/techmd/yarn/bin/yarn install --modules-path build/techmd/node_modules
```

### Pandoc

Install [pandoc](https://pandoc.org/installing.html) (>= 2.9.2.1, tested with
2.16.2)

For **Linux** and **macOs**:

```shell
brew install pandoc pandoc-crossref
```

For **Windows**:

```shell
choco install pandoc
```

### Python

Install a recent `python3` (>= 3.9) and the following packages.

Setup a python environment in `.venv` with
`python -m venv --system-site-packages ./.venv` and install the packages:

```shell
python -m venv --system-site-packages .venv # or simply symlink to an existing one.
source .venv/bin/activate
pip3 install -r tools/docker/setup/python.requirements
```

The VS Code tasks pass the config `${config:python.pythonEnv}` directly as an
argument to `gradlew` (if not set `python` is the default). The tasks are run in
a shell where `./.venv/bin/activate` has been called. Then, `pandoc` will use
the correct python when launching the filters.

You can also use the ignored [.envrc](.envrc) file with
[direnv](https://github.com/direnv/direnv).

## Building and Viewing

Run the following tasks defined in [tasks.json](.vscode/tasks.json) from VS Code
or use the following shell commands:

- **Show HTML Output**: Serves the HTML for preview in a browser with
  autoreload:

  ```shell
  ./gradlew -t view-html
  ```

- **Convert Markdown -> HTML**: Runs the markdown conversion with Pandoc
  (`html`) continuously:

  ```shell
  ./gradlew -t build-html
  ```

  - The conversion with pandoc applies the following filters in
    [defaults](tools/convert/defaults/pandoc-filters.yaml).
  - The HTML output can be inspected in `Content.html`.

- **Convert Markdown -> PDF**: Runs the markdown conversion with Pandoc
  (`latexmk` and `xelatex`) continuously:

  ```shell
  ./gradlew -t build-pdf-tex
  ```

  - The conversion with pandoc applies the following filters in
    [defaults](tools/convert/defaults/pandoc-filters.yaml).
  - The PDF output can be inspected in [`Content.pdf`](build/Content.pdf).
  - The LaTeX output can be inspected in `build/output-tex/input.tex`.

- **Convert Markdown -> Jira**: Runs the markdown conversion to Jira
  (experimental) with Pandoc continuously:

  ```shell
  ./gradlew -t build-jira
  ```

  - The conversion with pandoc applies the following filters in
    [defaults](tools/convert/defaults/pandoc-filters.yaml).
  - The Jira output can be inspected in `Content.jira`.

## Docker Build

We provide 2 images based on `pandoc/latex:2.18-alpine` in
[gabyxgabyx/technical-markdown](https://hub.docker.com/r/gabyxgabyx/technical-markdown):

1. [**`gabyxgabyx/technical-markdown:latest-minimal`**](https://hub.docker.com/r/gabyxgabyx/technical-markdown/tags)
   : Minimal docker images including pandoc and all necessary tools to fully
   build your markdown. It does not include the folder `tools` and `convert` and
   your mounted Git repository needs to contain these as in this repository or
   by setting the environment variables described below. This is useful if you
   want to tweak the layout and styling of the document.
2. [**`gabyxgabyx/technical-markdown:latest`**](https://hub.docker.com/r/gabyxgabyx/technical-markdown/tags)
   : The full-fledged image which is used in this VS Code `.devcontainer` setup.
   It contains its baked `tools` and `tools/convert` folders which are used to
   compile your markdown.

The `<version>` above corresponds to either `latest` or the Git version tag
minus the `v` prefix.

### Environment Variables

Numbers refer to the container images above:

| Env. Name                | Default Value                                       | Description                                                                                     |
| ------------------------ | --------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `TECHMD_TOOLS_DIR`       | 1. not set                                          | The tools directory containing all files needed for the conversion.                             |
|                          | 2 . `/home/techmd/technical-markdown/tools`         |                                                                                                 |
| `TECHMD_CONVERT_DIR`     | 1. not set                                          | The convert directory containing the files needed for the `pandoc` converstion.                 |
|                          | 2 . `/home/techmd/technical-markdown/tools/convert` |                                                                                                 |
| `TECHMD_USE_SYSTEM_NODE` | 1. `true`                                           | Use the node installation on the system instead of installing a local one into the build folder |
|                          | 2. `true`                                           |                                                                                                 |

### Using the Docker Image

Either copy the `.devontainer` to your project (you don't need the `tools`
folder) and open the project in the VS Code remote container extension.

Alternatively you can always use:

```shell
docker run -v "<path-to-your-repo>:/workspace" \
    gabyxgabyx/technical-markdown:latest"
    ./gradlew build-html
```

### Extending the Technical-Markdown Docker Images

If you need special other tools and an other setup which might be useful for the
general images above, consider submitting an issue. Otherwise you can always
extend the existing images for [layout/styling](#editing-styles) changes with
another Dockerfile like:

```dockerfile
FROM gabyxgabyx/technical-markdown:latest-minimal as mycustomtechmd
// More Dockerfile commands ...
```

### Building the Technical-Markdown Docker Images

To build the images in this repository for customization use:

```shell
tools/docker/build.sh \
    --base-name "mycustomimage" \
    [--push-base-name "docker.io/superuser"] \
    [--push]
```

## Editing Styles

### HTML

You can edit the [main.less](tools/convert/css/src/main.less) file to change the
look of the markdown. Edit the [main.less](tools/convert/css/src/main.less) file
to see changes in the conversion from [content.md](content.md).

### LaTeX

The following templates are responsible for the LaTeX output:

- [Template.tex](tools/convert/includes/Template.tex) : The main template.
- [Header.tex](tools/convert/includes/Header.tex) : The class, packages and
  styles defining the document, included by the main template with
  `include-in-header` in
  [pandoc-latex.yaml](tools/convert/defaults/pandoc-latex.yaml)

### Pandoc Filters

Pandoc filters are harder to debug. There is an included unix-like
[tee.py](tools/convert/filters/tee.py) filter which can be put anywhere into the
filter chain as needed, to see the AST JSON output in the folder
`build/pandoc-filter-out` (see [dev.py](tools/convert/filters/module/dev.py) for
adjustments). The filter [teeStart.py](tools/convert/filters/teeStart.py) first
clears all output before doing the same as
[tee.py](tools/convert/filters/tee.py). Uncomment the `tee.py` filters in
[pandoc-filters.yaml](tools/convert/defaults/pandoc-filters.yaml).

## Issues

### Panflute [done]

Using pandoc `>=2.10` we have more types and AST changes in

- [jgm/pandoc#1024](https://github.com/jgm/pandoc/issues/1024),
- [jgm/pandoc#6277](https://github.com/jgm/pandoc/pull/6277),
- [2.10](https://github.com/jgm/pandoc/releases/tag/2.10)

meaning that also the python library `panflute` needs to be supporting this:

- [Issue](https://github.com/sergiocorreia/panflute/issues/142) :
  ![](https://img.shields.io/badge/dynamic/json?color=%23FF0000&label=Status&query=%24.state&url=https%3A%2F%2Fapi.github.com%2Frepos%2Fsergiocorreia%2Fpanflute%2Fissues%2F142)

### Transclude: Relative file paths [done]

So far _relative_ paths are not yet supported in `pandoc-include-files.lua`
filter.

- [Issue](https://github.com/pandoc/lua-filters/issues/102) :
  ![Status](https://img.shields.io/badge/dynamic/json?color=%23FF0000&label=Status&query=%24.state&url=https%3A%2F%2Fapi.github.com%2Frepos%2Fpandoc%2Flua-filters%2Fissues%2F102)

### Table Issues [done]

- Wrong format for `latex`: [Issue](https://github.com/jgm/pandoc/issues/6883) :
  ![Status](https://img.shields.io/badge/dynamic/json?color=%23FF0000&label=Status&query=%24.state&url=https%3A%2F%2Fapi.github.com%2Frepos%2Fjgm%2Fpandoc%2Fissues%2F6883)
  -> Update to next version.

## Todo

- Add CI.
- Add tests.
- Add prince conversion to PDF.

## Support & Donation

When you use Githooks and you would like to say thank you for its development
and its future maintenance: I am happy to receive any donation:

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6S6BJL4GSMSG4)
