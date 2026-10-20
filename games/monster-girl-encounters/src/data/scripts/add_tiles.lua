local _data = require('data/scripts/data.lua')

--Flat Increase Set

_data.addTile('canteen', {
    name = 'canteen_name',
    description = 'canteen_description',
    subtype = 'tool',
    icon = 'data/sprites/items/canteen.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/canteen.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'sandwich',
    --    product = 'basket'
    --},
    exhaustion = 10,
})

_data.addTile('sandwich', {
    name = 'sandwich_name',
    description = 'sandwich_description',
    subtype = 'food',
    icon = 'data/sprites/items/sandwich.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/sandwich.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'canteen',
    --    product = 'basket'
    --},
    exhaustion = 15,
    modifier = -5,
})

_data.addTile('lantern', {
    name = 'lantern_name',
    description = 'lantern_description',
    subtype = 'tool',
    icon = 'data/sprites/items/lantern.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/lantern.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'compass',
    --    product = 'map'
    --},
    modifier = 5,
})

_data.addTile('compass', {
    name = 'compass_name',
    description = 'compass_description',
    subtype = 'tool',
    icon = 'data/sprites/items/compass.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/compass.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'lantern',
    --    product = 'map'
    --},
    modifier = 7,
})

_data.addTile('basket', {
    name = 'basket_name',
    description = 'basket_description',
    subtype = 'food',
    icon = 'data/sprites/items/basket.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/basket.lua',
    value = 5,
    rarity = 2,
    limit = 4,
    --combination = {
    --    target = 'map',
    --    product = 'multitool'
    --},
    exhaustion = 20,
})

_data.addTile('map', {
    name = 'map_name',
    description = 'map_description',
    subtype = 'tool',
    icon = 'data/sprites/items/map.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/map.lua',
    value = 5,
    rarity = 2,
    limit = 0,
    --combination = {
    --    target = 'basket',
    --    product = 'multitool'
    --},
    modifier = 15,
})

_data.addTile('multitool', {
    name = 'multitool_name',
    description = 'multitool_description',
    subtype = 'tool',
    icon = 'data/sprites/items/multitool.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/multitool.lua',
    value = 10,
    rarity = 3,
    limit = 0,
    modifier = 10,
})

--Ramping Set

_data.addTile('vibrating_egg', {
    name = 'vibrating_egg_name',
    description = 'vibrating_egg_description',
    subtype = 'toy',
    icon = 'data/sprites/items/vibrating_egg.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/vibrating_egg.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'binding_ropes',
    --    product = 'bag_of_toys'
    --},
    exhaustion = 1,
    increase = 0.25,
})

_data.addTile('binding_ropes', {
    name = 'binding_ropes_name',
    description = 'binding_ropes_description',
    subtype = 'tool',
    icon = 'data/sprites/items/binding_ropes.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/binding_ropes.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'vibrating_egg',
    --    product = 'bag_of_toys'
    --},
    exhaustion = 8,
    increase = 15,
})

_data.addTile('ground_horn', {
    name = 'ground_horn_name',
    description = 'ground_horn_description',
    subtype = 'food',
    icon = 'data/sprites/items/ground_horn.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/ground_horn.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'slime_essence',
    --    product = 'lusty_elixir'
    --},
    modifier = 1.5,
    increase = 0.5,
})

_data.addTile('slime_essence', {
    name = 'slime_essence_name',
    description = 'slime_essence_description',
    subtype = 'food',
    icon = 'data/sprites/items/slime_essence.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/slime_essence.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'ground_horn',
    --    product = 'lusty_elixir'
    --},
    increase = 3.0,
})

_data.addTile('bag_of_toys', {
    name = 'bag_of_toys_name',
    description = 'bag_of_toys_description',
    subtype = 'toy',
    icon = 'data/sprites/items/bag_of_toys.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/bag_of_toys.lua',
    value = 5,
    rarity = 2,
    limit = 0,
    --combination = {
    --    target = 'lusty_elixir',
    --    product = 'bottomless_bag_of_toys'
    --},
    exhaustion = 10,
    increase = 5,
})

_data.addTile('lusty_elixir', {
    name = 'lusty_elixir_name',
    description = 'lusty_elixir_description',
    subtype = 'food',
    icon = 'data/sprites/items/lusty_elixir.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/lusty_elixir.lua',
    value = 5,
    rarity = 2,
    limit = 0,
    --combination = {
    --    target = 'bag_of_toys',
    --    product = 'bottomless_bag_of_toys'
    --},
    modifier = 0.75,
    increase = 0.007,
})

_data.addTile('bottomless_bag_of_toys', {
    name = 'bottomless_bag_of_toys_name',
    description = 'bottomless_bag_of_toys_description',
    subtype = 'toy',
    icon = 'data/sprites/items/bottomless_bag_of_toys.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/bottomless_bag_of_toys.lua',
    value = 10,
    rarity = 3,
    limit = 0,
    exhaustion = 15,
    increase = 20,
})

--Vampire Set

_data.addTile('bloodgem', {
    name = 'bloodgem_name',
    description = 'bloodgem_description',
    subtype = 'relic',
    icon = 'data/sprites/items/bloodgem.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/bloodgem.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'lifegem',
    --    product = 'gem_of_consumption'
    --},
    exhaustion = 7,
    increase = 15,
})

_data.addTile('lifegem', {
    name = 'lifegem_name',
    description = 'lifegem_description',
    subtype = 'relic',
    icon = 'data/sprites/items/lifegem.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/lifegem.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'bloodgem',
    --    product = 'gem_of_consumption'
    --},
    remaining = 10, --ui use
    amount = 10,
})

_data.addTile('lifegem_off', {
    name = 'lifegem_name',
    description = 'lifegem_description',
    subtype = 'junk',
    icon = 'data/sprites/items/lifegem_off.png',
    script = 'data/scripts/tiles/lifegem_off.lua',
    value = 0,
    rarity = 1,
    limit = 0,
    remaining = 10,
    amount = 10,
})

_data.addTile('silver_tiara', {
    name = 'silver_tiara_name',
    description = 'silver_tiara_description',
    subtype = 'relic',
    icon = 'data/sprites/items/silver_tiara.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/silver_tiara.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'golden_bracelet',
    --    product = 'amulet_of_avarice'
    --},
    modifier = 1.0,
    increase = 0.1,
})

_data.addTile('golden_bracelet', {
    name = 'golden_bracelet_name',
    description = 'golden_bracelet_description',
    subtype = 'relic',
    icon = 'data/sprites/items/golden_bracelet.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/golden_bracelet.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'silver_tiara',
    --    product = 'amulet_of_avarice'
    --},
    amount = 2,
})

_data.addTile('gem_of_consumption', {
    name = 'gem_of_consumption_name',
    description = 'gem_of_consumption_description',
    subtype = 'relic',
    icon = 'data/sprites/items/gem_of_consumption.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/gem_of_consumption.lua',
    value = 5,
    rarity = 2,
    limit = 0,
    --combination = {
    --    target = 'amulet_of_avarice',
    --    product = 'vampiric_necklace'
    --},
    modifier = 1.1,
    increase = 0.15,
})

_data.addTile('amulet_of_avarice', {
    name = 'amulet_of_avarice_name',
    description = 'amulet_of_avarice_description',
    subtype = 'relic',
    icon = 'data/sprites/items/amulet_of_avarice.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/amulet_of_avarice.lua',
    value = 5,
    rarity = 2,
    limit = 0,
    --combination = {
    --    target = 'gem_of_consumption',
    --    product = 'vampiric_necklace'
    --},
    remaining = 5, --ui use
    amount = 5,
})

_data.addTile('vampiric_necklace', {
    name = 'vampiric_necklace_name',
    description = 'vampiric_necklace_description',
    subtype = 'relic',
    icon = 'data/sprites/items/vampiric_necklace.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/vampiric_necklace.lua',
    value = 10,
    rarity = 3,
    limit = 0,
    increase = 10,
})

--Inventory Set

_data.addTile('handful_of_seeds', {
    name = 'handful_of_seeds_name',
    description = 'handful_of_seeds_description',
    subtype = 'food',
    icon = 'data/sprites/items/handful_of_seeds.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/handful_of_seeds.lua',
    value = 2,
    rarity = 1,
    limit = 1,
    --combination = {
    --    target = 'dandelion_bouquet',
    --    product = 'wildflowers'
    --},
})

_data.addTile('dandelion_bouquet', {
    name = 'dandelion_bouquet_name',
    description = 'dandelion_bouquet_description',
    subtype = 'food',
    icon = 'data/sprites/items/dandelion_bouquet.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/dandelion_bouquet.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'handful_of_seeds',
    --    product = 'wildflowers'
    --},
    exhaustion = 15,
})

_data.addTile('spacious_bag', {
    name = 'spacious_bag_name',
    description = 'spacious_bag_description',
    subtype = 'tool',
    icon = 'data/sprites/items/spacious_bag.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/spacious_bag.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'lucky_clover',
    --    product = 'potted_clover'
    --},
})

_data.addTile('lucky_clover', {
    name = 'lucky_clover_name',
    description = 'lucky_clover_description',
    subtype = 'relic',
    icon = 'data/sprites/items/lucky_clover.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/lucky_clover.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'spacious_bag',
    --    product = 'potted_clover'
    --},
    amount = 1,
    increase = 1,
})

_data.addTile('wildflowers', {
    name = 'wildflowers_name',
    description = 'wildflowers_description',
    subtype = 'food',
    icon = 'data/sprites/items/wildflowers.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/wildflowers.lua',
    value = 5,
    rarity = 2,
    limit = 0,
    --combination = {
    --    target = 'potted_clover',
    --    product = 'blessed_herbs'
    --},
    exhaustion = 10,
    increase = 1,
})

_data.addTile('potted_clover', {
    name = 'potted_clover_name',
    description = 'potted_clover_description',
    subtype = 'relic',
    icon = 'data/sprites/items/potted_clover.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/potted_clover.lua',
    value = 5,
    rarity = 2,
    limit = 0,
    --combination = {
    --    target = 'wildflowers',
    --    product = 'blessed_herbs'
    --},
    amount = 0.5,
})

_data.addTile('blessed_herbs', {
    name = 'blessed_herbs_name',
    description = 'blessed_herbs_description',
    subtype = 'relic',
    icon = 'data/sprites/items/blessed_herbs.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/blessed_herbs.lua',
    value = 10,
    rarity = 3,
    limit = 0,
    amount = 5,
    modifier = 1.5,
})

--Junk Set

_data.addTile('rock', {
    name = 'rock_name',
    description = 'rock_description',
    subtype = 'junk',
    icon = 'data/sprites/items/rock.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/rock.lua',
    value = 0,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'rock',
    --    product = 'boulder'
    --},
})

_data.addTile('gardening_gloves', {
    name = 'gardening_gloves_name',
    description = 'gardening_gloves_description',
    subtype = 'tool',
    icon = 'data/sprites/items/gardening_gloves.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/gardening_gloves.lua',
    value = 2,
    rarity = 1,
    limit = 0,
})

_data.addTile('wrench', {
    name = 'wrench_name',
    description = 'wrench_description',
    subtype = 'tool',
    icon = 'data/sprites/items/wrench.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/wrench.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'sack_of_junk',
    --    product = 'toolbox'
    --},
})

_data.addTile('sack_of_junk', {
    name = 'sack_of_junk_name',
    description = 'sack_of_junk_description',
    subtype = 'tool',
    icon = 'data/sprites/items/sack_of_junk.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/sack_of_junk.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    --combination = {
    --    target = 'wrench',
    --    product = 'toolbox'
    --},
    amount = 1,
})

_data.addTile('boulder', {
    name = 'boulder_name',
    description = 'boulder_description',
    subtype = 'junk',
    icon = 'data/sprites/items/boulder.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/boulder.lua',
    value = 0,
    rarity = 2,
    limit = 0,
    --combination = {
    --    target = 'toolbox',
    --    product = 'magic_box'
    --},
    exhaustion = 7,
})

_data.addTile('toolbox', {
    name = 'toolbox_name',
    description = 'toolbox_description',
    subtype = 'tool',
    icon = 'data/sprites/items/toolbox.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/toolbox.lua',
    value = 5,
    rarity = 2,
    limit = 0,
    --combination = {
    --    target = 'boulder',
    --    product = 'magic_box'
    --},
    exhaustion = 10,
    increase = 15,
})

_data.addTile('magic_box', {
    name = 'magic_box_name',
    description = 'magic_box_description',
    subtype = 'relic',
    icon = 'data/sprites/items/magic_box.png',
    lockedIcon = 'data/sprites/items/tile_placeholder.png',
    script = 'data/scripts/tiles/magic_box.lua',
    value = 10,
    rarity = 3,
    limit = 0,
    amount = 30,
})

_data.addTile('mini_slime', {
    name = 'mini_slime_name',
    description = 'mini_slime_description',
    subtype = 'relic',
    icon = 'data/sprites/items/mini_slime.png',
    script = 'data/scripts/tiles/mini_slime.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    current = 'no_item',
})

_data.addTile('doll', {
    name = 'doll_name',
    description = 'doll_description',
    subtype = 'relic',
    icon = 'data/sprites/items/doll.png',
    script = 'data/scripts/tiles/doll.lua',
    value = 2,
    rarity = 1,
    limit = 1,
})

_data.addTile('doll_off', {
    name = 'doll_name',
    description = 'doll_description',
    subtype = 'junk',
    icon = 'data/sprites/items/doll_off.png',
    script = 'data/scripts/tiles/doll_off.lua',
    value = 0,
    rarity = 1,
    limit = 1,
})

_data.addTile('buff_slime', {
    name = 'buff_slime_name',
    description = 'buff_slime_description',
    subtype = 'relic',
    icon = 'data/sprites/items/buff_slime.png',
    script = 'data/scripts/tiles/buff_slime.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    current = 'no_item',
})

_data.addTile('swirling_orb', {
    name = 'swirling_orb_name',
    description = 'swirling_orb_description',
    subtype = 'relic',
    icon = 'data/sprites/items/swirling_orb.png',
    script = 'data/scripts/tiles/swirling_orb.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    min = 0.5,
    max = 1.6,
})

_data.addTile('half_slime', {
    name = 'half_slime_name',
    description = 'half_slime_description',
    subtype = 'relic',
    icon = 'data/sprites/items/half_slime.png',
    script = 'data/scripts/tiles/half_slime.lua',
    value = 5,
    rarity = 2,
    limit = 0,
})

_data.addTile('chaotic_orb', {
    name = 'chaotic_orb_name',
    description = 'chaotic_orb_description',
    subtype = 'relic',
    icon = 'data/sprites/items/chaotic_orb.png',
    script = 'data/scripts/tiles/chaotic_orb.lua',
    value = 5,
    rarity = 2,
    limit = 0,
    modifier = 1.1,
})

_data.addTile('leftovers', {
    name = 'leftovers_name',
    description = 'leftovers_description',
    subtype = 'food',
    icon = 'data/sprites/items/leftovers.png',
    script = 'data/scripts/tiles/leftovers.lua',
    value = 10,
    rarity = 3,
    limit = 0,
    modifier = 1.3,
    chance = 0.5,
})

_data.addTile('coupon', {
    name = 'coupon_name',
    description = 'coupon_description',
    subtype = 'tool',
    icon = 'data/sprites/items/coupon.png',
    script = 'data/scripts/tiles/coupon.lua',
    value = 2,
    rarity = 1,
    limit = 4,
    amount = 25,
})

_data.addTile('spider_charm', {
    name = 'spider_charm_name',
    description = 'spider_charm_description',
    subtype = 'relic',
    icon = 'data/sprites/items/spider_charm.png',
    script = 'data/scripts/tiles/spider_charm.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    amount = 5,
})

_data.addTile('alchemical_orb', {
    name = 'alchemical_orb_name',
    description = 'alchemical_orb_description',
    subtype = 'relic',
    icon = 'data/sprites/items/alchemical_orb.png',
    script = 'data/scripts/tiles/alchemical_orb.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    amount = 20,
})

_data.addTile('web_covered_rope', {
    name = 'web_covered_rope_name',
    description = 'web_covered_rope_description',
    subtype = 'tool',
    icon = 'data/sprites/items/web_covered_rope.png',
    script = 'data/scripts/tiles/web_covered_rope.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    exhaustion = 8,
    increase = 2,
})

_data.addTile('golden_idol', {
    name = 'golden_idol_name',
    description = 'golden_idol_description',
    subtype = 'relic',
    icon = 'data/sprites/items/golden_idol.png',
    script = 'data/scripts/tiles/golden_idol.lua',
    value = 5,
    rarity = 2,
    limit = 0,
    exhaustion = 8,
    increase = 0.25,
})

_data.addTile('golden_elixir', {
    name = 'golden_elixir_name',
    description = 'golden_elixir_description',
    subtype = 'food',
    icon = 'data/sprites/items/golden_elixir.png',
    script = 'data/scripts/tiles/golden_elixir.lua',
    value = 5,
    rarity = 2,
    limit = 0,
    modifier = 1.0,
    increase = 0.005,
})

_data.addTile('golden_slime', {
    name = 'golden_slime_name',
    description = 'golden_slime_description',
    subtype = 'relic',
    icon = 'data/sprites/items/golden_slime.png',
    script = 'data/scripts/tiles/golden_slime.lua',
    value = 10,
    rarity = 3,
    limit = 1,
    chance = 25,
})

_data.addTile('paper', {
    name = 'paper_name',
    description = 'paper_description',
    subtype = 'tool',
    icon = 'data/sprites/items/paper.png',
    script = 'data/scripts/tiles/paper.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    amount = 0.1,
})

_data.addTile('contract', {
    name = 'contract_name',
    description = 'contract_description',
    subtype = 'tool',
    icon = 'data/sprites/items/contract.png',
    script = 'data/scripts/tiles/contract.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    exhaustion = 5,
    increase = 0.5,
})

_data.addTile('dated_certificate', {
    name = 'dated_certificate_name',
    description = 'dated_certificate_description',
    subtype = 'tool',
    icon = 'data/sprites/items/dated_certificate.png',
    script = 'data/scripts/tiles/dated_certificate.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    modifier = 1.4,
    decrease = 0.15,
})

_data.addTile('paintbrush', {
    name = 'paintbrush_name',
    description = 'paintbrush_description',
    subtype = 'tool',
    icon = 'data/sprites/items/paintbrush.png',
    script = 'data/scripts/tiles/paintbrush.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    amount = 6,
})

_data.addTile('ring_of_charming', {
    name = 'ring_of_charming_name',
    description = 'ring_of_charming_description',
    subtype = 'relic',
    icon = 'data/sprites/items/ring_of_charming.png',
    script = 'data/scripts/tiles/ring_of_charming.lua',
    value = 5,
    rarity = 2,
    limit = 0,
    increase = 2,
})

_data.addTile('hungry_slime', {
    name = 'hungry_slime_name',
    description = 'hungry_slime_description',
    subtype = 'relic',
    icon = 'data/sprites/items/hungry_slime.png',
    script = 'data/scripts/tiles/hungry_slime.lua',
    value = 5,
    rarity = 2,
    limit = 0,
    modifier = 1.0,
    increase = 0.025,
})

_data.addTile('golden_scroll', {
    name = 'golden_scroll_name',
    description = 'golden_scroll_description',
    subtype = 'relic',
    icon = 'data/sprites/items/golden_scroll.png',
    script = 'data/scripts/tiles/golden_scroll.lua',
    value = 10,
    rarity = 3,
    limit = 0,
    modifier = 1.0,
    increase = 0.01,
})

_data.addTile('polymorphic_elixir', {
    name = 'polymorphic_elixir_name',
    description = 'polymorphic_elixir_description',
    subtype = 'food',
    icon = 'data/sprites/items/polymorphic_elixir.png',
    script = 'data/scripts/tiles/polymorphic_elixir.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    min = 10,
    max = 30,
})

_data.addTile('polymorphic_gem', {
    name = 'polymorphic_gem_name',
    description = 'polymorphic_gem_description',
    subtype = 'relic',
    icon = 'data/sprites/items/polymorphic_gem.png',
    script = 'data/scripts/tiles/polymorphic_gem.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    min = 0,
    max = 2.5,
})

_data.addTile('cursed_charm', {
    name = 'cursed_charm_name',
    description = 'cursed_charm_description',
    subtype = 'relic',
    icon = 'data/sprites/items/cursed_charm.png',
    script = 'data/scripts/tiles/cursed_charm.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    amount = 15,
    decrease = 10,
})

_data.addTile('stone_crown', {
    name = 'stone_crown_name',
    description = 'stone_crown_description',
    subtype = 'relic',
    icon = 'data/sprites/items/stone_crown.png',
    script = 'data/scripts/tiles/stone_crown.lua',
    value = 2,
    rarity = 1,
    limit = 0,
    modifier = 1.3,
})

_data.addTile('thorns', {
    name = 'thorns_name',
    description = 'thorns_description',
    subtype = 'tool',
    icon = 'data/sprites/items/thorns.png',
    script = 'data/scripts/tiles/thorns.lua',
    value = 5,
    rarity = 2,
    limit = 0,
    modifier = 1.4,
})

_data.addTile('sleepy_slime', {
    name = 'sleepy_slime_name',
    description = 'sleepy_slime_description',
    subtype = 'relic',
    icon = 'data/sprites/items/sleepy_slime.png',
    script = 'data/scripts/tiles/sleepy_slime.lua',
    value = 5,
    rarity = 2,
    limit = 0,
    amount = 2,
})

_data.addTile('sparkling_crown', {
    name = 'sparkling_crown_name',
    description = 'sparkling_crown_description',
    subtype = 'relic',
    icon = 'data/sprites/items/sparkling_crown.png',
    script = 'data/scripts/tiles/sparkling_crown.lua',
    value = 10,
    rarity = 3,
    limit = 0,
    modifier = 0.9,
    increase = 0.1,
})

_data.addTile('broken_doll', {
    name = 'broken_doll_name',
    description = 'broken_doll_description',
    subtype = 'junk',
    icon = 'data/sprites/items/broken_doll.png',
    script = 'data/scripts/tiles/broken_doll.lua',
    value = 0,
    rarity = 1,
    limit = 0,
})

_data.addTile('bone', {
    name = 'bone_name',
    description = 'bone_description',
    subtype = 'junk',
    icon = 'data/sprites/items/bone.png',
    script = 'data/scripts/tiles/bone.lua',
    value = 0,
    rarity = 1,
    limit = 0,
})

_data.addTile('gravel', {
    name = 'gravel_name',
    description = 'gravel_description',
    subtype = 'junk',
    icon = 'data/sprites/items/gravel.png',
    script = 'data/scripts/tiles/gravel.lua',
    value = 0,
    rarity = 1,
    limit = 0,
})

_data.addTile('queen_slime', {
    name = 'queen_slime_name',
    description = 'queen_slime_description',
    subtype = 'relic',
    icon = 'data/sprites/items/queen_slime.png',
    script = 'data/scripts/tiles/queen_slime.lua',
    value = 20,
    rarity = 4,
    limit = 1,
})

_data.addTile('oni_killer', {
    name = 'oni_killer_name',
    description = 'oni_killer_description',
    subtype = 'food',
    icon = 'data/sprites/items/oni_killer.png',
    script = 'data/scripts/tiles/oni_killer.lua',
    value = 20,
    rarity = 4,
    limit = 1,
    chance = 30,
})

_data.addTile('black_card', {
    name = 'black_card_name',
    description = 'black_card_description',
    subtype = 'tool',
    icon = 'data/sprites/items/black_card.png',
    script = 'data/scripts/tiles/black_card.lua',
    value = 20,
    rarity = 4,
    limit = 1,
    reduce = 50,
    luckIncrease = 50,
})

_data.addTile('vampiric_slime', {
    name = 'vampiric_slime_name',
    description = 'vampiric_slime_description',
    subtype = 'relic',
    icon = 'data/sprites/items/vampiric_slime.png',
    script = 'data/scripts/tiles/vampiric_slime.lua',
    value = 20,
    rarity = 4,
    limit = 1,
    amount = 20,
})

_data.addTile('king_crown', {
    name = 'king_crown_name',
    description = 'king_crown_description',
    subtype = 'relic',
    icon = 'data/sprites/items/king_crown.png',
    script = 'data/scripts/tiles/king_crown.lua',
    value = 20,
    rarity = 4,
    limit = 1,
})

_data.addTile('jester_hat', {
    name = 'jester_hat_name',
    description = 'jester_hat_description',
    subtype = 'relic',
    icon = 'data/sprites/items/jester_hat.png',
    script = 'data/scripts/tiles/jester_hat.lua',
    value = 20,
    rarity = 4,
    limit = 1,
    modifier = 1.0,
    increase = 0.06,
})

_data.addTile('ectoplasmic_slime', {
    name = 'ectoplasmic_slime_name',
    description = 'ectoplasmic_slime_description',
    subtype = 'relic',
    icon = 'data/sprites/items/ectoplasmic_slime.png',
    script = 'data/scripts/tiles/ectoplasmic_slime.lua',
    value = 20,
    rarity = 4,
    limit = 1,
})
