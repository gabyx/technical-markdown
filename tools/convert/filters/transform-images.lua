-- Pandoc filter to convert image includes to latex commands
--    - `\imageWithCaption` or `\svgWithCaption`
local List = require("pandoc.List")
ut = require("module-lua.utils")

function latexBlock(code)
    return pandoc.RawInline("tex", code)
end

function toScaling(size, proportionalTo)
    if size and string.match(size, "%%") then
        local s = tonumber(ut.trim(size):gsub("%%", "")) / 100.0
        return ut.fmt("%s%s", s, proportionalTo)
    else
        return size
    end
end

--- Filter function for images
function transformImages(image)
    if not FORMAT:match("latex") then
        return nil
    end

    local url = image.src
    local label = image.identifier

    ut.log("Transforming image '%s' ... \n", url)

    baseCommand = "imageWithCaption"
    if string.match(url, "%.svg$") then
        baseCommand = "svgWithCaption"
    end

    width = toScaling(image.attributes["width"], "\textwidth")
    height = toScaling(image.attributes["height"], "\textwidth")

    lGraphicsOpts = {}
    if width then
        lGraphicsOpts.insert(ut.fmt("width=%s", width))
    end

    if height then
        lGraphicsOpts.append(ut.fmt("height=%s", height))
    end

    local img = pandoc.List({ latexBlock(ut.fmt("\\%s{%s}{", baseCommand, url)) })
    img:extend(image.caption)
    img:extend({ latexBlock(ut.fmt("}{%s}[%s]", table.concat(lGraphicsOpts, ","), label)) })
    return img
end

return { { Image = transformImages } }
