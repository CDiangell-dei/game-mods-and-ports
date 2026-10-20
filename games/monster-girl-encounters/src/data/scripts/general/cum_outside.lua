local _count = 0
local _onComplete = nil

local function _cum()
    _count = _count + 1
    if _count > 3 then
        if _onComplete ~= nil then
            local onComplete = _onComplete
            _onComplete = nil
            onComplete()
        end
        return
    end

    local function fadeIn()
        game.control.ui.fadeIn(_cum, 0.5)
    end

    game.control.ui.fadeToWhite(nil, 0.2)
    game.timer.queue(0.3, fadeIn)
end

game.audio.playSound('data/sounds/sex/cum_outside.json')
_cum()

local function _init(onComplete)
    _onComplete = onComplete
end

return _init