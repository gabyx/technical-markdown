---
title: "Technical Documents"
titlepage-logo: "files/logo.svg"
subtitle: "Demonstrating the Power of Markdown with Pandoc (v3)"
author:
  - "Gabriel Nützi"
  - "The Community"
date: 10. July 2026
location: Zürich, Switzerland

thesis-where:
  - Study of "Open Source Software"
  - Institute for Anti-AI-Slop, Zurich

handed-in-by: "handed-in-by"
author:
  - "Gabriel Nützi"
  - "The Community"
on-date: "on"
date: "July 2026"
recommended-by:
  - "Begleitung: Prof. Dr. No-Slop"
location: "Luzern, 2026"

bibliography: ["literature/bibliography.bib"]
csl: "literature/ieee-with-url.csl"
crossrefYaml: "includes/pandoc-crossref.yaml"
link-citations: true

fontsize: 12pt
linestrech: 1.2
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
lot: true
lof: true
---

:::{include-if-format=}

Reasonable applied defaults before the above yaml meta block are found in:

- `tools/convert/defaults/pandoc-general.yaml` for all output formats
- `tools/convert/defaults/pandoc-html.yaml` for HTML
- `tools/convert/defaults/pandoc-latex.yaml` for LaTeX output Note: This is a
  Div block which gets discarded because of the `{include-if-format=}`

:::

```{.include format=html include-if-format=html;html5}
includes/math.html
```

```{.include}
${env:TECHMD_ROOT_DIR}/chapters/acknowledgement.md
```

# Intro

Read the
[Readme.md](https://github.com/gabyx/technical-markdown/blob/master/Readme.md)
for further information.

# Samples

```{.include}
${env:TECHMD_ROOT_DIR}/chapters/konvexe-probleme.md
${env:TECHMD_ROOT_DIR}/chapters/markdown-samples.md
${env:TECHMD_ROOT_DIR}/chapters/table-samples.md
```

# References
