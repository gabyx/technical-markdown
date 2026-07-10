local dump = require("module-lua.dump")

local utils = {}

unpack = table.unpack

function utils.log(fmt, ...)
    io.stderr:write(string.format(fmt, ...))
end

function utils.trim(s)
    return s:match("^%s*(.-)%s*$")
end

function utils.fmt(...)
    return string.format(...)
end

-- Define a shortcut function for testing
function utils.dump(...)
    utils.log(dump.DataDumper(...))
    utils.log("\n---")
end

return utils
