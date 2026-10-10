-- Imperio Hub - carregador de personalização
-- Preserva o script-base e aplica alterações de interface por substituições verificadas.
-- IMPORTANTE: a detecção do Monster Obby depende dos nomes reais de estado replicados pelo jogo.
-- Este arquivo não inventa um estado "ativo" quando não consegue confirmá-lo.

local SOURCE_URL = "https://raw.githubusercontent.com/LSSOPS/OpenSource/refs/heads/main/KiraHub_Steal_An_Egg.lua"

local function replaceOnce(source, oldText, newText, label)
    local first, last = string.find(source, oldText, 1, true)
    if not first then
        error("Imperio Hub: não encontrei '" .. label .. "'. O script original pode ter mudado.")
    end
    if string.find(source, oldText, last + 1, true) then
        error("Imperio Hub: trecho duplicado para '" .. label .. "'; parei para evitar alterações erradas.")
    end
    return string.sub(source, 1, first - 1) .. newText .. string.sub(source, last + 1)
end

local ok, source = pcall(function()
    return game:HttpGet(SOURCE_URL)
end)
if not ok or type(source) ~= "string" or source == "" then
    error("Imperio Hub: não foi possível baixar o script original.")
end

-- Nome e identidade visual.
source = source:gsub('"Kira Hub"', '"Imperio Hub"')
source = source:gsub('"Kira"', '"Y"')
source = source:gsub('KiraWorldGui_', 'ImperioWorldGui_')
source = source:gsub('KiraUI', 'ImperioUI')

-- Paleta roxa: mantém fundos e contraste, alterando os acentos marrom/dourado.
source = replaceOnce(source,
    'accent = Color3.fromRGB(214, 168, 108),',
    'accent = Color3.fromRGB(168, 85, 247),',
    "acento roxo escuro")
source = replaceOnce(source,
    'accentDeep = Color3.fromRGB(92, 68, 36),',
    'accentDeep = Color3.fromRGB(91, 33, 182),',
    "acento profundo roxo")
source = replaceOnce(source,
    'accentHover = Color3.fromRGB(228, 186, 128),',
    'accentHover = Color3.fromRGB(192, 132, 252),',
    "acento hover roxo")
source = replaceOnce(source,
    'accent = Color3.fromRGB(168, 114, 56),',
    'accent = Color3.fromRGB(147, 51, 234),',
    "acento roxo claro")
source = replaceOnce(source,
    'accentDeep = Color3.fromRGB(120, 80, 38),',
    'accentDeep = Color3.fromRGB(107, 33, 168),',
    "acento profundo claro")
source = replaceOnce(source,
    'accentHover = Color3.fromRGB(186, 132, 70),',
    'accentHover = Color3.fromRGB(192, 132, 252),',
    "acento hover claro")

-- O filtro Value eggs que já existia no Império é mantido.
source = replaceOnce(source,
    'v288(v295, "MinWeight", "Minimum weight (Kg)", "the same Kg the game shows — blank for any", "any", "")',
    'v288(v295, "MinWeight", "Minimum weight (Kg)", "the same Kg the game shows — blank for any", "any", "")\n            v288(v295, "ValueEggs", "Value eggs", "Minimum egg earnings ($/s); e.g. 1m, 50m, 1b, 50b. Blank = any.", "any · e.g. 1b", "")',
    "campo Value eggs")
source = replaceOnce(source,
    '        local num = tonumber(t9.MinWeight)',
    '        local minEggValue = v1194(t9.ValueEggs)\n        if minEggValue > 0 and minEggValue > v1193(p308, p309) then\n            return false\n        end\n\n        local num = tonumber(t9.MinWeight)',
    "filtro Value eggs")

-- Adiciona uma página Eventos ao sistema de navegação existente.
-- O status fica explicitamente INATIVO até que se implemente/valide um identificador real do evento.
source = replaceOnce(source,
    'local v300 = v259("Settings", "window and config")',
    'local v300 = v259("Settings", "window and config")\nlocal v310 = v259("Eventos", "Monster Obby e velocidade do percurso")',
    "página Eventos")
source = replaceOnce(source,
    'v261("Config", {\n\t"Webhook",\n\t"Settings"\n}, 50);',
    'v261("Config", {\n\t"Webhook",\n\t"Settings"\n}, 50)\nv261("Eventos", { "Eventos" }, 60);',
    "navegação Eventos")
source = replaceOnce(source,
    'v263(v295, "Auto steal")',
    'v263(v310, "Monster Obby")\nv293(v310, "Status do evento", "Inativo")\nv281(v310, "AutoMonsterObby", "Auto Monster Obby", "Ativa a automação do percurso quando configurada.", false)\nv263(v310, "Speed Recurso")\nv293(v310, "configurações da velocidade do percurso", "Escolha uma opção de velocidade abaixo.")\nv287(v310, "EventSpeedMode", "Velocidade", "Rápido prioriza velocidade; Seguro prioriza movimento controlado.", { "Rápido", "Seguro" }, "Seguro", false)\nv263(v295, "Auto steal")',
    "conteúdo inicial Eventos")

-- Não removemos Auto Rejoin nem criamos uma detecção falsa: no código-base atual não existe
-- uma opção com esse nome, e ainda é necessário identificar os sinais reais do Monster Obby.
if type(loadstring) ~= "function" then
    error("Imperio Hub: loadstring não está disponível neste ambiente.")
end
local chunk, compileError = loadstring(source)
if not chunk then
    error("Imperio Hub: erro de compilação: " .. tostring(compileError))
end
return chunk()
