# Technical Markdown

<p align="center">
  <img src="https://raw.githubusercontent.com/gabyx/technical-markdown/src/techmd/includes/logo.svg" alt="logo" width="250">
</p>

<p align="center">
</p>
<p align="center">
  <img src="https://img.shields.io/badge/Nix,Pandoc,Tex,HTML-blue.svg" alt="License label" /></a>
  <a href="https://github.com/gabyx/technical-markdown/releases/latest">
    <img src="https://img.shields.io/github/release/gabyx/technical-markdown.svg" alt="Current Release label" /></a>
  <a href="https://raw.githubusercontent.com/gabyx/technical-markdown/LICENSE.md">
    <img src="https://img.shields.io/badge/License-MPL2.0-green.svg" alt="License label" /></a>
</p>

A markdown setup for technical documents, reports, theses & papers.

Check the [`Changelog.md`](Changelog.md) for the latest changes.

![Demo](docs/Demo.png)

## Quick Intro

**This is a markdown setup demonstrating the power and use of markdown for
technical documents:**

- **fully automated conversion sequence** with
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

> [!NOTE]
>
> You need [`nix`](https://nixos.org/download) installed on your system or you
> need to use the provided devcontainer. Also
> [direnv](https://github.com/direnv/direnv) is suggested.

### With Nix

- Activate the shell:

```shell
direnv allow && direnv reload
# or
just develop
# or
nix develop ./tools/nix --no-pure-eval
```

- Build the HTML output:

```
just build html
```

This will build the HTML output from its [markdown main file](content.md).

Serve all conversions with `process-compose` by doing:

```
just serve
```

# With Container

TODO: not yet refurbished.

If you have `docker` or `podman`, you should directly open this project in VS
Code with the provided `.devcontainer` setup which gives you a hassle free
experience. See [Docker Setup](#docker-build) for more information. Building on
a native system, you need the following dependencies:

## Demo Project

There is also a demo showing a
[full thesis](https://github.com/gabyx/technical-markdown-demo) project.

> [!WARNING]
>
> The demo is still in v2 and only here as a reference, it worked with pandoc
> `2.x`.

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

## Building and Viewing

Run the following tasks defined in [tasks.json](.vscode/tasks.json) from VS Code
or use the following shell commands:

- **Show HTML Output**: Serves the HTML for preview in a browser with
  autoreload:

  ```shell
  just main view-html
  ```

- **Convert Markdown -> HTML**: Runs the markdown conversion with Pandoc
  (`html`) continuously:

  ```shell
  just build html
  ```

  - The conversion with pandoc applies the following filters in
    [defaults](tools/convert/defaults/pandoc-filters.yaml).
  - The HTML output can be inspected in `content.html`.

- **Convert Markdown -> PDF**: Runs the markdown conversion with Pandoc
  (`latexmk` and `xelatex`) continuously:

  ```shell
  just build pdf
  ```

  - The conversion with pandoc applies the following filters in
    [defaults](tools/convert/defaults/pandoc-filters.yaml).
  - The PDF output can be inspected in [`Content.pdf`](build/content.pdf).
  - The LaTeX output can be inspected in `build/output-tex/input.tex`.

## IDE Editors

### VS Code

TODO: refurbish and test

## Docker Build

TODO: refurbish to v3.

- [Version v2](docs/v2/docker.md)

## Editing Styles

### HTML

- You can edit the [main.less](tools/convert/css/src/main.less) file to change
  the look of the markdown. Edit the
  [main.less](tools/convert/css/src/main.less) file to see changes in the
  conversion from [content.md](content.md).
- [pandoc-latex.yaml](tools/convert/defaults/pandoc-html.yaml): The pandoc
  defaults for the HTML conversion.

### LaTeX

The following templates are responsible for the LaTeX output:

- [pandoc-latex.yaml](tools/convert/defaults/pandoc-latex.yaml): The pandoc
  defaults for the latex conversion.
- [Latex template](tools/convert/includes/latex/default.latex): The main
  templates.

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

- [Pandoc `v2` issues](./docs/v2/issues.md)

## Todo

- Add CI.
- Add tests.
- Add prince conversion to PDF.

## Support & Donation

When you use Githooks and you would like to say thank you for its development
and its future maintenance: I am happy to receive any donation:

[🌻 Sponser Me 🌻](https://github.com/sponsors/gabyx)
