local objectManager = {}

local _world = engine.dofile('engine/root_object.lua')
local _spawnPrefab

local function _tryGetPrefab(prefabData)
    if type(prefabData.prefab) ~= 'string' then
        return nil
    end
    local prefab = engine.fileSystem.loadJson(prefabData.prefab)
    if prefab == nil then
        engine.debug.logWarning('Prefab not found within prefab for key: ' .. prefabData.prefab)
        return nil
    end
    return prefab
end

local function _getOrCreatePrefabObject(prefabData, parent, pendingComponents, existingObject)
    local subPrefab = _tryGetPrefab(prefabData)
    local object
    local isPrefab = false
    if subPrefab ~= nil then
        object = _spawnPrefab(subPrefab, parent, pendingComponents)
        isPrefab = true
    elseif existingObject == nil then
        object = objectManager.new(parent)
    else
        object = existingObject
    end
    return object, isPrefab
end

local function _populateObjectData(object, data, pendingComponents)
    if type(data.name) == 'string' then
        object.name = data.name
    end
    if type(data.position) == 'table' then
        local x = 0
        local y = 0
        if type(data.position.x) == 'number' then
            x = data.position.x
        end
        if type(data.position.y) == 'number' then
            y = data.position.y
        end
        object.setPosition(x, y)
    end
    if type(data.size) == 'table' then
        local x = 0
        local y = 0
        if type(data.size.x) == 'number' then
            x = data.size.x
        end
        if type(data.size.y) == 'number' then
            y = data.size.y
        end
        object.setSize(x, y)
    end
    if type(data.pivot) == 'table' then
        local x = 0
        local y = 0
        if type(data.pivot.x) == 'number' then
            x = data.pivot.x
        end
        if type(data.pivot.y) == 'number' then
            y = data.pivot.y
        end
        object.setPivot(x, y)
    end
    if type(data.components) == 'table' then
        for _, component in ipairs(data.components) do
            local pending = {
                object = object,
                data = component,
            }
            table.insert(pendingComponents, pending)
        end
    end
end

local function _iteratePrefabChildren(prefabData, parent, pendingComponents)
    if type(prefabData.children) ~= 'table' then
        return
    end
    for _, child in ipairs(prefabData.children) do
        if type(child) == 'table' then
            _spawnPrefab(child, parent, pendingComponents)
        end
    end
end

local function _appendChildrenData(prefabData, parent, pendingComponents)
    if type(prefabData.children) ~= 'table' then
        return
    end
    for _, child in ipairs(prefabData.children) do
        if type(child) == 'table' then
            if type(child.name) == 'string' then
                local childObject = parent._findChildByName(child.name)
                if childObject ~= nil then
                    _spawnPrefab(child, parent, pendingComponents, childObject)
                end
            end
        end
    end
end

_spawnPrefab = function(prefabData, parent, pendingComponents, existingObject)
    local object, isPrefab = _getOrCreatePrefabObject(prefabData, parent, pendingComponents, existingObject)
    _populateObjectData(object, prefabData, pendingComponents)
    if isPrefab or existingObject ~= nil then
        _appendChildrenData(prefabData, object, pendingComponents)
    else
        _iteratePrefabChildren(prefabData, object, pendingComponents)
    end
    return object
end

local function _instantiatePrefab(prefab, parent)
    parent = parent or engine.objectManager.getRoot()
    local pendingComponents = {}

    local prefabObject = _spawnPrefab(prefab, parent, pendingComponents)
    local pendingCount = #pendingComponents
    for i=1, pendingCount do
        local componentData = pendingComponents[i].data
        local object = pendingComponents[i].object
        local component = object._addComponentWithoutStart(componentData.type)
        component.populateFromData(componentData)
    end
    --Populate / start from furthest down hierarchy to top
    for i=pendingCount, 1, -1 do
        local object  = pendingComponents[i].object
        local componentData = pendingComponents[i].data
        local component = object.getComponent(componentData.type)
        if component ~= nil then
            if component.start ~= nil and not component._started then
                component.start()
                component._started = true
            end
        end
    end
    return prefabObject
end

function objectManager.new(parent)
    if not engine.typeValidator.isGameType('Object', parent) then
        parent = nil
    end
    local object = engine.dofile('engine/object.lua')
    object.init(parent)
    return object
end

function objectManager.instantiate(key, parent)
    if type(key) ~= 'string' then
        return nil
    end
    if not engine.typeValidator.isGameType('Object', parent) then
        parent = nil
    end
    local prefab = engine.fileSystem.loadJson(key)
    if prefab == nil then
        engine.debug.logWarning('Prefab not found for key: ' .. tostring(key))
        return nil
    end
    return _instantiatePrefab(prefab, parent)
end

function objectManager.getRoot()
    return _world
end

function objectManager.setVisual(object, visual)
    if not engine.typeValidator.isGameType('Object', object) then
        return
    end
    if type(visual) ~= 'string' then
        return
    end
    local isAnimation = engine.string.endsWith(visual, '.json')
    local animator = object.getComponent('animator')
    if isAnimation then
        if animator == nil then
            return
        end
        local animation = engine.fileSystem.loadAnimation(visual)
        animator.play(animation)
    else
        local image = object.getComponent('image')
        if image == nil then
            return
        end
        if animator ~= nil then
            animator.stop()
        end
        local sprite = engine.fileSystem.loadSprite(visual)
        image.setSprite(sprite)
    end
end

objectManager.update = _world._update
objectManager.lateUpdate = _world._lateUpdate
objectManager.draw = _world._draw
objectManager.overlay = _world._overlay

return objectManager
