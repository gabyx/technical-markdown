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
