local grid = {
    type = 'GridLayoutGroup',
}

local _spacing = {
    x = 0,
    y = 0,
}
local _size = {
    x = 100,
    y = 100,
}
local _startCorner = 'upperLeft'
local _startAxis = 'horizontal'
local _constraint = 'flexible'
local _constraintCount = 1
local _controlVerticalSize = false
local _controlHorizontalSize = false

local function _getDimensions()
    local count = grid.object.getChildCount()
    if count <= 1 then
        return 1, 1
    end
    if _constraint == 'fixedColumnCount' then
        if _constraintCount < 1 then
            return 1, count
        end
        local rows = math.ceil(count / _constraintCount)
        return _constraintCount, rows
    elseif _constraint == 'fixedRowCount' then
        if _constraintCount < 1 then
            return count, 1
        end
        local columns = math.ceil(count / _constraintCount)
        return columns, _constraintCount
    elseif _startAxis == 'vertical' then
        local _, y = grid.object.getSize()
        if _size.y <= 0 or y <= 0 then
            return count, 1
        end
        local rows = 0
        local remaining = y
        while remaining > 0 do
            remaining = remaining - _size.y
            rows = rows + 1
            remaining = remaining - _spacing.y
        end
        local columns = math.ceil(count / rows)
        return columns, rows
    else
        local x, _ = grid.object.getSize()
        if _size.x <= 0 or x <= 0 then
            return 1, count
        end
        local columns = 0
        local remaining = x
        while remaining > 0 do
            remaining = remaining - _size.x
            columns = columns + 1
            remaining = remaining - _spacing.x
        end
        local rows = math.ceil(count / columns)
        return columns, rows
    end
end

local function _iterateHorizontal(xStart, yStart, xIncrement, yIncrement)
    local width, height = _getDimensions()
    local xPos = xStart
    local yPos = yStart
    for y=1, height do
        for x=1, width do
            local index = x + ((y - 1) * width)
            local child = grid.object.getChild(index)
            if child ~= nil then
                child.setPosition(xPos, yPos)
                child.setSize(_size.x, _size.y)
            end
            xPos = xPos + xIncrement
        end
        yPos = yPos + yIncrement
        xPos = xStart
    end
    local w, h = grid.object.getSize()
    if _controlHorizontalSize then
        w = (width * _size.x) + ((width - 1) * _spacing.x)
    end
    if _controlVerticalSize then
        h = (height * _size.y) + ((height - 1) * _spacing.y)
    end
    grid.object.setSize(w, h)
end

local function _iterateVertical(xStart, yStart, xIncrement, yIncrement)
    local width, height = _getDimensions()
    local xPos = xStart
    local yPos = yStart
    for x=1, width do
        for y=1, height do
            local index = y + ((x - 1) * height)
            local child = grid.object.getChild(index)
            if child ~= nil then
                child.setPosition(xPos, yPos)
                child.setSize(_size.x, _size.y)
            end
            yPos = yPos + yIncrement
        end
        xPos = xPos + xIncrement
        yPos = yStart
    end
    local w, h = grid.object.getSize()
    if _controlHorizontalSize then
        w = (width * _size.x) + ((width - 1) * _spacing.x)
    end
    if _controlVerticalSize then
        h = (height * _size.y) + ((height - 1) * _spacing.y)
    end
    grid.object.setSize(w, h)
end

local function _alignToUpperLeftHorizontal()
    local xIncrement = _spacing.x + _size.x
    local yIncrement = _spacing.y + _size.y
    _iterateHorizontal(0, 0, xIncrement, yIncrement)
end

local function _alignToUpperRightHorizontal()
    local w, _ = grid.object.getSize()
    local xStart = w - _size.x
    local xIncrement = -(_spacing.x + _size.x)
    local yIncrement = _spacing.y + _size.y
    _iterateHorizontal(xStart, 0, xIncrement, yIncrement)
end

local function _alignToLowerLeftHorizontal()
    local _, h = grid.object.getSize()
    local yStart = h - _size.y
    local xIncrement = _spacing.x + _size.x
    local yIncrement = -(_spacing.y + _size.y)
    _iterateHorizontal(0, yStart, xIncrement, yIncrement)
end

local function _alignToLowerRightHorizontal()
    local w, h = grid.object.getSize()
    local xStart = w - _size.x
    local yStart = h - _size.y
    local xIncrement = -(_spacing.x + _size.x)
    local yIncrement = -(_spacing.y + _size.y)
    _iterateHorizontal(xStart, yStart, xIncrement, yIncrement)
end

local function _alignToUpperLeftVertical()
    local xIncrement = _spacing.x + _size.x
    local yIncrement = _spacing.y + _size.y
    _iterateVertical(0, 0, xIncrement, yIncrement)
end

local function _alignToUpperRightVertical()
    local w, _ = grid.object.getSize()
    local xStart = w - _size.x
    local xIncrement = -(_spacing.x + _size.x)
    local yIncrement = _spacing.y + _size.y
    _iterateVertical(xStart, 0, xIncrement, yIncrement)
end

local function _alignToLowerLeftVertical()
    local _, h = grid.object.getSize()
    local yStart = h - _size.y
    local xIncrement = _spacing.x + _size.x
    local yIncrement = -(_spacing.y + _size.y)
    _iterateVertical(0, yStart, xIncrement, yIncrement)
end

local function _alignToLowerRightVertical()
    local w, h = grid.object.getSize()
    local xStart = w - _size.x
    local yStart = h - _size.y
    local xIncrement = -(_spacing.x + _size.x)
    local yIncrement = -(_spacing.y + _size.y)
    _iterateVertical(xStart, yStart, xIncrement, yIncrement)
end

local function _setHorizontalUpdate()
    if _startCorner == 'upperRight' then
        grid.lateUpdate = _alignToUpperRightHorizontal
    elseif _startCorner == 'lowerLeft' then
        grid.lateUpdate = _alignToLowerLeftHorizontal
    elseif _startCorner == 'lowerRight' then
        grid.lateUpdate = _alignToLowerRightHorizontal
    else
        grid.lateUpdate = _alignToUpperLeftHorizontal
    end
end

local function _setVerticalUpdate()
    if _startCorner == 'upperRight' then
        grid.lateUpdate = _alignToUpperRightVertical
    elseif _startCorner == 'lowerLeft' then
        grid.lateUpdate = _alignToLowerLeftVertical
    elseif _startCorner == 'lowerRight' then
        grid.lateUpdate = _alignToLowerRightVertical
    else
        grid.lateUpdate = _alignToUpperLeftVertical
    end
end

local function _setUpdate()
    if _startAxis == 'vertical' then
        _setVerticalUpdate()
    else
        _setHorizontalUpdate()
    end
end

function grid.populateFromData(data)
    if type(data.spacing) == 'table' then
        if type(data.spacing.x) == 'number' then
            _spacing.x = data.spacing.x
        end
        if type(data.spacing.y) == 'number' then
            _spacing.y = data.spacing.y
        end
    end
    if type(data.cellSize) == 'table' then
        if type(data.cellSize.x) == 'number' then
             _size.x = data.cellSize.x
        end
        if type(data.cellSize.y) == 'number' then
             _size.y = data.cellSize.y
        end
    end
    if type(data.controlVerticalSize) == 'boolean' then
        _controlVerticalSize = data.controlVerticalSize
    end
    if type(data.controlHorizontalSize) == 'boolean' then
        _controlHorizontalSize = data.controlHorizontalSize
    end
    if type(data.startCorner) == 'string' then
        _startCorner = data.startCorner
    end
    if type(data.startAxis) == 'string' then
        _startAxis = data.startAxis
    end
    if type(data.constraint) == 'string' then
        _constraint = data.constraint
    end
    if type(data.constraintCount) == 'number' then
        _constraintCount = data.constraintCount
    end
    _setUpdate()
end

grid.lateUpdate = _alignToUpperLeftHorizontal

function grid.setSpacing(x, y)
    if type(x) ~= 'number' then
        engine.debug.logError('Invalid x spacing for gridLayoutGroup.')
        return
    end
    if type(y) ~= 'number' then
        engine.debug.logError('Invalid y spacing for gridLayoutGroup.')
        return
    end
    _spacing.x = x
    _spacing.y = y
end

function grid.setCellSize(x, y)
    if type(x) ~= 'number' then
        engine.debug.logError('Invalid x cell size for gridLayoutGroup.')
        return
    end
    if type(y) ~= 'number' then
        engine.debug.logError('Invalid y cell size for gridLayoutGroup.')
        return
    end
    _size.x = x
    _size.y = y
end

function grid.setStartCorner(corner)
    if type(corner) ~= 'string' then
        engine.debug.logError('Invalid startCorner type for gridLayoutGroup.')
        return
    end
    _startCorner = corner
    _setUpdate()
end

function grid.setStartAxis(axis)
    if type(axis) ~= 'string' then
        engine.debug.logError('Invalid axis type for gridLayoutGroup.')
        return
    end
    _startAxis = axis
    _setUpdate()
end

function grid.setConstraint(constraint)
    if type(constraint) ~= 'string' then
        engine.debug.logError('Invalid constraint type for gridLayoutGroup.')
        return
    end
    _constraint = constraint
end

function grid.setConstraintCount(count)
    if type(count) ~= 'number' then
        engine.debug.logError('Invalid constraint count type for gridLayoutGroup.')
        return
    end
    _constraintCount = count
end

function grid.setControlVerticalSize(controlSize)
    if type(controlSize) ~= 'boolean' then
        engine.debug.logError('Invalid setControlVerticalSize type for gridLayoutGroup.')
        return
    end
    _controlVerticalSize = controlSize
end

function grid.setControlHorizontalSize(controlSize)
    if type(controlSize) ~= 'boolean' then
        engine.debug.logError('Invalid setControlHorizontalSize type for gridLayoutGroup.')
        return
    end
    _controlHorizontalSize = controlSize
end

return grid