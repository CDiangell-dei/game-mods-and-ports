local mask = {
    type = 'Mask',
}

local _isDestroyed = false
local _color = {
    r = 1.0,
    g = 1.0,
    b = 1.0,
    a = 1.0,
}
local _persist = engine.require('engine/components/persistent_data.lua')
local _sprite = _persist.defaultSprite
local _spriteHeight = 4
local _spriteWidth = 4
local _objectHeight = 1
local _objectWidth = 1
local _quad = love.graphics.newQuad(0, 0, _objectWidth, _objectHeight, _spriteWidth, _spriteHeight)
local _isTiled = false

local function _testTiled()
    local x, y = mask.object.getActualPosition()
    love.graphics.setColor(_color.r, _color.g, _color.b, _color.a)
    love.graphics.setShader(_persist.maskShader)
    local offsetX, offsetY = engine.graphics.getScaledOffset()
    love.graphics.draw(_sprite, _quad, x + offsetX, y + offsetY)
    love.graphics.setShader()
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
end

local function _testSimple()
    local x, y = mask.object.getActualPosition()
    local sx, sy = mask.object.getSize()
    love.graphics.setColor(_color.r, _color.g, _color.b, _color.a)
    love.graphics.setShader(_persist.maskShader)
    local offsetX, offsetY = engine.graphics.getScaledOffset()
    love.graphics.draw(_sprite, x + offsetX, y + offsetY, 0, sx / _spriteWidth, sy / _spriteHeight)
    love.graphics.setShader()
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
end

local function _draw()
    if _isTiled then
        love.graphics.stencil(_testTiled, 'increment', 1, true)
    else
        love.graphics.stencil(_testSimple, 'increment', 1, true)
    end
    _persist.maskCount = _persist.maskCount + 1
end

local function _endDraw()
    if _isTiled then
        love.graphics.stencil(_testTiled, 'decrement', 1, true)
    else
        love.graphics.stencil(_testSimple, 'decrement', 1, true)
    end
    _persist.maskCount = _persist.maskCount - 1
end

function mask.populateFromData(data)
    if type(data.sprite) == 'string' then
        local sprite = engine.fileSystem.loadSprite(data.sprite)
        mask.setSprite(sprite)
    end
    if type(data.imageType) == 'string' then
        mask.setImageType(data.imageType)
    end
    if type(data.alpha) == 'number' then
        _color.a = data.alpha
    end
    if type(data.overlay) == 'boolean' then
        mask.setOverlay(data.overlay)
    end
end

function mask.update()
    local w, h = mask.object.getSize()
    if h == _objectHeight and w == _objectWidth then
        return
    end
    _objectWidth = w
    _objectHeight = h
    _quad:setViewport(0, 0, _objectWidth, _objectHeight)
end

function mask.onDestroy()
    _isDestroyed = true
    _sprite = nil
    _quad = nil
end

mask.draw = _draw
mask.endDraw = _endDraw

function mask.setImageType(imageType)
    if type(imageType) ~= 'string' then
        engine.debug.logError('Invalid imageType supplied to mask.')
        return
    end
    _isTiled = imageType == 'tiled'
end

function mask.setOverlay(isOverlay)
    if type(isOverlay) ~= 'boolean' then
        engine.debug.logError('Invalid setOverlay supplied to mask.')
        return
    end
    if isOverlay then
        mask.overlay = _draw
        mask.endOverlay = _endDraw
        mask.draw = nil
        mask.endDraw = nil
    else
        mask.draw = _draw
        mask.endDraw = _endDraw
        mask.overlay = nil
        mask.endOverlay = nil
    end
end

function mask.setSprite(sprite)
    if _isDestroyed then
        return
    end
    if _sprite == sprite then
        return
    end
    if not engine.typeValidator.isSprite(sprite) then
        if sprite ~= nil then
            engine.debug.logError('Invalid sprite supplied to mask.')
            return
        end
        sprite = _persist.defaultSprite
    end
    _sprite = sprite
    _spriteWidth = _sprite:getPixelWidth()
    _spriteHeight = _sprite:getPixelHeight()
    _quad = love.graphics.newQuad(0, 0, _objectWidth, _objectHeight, _spriteWidth, _spriteHeight)
end

function mask.getSprite()
    if _sprite == _persist.defaultSprite then
        return nil
    end
    return _sprite
end

function mask.setAlpha(a)
    if type(a) ~= 'number' then
        engine.debug.logError('Invalid alpha supplied to mask.')
        return
    end
    _color.a = a or 1.0
end

function mask.getAlpha()
    return _color.a
end

return mask