local rootObject = {
    name = 'root',
}

local _children = {}
local _workingChildren = {}

local function _repopulateWorkingTable()
    while #_workingChildren > 0 do
        table.remove(_workingChildren)
    end
    for i=1, #_children do
        _workingChildren[i] = _children[i]
    end
end

function rootObject.getParent()
    return rootObject
end

function rootObject.getChildCount()
    return #_children
end

function rootObject.getChild(index)
    return _children[index]
end

function rootObject.find(path)
    local startIndex, endIndex = string.find(path, '/')
    if startIndex then
        local child = string.sub(path, 1, startIndex - 1)
        local remainder = string.sub(path, endIndex + 1)
        local childObject = rootObject._findChildByName(child)
        if childObject == nil then
            return nil
        end
        return childObject.find(remainder)
    else
        return rootObject._findChildByName(path)
    end
end

function rootObject.isDestroyed()
    return false
end

function rootObject.addComponent()
    engine.debug.logWarning('Cannot add components to root object.')
end

function rootObject.removeComponent()
    engine.debug.logWarning('Cannot remove components from root object.')
end

function rootObject.getComponent()
    return nil
end

function rootObject.destroy()
    local count = #_children
    for i=count, 1, -1 do
        _children[i].destroy()
    end
    _children = {}
end

function rootObject.getPosition()
    return 0, 0
end

function rootObject.getActualPosition()
    return 0, 0
end

function rootObject.setPosition()
    engine.debug.logWarning('Cannot change position of root object.')
end

function rootObject.getSize()
    return 0, 0
end

function rootObject.setSize()
    engine.debug.logWarning('Cannot change size of root object.')
end

function rootObject.getPivot()
    return 0, 0
end

function rootObject.setPivot()
    engine.debug.logWarning('Cannot change pivot of root object.')
end

function rootObject._addChild(child)
    table.insert(_children, child)
end

function rootObject._findChildByName(name)
    if name == '..' then
        return rootObject
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

function rootObject._removeChild(child)
    local count = #_children
    for i=1, count do
        if child == _children[i] then
            table.remove(_children, i)
            return
        end
    end
end

function rootObject._update()
    _repopulateWorkingTable()
    local count = #_workingChildren
    for i=1, count do
        local child = _workingChildren[i]
        child._update()
    end
end

function rootObject._lateUpdate()
    _repopulateWorkingTable()
    local count = #_workingChildren
    for i=count, 1, -1 do
        local child = _workingChildren[i]
        child._lateUpdate()
    end
end

function rootObject._draw()
    _repopulateWorkingTable()
    local count = #_workingChildren
    for i=1, count do
        local child = _workingChildren[i]
        child._draw()
    end
end

function rootObject._overlay()
    _repopulateWorkingTable()
    local count = #_workingChildren
    for i=1, count do
        local child = _workingChildren[i]
        child._overlay()
    end
end

return rootObject