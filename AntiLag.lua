
-- Anti Lag Hub | Yuri Developer
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "AntiLagHub"
gui.ResetOnSpawn = false

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(260, 300)
panel.Position = UDim2.new(0.5, -130, 0.5, -150)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
panel.Active = true
panel.Draggable = true
panel.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
title.Text = "ANTI LAG HUB"
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = panel

local function makeButton(text, y, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 35)
    b.Position = UDim2.fromOffset(10, y)
    b.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = text .. ": OFF"
    b.Parent = panel

    local enabled = false
    b.Activated:Connect(function()
        enabled = not enabled
        b.Text = text .. (enabled and ": ON" or ": OFF")
        callback(enabled)
    end)
end

local function setEffects(enabled)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Beam") then
            obj.Enabled = not enabled
        end
    end
end

makeButton("Anti Lag / Partículas", 50, setEffects)

makeButton("Sombras", 95, function(enabled)
    Lighting.GlobalShadows = not enabled
end)

makeButton("Céu Cinza", 140, function(enabled)
    Lighting.Ambient = enabled
        and Color3.fromRGB(125, 125, 125)
        or Color3.fromRGB(70, 70, 70)
    Lighting.OutdoorAmbient = Lighting.Ambient
end)

local minimized = false
makeButton("Minimizar", 185, function(enabled)
    minimized = enabled
    for _, child in ipairs(panel:GetChildren()) do
        if child ~= title then
            child.Visible = not minimized
        end
    end
    panel.Size = minimized
        and UDim2.fromOffset(260, 40)
        or UDim2.fromOffset(260, 300)
end)

makeButton("Fechar painel", 230, function()
    gui:Destroy()
end)

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, 0, 0, 20)
credit.Position = UDim2.new(0, 0, 1, -20)
credit.BackgroundTransparency = 1
credit.Text = "Yuri Developer"
credit.TextColor3 = Color3.fromRGB(160, 160, 160)
credit.Parent = panel

gui.Parent = player:WaitForChild("PlayerGui")

