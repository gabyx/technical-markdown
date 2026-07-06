--- Pandoc filter for replacing the rule elements:
---
--- - `[]{.hrule-fill thickness=0.5pt height=5pt}` corresponding to `\hrulefill`.
--- - `[]{.hrule thickness=0.5pt width=2cm height=5pt}` corresponding to `\rule`.
---
--- with the corresponding rule element in HTML and Latex.

local List = require("pandoc.List")

function create_latex_rule(element, cmd)
    width = element.attributes["width"]
    thickness = element.attributes["thickness"]
    height = element.attributes["height"]

    cmd = "\\" .. cmd

    args = ""
    if width ~= nil then
        if width:match("%d*%%") then
            _, _, percentage = string.find(width, "^(%d*)")
            width = string.format("%0.4f", tonumber(percentage) / 100.0) .. "\\textwidth"
        end

        args = args .. string.format(",fill=%s", width)
    end

    if thickness ~= nil then
        args = args .. string.format(",thickness=%s", thickness)
    end

    if height ~= nil then
        if height:match("%d*%%") then
            _, _, percentage = string.find(height, "^(%d*)")
            height = string.format("%0.4f", tonumber(percentage) / 100.0) .. "\\baselineskip"
        end
        args = args .. string.format(",height=%s", height)
    end

    if args ~= "" then
        cmd = cmd .. "[" .. args .. "]"
    end

    -- Set the test infront of the line.
    elements = pandoc.List()
    if element.content ~= nil then
        elements = elements .. element.content
    end
    elements = elements .. { pandoc.RawInline("latex", cmd) }

    if element.classes:includes(".linebreak") then
        elements = elements .. { pandoc.Linebreak() }
    end

    return elements
end

function create_html_rule(element)
    width = element.attributes["width"]
    thickness = element.attributes["thickness"]
    height = element.attributes["height"]

    attr = ""
    if width ~= nil then
        attr = attr .. string.format("width:%s;", width)
    end

    if thickness ~= nil then
        attr = attr .. string.format("border-bottom-width:%s", thickness)
    end

    if height ~= nil then
        attr = attr .. string.format("vertical-align:%s", height)
    end

    return pandoc.Span(element.content, { class = "hrule-fill", style = attr })
end

function add_rulers(element)
    if element.classes:includes("hrule-fill") then
        if FORMAT:match("html*") then
            return create_html_rule(element)
        elseif FORMAT:match("latex") then
            return create_latex_rule(element, "xhrulefill")
        end
    elseif element.classes:includes("hrule") then
        if FORMAT:match("html*") then
            return create_html_rule(element)
        elseif FORMAT:match("latex") then
            return create_latex_rule(element, "xhrule")
        end
    end

    return element
end

return {
    { Span = add_rulers },
}
