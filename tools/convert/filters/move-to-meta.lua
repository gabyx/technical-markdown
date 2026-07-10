--- Pandoc filter to move content to a metadata variable
--- Usage with attributes `{.move-to-meta var=myvariable}`.

local List = require("pandoc.List")

local metaVars = {}
function set(meta)
    for varName, content in pairs(metaVars) do
        io.stderr:write("Settings meta data '" .. varName .. "' ... \n")
        meta[varName] = pandoc.MetaBlocks(content)
    end
    return meta
end

function move_to_meta(d)
    if d.classes:includes("move-to-meta") then
        varName = d.attributes["var"]
        metaVars[varName] = d.content
        return List() -- remove the content
    end
    return nil -- don't do anything
end

return {
    { Div = move_to_meta },
    { Meta = set },
}
