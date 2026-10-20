local inactiveTooltip = {}

local _activeTooltip = nil
local _theme = require('data/scripts/ui/theme.lua')
local _data = require('data/scripts/data.lua')
local _hasInit = false

local function _replaceVariables(descriptionKey, replaceFunction)
    local description = game.text.getText(descriptionKey)
    return string.gsub(description, '(<var=.->)', replaceFunction)
end

local function _getActiveDescription(item)
    local function replace(s)
        local variable = string.match(s, '=(.-)>')
        if item.getVar == nil then
            return s
        end
        local itemVariable = item.getVar(variable)
        if itemVariable == nil then
            return s
        end
        local baseString
        if type(itemVariable) == 'number' then
            baseString = string.format('%.5g', itemVariable)
        elseif type(itemVariable) == 'string' then
            baseString = game.text.getText(itemVariable)
        else
            baseString = tostring(itemVariable)
        end
        return baseString
    end
    return _replaceVariables(item.data.description, replace)
end

local function _getInactiveDescription(data)
    local function replace(s)
        local variable = string.match(s, '=(.-)>')
        local itemVariable = data[variable]
        if type(itemVariable) == 'string' then
            return game.text.getText(itemVariable)
        end
        if itemVariable ~= nil then
            return tostring(itemVariable)
        end
        return s
    end
    return _replaceVariables(data.description, replace)
end

local function _updatePosition()
    if _activeTooltip == nil then
        return
    end
    local x, y = game.input.getMousePosition()
    if x > game.config.canvasWidth - 5 then
        x = game.config.canvasWidth - 5
    end
    if x < 5 then
        x = 5
    end
    if y > game.config.canvasHeight - 5 then
        y = game.config.canvasHeight - 5
    end
    if y < 5 then
        y = 5
    end
    _activeTooltip.setPosition(x, y)
end

local function _getItemCount(data)
    if game.control == nil then
        return 0
    end
    local totalCount = 0
    if data.type == 'tile' then
        local count = game.control.tiles.getCount()
        for i=1, count do
            local tile = game.control.tiles.getTile(i)
            if tile ~= nil then
                if tile.data.key == data.key then
                    totalCount = totalCount + 1
                end
            end
        end
    elseif data.type == 'buff' then
        local count = game.control.buffs.getCount()
        for i=1, count do
            local buff = game.control.buffs.getBuff(i)
            if buff ~= nil then
                if buff.data.key == data.key then
                    totalCount = totalCount +1
                end
            end
        end
    end
    return totalCount
end

local function _getLimitText(data)
    local limit = data.limit or 0
    if limit > 0 then
        local currentCount = _getItemCount(data)
        return tostring(currentCount) .. ' / ' .. tostring(limit)
    end
    return ''
end

local function _getSubTypeText(subtype)
    if subtype == nil then
        return ''
    end
    return game.text.getText('type_' .. subtype)
end

local function _getValueText(value)
    if value ~= nil then
        --value = value * 0.5
        value = math.floor(value + 0.5)
        value = math.max(0, value)
        return tostring(value) .. ' G'
    end
    return ''
end

local function _getCombinationText(data)
    if data.combination ~= nil then
        local target =  _data.tiles[data.combination.target]
        if target == nil then
            return ''
        else
            local comboTranslation = game.text.getText('combines_with')
            local targetName = game.text.getText(target.name)
            return comboTranslation .. targetName
        end
    end
    return ''
end

local function _setRarityText(data, activeTooltip)
    local rarity
    if data.rarity == 4 then
        rarity = 'rarity_legendary'
    elseif data.rarity == 3 then
        rarity = 'rarity_rare'
    elseif data.rarity == 2 then
        rarity = 'rarity_uncommon'
    else
        rarity = 'rarity_common'
    end
    activeTooltip.find('header/view/types/main').getComponent('text').setText(rarity)
end

local function _spawnTooltip(data, description, value, subtype)
    _activeTooltip = game.object.instantiate('data/scenes/tooltip.json')
    --color border
    _theme.colorRarityImage(_activeTooltip.find('spacing1').getComponent('image'), data.rarity)
    _theme.colorRarityImage(_activeTooltip.find('spacing2').getComponent('image'), data.rarity)
    _theme.colorRarityImage(_activeTooltip.find('header').getComponent('image'), data.rarity)
    _theme.colorRarityImage(_activeTooltip.find('description').getComponent('image'), data.rarity)

    local title = _activeTooltip.find('header/view/title/name').getComponent('text')
    title.setText(data.name)
    _theme.colorRarityText(title, data.rarity)

    local limit = _getLimitText(data)
    _activeTooltip.find('header/view/title/limit').getComponent('text').setText(limit)
    local subType = _getSubTypeText(subtype)
    local valueText = _getValueText(value)
    local combination = _getCombinationText(data)
    --_activeTooltip.find('header/view/types/main').getComponent('text').setText('type_' .. data.type)
    _setRarityText(data, _activeTooltip)
    _activeTooltip.find('header/view/types/sub').getComponent('text').setText(subType)
    _activeTooltip.find('description/view/text').getComponent('text').setText(description)
    _activeTooltip.find('description/view/saleValue').getComponent('text').setText(valueText)
    _activeTooltip.find('description/view/saleValue/combination').getComponent('text').setText(combination)
    local x, y = game.input.getMousePosition()
    local pivotX = 0
    if x > game.config.canvasWidth * 0.5 then
        pivotX = 1
    end
    local pivotY = 0
    if y > game.config.canvasHeight * 0.5 then
        pivotY = 1
    end
    _activeTooltip.setPivot(pivotX, pivotY)
    _updatePosition()
end

function inactiveTooltip.initActive(item)
    if _hasInit then
        return
    end
    _hasInit = true
    if item == nil then
        return
    end
    local description = _getActiveDescription(item)
    _spawnTooltip(item.data, description, item.value, item.subtype)
    game.events.subscribe('update', _updatePosition)
end

function inactiveTooltip.initInactive(data)
    if _hasInit then
        return
    end
    _hasInit = true
    if data == nil then
        return
    end
    local description = _getInactiveDescription(data)
    _spawnTooltip(data, description, data.value * 0.5, data.subtype)
    game.events.subscribe('update', _updatePosition)
end

function inactiveTooltip.destroy()
    if _activeTooltip ~= nil then
        _activeTooltip.destroy()
        _activeTooltip = nil
    end
    game.events.unsubscribe('update', _updatePosition)
end

return inactiveTooltip
