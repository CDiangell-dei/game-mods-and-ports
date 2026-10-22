local function _init(var)
    local function talk()
        game.control.encounter.ui.spawnDialogue(var.dialogue, false, nil)
    end
    game.timer.queue(var.wait, talk)
end

return _init
