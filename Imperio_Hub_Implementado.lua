-- Imperio Hub - personalizacao do Kira Hub para Steal an Egg
-- Baseado na estrutura observada do script original.
-- Nota: o estado real do Monster Obby precisa ser confirmado por um indicador do jogo;
-- esta versão mantém "Inativo" quando não há sinal conhecido, evitando falsos positivos.

local SOURCE_URL = "https://raw.githubusercontent.com/LSSOPS/OpenSource/refs/heads/main/KiraHub_Steal_An_Egg.lua"

local ok, source = pcall(function()
    return game:HttpGet(SOURCE_URL)
end)
if not ok or type(source) ~= "string" or source == "" then
    error("Imperio Hub: falha ao baixar o script original.")
end

local function replaceOnce(text, old, new, label)
    local a, b = string.find(text, old, 1, true)
    if not a then error("Imperio Hub: não encontrei o trecho '" .. label .. "'. Script original pode ter mudado.") end
    if string.find(text, old, b + 1, true) then error("Imperio Hub: trecho duplicado '" .. label .. "'.") end
    return string.sub(text, 1, a - 1) .. new .. string.sub(text, b + 1)
end

-- Identidade, mantendo a estrutura do hub.
source = source:gsub('Title = "Kira Hub"', 'Title = "Imperio Hub"')
source = source:gsub('"Kira Hub"', '"Imperio Hub"')
source = source:gsub('KiraWorldGui_', 'ImperioWorldGui_')
source = source:gsub('t1%.LogoFile = "Kira" %.. "/logo%.png"', 't1.LogoFile = "Imperio" .. "/logo.png"')
source = source:gsub('t1%.LogoFileLight = "Kira" %.. "/logo%-light%.png"', 't1.LogoFileLight = "Imperio" .. "/logo-light.png"')

-- Tema roxo nos dois temas (Dark e Light).
source = source:gsub('Color3%.fromRGB%(214, 168, 108%)', 'Color3.fromRGB(168, 85, 247)')
source = source:gsub('Color3%.fromRGB%(92, 68, 36%)', 'Color3.fromRGB(91, 33, 182)')
source = source:gsub('Color3%.fromRGB%(228, 186, 128%)', 'Color3.fromRGB(192, 132, 252)')
source = source:gsub('Color3%.fromRGB%(168, 114, 56%)', 'Color3.fromRGB(147, 51, 234)')
source = source:gsub('Color3%.fromRGB%(120, 80, 38%)', 'Color3.fromRGB(107, 33, 168)')
source = source:gsub('Color3%.fromRGB%(186, 132, 70%)', 'Color3.fromRGB(192, 132, 252)')
source = source:gsub('Kira = Color3%.fromRGB%(246, 242, 234%)', 'Kira = Color3.fromRGB(192, 132, 252)')
source = source:gsub('Kira = Color3%.fromRGB%(28, 24, 20%)', 'Kira = Color3.fromRGB(147, 51, 234)')

-- Ícone da aba Eventos.
source = replaceOnce(source,
    '["Auto Steal"] = "egg",',
    '["Auto Steal"] = "egg",\n\t\t\t\tEventos = "flag",',
    "ícone Eventos")

-- Adiciona a página e sua navegação ao menu.
source = replaceOnce(source,
    'local v300 = v259("Settings", "window and config")',
    'local v300 = v259("Settings", "window and config")\nlocal v310 = v259("Eventos", "Monster Obby e velocidade do percurso")',
    "página Eventos")
source = replaceOnce(source,
    'v261("Config", {\n\t"Webhook",\n\t"Settings"\n}, 50);',
    'v261("Config", {\n\t"Webhook",\n\t"Settings"\n}, 50)\nv261("Eventos", { "Eventos" }, 60);',
    "grupo Eventos")

-- Conteúdo do painel Eventos. O status começa Inativo por segurança.
source = replaceOnce(source,
    'v263(v295, "Auto steal")',
    'v263(v310, "Monster Obby")\nv293(v310, "Status do evento", "Inativo")\nv281(v310, "AutoMonsterObby", "Auto Monster Obby", "Liga/desliga a opção de automação do evento.", false)\nv263(v310, "Speed Recurso")\nv293(v310, "configurações da velocidade do percurso", "Escolha o estilo de movimento.")\nv287(v310, "EventSpeedMode", "Velocidade", "Rápido prioriza velocidade; Seguro prioriza um percurso controlado.", { "Rápido", "Seguro" }, "Seguro", false)\nv263(v295, "Auto steal")',
    "conteúdo Eventos")

-- Atualiza o status a cada 3 s. Só marca Ativo se houver um indicador explícito
-- de estado/evento em objetos replicados. Como os nomes reais podem variar, o fallback é Inativo.
local statusPatch = [[
-- Imperio Hub: verificação conservadora do estado do evento.
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local function explicitEventState()
        local roots = {workspace, ReplicatedStorage}
        for _, root in ipairs(roots) do
            for _, obj in ipairs(root:GetDescendants()) do
                local n = string.lower(obj.Name)
                if string.find(n, "monster", 1, true) and
                   (string.find(n, "event", 1, true) or string.find(n, "obby", 1, true) or string.find(n, "active", 1, true)) then
                    local value
                    pcall(function()
                        if obj:IsA("BoolValue") then value = obj.Value end
                        if obj:IsA("StringValue") then
                            local s = string.lower(obj.Value)
                            if s == "active" or s == "started" or s == "true" then value = true end
                            if s == "inactive" or s == "ended" or s == "false" then value = false end
                        end
                        local a = obj:GetAttribute("Active")
                        if type(a) == "boolean" then value = a end
                        local b = obj:GetAttribute("IsActive")
                        if type(b) == "boolean" then value = b end
                    end)
                    if value ~= nil then return value end
                end
            end
        end
        return false
    end
    while task.wait(3) do
        t9.EventStatus = explicitEventState() and "Ativo" or "Inativo"
    end
end)
]]
source = replaceOnce(source,
    'u68("Auto Steal")',
    statusPatch .. '\nu68("Auto Steal")',
    "verificador de status")

-- Compila antes de executar.
if type(loadstring) ~= "function" then
    error("Imperio Hub: loadstring não está disponível neste executor.")
end
local chunk, compileError = loadstring(source)
if not chunk then
    error("Imperio Hub: erro de compilação: " .. tostring(compileError))
end
return chunk()
