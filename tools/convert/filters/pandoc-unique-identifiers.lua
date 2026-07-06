--- Make all identifiers heading indetifiers unique.
--- Useful in combination with `include-files.lua`.
---
--- Copyright: © 2019–2020 Gabriel Nützi
--- License:   MIT – see LICENSE file for details
local ids = {}

-- Get the key in the table, otherwise return nil
local function get(obj, field, ...)
    if obj == nil or field == nil then
        return obj
    else
        return get(obj[field], ...)
    end
end

function make_unique(block)
    local id = get(block, "identifier")
    if id == nil or id == "" then
        return nil
    end

    local index = ids[id]

    -- get master count if possible
    local baseId = id:match("^(.*)-%d+$")
    if baseId then
        id = baseId
        index = ids[id]
    end

    if index == nil then
        ids[id] = 0 -- initialize counter
    end

    -- we have duplicate id, e.g 'id: name-3', 'index: 3', baseId = "name"
    if index then
        -- Replace id
        index = index + 1
        newId = id .. "-" .. tostring(index)

        ids[id] = index
        ids[newId] = index

        io.stderr:write("Adjust existing identifier " .. id .. " to: '" .. newId .. "'\n")
        block.identifier = newId
        return block
    end
    return nil
end

return { { Header = make_unique } }
