local image = {
    type = 'Image',
}

local _persist = engine.require('engine/components/persistent_data.lua')
local _isDestroyed = false
local _color = {
    r = 1.0,
    g = 1.0,
    b = 1.0,
    a = 1.0,
}
local _sprite = _persist.defaultSprite
local _spriteHeight = 4
local _spriteWidth = 4
local _objectHeight = 1
local _objectWidth = 1
local _quad = love.graphics.newQuad(0, 0, _objectWidth, _objectHeight, _spriteWidth, _spriteHeight)
local _isMaskable = true
local _isTiled = false

local function _drawTiled()
    local x, y = image.object.getActualPosition()
    love.graphics.setColor(_color.r, _color.g, _color.b, _color.a)
    if _isMaskable then
        love.graphics.setStencilTest('equal', _persist.maskCount)
    end
    local offsetX, offsetY = engine.graphics.getScaledOffset()
    love.graphics.draw(_sprite, _quad, x + offsetX, y + offsetY)
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    love.graphics.setStencilTest()
end

local function _drawSimple()
    local x, y = image.object.getActualPosition()
    local sx, sy = image.object.getSize()
    love.graphics.setColor(_color.r, _color.g, _color.b, _color.a)
    if _isMaskable then
        love.graphics.setStencilTest('equal', _persist.maskCount)
    end
    local offsetX, offsetY = engine.graphics.getScaledOffset()
    love.graphics.draw(_sprite, x + offsetX, y + offsetY, 0, sx / _spriteWidth, sy / _spriteHeight)
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    love.graphics.setStencilTest()
end

local function _draw()
    if _isTiled then
        _drawTiled()
    else
        _drawSimple()
    end
end

function image.populateFromData(data)
    if type(data.sprite) == 'string' then
        local sprite = engine.fileSystem.loadSprite(data.sprite)
        image.setSprite(sprite)
    end
    if type(data.color) == 'string' then
        _color.r, _color.g, _color.b, _color.a = engine.graphics.hexToColor(data.color)
    end
    if type(data.maskable) == 'boolean' then
        _isMaskable = data.maskable
    end
    if type(data.imageType) == 'string' then
        image.setImageType(data.imageType)
    end
    if type(data.overlay) == 'boolean' then
        image.setOverlay(data.overlay)
    end
end

function image.update()
    local w, h = image.object.getSize()
    if h == _objectHeight and w == _objectWidth then
        return
    end
    _objectWidth = w
    _objectHeight = h
    _quad:setViewport(0, 0, _objectWidth, _objectHeight)
end

function image.onDestroy()
    _isDestroyed = true
    _sprite = nil
    _quad = nil
end

image.draw = _draw

function image.setImageType(imageType)
    if type(imageType) ~= 'string' then
        engine.debug.logError('Invalid imageType type on image.')
        return
    end
    _isTiled = imageType == 'tiled'
end

function image.setOverlay(isOverlay)
    if type(isOverlay) ~= 'boolean' then
        engine.debug.logError('Invalid overlay type on image.')
        return
    end
    if isOverlay then
        image.overlay = _draw
        image.draw = nil
    else
        image.draw = _draw
        image.overlay = nil
    end
end

function image.setSprite(sprite)
    if _isDestroyed then
        return
    end
    if _sprite == sprite then
        return
    end
    if not engine.typeValidator.isSprite(sprite) then
        if sprite ~= nil then
            engine.debug.logError('Invalid sprite supplied to image.')
            return
        end
        sprite = _persist.defaultSprite
    end
    _sprite = sprite
    _spriteWidth = _sprite:getPixelWidth()
    _spriteHeight = _sprite:getPixelHeight()
    _quad = love.graphics.newQuad(0, 0, _objectWidth, _objectHeight, _spriteWidth, _spriteHeight)
end

function image.getSprite()
    if _sprite == _persist.defaultSprite then
        return nil
    end
    return _sprite
end

function image.setColor(r, g, b, a)
    if type(r) ~= 'number' or type(g) ~= 'number' or type(b) ~= 'number' then
        engine.debug.logError('Invalid color supplied to image.')
        return
    end
    if type(a) ~= 'number' then
        a = 1.0
    end
    _color.r = r
    _color.g = g
    _color.b = b
    _color.a = a
end

function image.getColor()
    return _color.r, _color.g, _color.b, _color.a
end

function image.setMaskable(isMaskable)
    if type(isMaskable) ~= 'boolean' then
        engine.debug.logError('Invalid setMaskable supplied to image.')
        return
    end
    _isMaskable = isMaskable
end

function image.getMaskable()
    return _isMaskable
end

return image