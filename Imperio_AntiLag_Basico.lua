-- Imperio AntiLag - versão básica
-- Coloque como LocalScript em StarterPlayer > StarterPlayerScripts.
-- As alterações são locais: afetam apenas a aparência no seu cliente.

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- 1) Reduzir detalhes visuais do mapa
local function reduzirObjeto(obj)
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
        obj.CastShadow = false
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1
    elseif obj:IsA("SurfaceAppearance") then
        obj:Destroy()
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail")
        or obj:IsA("Beam") or obj:IsA("Smoke")
        or obj:IsA("Fire") or obj:IsA("Sparkles") then
        obj.Enabled = false
    elseif obj:IsA("PostEffect") then
        obj.Enabled = false
    end
end

-- Aplicar aos objetos que já existem
for _, obj in ipairs(Workspace:GetDescendants()) do
    reduzirObjeto(obj)
end

-- Aplicar também aos objetos criados depois
Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        if obj and obj.Parent then
            reduzirObjeto(obj)
        end
    end)
end)

-- Remover detalhes decorativos do terreno
local terrain = Workspace:FindFirstChildOfClass("Terrain")
if terrain then
    terrain.Decoration = false
end

-- 2) Céu cinza escuro (não preto)
Lighting.GlobalShadows = false
Lighting.Brightness = 1
Lighting.Ambient = Color3.fromRGB(75, 75, 75)
Lighting.OutdoorAmbient = Color3.fromRGB(65, 65, 65)
Lighting.ColorShift_Top = Color3.fromRGB(55, 55, 55)
Lighting.ColorShift_Bottom = Color3.fromRGB(45, 45, 45)

-- Atmosfera para dar o tom cinza escuro ao céu
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if not atmosphere then
    atmosphere = Instance.new("Atmosphere")
    atmosphere.Parent = Lighting
end

atmosphere.Color = Color3.fromRGB(75, 75, 75)
atmosphere.Decay = Color3.fromRGB(55, 55, 55)
atmosphere.Density = 0.45
atmosphere.Haze = 2
atmosphere.Glare = 0

print("Imperio AntiLag: otimizações visuais aplicadas.")
