local object = {
    type = "Object",
    name = 'object',
}

local _componentFactory = engine.require('engine/component_factory.lua')
local _parent
local _children = {}
local _workingChildren = {}
local _components = {}
local _isDestroyed = false
local _actualPosition = {
    x = 0,
    y = 0,
}
local _position = {
    x = 0,
    y = 0,
}
local _size = {
    x = 0,
    y = 0,
}
local _pivot = {
    x = 0,
    y = 0,
}
local _start = 0 --prevents objects that somehow spawn between late update and draw to wait for update until drawing

local function _updatePosition()
    local posX, posY = _parent.getActualPosition()
    local x = posX - (_size.x * _pivot.x) + _position.x
    local y = posY - (_size.y * _pivot.y) + _position.y
    _actualPosition.x = math.floor(x + 0.5)
    _actualPosition.y = math.floor(y + 0.5)
end

local function _repopulateWorkingTable()
    while #_workingChildren > 0 do
        table.remove(_workingChildren)
    end
    for i=1, #_children do
        _workingChildren[i] = _children[i]
    end
end

function object.init(parent)
    _parent = parent or engine.objectManager.getRoot()
    _parent._addChild(object)
end

function object.getParent()
    return _parent
end

function object.getChildCount()
    return #_children
end

function object.getChild(index)
    if type(index) ~= 'number' then
        return nil
    end
    return _children[index]
end

function object.find(path)
    if type(path) ~= 'string' then
        return nil
    end
    local startIndex, endIndex = string.find(path, '/')
    if startIndex then
        local child = string.sub(path, 1, startIndex - 1)
        local remainder = string.sub(path, endIndex + 1)
        local childObject = object._findChildByName(child)
        if childObject == nil then
            return nil
        end
        return childObject.find(remainder)
    else
        return object._findChildByName(path)
    end
end

function object.isDestroyed()
    return _isDestroyed
end

function object._addComponentWithoutStart(type)
    if _components == nil then
        return nil, false
    end
    if _components[type] ~= nil then
        return _components[type], true
    end
    local component = _componentFactory.instantiate(type, object)
    _components[type] = component
    return component, false
end

function object.addComponent(componentType)
    if type(componentType) ~= 'string' then
        engine.debug.logError('Invalid component type.')
        return nil
    end
    local component, hasStarted = object._addComponentWithoutStart(componentType)
    if component == nil or hasStarted then
        return component
    end
    if component.start ~= nil then
        component.start()
    end
    return component
end

function object.removeComponent(componentType)
    if type(componentType) ~= 'string' then
        return
    end
    if _components == nil then
        return
    end
    local component = _components[componentType]
    if component ~= nil then
        if component.onDestroy then
            component.onDestroy()
        end
        component._destroyed = true
    end
    _components[componentType] = nil
end

function object.getComponent(componentType)
    if type(componentType) ~= 'string' then
        return
    end
    if _components == nil then
        return nil
    end
    return _components[componentType]
end

function object.destroy()
    if _isDestroyed then
        return
    end
    _isDestroyed = true
    local count = #_children
    for i=count, 1, -1 do
        local child = _children[i]
        if child ~= nil then
            child.destroy()
        end
    end
    _children = {}
    for _, component in pairs(_components) do
        if component.onDestroy then
            component.onDestroy()
        end
        component._destroyed = true
    end
    _components = {}
    _parent._removeChild(object)
    _parent = nil
end

function object.getPosition()
    return _position.x, _position.y
end

function object.getActualPosition()
    return _actualPosition.x, _actualPosition.y
end

function object.setPosition(x, y)
    if _isDestroyed then
        return
    end
    if type(x) ~= 'number' or type(y) ~= 'number' then
        return
    end
    _position.x = x
    _position.y = y
    _updatePosition()
end

function object.getSize()
    return _size.x, _size.y
end

function object.setSize(x, y)
    if _isDestroyed then
        return
    end
    if type(x) ~= 'number' or type(y) ~= 'number' then
        return
    end
    _size.x = math.floor(x + 0.5)
    _size.y = math.floor(y + 0.5)
    _updatePosition()
end

function object.getPivot()
    return _pivot.x, _pivot.y
end

function object.setPivot(x, y)
    if _isDestroyed then
        return
    end
    if type(x) ~= 'number' or type(y) ~= 'number' then
        return
    end
    _pivot.x = x
    _pivot.y = y
    _updatePosition()
end

function object._addChild(child)
    if _isDestroyed then
        return
    end
    table.insert(_children, child)
end

function object._findChildByName(name)
    if name == '..' then
        return _parent
    end
    local count = #_children
    for i=1, count do
        local child = _children[i]
        if child.name == name then
            return child
        end
    end
    return nil
end

function object._removeChild(child)
    local count = #_children
    for i=1, count do
        if _children[i] == child then
            table.remove(_children, i)
            return
        end
    end
end

function object._update()
    _start = _start + 1
    if _isDestroyed then
        return
    end
    _updatePosition()
    for _, component in pairs(_components) do
        if component.update and not component._destroyed then
            component.update()
        end
    end
    _repopulateWorkingTable()
    local count = #_workingChildren
    for i=1, count do
        local child = _workingChildren[i]
        child._update()
    end
end

function object._lateUpdate()
    if _isDestroyed then
        return
    end
    _repopulateWorkingTable()
    local count = #_workingChildren
    for i=count, 1, -1 do
        local child = _workingChildren[i]
        child._lateUpdate()
    end
    for _, component in pairs(_components) do
        if component.lateUpdate and not component._destroyed then
            component.lateUpdate()
        end
    end
end

function object._draw()
    if _isDestroyed or _start < 1 then
        return
    end
    _updatePosition()
    for _, component in pairs(_components) do
        if component.draw then
            component.draw()
        end
    end
    _repopulateWorkingTable()
    local count = #_workingChildren
    for i=1, count do
        local child = _workingChildren[i]
        child._draw()
    end
    for _, component in pairs(_components) do
        if component.endDraw then
            component.endDraw()
        end
    end
end

function object._overlay()
    if _isDestroyed or _start < 1 then
        return
    end
    for _, component in pairs(_components) do
        if component.overlay then
            component.overlay()
        end
    end
    _repopulateWorkingTable()
    local count = #_workingChildren
    for i=1, count do
        local child = _workingChildren[i]
        child._overlay()
    end
    for _, component in pairs(_components) do
        if component.endOverlay then
            component.endOverlay()
        end
    end
end

return object