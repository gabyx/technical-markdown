# Tables

## HTML Table

:::{include-if-format=latex;html;html5;json;native}
- Included html file as `html`.
- Markdown citations/cross refeferences do not work inside.
- HTML citations dont work.
- Table caption is not parsed `table_caption` not allowed as extension.

```{.include format=html+tex_math_dollars .relative-to-current}
tables/TableExample.html
```
:::

:::{include-if-format=latex;json;native}
## \LaTeX\ Table
- Included latex file as raw `latex`.
- Converted from `.html` by `convert-tables.py` and `convert-tables.json`.
- Latex citations do work inside.

```{.include format=latex raw=true include-if-format=latex;json;native .relative-to-current}
tables-tex/TableExample.tex
```
:::

## Markdown Tables {#sec:tables}

- Included markdown file.
- Cross references do work here inside.

```{.include .relative-to-current}
tables/TableExample.md
```
