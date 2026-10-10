-- Império.lua — carregador corrigido com o filtro "Value eggs".
-- Aplica o campo e o filtro no código original antes de executar.
-- Requer game:HttpGet e loadstring no ambiente usado.

local SOURCE_URL = "https://raw.githubusercontent.com/LSSOPS/OpenSource/refs/heads/main/KiraHub_Steal_An_Egg.lua"

local function replaceOnce(source, oldText, newText, label)
    local first, last = string.find(source, oldText, 1, true)
    if not first then
        error("Império: não encontrei o trecho '" .. label .. "'. O código remoto pode ter mudado.")
    end
    if string.find(source, oldText, last + 1, true) then
        error("Império: encontrei mais de um trecho para '" .. label .. "'; parei para evitar alterações erradas.")
    end
    return string.sub(source, 1, first - 1) .. newText .. string.sub(source, last + 1)
end

local ok, source = pcall(function()
    return game:HttpGet(SOURCE_URL)
end)

if not ok or type(source) ~= "string" or source == "" then
    error("Império: não foi possível baixar o código original.")
end

-- Altera o título do hub.
source = source:gsub('"Kira Hub"', '"Império"')

-- Adiciona Value eggs logo após o filtro de peso, dentro de Eggs Filter.
source = replaceOnce(
    source,
    'v288(v295, "MinWeight", "Minimum weight (Kg)", "the same Kg the game shows — blank for any", "any", "")',
    'v288(v295, "MinWeight", "Minimum weight (Kg)", "the same Kg the game shows — blank for any", "any", "")\n            v288(v295, "ValueEggs", "Value eggs", "Minimum egg earnings ($/s); e.g. 1m, 50m, 1b, 50b. Blank = any.", "any · e.g. 1b", "")',
    "campo Value eggs"
)

-- A função v1215 filtra os ovos por área, raridade, mutação e peso.
-- O limite de rendimento é aplicado nessa mesma função, independentemente do StealMode.
source = replaceOnce(
    source,
    '        local num = tonumber(t9.MinWeight)',
    '        local minEggValue = v1194(t9.ValueEggs)\n        if minEggValue > 0 and minEggValue > v1193(p308, p309) then\n            return false\n        end\n\n        local num = tonumber(t9.MinWeight)',
    "filtro mínimo de rendimento"
)

if type(loadstring) ~= "function" then
    error("Império: loadstring não está disponível neste ambiente.")
end

local chunk, compileError = loadstring(source)
if not chunk then
    error("Império: erro de compilação: " .. tostring(compileError))
end

return chunk()
