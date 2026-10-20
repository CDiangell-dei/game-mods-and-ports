-- SAFE MATH: formulas para o jogo nao quebrar com numeros muito grandes.
--
-- O que da errado com numeros enormes (Lua usa double de 64 bits):
--   * acima de ~1.8e308 o resultado vira inf; inf - inf, inf * 0 e inf / inf viram NaN
--     e NaN contamina tudo (ouro, barras, comparacoes). NaN nunca volta ao normal.
--   * acima de ~9e15 somar um numero pequeno nao muda nada (perde precisao); um contador
--     que anda de 1 em 1 nunca chega no destino.
--   * a ^ b cresce rapido: 1.58 ^ andar passa de 1e308 no andar ~1556.
--
-- Estrategia: todo valor fica entre -MAX e MAX (MAX = 1e300, longe do limite do double),
-- NaN vira 0, e contas que estouram sao refeitas em escala logaritmica (somando logs).

local safe = {}

safe.MAX = 1e300
safe.LOG_MAX = math.log(safe.MAX) -- ~690.8

function safe.isFinite(x)
    return x == x and x ~= math.huge and x ~= -math.huge
end

-- NaN -> fallback (0); +-inf -> +-MAX; qualquer valor limitado a +-MAX
function safe.sanitize(x, fallback)
    if x ~= x then
        return fallback or 0
    end
    if x > safe.MAX then
        return safe.MAX
    end
    if x < -safe.MAX then
        return -safe.MAX
    end
    return x
end

function safe.add(a, b)
    return safe.sanitize(safe.sanitize(a) + safe.sanitize(b))
end

-- a * b; se estourar, calcula por logaritmo: exp(log|a| + log|b|), limitado a MAX
function safe.mul(a, b)
    a, b = safe.sanitize(a), safe.sanitize(b)
    local result = a * b
    if safe.isFinite(result) and math.abs(result) <= safe.MAX then
        return result
    end
    if a == 0 or b == 0 then
        return 0
    end
    local sign = ((a < 0) ~= (b < 0)) and -1 or 1
    local logValue = math.log(math.abs(a)) + math.log(math.abs(b))
    return sign * math.exp(math.min(logValue, safe.LOG_MAX))
end

-- base ^ expoente (base > 0): exp(expoente * log(base)), limitado a MAX
function safe.pow(base, exponent)
    if base <= 0 then
        return safe.sanitize(base ^ exponent)
    end
    local logValue = exponent * math.log(base)
    if logValue ~= logValue then
        return 0
    end
    return math.exp(math.min(logValue, safe.LOG_MAX))
end

-- a / b sem NaN: se der inf/NaN, usa exp(log a - log b)
function safe.ratio(a, b)
    a, b = safe.sanitize(a), safe.sanitize(b)
    if b == 0 then
        return a > 0 and safe.MAX or 0
    end
    local result = a / b
    if safe.isFinite(result) then
        return result
    end
    local sign = ((a < 0) ~= (b < 0)) and -1 or 1
    return sign * math.exp(math.min(math.log(math.abs(a)) - math.log(math.abs(b)), safe.LOG_MAX))
end

-- menor passo que ainda muda o numero (double tem 52 bits de mantissa)
function safe.ulp(x)
    return math.abs(x) * 2 ^ -52
end

-- passo do contador animado da tela: rapido para numeros enormes e sem ficar preso
function safe.lagStep(increment, difference, current)
    -- numeros enormes: fecha 1/8 da distancia por quadro (em vez de 1/30)
    if difference > 1e6 then
        increment = math.max(increment, math.floor(difference / 8))
    end
    -- passo menor que a precisao do double nao muda nada: vai direto ao destino
    if increment <= safe.ulp(current) * 2 then
        increment = difference
    end
    return increment
end

return safe
