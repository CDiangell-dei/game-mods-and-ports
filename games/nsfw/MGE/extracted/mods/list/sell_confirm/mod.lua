-- Confirmar venda de item (somente PC).
-- No Android a confirmacao e nativa (shop_helper.lua usa o padrao 'Android'); no PC este mod
-- liga o mesmo popup pelo hook sellNeedsConfirmation. Textos: sell_confirm_* do jogo base.
local hooks = {}

function hooks.sellNeedsConfirmation()
    return true
end

return { hooks = hooks }
