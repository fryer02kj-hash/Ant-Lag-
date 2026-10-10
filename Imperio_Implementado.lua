-- Império.lua — versão com filtro mínimo de rendimento dos ovos.
-- Baixa o código-base e aplica as alterações antes de executar.
-- Campo "Value eggs": aceita valores como 1m, 50m, 1b, 50b.
-- O limite é comparado com o rendimento por segundo ($/s) calculado pelo jogo.

local SOURCE_URL = "https://raw.githubusercontent.com/LSSOPS/OpenSource/refs/heads/main/KiraHub_Steal_An_Egg.lua"

local function replaceOnce(source, oldText, newText, label)
    local first, last = string.find(source, oldText, 1, true)
    if not first then
        error("Império: não foi possível aplicar '" .. label .. "'; o código original pode ter mudado.")
    end
    if string.find(source, oldText, last + 1, true) then
        error("Império: trecho ambíguo ao aplicar '" .. label .. "'.")
    end
    return string.sub(source, 1, first - 1) .. newText .. string.sub(source, last + 1)
end

local ok, source = pcall(function()
    return game:HttpGet(SOURCE_URL)
end)

if not ok or type(source) ~= "string" or source == "" then
    error("Império: não foi possível baixar o código-base.")
end

source = source:gsub('"Kira Hub"', '"Império"')

source = replaceOnce(
    source,
    'v288(v295, "MinWeight", "Minimum weight (Kg)", "the same Kg the game shows — blank for any", "any", "")',
    'v288(v295, "MinWeight", "Minimum weight (Kg)", "the same Kg the game shows — blank for any", "any", "")\n    v288(v295, "ValueEggs", "Value eggs", "Minimum egg earnings ($/s); e.g. 1m, 50m, 1b, 50b. Blank = any.", "any · e.g. 1b", "")',
    "campo Value eggs"
)

source = replaceOnce(
    source,
    '            local v3173 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil\n            local v3174 = v1209(p311)\n\n            if not v3174 or v1213(p311, v3174) then\n                return\n            end\n\n            return {\n\t\t\t\trec = p311,\n\t\t\t\tcfg = v3173,\n\t\t\t\tpos = v3174,\n\t\t\t\tearn = v1193(p311, v3173),',
    '            local v3173 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil\n            local eggEarn = v1193(p311, v3173)\n            local minEggValue = v1194(t9.ValueEggs)\n            if minEggValue > 0 and minEggValue > (tonumber(eggEarn) or 0) then\n                return\n            end\n            local v3174 = v1209(p311)\n\n            if not v3174 or v1213(p311, v3174) then\n                return\n            end\n\n            return {\n\t\t\t\trec = p311,\n\t\t\t\tcfg = v3173,\n\t\t\t\tpos = v3174,\n\t\t\t\tearn = eggEarn,',
    "filtro mínimo do Auto Steal"
)

local compile = loadstring
if type(compile) ~= "function" then
    error("Império: este ambiente não oferece loadstring.")
end

local chunk, compileError = compile(source)
if not chunk then
    error("Império: erro de compilação após aplicar a alteração: " .. tostring(compileError))
end

return chunk()
