local data = {
    tiles = {},
    buffs = {},
    battleEncounters = {},
    eliteEncounters = {},
    bossEncounters = {},
    shopEncounters = {},
    randomEncounters = {},
}

function data.addTile(key, tile)
    tile.key = key
    tile.type = 'tile'
    data.tiles[key] = tile
end

function data.addBuff(key, buff)
    buff.key = key
    buff.type = 'buff'
    data.buffs[key] = buff
end

function data.addBattle(key, encounter)
    encounter.key = key
    encounter.type = 'battle'
    data.battleEncounters[key] = encounter
end

function data.addElite(key, encounter)
    encounter.key = key
    encounter.type = 'elite'
    data.eliteEncounters[key] = encounter
end

function data.addBoss(key, encounter)
    encounter.key = key
    encounter.type = 'boss'
    data.bossEncounters[key] = encounter
end

function data.addShop(key, encounter)
    encounter.key = key
    encounter.type = 'shop'
    data.shopEncounters[key] = encounter
end

function data.addRandomEncounter(key, encounter)
    encounter.key = key
    encounter.type = 'randomEncounter'
    data.randomEncounters[key] = encounter
end

return data