local _data = require('data/scripts/data.lua')

_data.addBuff('determination', {
    name = 'determination_name',
    description = 'determination_description',
    icon = 'data/sprites/buffs/determination.png',
    script = 'data/scripts/buffs/determination.lua',
    rarity = 0,
    modifier = 1.2,
    remaining = 0,
})

_data.addBuff('sylph', {
    name = 'sylph_name',
    description = 'sylph_description',
    icon = 'data/sprites/buffs/sylph.png',
    script = 'data/scripts/buffs/sylph_blessing.lua',
    rarity = 4,
    amount = 20,
})

_data.addBuff('salamander', {
    name = 'salamander_name',
    description = 'salamander_description',
    icon = 'data/sprites/buffs/salamander.png',
    script = 'data/scripts/buffs/salamander_blessing.lua',
    rarity = 4,
    modifier = 3.0,
    remaining = 2,
    amount = 2,
})

_data.addBuff('undine', {
    name = 'undine_name',
    description = 'undine_description',
    icon = 'data/sprites/buffs/undine.png',
    script = 'data/scripts/buffs/undine_blessing.lua',
    rarity = 4,
    modifier = 1.75,
})

_data.addBuff('gnome', {
    name = 'gnome_name',
    description = 'gnome_description',
    icon = 'data/sprites/buffs/gnome.png',
    script = 'data/scripts/buffs/gnome_blessing.lua',
    rarity = 4,
    amount = 10,
})

_data.addBuff('well_rested', {
    name = 'well_rested_name',
    description = 'well_rested_description',
    icon = 'data/sprites/buffs/well_rested.png',
    script = 'data/scripts/buffs/well_rested.lua',
    rarity = 0,
    modifier = 1.1,
    remaining = 0,
})

_data.addBuff('tired', {
    name = 'tired_name',
    description = 'tired_description',
    icon = 'data/sprites/buffs/tired.png',
    script = 'data/scripts/buffs/tired.lua',
    rarity = 0,
    modifier = 0.9,
    amount = 1,
    remaining = 0,
})

_data.addBuff('growing_strength', {
    name = 'growing_strength_name',
    description = 'growing_strength_description',
    icon = 'data/sprites/buffs/growing_strength.png',
    script = 'data/scripts/buffs/growing_strength.lua',
    rarity = 4,
    modifier = 1.0,
    increase = 0.5,
    duration = 3,
})

_data.addBuff('shadowed_backpack', {
    name = 'shadowed_backpack_name',
    description = 'shadowed_backpack_description',
    icon = 'data/sprites/buffs/shadowed_backpack.png',
    script = 'data/scripts/buffs/shadowed_backpack.lua',
    rarity = 4,
    reduction = 60,
})
