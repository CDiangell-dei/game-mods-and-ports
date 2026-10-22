local doll = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

function doll.onLoseBattle()
    game.control.shield = game.control.shield + 1
    game.audio.playSound('data/sounds/general/heal.json')
    game.control.tiles.destroyTile(doll.index)
end

return doll
