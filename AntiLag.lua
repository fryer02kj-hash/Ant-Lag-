
-- Anti Lag Hub | Yuri Developer

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "AntiLagHub"
gui.ResetOnSpawn = false

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(260, 330)
panel.Position = UDim2.new(0.5, -130, 0.5, -165)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
panel.Active = true
panel.Draggable = true
panel.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
title.Text = "ANTI LAG HUB"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Parent = panel

local minimized = false
local function button(text, y, callback)
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
    return b
end

local function particles(enabled)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Beam") then
            obj.Enabled = not enabled
        end
    end
end

button("Anti Lag / Partículas", 50, particles)

button("Sombras", 90, function(enabled)
    Lighting.GlobalShadows = not enabled
end)

local oldAmbient = Lighting.Ambient
local oldOutdoor = Lighting.OutdoorAmbient
button("Iluminação cinza", 130, function(enabled)
    if enabled then
        Lighting.Ambient = Color3.fromRGB(125, 125, 125)
        Lighting.OutdoorAmbient = Color3.fromRGB(125, 125, 125)
    else
        Lighting.Ambient = oldAmbient
        Lighting.OutdoorAmbient = oldOutdoor
    end
end)

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, -20, 0, 25)
fpsLabel.Position = UDim2.fromOffset(10, 170)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.new(1, 1, 1)
fpsLabel.Text = "FPS: calculando..."
fpsLabel.Parent = panel

local showFPS = false
button("Mostrar FPS", 200, function(enabled)
    showFPS = enabled
    fpsLabel.Visible = enabled
end)

local fpsFrames, fpsTime = 0, 0
local connection = RunService.RenderStepped:Connect(function(dt)
    fpsFrames += 1
    fpsTime += dt
    if fpsTime >= 1 then
        fpsLabel.Text = "FPS: " .. fpsFrames
        fpsFrames, fpsTime = 0, 0
    end
end)

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(35, 35)
minimize.Position = UDim2.new(1, -75, 0, 2)
minimize.Text = "_"
minimize.Parent = panel

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(35, 35)
close.Position = UDim2.new(1, -38, 0, 2)
close.Text = "X"
close.Parent = panel

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(120, 35)
toggle.Position = UDim2.new(0, 10, 0, 10)
toggle.Text = "Abrir Anti Lag"
toggle.Visible = false
toggle.Parent = gui

minimize.Activated:Connect(function()
    minimized = not minimized
    for _, child in ipairs(panel:GetChildren()) do
        if child ~= title and child ~= minimize and child ~= close then
            child.Visible = not minimized
        end
    end
    panel.Size = minimized
        and UDim2.fromOffset(260, 40)
        or UDim2.fromOffset(260, 330)
    toggle.Visible = minimized
end)

toggle.Activated:Connect(function()
    minimized = false
    panel.Size = UDim2.fromOffset(260, 330)
    for _, child in ipairs(panel:GetChildren()) do
        child.Visible = true
    end
    toggle.Visible = false
end)

close.Activated:Connect(function()
    connection:Disconnect()
    gui:Destroy()
end)

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, 0, 0, 18)
credit.Position = UDim2.new(0, 0, 1, -18)
credit.BackgroundTransparency = 1
credit.Text = "Yuri Developer"
credit.TextColor3 = Color3.fromRGB(160, 160, 160)
credit.TextSize = 11
credit.Parent = panel

gui.Parent = player:WaitForChild("PlayerGui")

