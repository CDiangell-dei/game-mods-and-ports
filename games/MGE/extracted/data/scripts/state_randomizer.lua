local stateRandomizer = {}

local function _stateIsAvailable(state, currentValue, occurencesTable)
    if occurencesTable ~= nil and state.isUnique == true and occurencesTable[state] ~= nil then
        return false
    end
    if type(state.min) == 'number' and currentValue < state.min then
        return false
    end
    if type(state.max) == 'number' and currentValue > state.max then
        return false
    end
    return true
end

local function _calculateTotalStateWeight(stateTable, currentValue, occurences)
    local weight = 0
    for _, state in ipairs(stateTable) do
        if _stateIsAvailable(state, currentValue, occurences) then
            if type(state.weight) == 'number' then
                weight = weight + state.weight
            else
                weight = weight + 1.0
            end
        end
    end
    return weight
end

local function _getRandom(states, current, occurences, roll)
    local final = nil
    for _, state in ipairs(states) do
        if _stateIsAvailable(state, current, occurences) then
            if type(state.weight) == 'number' then
                roll = roll - state.weight
            else
                roll = roll - 1.0
            end
            if roll <= 0 then
                return state
            end
            final = state
        end
    end
    return final
end

function stateRandomizer.randomizeState(stateTable, currentValue, occurences)
    if type(stateTable) ~= 'table' or #stateTable < 1 then
        return
    end
    local total = _calculateTotalStateWeight(stateTable, currentValue, occurences)
    if total <= 0 then
        return
    end
    local roll = total * math.random()
    local state = _getRandom(stateTable, currentValue, occurences, roll)
    if state == nil then
        return
    end
    if occurences ~= nil then
        occurences[state] = 1
    end
    return state
end

return stateRandomizer