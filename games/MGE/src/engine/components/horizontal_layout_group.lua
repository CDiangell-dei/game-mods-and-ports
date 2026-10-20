local horizontalLayout = {
    type = 'HorizontalLayoutGroup',
}

local _spacing = 0
local _reverse = false
local _expand = false
local _fitChildWidth = false
local _fitChildHeight = false
local _controlObjectSize = false

local function _placeChild(i, x, widthOverride, heightOverride)
    local child = horizontalLayout.object.getChild(i)
    local _, y = child.getPosition()
    child.setPosition(x, y)
    local w, h = child.getSize()
    local setW = widthOverride or w
    local setH = heightOverride or h
    child.setSize(setW, setH)
    return x + setW
end

local function _placeChildrenDefault(spacing, widthOverride, heightOverride)
    local count = horizontalLayout.object.getChildCount()
    local x = 0
    for i=1, count do
        x = _placeChild(i, x, widthOverride, heightOverride)
        x = x + spacing
    end
end

local function _placeChildrenReversed(spacing, widthOverride, heightOverride)
    local count = horizontalLayout.object.getChildCount()
    local x = 0
    for i=count, 1, -1 do
        x = _placeChild(i, x, widthOverride, heightOverride)
        x = x + spacing
    end
end

local function _calculateSpacingDefault()
    return _spacing
end

local function _calculateSpacingAndFit()
    local count = horizontalLayout.object.getChildCount()
    local size = 0
    for i=1, count do
        local child = horizontalLayout.object.getChild(i)
        local childW, _ = child.getSize()
        size = size + childW + _spacing
    end
    size = size - _spacing
    local _, h = horizontalLayout.object.getSize()
    horizontalLayout.object.setSize(size, h)
    return _spacing
end

local function _calculateSpacingExpanded()
    local count = horizontalLayout.object.getChildCount()
    local size = 0
    for i=1, count do
        local child = horizontalLayout.object.getChild(i)
        local childW, _ = child.getSize()
        size = size + childW
    end
    local w, _ = horizontalLayout.object.getSize()
    if size >= w then
        return _spacing
    end
    local spacing = (w - size) / (count - 1)
    if spacing < _spacing then
        spacing = _spacing
    end
    return spacing
end

local function _ignoreOverride()
    return nil
end

local function _overrideWidth()
    local count = horizontalLayout.object.getChildCount()
    local w, _ = horizontalLayout.object.getSize()
    local size = w - ((_spacing) * (count - 1))
    return size / count
end

local function _overrideHeight()
    local _, h = horizontalLayout.object.getSize()
    return h
end

local _placeChildren = _placeChildrenDefault
local _tryOverrideWidth = _ignoreOverride
local _tryOverrideHeight = _ignoreOverride
local _calculateSpacing = _calculateSpacingDefault

local function _setUpdate()
    if _reverse then
        _placeChildren = _placeChildrenReversed
    else
        _placeChildren = _placeChildrenDefault
    end

    if _fitChildWidth then
        _tryOverrideWidth = _overrideWidth
    else
        _tryOverrideWidth = _ignoreOverride
    end

    if _fitChildHeight then
        _tryOverrideHeight = _overrideHeight
    else
        _tryOverrideHeight = _ignoreOverride
    end

    if _controlObjectSize then
        _calculateSpacing = _calculateSpacingAndFit
    elseif _expand then
        _calculateSpacing = _calculateSpacingExpanded
    else
        _calculateSpacing = _calculateSpacingDefault
    end
end

function horizontalLayout.populateFromData(data)
    if type(data.spacing) == 'number' then
        _spacing = data.spacing
    end
    if type(data.reverse) == 'boolean' then
        _reverse = data.reverse
    end
    if type(data.expand) == 'boolean' then
        _expand = data.expand
    end
    if type(data.controlChildWidth) == 'boolean' then
        _fitChildWidth = data.controlChildWidth
    end
    if type(data.controlChildHeight) == 'boolean' then
        _fitChildHeight = data.controlChildHeight
    end
    if type(data.controlObjectSize) == 'boolean' then
        _controlObjectSize = data.controlObjectSize
    end
    _setUpdate()
end

function horizontalLayout.lateUpdate()
    local spacing = _calculateSpacing()
    local widthOverride = _tryOverrideWidth()
    local heightOverride = _tryOverrideHeight()
    _placeChildren(spacing, widthOverride, heightOverride)
end

function horizontalLayout.setSpacing(spacing)
    if type(spacing) ~= 'number' then
        engine.debug.logError('Invalid setSpacing for horizontalLayoutGroup.')
        return
    end
    _spacing = spacing or 0
    _setUpdate()
end

function horizontalLayout.setReverse(reverse)
    if type(reverse) ~= 'boolean' then
        engine.debug.logError('Invalid setReverse for horizontalLayoutGroup.')
        return
    end
    _reverse = reverse or false
    _setUpdate()
end

function horizontalLayout.setExpand(expand)
    if type(expand) ~= 'boolean' then
        engine.debug.logError('Invalid setExpand for horizontalLayoutGroup.')
        return
    end
    _expand = expand or false
    _setUpdate()
end

function horizontalLayout.setFitChildWidth(fit)
    if type(fit) ~= 'boolean' then
        engine.debug.logError('Invalid setFitChildWidth for horizontalLayoutGroup.')
        return
    end
    _fitChildWidth = fit or false
    _setUpdate()
end

function horizontalLayout.setFitChildHeight(fit)
    if type(fit) ~= 'boolean' then
        engine.debug.logError('Invalid setFitChildHeight for horizontalLayoutGroup.')
        return
    end
    _fitChildHeight = fit or false
    _setUpdate()
end

function horizontalLayout.setControlObjectSize(controlSize)
    if type(controlSize) ~= 'boolean' then
        engine.debug.logError('Invalid setControlObjectSize for horizontalLayoutGroup.')
        return
    end
    _controlObjectSize = controlSize
    _setUpdate()
end

return horizontalLayout