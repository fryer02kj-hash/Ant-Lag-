--[[
	IMPÉRIO Anti Lag Hub
	Yuri Developer
	Versão Final — Tudo que foi pedido no chat

	Instalar como LocalScript em:
	StarterPlayer > StarterPlayerScripts
]]

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Lighting          = game:GetService("Lighting")
local Stats             = game:GetService("Stats")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Textura pedida
local TEXTURE = "rbxassetid://113820173247546"

-- Cores
local RED      = Color3.fromRGB(255, 20, 45)
local RED_DARK = Color3.fromRGB(80, 0, 12)
local BLACK    = Color3.fromRGB(8, 6, 10)
local WHITE    = Color3.fromRGB(245, 242, 245)
local MUTED    = Color3.fromRGB(175, 170, 180)
local CARD_BG  = Color3.fromRGB(12, 8, 12)

-- Limpa GUI antiga
local old = playerGui:FindFirstChild("ImperioAntiLagGui")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ImperioAntiLagGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 200
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Helpers
local function corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = obj
end

local function stroke(obj, color, th)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = th or 1
	s.Parent = obj
	return s
end

local function label(parent, text, size, font, color, pos, sizeUDim, align)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextSize = size
	t.Font = font
	t.TextColor3 = color
	t.Position = pos
	t.Size = sizeUDim
	t.TextXAlignment = align or Enum.TextXAlignment.Left
	t.TextYAlignment = Enum.TextYAlignment.Center
	t.ZIndex = 10
	t.Parent = parent
	return t
end

------------------------------------------------------------
-- PAINEL PRINCIPAL
------------------------------------------------------------
local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Size = UDim2.fromOffset(540, 400)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.BackgroundColor3 = BLACK
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Visible = false
panel.ZIndex = 1
panel.Parent = gui
corner(panel, 16)
stroke(panel, RED, 1.5)

-- Textura de fundo
local bg = Instance.new("ImageLabel")
bg.Name = "Texture"
bg.BackgroundTransparency = 1
bg.Size = UDim2.fromScale(1, 1)
bg.Image = TEXTURE
bg.ScaleType = Enum.ScaleType.Crop
bg.ImageTransparency = 0.15
bg.ZIndex = 1
bg.Parent = panel

-- Overlay escuro para legibilidade (importante!)
local wash = Instance.new("Frame")
wash.Size = UDim2.fromScale(1, 1)
wash.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
wash.BackgroundTransparency = 0.45
wash.BorderSizePixel = 0
wash.ZIndex = 2
wash.Parent = panel
corner(wash, 16)

------------------------------------------------------------
-- HEADER
------------------------------------------------------------
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 64)
header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
header.BackgroundTransparency = 0.35
header.BorderSizePixel = 0
header.ZIndex = 5
header.Parent = panel

label(header, "♛", 30, Enum.Font.GothamBold, RED,
	UDim2.new(0, 12, 0, 8), UDim2.new(0, 40, 0, 40), Enum.TextXAlignment.Center)

label(header, "IMPÉRIO", 26, Enum.Font.GothamBlack, RED,
	UDim2.new(0, 52, 0, 6), UDim2.new(0.5, -40, 0, 30))

label(header, "ANTI LAG HUB  •  Yuri Developer", 11, Enum.Font.Gotham, WHITE,
	UDim2.new(0, 52, 0, 34), UDim2.new(0.55, -40, 0, 20))

local function makeHeaderBtn(txt, x)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(34, 30)
	b.Position = UDim2.new(1, x, 0, 16)
	b.BackgroundColor3 = Color3.fromRGB(15, 10, 12)
	b.Text = txt
	b.TextColor3 = RED
	b.TextSize = 18
	b.Font = Enum.Font.GothamBold
	b.ZIndex = 12
	b.Parent = header
	corner(b, 8)
	stroke(b, RED, 1)
	return b
end

local btnMin = makeHeaderBtn("−", -82)
local btnClose = makeHeaderBtn("×", -42)

------------------------------------------------------------
-- BODY
------------------------------------------------------------
local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.new(0, 10, 0, 70)
body.Size = UDim2.new(1, -20, 1, -80)
body.ZIndex = 5
body.Parent = panel

-- SIDEBAR
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 115, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
sidebar.BackgroundTransparency = 0.3
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 6
sidebar.Parent = body
corner(sidebar, 12)
stroke(sidebar, Color3.fromRGB(90, 10, 20), 1)

-- CONTENT
local content = Instance.new("Frame")
content.Name = "Content"
content.Position = UDim2.new(0, 123, 0, 0)
content.Size = UDim2.new(1, -123, 1, 0)
content.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
content.BackgroundTransparency = 0.3
content.BorderSizePixel = 0
content.ClipsDescendants = true
content.ZIndex = 6
content.Parent = body
corner(content, 12)
stroke(content, Color3.fromRGB(80, 8, 18), 1)

------------------------------------------------------------
-- CATEGORIAS
------------------------------------------------------------
local categories = {
	{ key = "Geral",     name = "⌂  Geral" },
	{ key = "Gráficos",  name = "▧  Gráficos" },
	{ key = "Movimento", name = "♟  Movimento" },
	{ key = "Extra",     name = "⚙  Extra" },
}

local activeCat = "Geral"
local catButtons = {}

local function makeCatBtn(info, i)
	local b = Instance.new("TextButton")
	b.Name = info.key
	b.Size = UDim2.new(1, -8, 0, 36)
	b.Position = UDim2.new(0, 4, 0, 8 + (i - 1) * 42)
	b.BackgroundColor3 = (info.key == activeCat) and RED_DARK or Color3.fromRGB(10, 8, 12)
	b.BackgroundTransparency = (info.key == activeCat) and 0.1 or 0.5
	b.BorderSizePixel = 0
	b.Text = info.name
	b.TextColor3 = (info.key == activeCat) and WHITE or MUTED
	b.TextSize = 13
	b.Font = Enum.Font.GothamSemibold
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.ZIndex = 8
	b.Parent = sidebar
	corner(b, 9)
	if info.key == activeCat then stroke(b, RED, 1) end
	catButtons[info.key] = b
	return b
end

for i, info in ipairs(categories) do
	makeCatBtn(info, i)
end

------------------------------------------------------------
-- SCROLL + OPÇÕES
------------------------------------------------------------
local scroll = Instance.new("ScrollingFrame")
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.Position = UDim2.new(0, 6, 0, 6)
scroll.Size = UDim2.new(1, -16, 1, -12)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = RED
scroll.ZIndex = 7
scroll.Parent = content

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 2)
pad.PaddingBottom = UDim.new(0, 4)
pad.Parent = scroll

-- Estados
local states = {
	antiLag   = false,
	particles = false,
	shadows   = false,
	graySky   = false,
	fps       = false,
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
local function track(c) table.insert(connections, c) return c end

local function isParticle(obj)
	return obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
		or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles")
end

local function applyEffects()
	local noParticles = states.antiLag or states.particles
	local noPost = states.antiLag
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if isParticle(obj) then
			if originalParticles[obj] == nil then originalParticles[obj] = obj.Enabled end
			obj.Enabled = not noParticles and originalParticles[obj]
		elseif obj:IsA("PostEffect") then
			if originalPost[obj] == nil then originalPost[obj] = obj.Enabled end
			obj.Enabled = not noPost and originalPost[obj]
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
		for obj, v in pairs(originalShadows) do
			if obj and obj.Parent then obj.CastShadow = v end
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
				obj.Color = Color3.fromRGB(140, 140, 140)
				obj.Decay = Color3.fromRGB(90, 90, 90)
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
				obj.Color, obj.Decay, obj.Haze, obj.Glare = v.Color, v.Decay, v.Haze, v.Glare
			end
		end
		table.clear(originalAtmospheres)
	end
end

local statsFrame

local function updateOption(key, on)
	states[key] = on
	local e = optionButtons[key]
	if e then
		e.btn.Text = on and "● ON" or "● OFF"
		e.btn.TextColor3 = on and RED or MUTED
		e.btn.BackgroundColor3 = on and Color3.fromRGB(50, 0, 10) or Color3.fromRGB(28, 26, 30)
		e.stroke.Color = on and RED or Color3.fromRGB(70, 12, 22)
	end
	applyEffects()
	applyShadows()
	applyGraySky()
	if statsFrame then statsFrame.Visible = states.fps end
end

local options = {
	{key = "antiLag",   title = "Anti Lag",           desc = "Melhora o desempenho do jogo.",     icon = "ϟ", cat = "Geral"},
	{key = "particles", title = "Remover partículas", desc = "Desativa partículas e efeitos.",    icon = "✣", cat = "Gráficos"},
	{key = "shadows",   title = "Remover sombras",    desc = "Remove sombras dos objetos.",       icon = "☼", cat = "Gráficos"},
	{key = "graySky",   title = "Céu cinza",          desc = "Deixa o céu cinza para menos luz.", icon = "☁", cat = "Gráficos"},
	{key = "fps",       title = "FPS e Ping",         desc = "Mostra FPS e ping no canto da tela.", icon = "▥", cat = "Extra"},
}

local function createCard(info, order)
	local card = Instance.new("Frame")
	card.Name = info.key
	card.Size = UDim2.new(1, -4, 0, 54)
	card.BackgroundColor3 = CARD_BG
	card.BackgroundTransparency = 0.15
	card.BorderSizePixel = 0
	card.LayoutOrder = order
	card.ZIndex = 8
	card.Parent = scroll
	corner(card, 12)
	local cs = stroke(card, Color3.fromRGB(90, 12, 24), 1)

	-- Ícone
	local iconBg = Instance.new("Frame")
	iconBg.Size = UDim2.fromOffset(36, 36)
	iconBg.Position = UDim2.new(0, 8, 0.5, -18)
	iconBg.BackgroundColor3 = Color3.fromRGB(25, 0, 8)
	iconBg.BorderSizePixel = 0
	iconBg.ZIndex = 9
	iconBg.Parent = card
	corner(iconBg, 18)
	stroke(iconBg, RED, 1)

	label(iconBg, info.icon, 18, Enum.Font.GothamBold, RED,
		UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Enum.TextXAlignment.Center)

	-- Título e descrição
	label(card, info.title, 14, Enum.Font.GothamBold, WHITE,
		UDim2.new(0, 52, 0, 5), UDim2.new(1, -150, 0, 22))

	label(card, info.desc, 11, Enum.Font.Gotham, Color3.fromRGB(195, 190, 200),
		UDim2.new(0, 52, 0, 27), UDim2.new(1, -150, 0, 18))

	-- Toggle
	local btn = Instance.new("TextButton")
	btn.Name = "Toggle"
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(1, -8, 0.5, 0)
	btn.Size = UDim2.fromOffset(68, 28)
	btn.BackgroundColor3 = Color3.fromRGB(28, 26, 30)
	btn.BorderSizePixel = 0
	btn.Text = "● OFF"
	btn.TextColor3 = MUTED
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	btn.ZIndex = 10
	btn.Parent = card
	corner(btn, 14)
	stroke(btn, RED_DARK, 1)

	optionButtons[info.key] = {btn = btn, stroke = cs, card = card, info = info}
	btn.Activated:Connect(function()
		updateOption(info.key, not states[info.key])
	end)
end

for i, info in ipairs(options) do
	createCard(info, i)
end

local function setCategory(cat)
	activeCat = cat
	for name, b in pairs(catButtons) do
		local sel = name == cat
		b.BackgroundColor3 = sel and RED_DARK or Color3.fromRGB(10, 8, 12)
		b.BackgroundTransparency = sel and 0.1 or 0.5
		b.TextColor3 = sel and WHITE or MUTED
	end
	for _, info in ipairs(options) do
		optionButtons[info.key].card.Visible = (cat == "Geral") or (info.cat == cat)
	end
	scroll.CanvasPosition = Vector2.zero
end

for name, b in pairs(catButtons) do
	b.Activated:Connect(function() setCategory(name) end)
end

------------------------------------------------------------
-- FPS / PING (igual segunda foto)
------------------------------------------------------------
statsFrame = Instance.new("Frame")
statsFrame.Name = "FPSPing"
statsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
statsFrame.Position = UDim2.new(0.85, 0, 0.1, 0)
statsFrame.Size = UDim2.fromOffset(210, 48)
statsFrame.BackgroundColor3 = BLACK
statsFrame.BackgroundTransparency = 0.1
statsFrame.BorderSizePixel = 0
statsFrame.Visible = false
statsFrame.Active = true
statsFrame.ZIndex = 30
statsFrame.Parent = gui
corner(statsFrame, 14)
stroke(statsFrame, RED, 1.5)

local stTex = Instance.new("ImageLabel")
stTex.BackgroundTransparency = 1
stTex.Size = UDim2.fromScale(1, 1)
stTex.Image = TEXTURE
stTex.ImageTransparency = 0.45
stTex.ScaleType = Enum.ScaleType.Crop
stTex.ZIndex = 30
stTex.Parent = statsFrame
corner(stTex, 14)

label(statsFrame, "♛", 20, Enum.Font.GothamBold, RED,
	UDim2.new(0, 6, 0, 4), UDim2.new(0, 28, 0, 24), Enum.TextXAlignment.Center)

local fpsLabel = label(statsFrame, "FPS: -- | Ping: -- ms", 12, Enum.Font.GothamBold, WHITE,
	UDim2.new(0, 36, 0, 3), UDim2.new(1, -42, 0, 20))

label(statsFrame, "Arraste para mover", 9, Enum.Font.Gotham, MUTED,
	UDim2.new(0, 36, 0, 24), UDim2.new(1, -42, 0, 16))

-- FPS loop
local fpsC, fpsT, curFPS = 0, 0, 0
track(RunService.RenderStepped:Connect(function(dt)
	fpsC += 1
	fpsT += dt
	if fpsT >= 1 then
		curFPS = math.floor(fpsC / fpsT + 0.5)
		fpsC, fpsT = 0, 0
	end
	if states.fps then
		local ping = "--"
		local ok, res = pcall(function()
			return Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
		end)
		if ok and res then
			local n = tostring(res):match("[%d%.]+")
			if n then ping = n end
		end
		fpsLabel.Text = string.format("FPS: %d | Ping: %s ms", curFPS, ping)
	end
end))

-- Arraste FPS
local drag, dragIn, dragStart, startPos = false, nil, nil, nil
statsFrame.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		drag = true
		dragIn = inp
		dragStart = inp.Position
		startPos = statsFrame.Position
	end
end)

track(UserInputService.InputChanged:Connect(function(inp)
	if not drag or not dragStart or not startPos then return end
	local move = (dragIn.UserInputType == Enum.UserInputType.MouseButton1 and inp.UserInputType == Enum.UserInputType.MouseMovement)
		or (dragIn.UserInputType == Enum.UserInputType.Touch and inp.UserInputType == Enum.UserInputType.Touch)
	if move then
		local d = inp.Position - dragStart
		local cam = Workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
		local nx = (startPos.X.Scale * vp.X) + startPos.X.Offset + d.X
		local ny = (startPos.Y.Scale * vp.Y) + startPos.Y.Offset + d.Y
		local halfW, halfH = statsFrame.AbsoluteSize.X / 2, statsFrame.AbsoluteSize.Y / 2
		nx = math.clamp(nx, halfW + 4, vp.X - halfW - 4)
		ny = math.clamp(ny, halfH + 4, vp.Y - halfH - 4)
		statsFrame.Position = UDim2.fromOffset(nx, ny)
	end
end))

track(UserInputService.InputEnded:Connect(function(inp)
	if inp == dragIn or (drag and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch)) then
		drag = false
		dragIn = nil
	end
end))

------------------------------------------------------------
-- BOTÃO ABRIR (coroa vermelha)
------------------------------------------------------------
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenBtn"
openBtn.Size = UDim2.fromOffset(52, 52)
openBtn.Position = UDim2.new(0, 14, 0.5, -26)
openBtn.BackgroundColor3 = BLACK
openBtn.BackgroundTransparency = 0.1
openBtn.BorderSizePixel = 0
openBtn.Text = "♛"
openBtn.TextColor3 = RED
openBtn.TextSize = 26
openBtn.Font = Enum.Font.GothamBold
openBtn.ZIndex = 40
openBtn.Parent = gui
corner(openBtn, 13)
stroke(openBtn, RED, 1.5)

local isOpen = false
local function toggle(force)
	if force ~= nil then isOpen = force else isOpen = not isOpen end
	panel.Visible = isOpen
	openBtn.Visible = not isOpen
end

openBtn.Activated:Connect(function() toggle(true) end)
btnMin.Activated:Connect(function() toggle(false) end)
btnClose.Activated:Connect(function() toggle(false) end)

-- Arrastar painel pelo header
local pDrag, pStart, pPos = false, nil, nil
header.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		pDrag = true
		pStart = inp.Position
		pPos = panel.Position
	end
end)

track(UserInputService.InputChanged:Connect(function(inp)
	if not pDrag or not pStart or not pPos then return end
	if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
		local d = inp.Position - pStart
		local cam = Workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
		local nx = (pPos.X.Scale * vp.X) + pPos.X.Offset + d.X
		local ny = (pPos.Y.Scale * vp.Y) + pPos.Y.Offset + d.Y
		panel.Position = UDim2.fromOffset(nx, ny)
		panel.AnchorPoint = Vector2.new(0.5, 0.5)
	end
end))

track(UserInputService.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		pDrag = false
	end
end))

-- Atalho
track(UserInputService.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.KeyCode == Enum.KeyCode.RightControl or inp.KeyCode == Enum.KeyCode.F4 then
		toggle()
	end
end))

setCategory("Geral")

player.AncestryChanged:Connect(function()
	if not player.Parent then
		for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
	end
end)

print("[IMPÉRIO Anti Lag Hub] Carregado com sucesso • Yuri Developer")
