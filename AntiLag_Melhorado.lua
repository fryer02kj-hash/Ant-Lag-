-- IMPÉRIO Anti Lag Hub
-- Yuri Developer
-- LocalScript para uma experiência Roblox própria.
-- Instale em StarterPlayer > StarterPlayerScripts no Roblox Studio.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Para exibir o logo, envie a imagem ao Roblox e coloque o ID aqui:
-- Exemplo: local LOGO_IMAGE = "rbxassetid://1234567890"
local LOGO_IMAGE = "rbxassetid://0"

local RED = Color3.fromRGB(230, 25, 45)
local BLACK = Color3.fromRGB(13, 13, 16)
local PANEL_COLOR = Color3.fromRGB(22, 22, 27)
local WHITE = Color3.fromRGB(245, 245, 245)
local MUTED = Color3.fromRGB(175, 175, 185)

-- Limpa uma execução anterior para não duplicar a interface.
local oldGui = playerGui:FindFirstChild("ImperioAntiLagGui")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ImperioAntiLagGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 100
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function addCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
    return corner
end

local function addStroke(object, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Parent = object
    return stroke
end

-- Painel principal
local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0.88, 0, 0, 285)
panel.Position = UDim2.new(0.5, 0, 0.5, 0)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = BLACK
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Visible = false
panel.Parent = gui
addCorner(panel, 24)
local panelStroke = addStroke(panel, RED, 2)

-- Fundo líquido vermelho/preto animado com gradientes em movimento.
local liquidGradient = Instance.new("UIGradient")
liquidGradient.Name = "LiquidRedBlack"
liquidGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(5, 5, 8)),
    ColorSequenceKeypoint.new(0.20, Color3.fromRGB(45, 0, 8)),
    ColorSequenceKeypoint.new(0.38, Color3.fromRGB(220, 0, 30)),
    ColorSequenceKeypoint.new(0.52, Color3.fromRGB(8, 5, 9)),
    ColorSequenceKeypoint.new(0.70, Color3.fromRGB(85, 0, 15)),
    ColorSequenceKeypoint.new(0.86, Color3.fromRGB(240, 10, 35)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(5, 5, 8)),
})
liquidGradient.Rotation = 15
liquidGradient.Parent = panel

local liquidTween = TweenService:Create(
    liquidGradient,
    TweenInfo.new(7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    { Offset = Vector2.new(1, 0), Rotation = 195 }
)
liquidTween:Play()

-- Camada escura translúcida mantém o texto legível sobre o efeito.
local liquidShade = Instance.new("Frame")
liquidShade.Name = "LiquidShade"
liquidShade.Size = UDim2.fromScale(1, 1)
liquidShade.BackgroundColor3 = Color3.fromRGB(5, 4, 8)
liquidShade.BackgroundTransparency = 0.22
liquidShade.BorderSizePixel = 0
liquidShade.ZIndex = 1
liquidShade.Parent = panel
addCorner(liquidShade, 24)

panelStroke.Thickness = 2

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 58)
header.BackgroundColor3 = PANEL_COLOR
header.BorderSizePixel = 0
header.ZIndex = 2
header.Parent = panel
addCorner(header, 18)
header.ZIndex = 2
local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 7, 10)),
    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(80, 0, 16)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(8, 7, 10)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(150, 0, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 7, 10)),
})
headerGradient.Parent = header
TweenService:Create(
    headerGradient,
    TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    { Offset = Vector2.new(1, 0) }
):Play()

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 12)
headerFix.Position = UDim2.new(0, 0, 1, -12)
headerFix.BackgroundColor3 = PANEL_COLOR
headerFix.BorderSizePixel = 0
headerFix.ZIndex = 3
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(14, 5)
title.Size = UDim2.new(1, -28, 0, 26)
title.Font = Enum.Font.GothamBold
title.Text = "IMPÉRIO"
title.TextColor3 = RED
title.TextSize = 21
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(15, 31)
subtitle.Size = UDim2.new(1, -30, 0, 17)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "ANTI LAG HUB  •  Yuri Developer"
subtitle.TextColor3 = MUTED
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 3
title.Parent = header

local buttonArea = Instance.new("ScrollingFrame")
buttonArea.Name = "ButtonScrollArea"
buttonArea.BackgroundTransparency = 1
buttonArea.BorderSizePixel = 0
buttonArea.Position = UDim2.fromOffset(13, 70)
buttonArea.Size = UDim2.new(1, -26, 1, -82)
buttonArea.CanvasSize = UDim2.new(0, 0, 0, 0)
buttonArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
buttonArea.ScrollingDirection = Enum.ScrollingDirection.Y
buttonArea.ScrollBarThickness = 5
buttonArea.ScrollBarImageColor3 = RED
buttonArea.Active = true
buttonArea.ZIndex = 3
buttonArea.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = buttonArea

local function makeButton(label, order)
    local button = Instance.new("TextButton")
    button.Name = "Button" .. tostring(order)
    button.LayoutOrder = order
    button.Size = UDim2.new(1, -6, 0, 42)
    button.BackgroundColor3 = PANEL_COLOR
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Font = Enum.Font.GothamSemibold
    button.Text = label .. "   [OFF]"
    button.TextColor3 = WHITE
    button.TextSize = 13
    button.Parent = buttonArea
    addCorner(button, 8)
    addStroke(button, Color3.fromRGB(65, 30, 35), 1)
    return button
end

local antiLagButton = makeButton("Anti Lag", 1)
local particlesButton = makeButton("Remover partículas", 2)
local shadowsButton = makeButton("Remover sombras", 3)
local graySkyButton = makeButton("Céu cinza", 4)
local fpsButton = makeButton("FPS e Ping", 5)

local function setButtonState(button, label, enabled)
    button.Text = label .. (enabled and "   [ON]" or "   [OFF]")
    button.TextColor3 = enabled and RED or WHITE
end

local antiLagEnabled = false
local particlesEnabled = false
local shadowsEnabled = false
local graySkyEnabled = false
local fpsEnabled = false

-- Valores originais usados para restaurar o estado visual.
local originalLighting = {
    GlobalShadows = Lighting.GlobalShadows,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
}

-- Os estados são compartilhados entre os modos para que desligar um botão
-- não reative um efeito que outro modo ainda precisa manter desligado.
local originalParticleStates = {}
local originalPostEffectStates = {}
local originalTextureStates = {}
local originalLightStates = {}
local originalPartShadows = {}
local originalSkyObjects = {}
local graySkyObjects = {}

local function isParticleLike(obj)
    return obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Beam")
        or obj:IsA("Fire")
        or obj:IsA("Smoke")
        or obj:IsA("Sparkles")
end

local function rememberAndDisableEffects()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isParticleLike(obj) then
            if originalParticleStates[obj] == nil then
                originalParticleStates[obj] = obj.Enabled
            end
            obj.Enabled = false
        elseif obj:IsA("PostEffect") then
            if originalPostEffectStates[obj] == nil then
                originalPostEffectStates[obj] = obj.Enabled
            end
            obj.Enabled = false
        end
        if antiLagEnabled and (obj:IsA("Decal") or obj:IsA("Texture")) then
            if originalTextureStates[obj] == nil then
                originalTextureStates[obj] = obj.Transparency
            end
            obj.Transparency = 1
        end
        if antiLagEnabled and (obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")) then
            if originalLightStates[obj] == nil then
                originalLightStates[obj] = obj.Enabled
            end
            obj.Enabled = false
        end
    end
end

local function restoreEffectsIfUnused()
    local shouldDisableParticles = antiLagEnabled or particlesEnabled
    local shouldDisablePostEffects = antiLagEnabled

    for obj, originalValue in pairs(originalParticleStates) do
        if obj and obj.Parent then
            if shouldDisableParticles then
                obj.Enabled = false
            else
                obj.Enabled = originalValue
            end
        end
    end

    for obj, originalValue in pairs(originalPostEffectStates) do
        if obj and obj.Parent then
            if shouldDisablePostEffects then
                obj.Enabled = false
            else
                obj.Enabled = originalValue
            end
        end
    end
end

local function applyAllActiveVisualModes()
    if antiLagEnabled or particlesEnabled then
        rememberAndDisableEffects()
    end
    if shadowsEnabled then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                if originalPartShadows[obj] == nil then
                    originalPartShadows[obj] = obj.CastShadow
                end
                obj.CastShadow = false
            end
        end
        Lighting.GlobalShadows = false
    end
    Lighting.EnvironmentDiffuseScale = antiLagEnabled and 0 or originalLighting.EnvironmentDiffuseScale
    Lighting.EnvironmentSpecularScale = antiLagEnabled and 0 or originalLighting.EnvironmentSpecularScale
end

local function restoreShadowsIfUnused()
    if shadowsEnabled then
        Lighting.GlobalShadows = false
        for obj in pairs(originalPartShadows) do
            if obj and obj.Parent then
                obj.CastShadow = false
            end
        end
        return
    end

    Lighting.GlobalShadows = originalLighting.GlobalShadows
    for obj, originalValue in pairs(originalPartShadows) do
        if obj and obj.Parent then
            obj.CastShadow = originalValue
        end
    end
    table.clear(originalPartShadows)
end

antiLagButton.Activated:Connect(function()
    antiLagEnabled = not antiLagEnabled
    setButtonState(antiLagButton, "Anti Lag", antiLagEnabled)
    applyAllActiveVisualModes()
    restoreEffectsIfUnused()
end)

particlesButton.Activated:Connect(function()
    particlesEnabled = not particlesEnabled
    setButtonState(particlesButton, "Remover partículas", particlesEnabled)
    applyAllActiveVisualModes()
    restoreEffectsIfUnused()
end)

shadowsButton.Activated:Connect(function()
    shadowsEnabled = not shadowsEnabled
    setButtonState(shadowsButton, "Remover sombras", shadowsEnabled)
    applyAllActiveVisualModes()
    restoreShadowsIfUnused()
end)

-- Céu cinza: um Sky sem imagens não produz cinza de forma confiável em todos
-- os jogos. Aqui alteramos apenas a cor Atmosphere, se existir; a aparência
-- depende da iluminação e do skybox que a experiência já usa.
local originalAtmosphereColors = {}

local function applyGraySky()
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") then
            if not originalSkyObjects[obj] then
                originalSkyObjects[obj] = obj.Parent
            end
            obj.Parent = nil
        elseif obj:IsA("Atmosphere") then
            if originalAtmosphereColors[obj] == nil then
                originalAtmosphereColors[obj] = {
                    Color = obj.Color,
                    Decay = obj.Decay,
                    Haze = obj.Haze,
                    Glare = obj.Glare,
                }
            end
            obj.Color = Color3.fromRGB(145, 145, 145)
            obj.Decay = Color3.fromRGB(100, 100, 100)
            obj.Haze = math.max(obj.Haze, 1)
            obj.Glare = 0
        end
    end
end

local function restoreGraySky()
    for obj, originalParent in pairs(originalSkyObjects) do
        if obj then
            obj.Parent = originalParent or Lighting
        end
    end
    table.clear(originalSkyObjects)

    for obj, values in pairs(originalAtmosphereColors) do
        if obj and obj.Parent then
            obj.Color = values.Color
            obj.Decay = values.Decay
            obj.Haze = values.Haze
            obj.Glare = values.Glare
        end
    end
    table.clear(originalAtmosphereColors)
end

graySkyButton.Activated:Connect(function()
    graySkyEnabled = not graySkyEnabled
    setButtonState(graySkyButton, "Céu cinza", graySkyEnabled)
    if graySkyEnabled then
        applyGraySky()
    else
        restoreGraySky()
    end
end)

-- Indicador no canto superior direito.
local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "FPSPingIndicator"
statsLabel.AnchorPoint = Vector2.new(1, 0)
statsLabel.Position = UDim2.new(1, -12, 0, 12)
statsLabel.Size = UDim2.fromOffset(190, 30)
statsLabel.BackgroundColor3 = BLACK
statsLabel.BackgroundTransparency = 0.15
statsLabel.BorderSizePixel = 0
statsLabel.Font = Enum.Font.GothamBold
statsLabel.Text = "FPS: -- | Ping: -- ms"
statsLabel.TextColor3 = WHITE
statsLabel.TextSize = 12
statsLabel.Visible = false
statsLabel.Parent = gui
addCorner(statsLabel, 7)
addStroke(statsLabel, RED, 1)
statsLabel.Active = true
statsLabel.Selectable = true

-- O indicador FPS/Ping pode ser arrastado com o dedo ou mouse.
local statsDragging = false
local statsDragInput = nil
local statsDragStart = nil
local statsStartPos = nil
local statsMoved = false
local function moveStatsIndicator(pos)
    if not statsDragging or not statsDragStart or not statsStartPos then return end
    local delta = pos - statsDragStart
    if math.abs(delta.X) + math.abs(delta.Y) > 4 then statsMoved = true end
    local camera = Workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
    local width = statsLabel.AbsoluteSize.X
    local height = statsLabel.AbsoluteSize.Y
    local x = math.clamp(statsStartPos.X.Offset + delta.X, 0, math.max(0, viewport.X - width))
    local y = math.clamp(statsStartPos.Y.Offset + delta.Y, 0, math.max(0, viewport.Y - height))
    statsLabel.AnchorPoint = Vector2.new(0, 0)
    statsLabel.Position = UDim2.fromOffset(x, y)
end
statsLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        statsDragging = true
        statsDragInput = input
        statsDragStart = input.Position
        statsStartPos = statsLabel.Position
        statsMoved = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if statsDragging and statsDragInput and statsDragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement then
        moveStatsIndicator(input.Position)
    end
end)
UserInputService.TouchMoved:Connect(function(input)
    if statsDragging and statsDragInput and statsDragInput.UserInputType == Enum.UserInputType.Touch then
        moveStatsIndicator(input.Position)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if statsDragging and statsDragInput then
        local touchEnded = statsDragInput.UserInputType == Enum.UserInputType.Touch and input == statsDragInput
        local mouseEnded = statsDragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1
        if touchEnded or mouseEnded then
            statsDragging = false
            statsDragInput = nil
        end
    end
end)

local frameCount = 0
local elapsed = 0
local currentFPS = 0

RunService.RenderStepped:Connect(function(dt)
    frameCount += 1
    elapsed += dt
    if elapsed >= 1 then
        currentFPS = math.floor(frameCount / elapsed + 0.5)
        frameCount = 0
        elapsed = 0
    end

    if fpsEnabled then
        local pingText = "--"
        local ok, result = pcall(function()
            local item = Stats.Network.ServerStatsItem["Data Ping"]
            return item:GetValue()
        end)
        if ok and result then
            pingText = tostring(math.floor(tonumber(result) and tonumber(result) + 0.5 or 0))
        end
        statsLabel.Text = string.format("FPS: %d | Ping: %s ms", currentFPS, pingText)
    end
end)

fpsButton.Activated:Connect(function()
    fpsEnabled = not fpsEnabled
    setButtonState(fpsButton, "FPS e Ping", fpsEnabled)
    statsLabel.Visible = fpsEnabled
end)

-- Botão flutuante IMPÉRIO.
local toggle = Instance.new("ImageButton")
toggle.Name = "ImperioToggle"
toggle.Size = UDim2.fromOffset(58, 58)
toggle.Position = UDim2.new(0, 16, 0.4, 0)
toggle.BackgroundColor3 = BLACK
toggle.BorderSizePixel = 0
toggle.Image = LOGO_IMAGE
 toggle.ScaleType = Enum.ScaleType.Crop
 toggle.ImageTransparency = (LOGO_IMAGE == "rbxassetid://0") and 1 or 0
toggle.Active = true
toggle.Parent = gui
addCorner(toggle, 10)
addStroke(toggle, RED, 2)
local logoFallback = Instance.new("TextLabel")
logoFallback.Name = "LogoFallback"
logoFallback.BackgroundTransparency = 1
logoFallback.Size = UDim2.fromScale(1, 1)
logoFallback.Font = Enum.Font.GothamBold
logoFallback.Text = "IMPÉRIO"
logoFallback.TextColor3 = RED
logoFallback.TextScaled = true
logoFallback.Visible = (LOGO_IMAGE == "rbxassetid://0")
logoFallback.Parent = toggle

-- Arraste por toque ou mouse. Um toque sem movimento abre/fecha o painel.
local dragging = false
local moved = false
local activeInput = nil
local startInputPos = nil
local startButtonPos = nil
local dragThreshold = 7

toggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        moved = false
        activeInput = input
        startInputPos = input.Position
        startButtonPos = toggle.Position
    end
end)

local function updateToggleDrag(position)
    if not dragging or not startInputPos or not startButtonPos then
        return
    end

    local delta = position - startInputPos
    if math.abs(delta.X) > dragThreshold or math.abs(delta.Y) > dragThreshold then
        moved = true
    end

    toggle.Position = UDim2.new(
        startButtonPos.X.Scale,
        startButtonPos.X.Offset + delta.X,
        startButtonPos.Y.Scale,
        startButtonPos.Y.Offset + delta.Y
    )
end

UserInputService.InputChanged:Connect(function(input)
    if not dragging or not activeInput then
        return
    end

    if activeInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateToggleDrag(input.Position)
    end
end)

-- No celular, o InputObject de movimento nem sempre é o mesmo do toque inicial.
UserInputService.TouchMoved:Connect(function(input, gameProcessed)
    if dragging and activeInput
        and activeInput.UserInputType == Enum.UserInputType.Touch then
        updateToggleDrag(input.Position)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if not dragging or not activeInput then
        return
    end

    local touchEnded = activeInput.UserInputType == Enum.UserInputType.Touch
        and input == activeInput
    local mouseEnded = activeInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseButton1

    if touchEnded or mouseEnded then
        dragging = false
        activeInput = nil
        if not moved then
            panel.Visible = not panel.Visible
        end
    end
end)

-- Aplica os modos ativos a novos objetos criados durante o jogo.
Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        if not obj.Parent then
            return
        end

        if (antiLagEnabled or particlesEnabled) and isParticleLike(obj) then
            if originalParticleStates[obj] == nil then
                originalParticleStates[obj] = obj.Enabled
            end
            obj.Enabled = false
        elseif antiLagEnabled and obj:IsA("PostEffect") then
            if originalPostEffectStates[obj] == nil then
                originalPostEffectStates[obj] = obj.Enabled
            end
            obj.Enabled = false
        end

        if antiLagEnabled and (obj:IsA("Decal") or obj:IsA("Texture")) then
            if originalTextureStates[obj] == nil then
                originalTextureStates[obj] = obj.Transparency
            end
            obj.Transparency = 1
        elseif antiLagEnabled and (obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")) then
            if originalLightStates[obj] == nil then
                originalLightStates[obj] = obj.Enabled
            end
            obj.Enabled = false
        end

        if shadowsEnabled and obj:IsA("BasePart") then
            if originalPartShadows[obj] == nil then
                originalPartShadows[obj] = obj.CastShadow
            end
            obj.CastShadow = false
        end
    end)
end)

-- Limpeza ao remover a interface.
gui.Destroying:Connect(function()
    -- Desativa os modos antes da restauração para que nenhum deles
    -- mantenha efeitos ou sombras desligados durante a limpeza.
    antiLagEnabled = false
    particlesEnabled = false
    shadowsEnabled = false
    graySkyEnabled = false
    fpsEnabled = false

    statsLabel.Visible = false
    restoreEffectsIfUnused()
    restoreShadowsIfUnused()
    restoreGraySky()

    Lighting.GlobalShadows = originalLighting.GlobalShadows
    Lighting.EnvironmentDiffuseScale = originalLighting.EnvironmentDiffuseScale
    Lighting.EnvironmentSpecularScale = originalLighting.EnvironmentSpecularScale
end)
