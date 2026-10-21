local endlessPrompt = {}

local _object = nil

function endlessPrompt.init(onContinueEndless, onFinishStory)
    if _object ~= nil then
        _object.destroy()
        _object = nil
    end
    local root = game.object.getRoot()
    _object = game.object.instantiate('data/scenes/endless_prompt.json', root)
    game.audio.playSound('data/sounds/general/tile_super.json')

    local endlessBtn = _object.find('panel/endlessButton')
    if endlessBtn ~= nil then
        local btnComp = endlessBtn.find('button').getComponent('button')
        if btnComp ~= nil then
            btnComp.onMouseEnter.subscribe(function()
                game.audio.playSound('data/sounds/general/mouseover.json', nil, true)
            end)
            btnComp.onClick.subscribe(function()
                game.audio.playSound('data/sounds/general/button_press.json', nil, true)
                if _object ~= nil then
                    _object.destroy()
                    _object = nil
                end
                if onContinueEndless ~= nil then
                    onContinueEndless()
                end
            end)
        end
    end

    local finishBtn = _object.find('panel/finishButton')
    if finishBtn ~= nil then
        local btnComp = finishBtn.find('button').getComponent('button')
        if btnComp ~= nil then
            btnComp.onMouseEnter.subscribe(function()
                game.audio.playSound('data/sounds/general/mouseover.json', nil, true)
            end)
            btnComp.onClick.subscribe(function()
                game.audio.playSound('data/sounds/general/button_press.json', nil, true)
                if _object ~= nil then
                    _object.destroy()
                    _object = nil
                end
                if onFinishStory ~= nil then
                    onFinishStory()
                end
            end)
        end
    end
end

function endlessPrompt.destroy()
    if _object ~= nil then
        _object.destroy()
        _object = nil
    end
end

return endlessPrompt
