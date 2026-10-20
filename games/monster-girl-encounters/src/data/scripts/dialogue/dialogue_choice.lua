local dialogueChoice = {}

local _activeChoices = {}
local _pendingChoice = nil

local function _triggerEvent(choiceEvent)
    if choiceEvent.sound ~= nil then
        game.audio.playSound(choiceEvent.sound)
    end
    if choiceEvent.script ~= nil then
        local scriptInit = dofile(choiceEvent.script)
        if type(scriptInit) == 'function' then
            scriptInit(choiceEvent.variable)
        end
    end
end

local function _tryTriggerEvents(choice)
    local events = choice.events
    if type(events) ~= 'table' then
        return
    end
    local count = #events
    for i=1, count do
        _triggerEvent(events[i])
    end
end

function dialogueChoice.init(target, chunk, _)
    local choices = target.find('choices')
    if choices == nil then
        game.debug.logError('No choices object found for dialogue.')
        return
    end
    for i, choice in ipairs(chunk.choices) do
        local choiceObject = game.object.instantiate('data/scenes/dialogue_choice.json', choices)
        choiceObject.name = tostring(i)
        local textObject = choiceObject.find('text/text')
        if textObject ~= nil then
            local text = textObject.getComponent('text')
            if text ~= nil then
                text.setText(choice.key)
            end
        end
        local shadowTextObject = choiceObject.find('text/shadow')
        if shadowTextObject ~= nil then
            local text = shadowTextObject.getComponent('text')
            if text ~= nil then
                text.setText(choice.key)
            end
        end
        local function pickChoice()
            _pendingChoice = choice
        end
        local textButton = dofile('data/scripts/ui/default_text_button.lua')
        textButton.init(choiceObject)
        local buttonObject = choiceObject.find('button')
        if buttonObject ~= nil then
            local button = buttonObject.getComponent('button')
            if button ~= nil then
                button.onClick.subscribe(pickChoice)
            end
        end
        table.insert(_activeChoices, choiceObject)
    end
    local ditherer = dofile('data/scripts/ui/staggered_dither.lua')
    ditherer.queueDitherIn(choices.getComponent('mask'), 0)
    local function playSpawnSound()
        game.audio.playSound('data/sounds/general/pop_up.json')
    end
    ditherer.executeDither(playSpawnSound)
end

function dialogueChoice.update()
    if _pendingChoice == nil then
        return 0
    end
    _tryTriggerEvents(_pendingChoice)
    return _pendingChoice.next
end

function dialogueChoice.destroy()
    for _, choice in ipairs(_activeChoices) do
        choice.destroy()
    end
    _activeChoices = {}
end

function dialogueChoice.progress() end

return dialogueChoice