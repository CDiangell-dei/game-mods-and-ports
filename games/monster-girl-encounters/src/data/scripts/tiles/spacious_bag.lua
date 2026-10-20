local spaciousBag = {
    percentageModifier = 1.0,
    flatModifier = 0,
}

function spaciousBag.init()
    game.control.tiles.addRow()
end

function spaciousBag.onDestroy()
    game.control.tiles.removeRow()
end

return spaciousBag