local dialogueEncounter = {
    ui = dofile('data/scripts/ui/dialogue_encounter.lua'),
}

function dialogueEncounter.init()
    dialogueEncounter.ui.instantiate(game.control.completeEncounter)
end

function dialogueEncounter.onDestroy()
    dialogueEncounter.ui.destroy()
end

return dialogueEncounter