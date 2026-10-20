local function _init(var)
    if game.control.encounter.script[var.name] ~= nil then
        game.control.encounter.script[var.name](var.var)
    end
end

return _init
