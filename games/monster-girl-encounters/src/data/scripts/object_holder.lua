local objectHolder = {}

local _objects = {}
local _count = 0

local function _copyTableForSafeIteration()
    local temp = {}
    for i=1, _count do
        table.insert(temp, _objects[i])
    end
    return temp
end

function objectHolder.add(value)
    _count = _count + 1
    _objects[_count] = value
end

function objectHolder.remove(index)
    if index > _count or index < 1 then
        game.debug.logWarning('Could not remove object, index ' .. tostring(index) .. ' out of range.')
        return
    end
    _objects[_count] = nil
    _count = _count - 1
end

function objectHolder.get(index)
    return _objects[index]
end

function objectHolder.count()
    return _count
end

function objectHolder.set(index, value)
    if index > _count or index < 1 then
        game.debug.logWarning('Could not set object, index ' .. tostring(index) .. ' out of range.')
        return
    end
    _objects[index] = value
end

function objectHolder.trigger(eventId, ...)
    local temp = _copyTableForSafeIteration()
    for _, v in ipairs(temp) do
        if v ~= nil and v._ready == true and v[eventId] ~= nil then
            -- MOD (safety net): an error in one item/mod must not cancel the event for everyone
            -- else (before this, one failing pump left the battle stuck with 0 EPP)
            local ok, err = pcall(v[eventId], ...)
            if not ok then
                local key = (v.data ~= nil and v.data.key) or '?'
                game.debug.logError('Item ' .. tostring(key) .. ' failed on ' .. tostring(eventId) .. ': ' .. tostring(err))
            end
        end
    end
end

return objectHolder
