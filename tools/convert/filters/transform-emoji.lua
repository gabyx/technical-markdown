--- Pandoc filter to replace emojis in latex
--- transforms to the command `\emojiFont{...}`
function emoji_replace(cb)
    if cb.classes:includes("emoji") then
        -- Only in latex emoticons need to be replaced
        if FORMAT:match("latex") then
            return pandoc.RawInline("latex", string.format("\\emojiFont{%s}", cb.text))
        end
        return pandoc.Str(pandoc.text)
    end
    return nil
end

return {
    { Code = emoji_replace },
}
