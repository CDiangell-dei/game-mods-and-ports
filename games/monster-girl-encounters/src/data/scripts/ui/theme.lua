local theme = {}

local function _getColorFromRarity(rarity)
    if rarity == 4 then
        return {
            r = 0.850980,
            g = 0.674510,
            b = 0.450980,
            a = 1.0,
        }
    elseif rarity == 3 then
        return {
            r = 0.525490,
            g = 0.670588,
            b = 0.811765,
            a = 1.0,
        }
    elseif rarity == 2 then
        return {
            r = 0.407843,
            g = 0.776471,
            b = 0.701961,
            a = 1.0,
        }
    else
        return {
            r = 0.741176,
            g = 0.741176,
            b = 0.741176,
            a = 1.0,
        }
    end
end

function theme.colorRarityImage(image, rarity)
    if image == nil then
        return
    end
    local color = _getColorFromRarity(rarity)
    if image.setColor == nil then
        game.debug.logError('Could not color rarity...')
        return
    end
    image.setColor(color.r, color.g, color.b, color.a)
end

function theme.colorRarityText(text, rarity)
    if text == nil then
        return
    end
    local color = _getColorFromRarity(rarity)
    text.setColor(color.r, color.g, color.b, color.a)
end

return theme
