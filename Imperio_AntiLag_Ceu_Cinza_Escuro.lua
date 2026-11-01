-- IMPÉRIO Anti Lag Hub — Céu simplificado com cinza mais escuro
-- Mantém o script original e altera somente as duas cores da opção "Céu simplificado".

local url = "https://raw.githubusercontent.com/fryer02kj-hash/Ant-Lag-/refs/heads/main/Imperio_AntiLag_Hub_40_Opcoes.lua"
local source = game:HttpGet(url)

local function replaceOnce(text, old, new)
    local startPos, endPos = text:find(old, 1, true)
    assert(startPos, "Não foi possível localizar a cor original: " .. old)
    return text:sub(1, startPos - 1) .. new .. text:sub(endPos + 1)
end

-- Antes: Color3.fromRGB(140,140,140) e Color3.fromRGB(90,90,90)
-- Depois: cinza médio-escuro, sem ficar preto.
source = replaceOnce(source, "Color3.fromRGB(140,140,140)", "Color3.fromRGB(110,110,110)")
source = replaceOnce(source, "Color3.fromRGB(90,90,90)", "Color3.fromRGB(75,75,75)")

local run = loadstring or load
assert(run, "Este ambiente não permite executar scripts carregados.")
run(source)()
