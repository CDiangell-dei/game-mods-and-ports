local sliderSmoother = {}

local _laggingBars = {}

local function _smooth(bar, deltaTime)
    local difference = math.abs(bar.current - bar.goal)
    if difference < 0.001 or bar.current > 1.0 then
        return
    end
    local changeAmount = deltaTime * difference * 0.5
    changeAmount = math.max(changeAmount, deltaTime * bar.minSpeed)
    difference = math.min(difference, changeAmount)
    if bar.current < bar.goal then
        bar.current = bar.current + difference
    else
        bar.current = bar.current - difference
    end
    if bar.current > 1.0 then
        bar.current = 1.0
    end
    if bar.current < 0 then
        bar.current = 0
    end
    bar.slider.setValue(bar.current)
end

function sliderSmoother.update(deltaTime)
    for _, bar in pairs(_laggingBars) do
        _smooth(bar, deltaTime)
    end
end

function sliderSmoother.set(slider, goal, minSpeed)
    local bar = _laggingBars[slider]
    if bar == nil then
        bar = {
            slider = slider,
            current = 0,
            minSpeed = minSpeed or 0.1,
        }
        _laggingBars[slider] = bar
    end
    bar.goal = goal
    bar.minSpeed = minSpeed or bar.minSpeed
end

return sliderSmoother