-- Auto Skip Dialog: dialogos avancam sozinhos, igual aos dialogos das batalhas.
--
-- O jogo ja tem um modo automatico (dialogue_text.lua, parametro isAuto): quando o texto
-- termina de aparecer (incluindo as pausas <pause=...> e as pausas de fim de frase), espera o
-- mesmo tempo usado nas batalhas e passa para o proximo dialogo. Os dialogos de batalha ja
-- usam esse modo; este mod apenas liga o mesmo modo nos dialogos que normalmente esperam clique.
-- Escolhas (botoes) continuam esperando o jogador.
local hooks = {}

-- Hook de dialogue_handler.lua (talk): recebe o valor padrao e devolve o valor final
function hooks.dialogueAutoProgress(_)
    return true
end

return { hooks = hooks }
