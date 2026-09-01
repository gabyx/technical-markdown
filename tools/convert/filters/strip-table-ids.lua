-- Strip a table's identifier for LaTeX output to avoid a duplicate `\label`.
--
-- Background: since pandoc 3.8.2 the native LaTeX writer emits a `\label` for
-- any Table carrying an identifier (e.g. `#tbl:foo`). pandoc-crossref also
-- emits its own `\label` inside the `\caption{}`, so the table ends up with two
-- labels and LaTeX warns "Label '...' multiply defined".
--
-- This filter must run AFTER pandoc-crossref. It removes only the native
-- writer's duplicate, guarded by two conditions so it can never break refs:
function Table(t)
    if not FORMAT:match("latex") then
        return
    end

    -- (2) Only strip if pandoc-crossref already put a \label in the caption.
    local hasCrossrefLabel = false
    t.caption.long = t.caption.long:walk({
        RawInline = function(r)
            if r.format:match("tex") and r.text:match("\\label") then
                hasCrossrefLabel = true
            end
        end,
    })

    if hasCrossrefLabel then
        t.identifier = ""
        return t
    end
end
