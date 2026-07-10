# Multiline Table

----------- ------- --------------------- -------------------------
   First    row                      12.0 Example of a row that
                                          spans multiple lines.

  Second    row                       5.0 Here's another one.
----------- ------- --------------------- -------------------------
: Here's a multiline table without a header.

# Grid Table

+---------------+-------+----------------------+
| Fruit         | Price | Advantages           |
+===============+=======+======================+
| Bananas       | $1.34 | - built-in wrapper   |
|               |       | - bright color       |
+---------------+-------+----------------------+
| Oranges       | $2.10 | - cures scurvy       |
|               |       | - tasty              |
|               |       | - Link [@sec:tables] |
+---------------+-------+----------------------+
: Sample grid table.

# RST-Style Table

This is a `RST-style` table which is converted by
[`filters/pandoc-list-table.lua`](tools/convert/filters/pandoc-list-table.lua)

:::{.list-table aligns=l,l,c,c header-cols=1 header-rows=1 widths=1,3,1,1}
   Sample Table

   * - Key
     - Name
     - Italic
     - Code

   * - A
     - This is some random text to demonstrate line breaks across cells. And it should happen.
     - []{rowspan=2} `*italic*`
     - `` `code` ``

   * - B
     - This is some random text to demonstrate line breaks across cells. And it should happen.
     - ` ``code`` `
:::
