local simpleTooltip = {}

local _activeTooltip = nil
local _hasInit = false

local function _updatePosition()
    if _activeTooltip == nil then
        return
    end
    local x, y = game.input.getMousePosition()
    if x > game.config.canvasWidth - 5 then
        x = game.config.canvasWidth - 5
    end
    if x < 5 then
        x = 5
    end
    if y > game.config.canvasHeight - 5 then
        y = game.config.canvasHeight - 5
    end
    if y < 5 then
        y = 5
    end
    _activeTooltip.setPosition(x, y)
end

local function _setSize(path, width)
    local child = _activeTooltip.find(path)
    if child == nil then
        return
    end
    local _, h = child.getSize()
    child.setSize(width, h)
end

local function _overrideTooltipWidth(width)
    if width == nil or _activeTooltip == nil then
        return
    end
    local _, h = _activeTooltip.getSize()
    _activeTooltip.setSize(width, h)
    _setSize('border1', width)
    _setSize('spacing1', width - 2)
    _setSize('description', width - 2)
    _setSize('description/view', width - 4)
    _setSize('description/view/spacing1', width - 4)
    _setSize('description/view/text', width - 22)
    _setSize('description/view/spacing2', width - 4)
    _setSize('spacing2', width - 2)
    _setSize('border2', width)
end

local function _spawnTooltip(text, widthOverride)
    _activeTooltip = game.object.instantiate('data/scenes/simple_tooltip.json')
    _overrideTooltipWidth(widthOverride)
    _activeTooltip.find('description/view/text').getComponent('text').setText(text)
    local x, y = game.input.getMousePosition()
    local pivotX = 0
    if x > game.config.canvasWidth * 0.5 then
        pivotX = 1
    end
    local pivotY = 0
    if y > game.config.canvasHeight * 0.5 then
        pivotY = 1
    end
    _activeTooltip.setPivot(pivotX, pivotY)
    _updatePosition()
end

function simpleTooltip.init(text, widthOverride)
    if _hasInit then
        return
    end
    _hasInit = true
    _spawnTooltip(text, widthOverride)
    game.events.subscribe('update', _updatePosition)
end

function simpleTooltip.destroy()
    if _activeTooltip ~= nil then
        _activeTooltip.destroy()
        _activeTooltip = nil
    end
    game.events.unsubscribe('update', _updatePosition)
end

return simpleTooltip