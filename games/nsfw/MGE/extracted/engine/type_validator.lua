local validator = {}

local function _isLoveType(loveType, data)
    if data == nil then
        return false
    end
    if type(data) ~= 'userdata' then
        return false
    end
    if data.typeOf == nil then
        return false
    end
    if data:typeOf(loveType) == true then
       return true
    end
    return false
end

function validator.isGameType(gameType, data)
    if type(data) ~= 'table' then
        return false
    end
    if gameType == 'Drawable' then
        return data.type == 'Mask' or data.type == 'Image' or data.type == 'Text'
    end
    return data.type == gameType
end

function validator.isSprite(sprite)
    return _isLoveType('Image', sprite)
end

function validator.isAnimation(animation)
    if animation == nil then
        return false
    end
    if type(animation) ~= 'table' then
        return false
    end
    return true
end

function validator.isSound(sound)
    if sound == nil then
        return false
    end
    if type(sound) ~= 'table' then
        return false
    end
    return true
end

function validator.isShader(shader)
    return _isLoveType('Shader', shader)
end

function validator.isFont(font)
    return _isLoveType('Font', font)
end

return validator