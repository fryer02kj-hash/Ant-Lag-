-- IMPÉRIO Anti Lag Hub
-- Yuri Developer
-- LocalScript → StarterPlayer > StarterPlayerScripts

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

local RED = Color3.fromRGB(255, 18, 42)
local RED_DARK = Color3.fromRGB(90, 0, 12)
local BLACK = Color3.fromRGB(6, 5, 8)
local WHITE = Color3.fromRGB(245, 242, 245)
local MUTED = Color3.fromRGB(170, 165, 175)

local oldGui = playerGui:FindFirstChild("ImperioAntiLagGui")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ImperioAntiLagGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = obj
	return c
end

local function stroke(obj, color, th, tr)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = th or 1
	s.Transparency = tr or 0
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

-------------------------------------------------
-- MAIN PANEL
-------------------------------------------------
local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Size = UDim2.new(0, 520, 0, 380)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.BackgroundColor3 = BLACK
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Visible = false
panel.Parent = gui
corner(panel, 18)
stroke(panel, RED, 1.5)

-- Textura de fundo (ID pedido)
local texture = Instance.new("ImageLabel")
texture.Name = "BgTexture"
texture.BackgroundTransparency = 1
texture.Size = UDim2.fromScale(1, 1)
texture.Image = TEXTURE_IMAGE
texture.ScaleType = Enum.ScaleType.Crop
texture.ImageTransparency = 0.05
texture.ZIndex = 1
texture.Parent = panel

local textureOverlay = Instance.new("ImageLabel")
textureOverlay.BackgroundTransparency = 1
textureOverlay.Size = UDim2.new(1.2, 0, 1.2, 0)
textureOverlay.Position = UDim2.new(-0.1, 0, -0.1, 0)
textureOverlay.Image = TEXTURE_IMAGE
textureOverlay.ScaleType = Enum.ScaleType.Crop
textureOverlay.ImageTransparency = 0.45
textureOverlay.ZIndex = 2
textureOverlay.Parent = panel

task.spawn(function()
	while gui.Parent and textureOverlay.Parent do
		local a = TweenService:Create(textureOverlay, TweenInfo.new(9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = UDim2.new(-0.02, 0, -0.12, 0), Rotation = 1.5
		})
		a:Play()
		a.Completed:Wait()
		if not gui.Parent then break end
		local b = TweenService:Create(textureOverlay, TweenInfo.new(9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = UDim2.new(-0.12, 0, -0.02, 0), Rotation = -1.5
		})
		b:Play()
		b.Completed:Wait()
	end
end)

local darkWash = Instance.new("Frame")
darkWash.Size = UDim2.fromScale(1, 1)
darkWash.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
darkWash.BackgroundTransparency = 0.38
darkWash.BorderSizePixel = 0
darkWash.ZIndex = 3
darkWash.Parent = panel
corner(darkWash, 18)

-------------------------------------------------
-- HEADER
-------------------------------------------------
local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = BLACK
header.BackgroundTransparency = 0.4
header.BorderSizePixel = 0
header.Size = UDim2.new(1, 0, 0, 68)
header.ZIndex = 4
header.Parent = panel

local crownIcon = makeText(header, "♛", 32, Enum.Font.GothamBold, RED,
	UDim2.new(0, 14, 0, 8), UDim2.new(0, 40, 0, 40), Enum.TextXAlignment.Center)
local brand = makeText(header, "IMPÉRIO", 28, Enum.Font.GothamBlack, RED,
	UDim2.new(0, 58, 0, 6), UDim2.new(0.55, -50, 0, 34))
local subtitle = makeText(header, "ANTI LAG HUB  •  Yuri Developer", 12, Enum.Font.Gotham, WHITE,
	UDim2.new(0, 58, 0, 38), UDim2.new(0.6, -50, 0, 20))

local function headerBtn(txt, xOff)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(36, 32)
	b.Position = UDim2.new(1, xOff, 0, 16)
	b.BackgroundColor3 = Color3.fromRGB(12, 8, 10)
	b.Text = txt
	b.TextColor3 = RED
	b.TextSize = 20
	b.Font = Enum.Font.GothamBold
	b.ZIndex = 6
	b.Parent = header
	corner(b, 10)
	stroke(b, RED, 1)
	return b
end
local minimize = headerBtn("−", -88)
local close = headerBtn("×", -46)

-------------------------------------------------
-- BODY
-------------------------------------------------
local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.new(0, 10, 0, 74)
body.Size = UDim2.new(1, -20, 1, -84)
body.ZIndex = 4
body.Parent = panel

-- SIDEBAR (menor)
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
sidebar.BackgroundTransparency = 0.35
sidebar.BorderSizePixel = 0
sidebar.Size = UDim2.new(0, 118, 1, 0)
sidebar.ZIndex = 4
sidebar.Parent = body
corner(sidebar, 14)
stroke(sidebar, Color3.fromRGB(90, 12, 22), 1)

local content = Instance.new("Frame")
content.Name = "Content"
content.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
content.BackgroundTransparency = 0.35
content.BorderSizePixel = 0
content.Position = UDim2.new(0, 126, 0, 0)
content.Size = UDim2.new(1, -126, 1, 0)
content.ClipsDescendants = true
content.ZIndex = 4
content.Parent = body
corner(content, 14)
stroke(content, Color3.fromRGB(85, 10, 20), 1)

local categories = {
	{name = "⌂  Geral", key = "Geral"},
	{name = "▧  Gráficos", key = "Gráficos"},
	{name = "♟  Movimento", key = "Movimento"},
	{name = "⚙  Extra", key = "Extra"},
}
local activeCategory = "Geral"
local categoryButtons = {}

local function categoryButton(info, index)
	local b = Instance.new("TextButton")
	b.Name = info.key
	b.Size = UDim2.new(1, -8, 0, 38)
	b.Position = UDim2.new(0, 4, 0, 8 + (index - 1) * 44)
	b.BackgroundColor3 = info.key == activeCategory and RED_DARK or Color3.fromRGB(8, 6, 9)
	b.BackgroundTransparency = info.key == activeCategory and 0.15 or 0.55
	b.BorderSizePixel = 0
	b.Text = info.name
	b.TextColor3 = info.key == activeCategory and WHITE or MUTED
	b.TextSize = 13
	b.Font = Enum.Font.GothamSemibold
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.ZIndex = 5
	b.Parent = sidebar
	corner(b, 10)
	if info.key == activeCategory then stroke(b, RED, 1) end
	categoryButtons[info.key] = b
	return b
end
for i, info in ipairs(categories) do categoryButton(info, i) end

local scroll = Instance.new("ScrollingFrame")
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.Position = UDim2.new(0, 6, 0, 6)
scroll.Size = UDim2.new(1, -18, 1, -12)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 5
scroll.ScrollBarImageColor3 = RED
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Active = true
scroll.ZIndex = 5
scroll.Parent = content

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 7)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 2)
pad.PaddingBottom = UDim.new(0, 6)
pad.PaddingLeft = UDim.new(0, 2)
pad.PaddingRight = UDim.new(0, 2)
pad.Parent = scroll

-------------------------------------------------
-- STATES & LOGIC
-------------------------------------------------
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

local function track(conn)
	table.insert(connections, conn)
	return conn
end

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
			obj.Enabled = disableParticles and false or originalParticles[obj]
		elseif obj:IsA("PostEffect") then
			if originalPost[obj] == nil then originalPost[obj] = obj.Enabled end
			obj.Enabled = disablePost and false or originalPost[obj]
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
		for obj, parent in pairs(originalSkies) do
			if obj then obj.Parent = parent or Lighting end
		end
		table.clear(originalSkies)
		for obj, v in pairs(originalAtmospheres) do
			if obj and obj.Parent then
				obj.Color = v.Color
				obj.Decay = v.Decay
				obj.Haze = v.Haze
				obj.Glare = v.Glare
			end
		end
		table.clear(originalAtmospheres)
	end
end

local statsFrame -- declarado antes para o updateOption

local function updateOption(key, enabled)
	states[key] = enabled
	local entry = optionButtons[key]
	if entry then
		entry.switch.Text = enabled and "● ON" or "● OFF"
		entry.switch.TextColor3 = enabled and RED or MUTED
		entry.switch.BackgroundColor3 = enabled and Color3.fromRGB(55, 0, 10) or Color3.fromRGB(30, 28, 32)
		entry.cardStroke.Color = enabled and RED or Color3.fromRGB(70, 12, 22)
	end
	applyEffects()
	applyShadows()
	applyGraySky()
	if statsFrame then
		statsFrame.Visible = states.fps
	end
end

local options = {
	{key = "antiLag", title = "Anti Lag", desc = "Melhora o desempenho do jogo.", icon = "ϟ", category = "Geral"},
	{key = "particles", title = "Remover partículas", desc = "Desativa partículas e efeitos.", icon = "✣", category = "Gráficos"},
	{key = "shadows", title = "Remover sombras", desc = "Remove sombras dos objetos.", icon = "☼", category = "Gráficos"},
	{key = "graySky", title = "Céu cinza", desc = "Deixa o céu cinza para menos luz.", icon = "☁", category = "Gráficos"},
	{key = "fps", title = "FPS e Ping", desc = "Mostra FPS e ping no canto da tela.", icon = "▥", category = "Extra"},
}

local function createOption(info, order)
	local card = Instance.new("Frame")
	card.Name = info.key .. "Card"
	card.Size = UDim2.new(1, -4, 0, 56) -- mais fino
	card.BackgroundColor3 = Color3.fromRGB(8, 6, 9)
	card.BackgroundTransparency = 0.25
	card.BorderSizePixel = 0
	card.LayoutOrder = order
	card.ZIndex = 6
	card.Parent = scroll
	corner(card, 14)
	local cs = stroke(card, Color3.fromRGB(100, 12, 24), 1)

	local iconCircle = Instance.new("Frame")
	iconCircle.Size = UDim2.fromOffset(38, 38)
	iconCircle.Position = UDim2.new(0, 8, 0.5, -19)
	iconCircle.BackgroundColor3 = Color3.fromRGB(22, 0, 6)
	iconCircle.BackgroundTransparency = 0.1
	iconCircle.BorderSizePixel = 0
	iconCircle.ZIndex = 7
	iconCircle.Parent = card
	corner(iconCircle, 19)
	stroke(iconCircle, RED, 1)
	local icon = makeText(iconCircle, info.icon, 20, Enum.Font.GothamBold, RED,
		UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Enum.TextXAlignment.Center)
	icon.ZIndex = 8

	local title = makeText(card, info.title, 14, Enum.Font.GothamBold, WHITE,
		UDim2.new(0, 54, 0, 6), UDim2.new(1, -160, 0, 22))
	title.ZIndex = 7
	local desc = makeText(card, info.desc, 11, Enum.Font.Gotham, Color3.fromRGB(200, 195, 205),
		UDim2.new(0, 54, 0, 28), UDim2.new(1, -160, 0, 18))
	desc.ZIndex = 7

	local switch = Instance.new("TextButton")
	switch.Name = "Toggle"
	switch.AnchorPoint = Vector2.new(1, 0.5)
	switch.Position = UDim2.new(1, -10, 0.5, 0)
	switch.Size = UDim2.fromOffset(72, 30)
	switch.BackgroundColor3 = Color3.fromRGB(30, 28, 32)
	switch.BorderSizePixel = 0
	switch.Text = "● OFF"
	switch.TextColor3 = MUTED
	switch.TextSize = 12
	switch.Font = Enum.Font.GothamBold
	switch.ZIndex = 8
	switch.Parent = card
	corner(switch, 15)
	stroke(switch, RED_DARK, 1)

	optionButtons[info.key] = {switch = switch, cardStroke = cs, card = card, info = info}
	switch.Activated:Connect(function()
		updateOption(info.key, not states[info.key])
	end)
	return card
end

for i, info in ipairs(options) do
	createOption(info, i)
end

local function setCategory(category)
	activeCategory = category
	for name, button in pairs(categoryButtons) do
		local selected = name == category
		button.BackgroundColor3 = selected and RED_DARK or Color3.fromRGB(8, 6, 9)
		button.BackgroundTransparency = selected and 0.15 or 0.55
		button.TextColor3 = selected and WHITE or MUTED
	end
	for _, info in ipairs(options) do
		local entry = optionButtons[info.key]
		entry.card.Visible = (category == "Geral") or (info.category == category)
	end
	scroll.CanvasPosition = Vector2.new(0, 0)
end

for name, button in pairs(categoryButtons) do
	button.Activated:Connect(function()
		setCategory(name)
	end)
end

-------------------------------------------------
-- FPS / PING (estilo segunda foto)
-------------------------------------------------
statsFrame = Instance.new("Frame")
statsFrame.Name = "FPSPingDraggable"
statsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
statsFrame.Position = UDim2.new(0.85, 0, 0.12, 0)
statsFrame.Size = UDim2.fromOffset(220, 52)
statsFrame.BackgroundColor3 = BLACK
statsFrame.BackgroundTransparency = 0.12
statsFrame.BorderSizePixel = 0
statsFrame.Visible = false
statsFrame.Active = true
statsFrame.ZIndex = 25
statsFrame.Parent = gui
corner(statsFrame, 16)
stroke(statsFrame, RED, 1.5)

local statsTex = Instance.new("ImageLabel")
statsTex.BackgroundTransparency = 1
statsTex.Size = UDim2.fromScale(1, 1)
statsTex.Image = TEXTURE_IMAGE
statsTex.ImageTransparency = 0.4
statsTex.ScaleType = Enum.ScaleType.Crop
statsTex.ZIndex = 25
statsTex.Parent = statsFrame
corner(statsTex, 16)

local statsCrown = makeText(statsFrame, "♛", 22, Enum.Font.GothamBold, RED,
	UDim2.new(0, 6, 0, 4), UDim2.new(0, 32, 0, 28), Enum.TextXAlignment.Center)
statsCrown.ZIndex = 26

local statsLabel = makeText(statsFrame, "FPS: -- | Ping: -- ms", 13, Enum.Font.GothamBold, WHITE,
	UDim2.new(0, 40, 0, 4), UDim2.new(1, -48, 0, 22))
statsLabel.ZIndex = 26

local statsHint = makeText(statsFrame, "Arraste para mover", 10, Enum.Font.Gotham, MUTED,
	UDim2.new(0, 40, 0, 26), UDim2.new(1, -48, 0, 18))
statsHint.ZIndex = 26

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

-- Arraste do FPS
local statsDragging, statsDragInput, statsDragStart, statsStartPosition = false, nil, nil, nil
local statsMoved = false

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
	if not statsDragging or not statsDragStart or not statsStartPosition then return end
	local isMove = (statsDragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement)
		or (statsDragInput.UserInputType == Enum.UserInputType.Touch and input.UserInputType == Enum.UserInputType.Touch)
	if isMove then
		local delta = input.Position - statsDragStart
		if math.abs(delta.X) + math.abs(delta.Y) > 4 then
			statsMoved = true
		end
		if statsMoved then
			local cam = Workspace.CurrentCamera
			local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
			local newX = (statsStartPosition.X.Scale * vp.X) + statsStartPosition.X.Offset + delta.X
			local newY = (statsStartPosition.Y.Scale * vp.Y) + statsStartPosition.Y.Offset + delta.Y
			clampGuiPosition(statsFrame, newX, newY)
		end
	end
end))

track(UserInputService.InputEnded:Connect(function(input)
	if input == statsDragInput or (statsDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)) then
		statsDragging = false
		statsDragInput = nil
		statsDragStart = nil
		statsStartPosition = nil
	end
end))

-------------------------------------------------
-- BOTÃO DE ABRIR (coroa vermelha)
-------------------------------------------------
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenButton"
openBtn.Size = UDim2.fromOffset(54, 54)
openBtn.Position = UDim2.new(0, 14, 0.5, -27)
openBtn.BackgroundColor3 = BLACK
openBtn.BackgroundTransparency = 0.15
openBtn.BorderSizePixel = 0
openBtn.Text = "♛"
openBtn.TextColor3 = RED
openBtn.TextSize = 28
openBtn.Font = Enum.Font.GothamBold
openBtn.ZIndex = 30
openBtn.Parent = gui
corner(openBtn, 14)
stroke(openBtn, RED, 1.5)

local isOpen = false

local function togglePanel(force)
	if force ~= nil then
		isOpen = force
	else
		isOpen = not isOpen
	end
	panel.Visible = isOpen
	openBtn.Visible = not isOpen
end

openBtn.Activated:Connect(function()
	togglePanel(true)
end)

minimize.Activated:Connect(function()
	togglePanel(false)
end)

close.Activated:Connect(function()
	togglePanel(false)
end)

-- Arrastar o painel pelo header
local panelDragging, panelDragStart, panelStartPos = false, nil, nil

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		panelDragging = true
		panelDragStart = input.Position
		panelStartPos = panel.Position
	end
end)

track(UserInputService.InputChanged:Connect(function(input)
	if not panelDragging or not panelDragStart or not panelStartPos then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - panelDragStart
		local cam = Workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
		local newX = (panelStartPos.X.Scale * vp.X) + panelStartPos.X.Offset + delta.X
		local newY = (panelStartPos.Y.Scale * vp.Y) + panelStartPos.Y.Offset + delta.Y
		panel.Position = UDim2.fromOffset(newX, newY)
		panel.AnchorPoint = Vector2.new(0.5, 0.5)
	end
end))

track(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		panelDragging = false
		panelDragStart = nil
		panelStartPos = nil
	end
end))

-- Atalho
track(UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.F4 then
		togglePanel()
	end
end))

setCategory("Geral")

player.AncestryChanged:Connect(function()
	if not player.Parent then
		for _, c in ipairs(connections) do
			pcall(function() c:Disconnect() end)
		end
	end
end)

print("[IMPÉRIO Anti Lag Hub] Carregado • Yuri Developer")
