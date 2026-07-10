---
title: "Technical Documents"
titlepage-logo: "files/logo.svg"
subtitle: "Demonstrating the Power of Markdown with Pandoc"
author:
  - "Gabriel Nützi"
  - "The Community"
date: 2. December 2020
location: Zürich, Switzerland

bibliography: ["literature/bibliography.bib"]
csl: "literature/ieee-with-url.csl"
crossrefYaml: "includes/pandoc-crossref.yaml"
link-citations: true

fontsize: 12pt
lang: en-GB

abstract-title: Abstract
acknowledgement-title: Thanks
toc-title: Contents
abstract: >
  This is a setup demonstrating the power and use of markdown for technical
  documents by using a fully automated conversion sequence with
  [`gradle`](https://gradle.org) and of course [`pandoc`](https://pandoc.org)."

toc: true
toc-depth: 2
top-level-division: chapter
secnumdepth: 3
---

:::{include-if-format=}

Reasonable applied defaults before the above yaml meta block are found in:

- `tools/convert/defaults/pandoc-general.yaml` for all output formats
- `tools/convert/defaults/pandoc-html.yaml` for HTML
- `tools/convert/defaults/pandoc-latex.yaml` for LaTex output Note: This is a
  Div block which get discarded because of the `{include-if-format=}`

:::

```{.include format=html include-if-format=html;html5}
includes/math.html
```

```{.include}
${env:TECHMD_ROOT_DIR}/chapters/acknowledgement.md
```

# Intro

Read the
[Readme.md](https://github.com/gabyx/TechnicalMarkdown/blob/master/Readme.md)
for further information.

# Samples

```{.include}
${env:TECHMD_ROOT_DIR}/chapters/konvexe-probleme.md
${env:TECHMD_ROOT_DIR}/chapters/markdown-samples.md
${env:TECHMD_ROOT_DIR}/chapters/table-samples.md
```

# References
