local buffsHolder = {}

local _holder = dofile('data/scripts/object_holder.lua')

function buffsHolder.trigger(eventId, ...)
    _holder.trigger(eventId, ...)
end

function buffsHolder.add(buffData)
    if buffData == nil then
        game.debug.logError('Could not add buff, buffData is nil.')
        return
    end
    local buff = dofile(buffData.script)
    buff.data = buffData
    _holder.add(buff)
    buff._index = _holder.count()
    game.control.trigger('onAddBuff', buff)
    buff._ready = true
    game.control.ui.addBuff(buff)
    if buff.init ~= nil then
        buff.init()
    end
end

function buffsHolder.remove(buff)
    local index = buff._index
    if index == nil or index == 0 then
        return
    end
    -- MOD (buffs fix): confirm the slot really holds this buff before touching the list
    if _holder.get(index) ~= buff then
        index = 0
        for i=1, _holder.count() do
            if _holder.get(i) == buff then
                index = i
                break
            end
        end
        if index == 0 then
            return
        end
    end
    buff._ready = false
    game.control.trigger('onRemoveBuff', buff)
    if buff.onDestroy ~= nil then
        buff.onDestroy()
    end
    game.control.ui.removeBuff(index)
    buff._index = 0
    -- MOD (buffs fix): object_holder.remove only pops the LAST slot, so the buffs after the
    -- removed one must be shifted down by hand. Before this, removing a temporary buff that sat
    -- before a blessing dropped the blessing from the list (it stopped working) and kept the
    -- expired buff alive.
    local count = _holder.count()
    for i=index, count - 1 do
        local movedBuff = _holder.get(i + 1)
        _holder.set(i, movedBuff)
        movedBuff._index = i
    end
    _holder.remove(count)
end

function buffsHolder.getCount()
    return _holder.count()
end

function buffsHolder.getBuff(index)
    return _holder.get(index)
end

return buffsHolder
