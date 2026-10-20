local effectSpawner = {}

local _effects = {
    heart = {
        size = {
            x = 36,
            y = 36,
        },
        animations = {
            'data/animations/effects/heart_1/data.json',
            'data/animations/effects/heart_2/data.json',
            'data/animations/effects/heart_3/data.json',
            'data/animations/effects/heart_4/data.json',
            'data/animations/effects/heart_5/data.json',
        },
    },
    steam = {
        size = {
            x = 64,
            y = 64,
        },
        animations = {
            'data/animations/effects/steam_1/data.json',
            'data/animations/effects/steam_2/data.json',
            'data/animations/effects/steam_3/data.json',
            'data/animations/effects/steam_4/data.json',
            'data/animations/effects/steam_5/data.json',
        },
    },
    sparkle = {
        size = {
            x = 16,
            y = 16
        },
        animations = {
            'data/animations/effects/sparkle_1/data.json',
            'data/animations/effects/sparkle_2/data.json',
            'data/animations/effects/sparkle_3/data.json',
            'data/animations/effects/sparkle_4/data.json',
            'data/animations/effects/sparkle_5/data.json',
        }
    }
}

local function _spawnObject(parent, animationKey, size)
    local animation = game.data.loadAnimation(animationKey)
    if animation == nil then
        return nil
    end
    local object = game.object.new(parent)
    object.setSize(size.x, size.y)
    object.addComponent('image')
    local animator = object.addComponent('animator')
    animator.play(animation)
    local function destroy()
        object.destroy()
    end
    animator.onCompletion.subscribe(destroy)
    return object
end

local function _spawnCollectionEffect(animationKey, size)
    local parent = game.object.getRoot().find('collection/bestiary/overlay')
    local object = _spawnObject(parent, animationKey, size)
    if object ~= nil then
        object.getComponent('animator').setIgnoreTimescale(true)
    end
    return object
end

local function _spawnViewportEffect(animationKey, size)
    local parent = game.object.getRoot().find('main/viewport')
    return _spawnObject(parent, animationKey, size)
end

local function _spawnEffectObject(animationKey, size)
    if game.collectionOpen then
        return _spawnCollectionEffect(animationKey, size)
    else
        return _spawnViewportEffect(animationKey, size)
    end
end

local function _getRandomEffect(key)
    local spawn = _effects[key]
    if spawn == nil then
        return nil
    end
    spawn.index = spawn.index or 0
    spawn.index = spawn.index + 1
    if spawn.index > #spawn.animations then
        spawn.index = 1
    end
    local animationKey = spawn.animations[spawn.index]
    if animationKey == nil then
        return nil
    end
    return _spawnEffectObject(animationKey, spawn.size)
end

function effectSpawner.spawn(key, range, color)
    local effect = _getRandomEffect(key)
    if effect == nil then
        return
    end
    local x = (math.random() * (range.max.x - range.min.x)) + range.min.x
    local y = (math.random() * (range.max.y - range.min.y)) + range.min.y
    effect.setPosition(x, y)
    local image = effect.getComponent('image')
    image.setColor(color.r, color.g, color.b, color.a)
end

return effectSpawner
