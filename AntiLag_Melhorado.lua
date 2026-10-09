-- IMPÉRIO Anti Lag Hub
-- Yuri Developer
-- LocalScript para uma experiência própria no Roblox Studio.
-- Instale em StarterPlayer > StarterPlayerScripts.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TEXTURE_IMAGE = "rbxassetid://113820173247546"
local LOGO_IMAGE = "" -- Opcional: coloque aqui o ID de um logo separado.

local RED = Color3.fromRGB(255, 18, 42)
local RED_DARK = Color3.fromRGB(100, 0, 12)
local BLACK = Color3.fromRGB(5, 5, 8)
local PANEL = Color3.fromRGB(10, 7, 10)
local WHITE = Color3.fromRGB(245, 242, 245)
local MUTED = Color3.fromRGB(180, 174, 182)

local oldGui = playerGui:FindFirstChild("ImperioAntiLagGui")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ImperioAntiLagGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

local function makeText(parent, text, size, font, color, pos, dims, xalign)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextSize = size
    t.Font = font
    t.TextColor3 = color
    t.Position = pos
    t.Size = dims
    t.TextXAlignment = xalign or Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Center
    t.Parent = parent
    return t
end

-- Fundo do painel: textura do usuário + camada escura para legibilidade.
local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Size = UDim2.new(0.82, 0, 0.78, 0)
panel.Position = UDim2.fromScale(0.5, 0.52)
panel.BackgroundColor3 = BLACK
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Visible = false
panel.Parent = gui
corner(panel, 28)
stroke(panel, RED, 2)

local panelConstraint = Instance.new("UISizeConstraint")
panelConstraint.MinSize = Vector2.new(320, 300)
panelConstraint.MaxSize = Vector2.new(1050, 760)
panelConstraint.Parent = panel

local texture = Instance.new("ImageLabel")
texture.Name = "LiquidRedBlackTexture"
texture.BackgroundTransparency = 1
texture.Size = UDim2.new(1, 0, 1, 0)
texture.Position = UDim2.new(0, 0, 0, 0)
texture.Image = TEXTURE_IMAGE
texture.ScaleType = Enum.ScaleType.Crop
texture.ImageTransparency = 0.02
texture.ZIndex = 1
texture.Parent = panel

-- Movimento de fluxo em camadas. A imagem pode não aparecer enquanto o asset estiver em revisão.
local textureOverlay = Instance.new("ImageLabel")
textureOverlay.Name = "MovingTextureLayer"
textureOverlay.BackgroundTransparency = 1
textureOverlay.Size = UDim2.new(1.18, 0, 1.18, 0)
textureOverlay.Position = UDim2.new(-0.09, 0, -0.09, 0)
textureOverlay.Image = TEXTURE_IMAGE
textureOverlay.ScaleType = Enum.ScaleType.Crop
textureOverlay.ImageTransparency = 0.42
textureOverlay.ZIndex = 2
textureOverlay.Parent = panel

task.spawn(function()
    while gui.Parent and textureOverlay.Parent do
        local a = TweenService:Create(textureOverlay, TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Position = UDim2.new(-0.03, 0, -0.12, 0),
            Rotation = 2
        })
        a:Play()
        a.Completed:Wait()
        if not gui.Parent then break end
        local b = TweenService:Create(textureOverlay, TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Position = UDim2.new(-0.12, 0, -0.03, 0),
            Rotation = -2
        })
        b:Play()
        b.Completed:Wait()
    end
end)

local darkWash = Instance.new("Frame")
darkWash.Name = "ContrastOverlay"
darkWash.Size = UDim2.fromScale(1, 1)
darkWash.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
darkWash.BackgroundTransparency = 0.32
darkWash.BorderSizePixel = 0
darkWash.ZIndex = 3
darkWash.Parent = panel
corner(darkWash, 28)

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = BLACK
header.BackgroundTransparency = 0.34
header.BorderSizePixel = 0
header.Position = UDim2.new(0, 0, 0, 0)
header.Size = UDim2.new(1, 0, 0, 105)
header.ZIndex = 4
header.Parent = panel

local crown = makeText(header, "♛", 55, Enum.Font.GothamBold, RED, UDim2.new(0, 24, 0, 12), UDim2.new(0, 80, 0, 70), Enum.TextXAlignment.Center)
local brand = makeText(header, "IMPÉRIO", 42, Enum.Font.GothamBlack, RED, UDim2.new(0, 110, 0, 9), UDim2.new(0.54, -100, 0, 55))
brand.Font = Enum.Font.GothamBlack
local subtitle = makeText(header, "ANTI LAG HUB   •   Yuri Developer", 16, Enum.Font.Gotham, WHITE, UDim2.new(0, 112, 0, 59), UDim2.new(0.6, -100, 0, 26))

local function headerButton(text, xOffset)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(48, 44)
    b.Position = UDim2.new(1, xOffset, 0, 18)
    b.BackgroundColor3 = Color3.fromRGB(10, 6, 8)
    b.Text = text
    b.TextColor3 = RED
    b.TextSize = 27
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = true
    b.ZIndex = 6
    b.Parent = header
    corner(b, 16)
    stroke(b, RED, 1)
    return b
end
local minimize = headerButton("−", -112)
local close = headerButton("×", -58)

local body = Instance.new("Frame")
body.Name = "Body"
body.BackgroundTransparency = 1
body.Position = UDim2.new(0, 12, 0, 115)
body.Size = UDim2.new(1, -24, 1, -127)
body.ZIndex = 4
body.Parent = panel

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
sidebar.BackgroundTransparency = 0.27
sidebar.BorderSizePixel = 0
sidebar.Size = UDim2.new(0, 155, 1, 0)
sidebar.ZIndex = 4
sidebar.Parent = body
corner(sidebar, 20)
stroke(sidebar, Color3.fromRGB(100, 15, 24), 1)

local content = Instance.new("Frame")
content.Name = "Content"
content.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
content.BackgroundTransparency = 0.28
content.BorderSizePixel = 0
content.Position = UDim2.new(0, 165, 0, 0)
content.Size = UDim2.new(1, -165, 1, 0)
content.ClipsDescendants = true
content.ZIndex = 4
content.Parent = body
corner(content, 22)
stroke(content, Color3.fromRGB(95, 12, 24), 1)

local categories = {
    {name = "⌂   Geral", key = "Geral"},
    {name = "▧   Gráficos", key = "Gráficos"},
    {name = "♟   Movimento", key = "Movimento"},
    {name = "⚙   Extra", key = "Extra"},
}
local activeCategory = "Geral"
local categoryButtons = {}

local function categoryButton(info, index)
    local b = Instance.new("TextButton")
    b.Name = info.key
    b.Size = UDim2.new(1, -8, 0, 52)
    b.Position = UDim2.new(0, 4, 0, 12 + (index - 1) * 58)
    b.BackgroundColor3 = info.key == activeCategory and RED_DARK or Color3.fromRGB(5, 5, 7)
    b.BackgroundTransparency = info.key == activeCategory and 0.12 or 0.48
    b.BorderSizePixel = 0
    b.Text = info.name
    b.TextColor3 = info.key == activeCategory and WHITE or MUTED
    b.TextSize = 15
    b.Font = Enum.Font.GothamSemibold
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.ZIndex = 5
    b.Parent = sidebar
    corner(b, 15)
    if info.key == activeCategory then stroke(b, RED, 1) end
    categoryButtons[info.key] = b
    return b
end
for i, info in ipairs(categories) do categoryButton(info, i) end

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "OptionsScroll"
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.Position = UDim2.new(0, 8, 0, 8)
scroll.Size = UDim2.new(1, -25, 1, -16)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 7
scroll.ScrollBarImageColor3 = RED
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Active = true
scroll.ZIndex = 5
scroll.Parent = content

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 10)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 2)
pad.PaddingBottom = UDim.new(0, 8)
pad.PaddingLeft = UDim.new(0, 2)
pad.PaddingRight = UDim.new(0, 2)
pad.Parent = scroll

local states = {
    antiLag = false,
    particles = false,
    shadows = false,
    graySky = false,
    fps = false,
}
local optionButtons = {}
local originalParticles, originalPost, originalShadows = {}, {}, {}
local originalLighting = {
    GlobalShadows = Lighting.GlobalShadows,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
}
local originalSkies, originalAtmospheres = {}, {}
local connections = {}

local function track(conn) table.insert(connections, conn); return conn end
local function isParticle(obj)
    return obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
        or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles")
end
local function applyEffects()
    local disableParticles = states.antiLag or states.particles
    local disablePost = states.antiLag
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isParticle(obj) then
            if originalParticles[obj] == nil then originalParticles[obj] = obj.Enabled end
            if disableParticles then
                obj.Enabled = false
            else
                obj.Enabled = originalParticles[obj]
            end
        elseif obj:IsA("PostEffect") then
            if originalPost[obj] == nil then originalPost[obj] = obj.Enabled end
            if disablePost then
                obj.Enabled = false
            else
                obj.Enabled = originalPost[obj]
            end
        elseif states.antiLag and (obj:IsA("Decal") or obj:IsA("Texture")) then
            -- Não remove imagens permanentemente; não altera conteúdo do jogo.
        end
    end
    Lighting.EnvironmentDiffuseScale = states.antiLag and 0 or originalLighting.EnvironmentDiffuseScale
    Lighting.EnvironmentSpecularScale = states.antiLag and 0 or originalLighting.EnvironmentSpecularScale
end
local function applyShadows()
    if states.shadows then
        Lighting.GlobalShadows = false
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                if originalShadows[obj] == nil then originalShadows[obj] = obj.CastShadow end
                obj.CastShadow = false
            end
        end
    else
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        for obj, value in pairs(originalShadows) do
            if obj and obj.Parent then obj.CastShadow = value end
        end
        table.clear(originalShadows)
    end
end
local function applyGraySky()
    if states.graySky then
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Sky") then
                if originalSkies[obj] == nil then originalSkies[obj] = obj.Parent end
                obj.Parent = nil
            elseif obj:IsA("Atmosphere") then
                if originalAtmospheres[obj] == nil then
                    originalAtmospheres[obj] = {Color = obj.Color, Decay = obj.Decay, Haze = obj.Haze, Glare = obj.Glare}
                end
                obj.Color = Color3.fromRGB(145, 145, 145)
                obj.Decay = Color3.fromRGB(100, 100, 100)
                obj.Haze = math.max(obj.Haze, 1)
                obj.Glare = 0
            end
        end
    else
        for obj, parent in pairs(originalSkies) do if obj then obj.Parent = parent or Lighting end end
        table.clear(originalSkies)
        for obj, v in pairs(originalAtmospheres) do
            if obj and obj.Parent then obj.Color = v.Color; obj.Decay = v.Decay; obj.Haze = v.Haze; obj.Glare = v.Glare end
        end
        table.clear(originalAtmospheres)
    end
end

local function updateOption(key, enabled)
    states[key] = enabled
    local entry = optionButtons[key]
    if entry then
        entry.switch.Text = enabled and "●  ON" or "●  OFF"
        entry.switch.TextColor3 = enabled and RED or MUTED
        entry.switch.BackgroundColor3 = enabled and Color3.fromRGB(65, 0, 12) or Color3.fromRGB(35, 32, 36)
        entry.cardStroke.Color = enabled and RED or Color3.fromRGB(80, 15, 25)
    end
    applyEffects()
    applyShadows()
    applyGraySky()
    statsFrame.Visible = states.fps
end

local options = {
    {key = "antiLag", title = "Anti Lag", desc = "Melhora o desempenho do jogo.", icon = "ϟ", category = "Geral"},
    {key = "particles", title = "Remover partículas", desc = "Desativa partículas e efeitos.", icon = "✣", category = "Gráficos"},
    {key = "shadows", title = "Remover sombras", desc = "Remove sombras dos objetos.", icon = "☼", category = "Gráficos"},
    {key = "graySky", title = "Céu cinza", desc = "Deixa o céu cinza para menos luz.", icon = "☁", category = "Gráficos"},
    {key = "fps", title = "FPS e Ping", desc = "Mostra FPS e ping no canto da tela.", icon = "▥", category = "Extra"},
}
local optionFrames = {}

local function createOption(info, order)
    local card = Instance.new("Frame")
    card.Name = info.key .. "Card"
    card.Size = UDim2.new(1, -3, 0, 78)
    card.BackgroundColor3 = Color3.fromRGB(5, 4, 6)
    card.BackgroundTransparency = 0.22
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.ZIndex = 6
    card.Parent = scroll
    corner(card, 24)
    local cs = stroke(card, Color3.fromRGB(125, 12, 28), 1)

    local iconCircle = Instance.new("Frame")
    iconCircle.Size = UDim2.fromOffset(52, 52)
    iconCircle.Position = UDim2.new(0, 12, 0.5, -26)
    iconCircle.BackgroundColor3 = Color3.fromRGB(25, 0, 6)
    iconCircle.BackgroundTransparency = 0.1
    iconCircle.BorderSizePixel = 0
    iconCircle.ZIndex = 7
    iconCircle.Parent = card
    corner(iconCircle, 26)
    stroke(iconCircle, RED, 1)
    local icon = makeText(iconCircle, info.icon, 30, Enum.Font.GothamBold, RED, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Enum.TextXAlignment.Center)
    icon.ZIndex = 8

    local title = makeText(card, info.title, 18, Enum.Font.GothamBold, WHITE, UDim2.new(0, 76, 0, 12), UDim2.new(1, -220, 0, 28))
    title.ZIndex = 7
    local desc = makeText(card, info.desc, 13, Enum.Font.Gotham, Color3.fromRGB(215, 207, 214), UDim2.new(0, 76, 0, 40), UDim2.new(1, -220, 0, 22))
    desc.ZIndex = 7

    local switch = Instance.new("TextButton")
    switch.Name = "Toggle"
    switch.AnchorPoint = Vector2.new(1, 0.5)
    switch.Position = UDim2.new(1, -14, 0.5, 0)
    switch.Size = UDim2.fromOffset(104, 42)
    switch.BackgroundColor3 = Color3.fromRGB(35, 32, 36)
    switch.BorderSizePixel = 0
    switch.Text = "●  OFF"
    switch.TextColor3 = MUTED
    switch.TextSize = 14
    switch.Font = Enum.Font.GothamBold
    switch.ZIndex = 8
    switch.Parent = card
    corner(switch, 22)
    stroke(switch, RED_DARK, 1)
    optionButtons[info.key] = {switch = switch, cardStroke = cs, card = card, info = info}
    optionFrames[info.key] = card
    switch.Activated:Connect(function() updateOption(info.key, not states[info.key]) end)
    return card
end
for i, info in ipairs(options) do createOption(info, i) end

local function setCategory(category)
    activeCategory = category
    for name, button in pairs(categoryButtons) do
        local selected = name == category
        button.BackgroundColor3 = selected and RED_DARK or Color3.fromRGB(5, 5, 7)
        button.BackgroundTransparency = selected and 0.12 or 0.48
        button.TextColor3 = selected and WHITE or MUTED
    end
    for _, info in ipairs(options) do
        local entry = optionButtons[info.key]
        entry.card.Visible = (category == "Geral" and true) or (info.category == category)
    end
    scroll.CanvasPosition = Vector2.new(0, 0)
end
for name, button in pairs(categoryButtons) do
    button.Activated:Connect(function() setCategory(name) end)
end

-- FPS/Ping indicator: draggable across the entire visible screen.
local statsFrame = Instance.new("Frame")
statsFrame.Name = "FPSPingDraggable"
statsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
statsFrame.Position = UDim2.new(0.82, 0, 0.16, 0)
statsFrame.Size = UDim2.fromOffset(290, 68)
statsFrame.BackgroundColor3 = BLACK
statsFrame.BackgroundTransparency = 0.08
statsFrame.BorderSizePixel = 0
statsFrame.Visible = false
statsFrame.Active = true
statsFrame.ZIndex = 20
statsFrame.Parent = gui
corner(statsFrame, 26)
stroke(statsFrame, RED, 2)

local statsTexture = Instance.new("ImageLabel")
statsTexture.BackgroundTransparency = 1
statsTexture.Size = UDim2.fromScale(1, 1)
statsTexture.Image = TEXTURE_IMAGE
statsTexture.ImageTransparency = 0.35
statsTexture.ScaleType = Enum.ScaleType.Crop
statsTexture.ZIndex = 20
statsTexture.Parent = statsFrame
corner(statsTexture, 26)

local statsCrown = makeText(statsFrame, "♛", 29, Enum.Font.GothamBold, RED,
    UDim2.new(0, 8, 0, 5), UDim2.new(0, 42, 0, 34), Enum.TextXAlignment.Center)
statsCrown.ZIndex = 21
local statsLabel = makeText(statsFrame, "FPS: -- | Ping: -- ms", 14, Enum.Font.GothamBold, WHITE,
    UDim2.new(0, 52, 0, 7), UDim2.new(1, -62, 0, 25))
statsLabel.ZIndex = 21
local statsHint = makeText(statsFrame, "Arraste para mover", 10, Enum.Font.Gotham, MUTED,
    UDim2.new(0, 52, 0, 33), UDim2.new(1, -62, 0, 19))
statsHint.ZIndex = 21

local function clampGuiPosition(frame, desiredX, desiredY)
    local camera = Workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
    local size = frame.AbsoluteSize
    local halfW, halfH = size.X / 2, size.Y / 2
    local x = math.clamp(desiredX, halfW + 4, math.max(halfW + 4, viewport.X - halfW - 4))
    local y = math.clamp(desiredY, halfH + 4, math.max(halfH + 4, viewport.Y - halfH - 4))
    frame.Position = UDim2.fromOffset(x, y)
end

local fpsCount, fpsElapsed, currentFPS = 0, 0, 0
track(RunService.RenderStepped:Connect(function(dt)
    fpsCount += 1
    fpsElapsed += dt
    if fpsElapsed >= 1 then
        currentFPS = math.floor(fpsCount / fpsElapsed + 0.5)
        fpsCount, fpsElapsed = 0, 0
    end
    if states.fps then
        local ping = "--"
        local ok, result = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
        end)
        if ok and result then
            local number = tostring(result):match("[%d%.]+")
            if number then ping = number end
        end
        statsLabel.Text = string.format("FPS: %d | Ping: %s ms", currentFPS, ping)
    end
end))

local statsDragging = false
local statsDragInput = nil
local statsDragStart = nil
local statsStartPosition = nil
local statsMoved = false
local statsDragThreshold = 5

statsFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        statsDragging = true
        statsMoved = false
        statsDragInput = input
        statsDragStart = input.Position
        statsStartPosition = statsFrame.Position
    end
end)

track(UserInputService.InputChanged:Connect(function(input)
    if not statsDragging or not statsDragInput or not statsDragStart or not statsStartPosition then return end
    local isMouseMove = statsDragInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement
    local isTouchMove = statsDragInput.UserInputType == Enum.UserInputType.Touch
        and input.UserInputType == Enum.UserInputType.Touch
    if isMouseMove or isTouchMove then
        local delta = input.Position - statsDragStart
        if math.abs(delta.X) + math.abs(delta.Y) > statsDragThreshold then statsMoved = true end
        local camera = Workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
        local startX = statsStartPosition.X.Scale * viewport.X + statsStartPosition.X.Offset
        local startY = statsStartPosition.Y.Scale * viewport.Y + statsStartPosition.Y.Offset
        clampGuiPosition(statsFrame, startX + delta.X, startY + delta.Y)
    end
end))

track(UserInputService.InputEnded:Connect(function(input)
    if statsDragging and statsDragInput then
        local endedTouch = statsDragInput.UserInputType == Enum.UserInputType.Touch
            and input.UserInputType == Enum.UserInputType.Touch
        local endedMouse = statsDragInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseButton1
        if endedTouch or endedMouse then
            statsDragging = false
            statsDragInput, statsDragStart, statsStartPosition = nil, nil, nil
        end
    end
end))

-- Floating button with fallback logo/brand text.
local toggle = Instance.new("ImageButton")
toggle.Name = "ImperioToggle"
toggle.Size = UDim2.fromOffset(62, 62)
toggle.Position = UDim2.new(0, 18, 0.24, 0)
toggle.BackgroundColor3 = BLACK
toggle.BorderSizePixel = 0
toggle.Image = LOGO_IMAGE
toggle.ScaleType = Enum.ScaleType.Crop
toggle.ZIndex = 30
toggle.Parent = gui
corner(toggle, 20)
stroke(toggle, RED, 2)
local fallback = makeText(toggle, "♛\nIMPÉRIO", 14, Enum.Font.GothamBlack, RED, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Enum.TextXAlignment.Center)
fallback.TextWrapped = true
fallback.ZIndex = 31
if LOGO_IMAGE ~= "" then fallback.Visible = false end

local toggleDrag = false
local toggleMoved = false
local toggleStartInput, toggleStartPos, toggleStartPoint
toggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleDrag, toggleMoved = true, false
        toggleStartInput, toggleStartPos, toggleStartPoint = input, toggle.Position, input.Position
    end
end)
track(UserInputService.InputChanged:Connect(function(input)
    if not toggleDrag or not toggleStartInput or not toggleStartPos or not toggleStartPoint then return end
    local touchMove = toggleStartInput.UserInputType == Enum.UserInputType.Touch
        and input.UserInputType == Enum.UserInputType.Touch
    local mouseMove = toggleStartInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement
    if touchMove or mouseMove then
        local delta = input.Position - toggleStartPoint
        if math.abs(delta.X) + math.abs(delta.Y) > 8 then toggleMoved = true end
        local camera = Workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
        local newX = toggleStartPos.X.Scale * viewport.X + toggleStartPos.X.Offset + delta.X
        local newY = toggleStartPos.Y.Scale * viewport.Y + toggleStartPos.Y.Offset + delta.Y
        local halfW, halfH = toggle.AbsoluteSize.X / 2, toggle.AbsoluteSize.Y / 2
        newX = math.clamp(newX, halfW + 2, math.max(halfW + 2, viewport.X - halfW - 2))
        newY = math.clamp(newY, halfH + 2, math.max(halfH + 2, viewport.Y - halfH - 2))
        toggle.AnchorPoint = Vector2.new(0.5, 0.5)
        toggle.Position = UDim2.fromOffset(newX, newY)
    end
end))
track(UserInputService.InputEnded:Connect(function(input)
    if toggleDrag and toggleStartInput then
        local endedTouch = toggleStartInput.UserInputType == Enum.UserInputType.Touch
            and input.UserInputType == Enum.UserInputType.Touch
        local endedMouse = toggleStartInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseButton1
        if endedTouch or endedMouse then
            toggleDrag = false
            if not toggleMoved then panel.Visible = not panel.Visible end
            toggleStartInput, toggleStartPos, toggleStartPoint = nil, nil, nil
        end
    end
end))

local minimized = false
minimize.Activated:Connect(function()
    minimized = not minimized
    body.Visible = not minimized
    header.Size = minimized and UDim2.new(1, 0, 0, 105) or UDim2.new(1, 0, 0, 105)
    panel.Size = minimized and UDim2.new(0.82, 0, 0, 105) or UDim2.new(0.82, 0, 0.78, 0)
end)
close.Activated:Connect(function() panel.Visible = false end)

-- Novos objetos também respeitam os modos ativos.
track(Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        if not obj.Parent then return end
        if (states.antiLag or states.particles) and isParticle(obj) then
            if originalParticles[obj] == nil then originalParticles[obj] = obj.Enabled end
            obj.Enabled = false
        elseif states.antiLag and obj:IsA("PostEffect") then
            if originalPost[obj] == nil then originalPost[obj] = obj.Enabled end
            obj.Enabled = false
        end
        if states.shadows and obj:IsA("BasePart") then
            if originalShadows[obj] == nil then originalShadows[obj] = obj.CastShadow end
            obj.CastShadow = false
        end
    end)
end))

local function cleanup()
    for _, conn in ipairs(connections) do pcall(function() conn:Disconnect() end) end
    Lighting.GlobalShadows = originalLighting.GlobalShadows
    Lighting.EnvironmentDiffuseScale = originalLighting.EnvironmentDiffuseScale
    Lighting.EnvironmentSpecularScale = originalLighting.EnvironmentSpecularScale
    for obj, value in pairs(originalParticles) do if obj and obj.Parent then obj.Enabled = value end end
    for obj, value in pairs(originalPost) do if obj and obj.Parent then obj.Enabled = value end end
    for obj, value in pairs(originalShadows) do if obj and obj.Parent then obj.CastShadow = value end end
    for obj, parent in pairs(originalSkies) do if obj then obj.Parent = parent or Lighting end end
    for obj, value in pairs(originalAtmospheres) do
        if obj and obj.Parent then obj.Color = value.Color; obj.Decay = value.Decay; obj.Haze = value.Haze; obj.Glare = value.Glare end
    end
end
gui.Destroying:Connect(cleanup)
