-- Império — carregador com o nome do hub alterado
-- Obtém o script original e altera somente o título visível "Kira Hub" para "Império".
-- Requer um ambiente que permita game:HttpGet e loadstring.

local sourceUrl = "https://raw.githubusercontent.com/LSSOPS/OpenSource/refs/heads/main/KiraHub_Steal_An_Egg.lua"

local ok, source = pcall(function()
    return game:HttpGet(sourceUrl)
end)

if not ok or type(source) ~= "string" or source == "" then
    error("Império: não foi possível baixar o script original.")
end

source = source:gsub('"Kira Hub"', '"Império"')

local compile = loadstring
if type(compile) ~= "function" then
    error("Império: loadstring não está disponível neste ambiente.")
end

local chunk, compileError = compile(source)
if not chunk then
    error("Império: erro ao preparar o script: " .. tostring(compileError))
end

return chunk()
