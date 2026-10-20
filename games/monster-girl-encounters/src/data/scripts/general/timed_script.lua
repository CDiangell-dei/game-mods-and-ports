local function _init(var)
    local function complete()
        local script = dofile(var.script)
        if type(script) == 'function' then
            script(var.variable)
        end
    end
    game.timer.queue(var.wait, complete)
end

return _init
