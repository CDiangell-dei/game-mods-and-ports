local _data = require('data/scripts/data.lua')

_data.addShop('shop_1', {
    name = 'shop_spider_name',
    icon = 'data/sprites/icons/spider.png',
    script = 'data/scripts/encounters/shops/spider_shop.lua',
    weight = 1.0,
})

_data.addBattle('battle_slime', {
    name = 'pink_slime_name',
    description = 'pink_slime_description',
    icon = 'data/sprites/icons/pink_slime.png',
    intro = {
        {
            background = 'data/sprites/encounters/pink_slime_intro.png',
            sprite = 'data/sprites/dither/0.png'
        },
        {
            background = 'data/sprites/encounters/pink_slime_intro.png',
            sprite = 'data/sprites/encounters/pink_slime_sprite.png'
        },
    },
    battle = {
        {
            background = 'data/sprites/encounters/pink_slime_bg.png',
            sprite = 'data/animations/pink_slime/1/data.json'
        },
        {
            background = 'data/sprites/encounters/pink_slime_bg.png',
            sprite = 'data/animations/pink_slime/2/data.json'
        },
    },
    winOutro = {
        {
            background = 'data/sprites/encounters/pink_slime_bg.png',
            sprite = 'data/animations/pink_slime/outro_win/data.json'
        },
    },
    failOutro = {
        {
            background = 'data/sprites/encounters/pink_slime_bg.png',
            sprite = 'data/animations/pink_slime/outro_loss/data.json'
        },
    },
    script = 'data/scripts/encounters/battles/pink_slime.lua',
    weight = 1.0,
})

_data.addBattle('battle_onikuma', {
    name = 'onikuma_name',
    description = 'onikuma_description',
    icon = 'data/sprites/icons/onikuma.png',
    intro = {
        {
            background = 'data/sprites/encounters/onikuma_intro.png',
            sprite = 'data/sprites/dither/0.png'
        },
        {
            background = 'data/sprites/encounters/onikuma_intro.png',
            sprite = 'data/sprites/encounters/onikuma_1.png'
        },
        {
            background = 'data/sprites/encounters/onikuma_intro.png',
            sprite = 'data/sprites/encounters/onikuma_2a.png'
        },
        {
            background = 'data/sprites/encounters/onikuma_intro.png',
            sprite = 'data/sprites/encounters/onikuma_2b.png'
        },
        {
            background = 'data/sprites/encounters/onikuma_intro.png',
            sprite = 'data/sprites/encounters/onikuma_2c.png'
        },
        {
            background = 'data/sprites/encounters/onikuma_intro.png',
            sprite = 'data/sprites/encounters/onikuma_2d.png'
        },
    },
    battle = {
        {
            background = 'data/sprites/encounters/onikuma_bg.png',
            sprite = 'data/animations/onikuma/1/data.json'
        },
        {
            background = 'data/sprites/encounters/onikuma_bg.png',
            sprite = 'data/animations/onikuma/2/data.json'
        },
    },
    winOutro = {
        {
            background = 'data/sprites/encounters/onikuma_bg.png',
            sprite = 'data/animations/onikuma/outro_win/data.json'
        },
    },
    failOutro = {
        {
            background = 'data/sprites/encounters/onikuma_bg.png',
            sprite = 'data/animations/onikuma/outro_loss_1/data.json'
        },
        {
            background = 'data/sprites/encounters/onikuma_bg.png',
            sprite = 'data/animations/onikuma/outro_loss_2/data.json'
        },
    },
    script = 'data/scripts/encounters/battles/onikuma.lua',
    weight = 1.0,
})

_data.addBattle('battle_mandragora', {
    name = 'mandragora_name',
    description = 'mandragora_description',
    icon = 'data/sprites/icons/mandragora.png',
    intro = {
        {
            background = 'data/sprites/encounters/mandragora_intro.png',
            sprite = 'data/sprites/dither/0.png'
        },
        {
            background = 'data/sprites/encounters/mandragora_intro.png',
            sprite = 'data/sprites/encounters/mandragora_sprite.png'
        },
    },
    battle = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/mandragora/1/data.json'
        },
    },
    winOutro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/mandragora/outro_win/data.json'
        },
    },
    failOutro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/mandragora/outro_loss/data.json'
        },
    },
    script = 'data/scripts/encounters/battles/mandragora.lua',
    weight = 1.0,
})

_data.addBattle('battle_cyclops', {
    name = 'cyclops_name',
    description = 'cyclops_description',
    autoBattleProfitMultiplier = 2,
    icon = 'data/sprites/icons/cyclops.png',
    intro = {
        {
            background = 'data/sprites/encounters/cyclops_intro.png',
            sprite = 'data/sprites/dither/0.png'
        },
    },
    battle = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/cyclops/1/data.json'
        },
    },
    winOutro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/cyclops/outro_win/data.json'
        },
    },
    failOutro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/cyclops/outro_loss/data.json'
        },
    },
    script = 'data/scripts/encounters/battles/cyclops.lua',
    weight = 1.0,
})

_data.addBattle('battle_goblin', {
    name = 'goblin_name',
    description = 'goblin_description',
    icon = 'data/sprites/icons/goblin.png',
    intro = {
        {
            background = 'data/sprites/encounters/goblin_intro_1.png',
            sprite = 'data/sprites/dither/0.png'
        },
        {
            background = 'data/sprites/encounters/goblin_intro_bg.png',
            sprite = 'data/sprites/encounters/goblin_intro_2.png'
        },
        {
            background = 'data/sprites/encounters/goblin_intro_bg.png',
            sprite = 'data/sprites/encounters/goblin_intro_3.png'
        },
    },
    battle = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/goblin/1/data.json'
        },
    },
    winOutro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/goblin/outro_win/data.json'
        },
    },
    failOutro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/goblin/outro_loss/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/goblin/outro_loss_2/data.json'
        },
    },
    script = 'data/scripts/encounters/battles/goblin.lua',
    weight = 1.0,
})

_data.addBattle('battle_imps', {
    name = 'imps_name',
    description = 'imps_description',
    icon = 'data/sprites/icons/imps.png',
    intro = {
        {
            background = 'data/sprites/encounters/imps_intro_2.png',
            sprite = 'data/sprites/dither/0.png'
        },
    },
    battle = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/imps/1/data.json'
        },
    },
    winOutro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/imps/win/data.json'
        },
    },
    failOutro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/imps/loss_1/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/imps/loss_2/data.json'
        },
    },
    script = 'data/scripts/encounters/battles/imps.lua',
    weight = 1.0,
})

_data.addElite('elite_sphinx', {
    name = 'sphinx_name',
    description = 'sphinx_description',
    autoBattleProfitMultiplier = 2,
    icon = 'data/sprites/icons/sphinx.png',
    intro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/sphinx/intro/0001.png',
        },
    },
    battle = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/sphinx/1/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/sphinx/2/data.json'
        }
    },
    winOutro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/sphinx/outro_win_1/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/sphinx/outro_win_2/data.json'
        },
    },
    failOutro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/sphinx/outro_loss_1/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/sphinx/outro_loss_2/data.json'
        },
    },
    script = 'data/scripts/encounters/battles/sphinx.lua',
    weight = 1.0,
})

_data.addElite('elite_succubus', {
    name = 'succubus_name',
    description = 'succubus_description',
    autoBattleProfitMultiplier = 2,
    icon = 'data/sprites/icons/succubus.png',
    intro = {
        {
            background = 'data/sprites/encounters/succubus_bg.png',
            sprite = 'data/sprites/encounters/succubus_intro.png',
        },
    },
    battle = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/succubus/1/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/succubus/2/data.json'
        }
    },
    winOutro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/succubus/win1/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/succubus/win2/data.json'
        },
    },
    failOutro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/succubus/loss1/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/succubus/loss2_1/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/succubus/loss2_2/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/succubus/loss2_3/data.json'
        },
    },
    script = 'data/scripts/encounters/battles/succubus.lua',
    weight = 1.0,
})

_data.addBoss('boss_fairies', {
    name = 'fairies_name',
    description = 'fairies_description',
    icon = 'data/sprites/icons/fairies.png',
    intro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/sprites/encounters/fairies_bg.png',
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/sprites/encounters/fairies_1.png',
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/sprites/encounters/fairies_2.png',
        },
    },
    battle = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/fairies/1_total/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/fairies/2/data.json'
        }
    },
    winOutro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/fairies/win_1/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/fairies/win_2/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/fairies/win_3/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/fairies/win_4a/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/fairies/win_4b/data.json'
        },
    },
    failOutro = {
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/fairies/loss_1a/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/fairies/loss_1b/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/fairies/loss_1c/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/fairies/loss_2a/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/fairies/loss_2b/data.json'
        },
        {
            background = 'data/sprites/dither/0.png',
            sprite = 'data/animations/fairies/loss_2c/data.json'
        },
    },
    script = 'data/scripts/encounters/battles/fairies.lua',
    weight = 1.0,
})

_data.addRandomEncounter('random_sylph', {
    name = 'sylph_name',
    icon = 'data/sprites/icons/sylph.png',
    script = 'data/scripts/encounters/random/sylph.lua',
    weight = 1.0,
})

_data.addRandomEncounter('random_salamander', {
    name = 'salamander_name',
    icon = 'data/sprites/icons/salamander.png',
    script = 'data/scripts/encounters/random/salamander.lua',
    weight = 1.0,
})

_data.addRandomEncounter('random_undine', {
    name = 'undine_name',
    icon = 'data/sprites/icons/undine.png',
    script = 'data/scripts/encounters/random/undine.lua',
    weight = 1.0,
})

_data.addRandomEncounter('random_gnome', {
    name = 'gnome_name',
    icon = 'data/sprites/icons/gnome.png',
    script = 'data/scripts/encounters/random/gnome.lua',
    weight = 1.0,
})

_data.addRandomEncounter('random_treasure', {
    name = 'treasure_name',
    icon = 'data/sprites/icons/treasure.png',
    script = 'data/scripts/encounters/random/treasure.lua',
    weight = 1.0,
})

_data.addRandomEncounter('random_hotspring', {
    name = 'hotspring_name',
    icon = 'data/sprites/icons/hotspring.png',
    script = 'data/scripts/encounters/random/hotspring.lua',
    weight = 1.0,
})

_data.addRandomEncounter('random_spirit', {
    name = 'spirit_name',
    icon = 'data/sprites/icons/spirit.png',
    script = 'data/scripts/encounters/random/spirit.lua',
    weight = 1.0,
})
