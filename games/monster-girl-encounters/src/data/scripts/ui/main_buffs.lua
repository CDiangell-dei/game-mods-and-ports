local mainBuffs = {}

local _buffs = {}
local _count = 0 -- MOD (buffs fix): highest slot in use, so icons can shift down on removal
local _uniqueId = 0

function mainBuffs.add(buff)
    local parent = game.object.getRoot().find('main/buffs/viewport/content')
    local buffObject = game.object.instantiate('data/scenes/main_buff.json', parent)
    _uniqueId = _uniqueId + 1
    buffObject.name = tostring(_uniqueId)
    game.object.setVisual(buffObject.find('mask/sprite'), buff.data.icon)
    _buffs[buff._index] = buffObject
    if buff._index > _count then
        _count = buff._index
    end
    local tooltip = nil
    local function enter()
        if tooltip ~= nil then
            tooltip.destroy()
        end
        tooltip = dofile('data/scripts/ui/tooltip.lua')
        tooltip.initActive(buff)
    end
    local function exit()
        if tooltip ~= nil then
            tooltip.destroy()
            tooltip = nil
        end
    end
    local button = dofile('data/scripts/ui/default_highlighter.lua')
    button.init(buffObject.find('mask'))
    buffObject.find('mask/sprite').getComponent('button').onMouseEnter.subscribe(enter)
    buffObject.find('mask/sprite').getComponent('button').onMouseExit.subscribe(exit)
    local fader = dofile('data/scripts/ui/dither_fader.lua')
    fader.init(buffObject.find('mask').getComponent('mask'), 0, false)
    fader.fadeTo(100, 0.3, nil)
end

function mainBuffs.remove(index)
    local buff = _buffs[index]
    -- MOD (buffs fix): keep the icon table aligned with the buffs holder (shift down)
    for i=index, _count - 1 do
        _buffs[i] = _buffs[i + 1]
    end
    _buffs[_count] = nil
    _count = math.max(_count - 1, 0)
    if buff ~= nil then
        local function complete()
            buff.destroy()
        end
        local fader = dofile('data/scripts/ui/dither_fader.lua')
        fader.init(buff.find('mask').getComponent('mask'), 100, false)
        fader.fadeTo(0, 0.3, complete)
    end
end

return mainBuffs