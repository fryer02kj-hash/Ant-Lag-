--[[
	IMPÉRIO Anti Lag Hub
	Yuri Developer
	Proporções idênticas à imagem de referência

	LocalScript → StarterPlayer > StarterPlayerScripts
]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local Stats            = game:GetService("Stats")
local Workspace        = game:GetService("Workspace")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TEXTURE = "rbxassetid://113820173247546"

local RED      = Color3.fromRGB(255, 18, 42)
local RED_DARK = Color3.fromRGB(65, 0, 10)
local BLACK    = Color3.fromRGB(5, 4, 7)
local WHITE    = Color3.fromRGB(245, 242, 245)
local MUTED    = Color3.fromRGB(155, 150, 160)
local CARD     = Color3.fromRGB(9, 6, 10)

local old = playerGui:FindFirstChild("ImperioAntiLagGui")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ImperioAntiLagGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 200
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function corner(o, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = o
end

local function stroke(o, col, th)
	local s = Instance.new("UIStroke")
	s.Color = col
	s.Thickness = th or 1
	s.Parent = o
	return s
end

local function txt(parent, text, size, font, color, pos, sz, align)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextSize = size
	t.Font = font
	t.TextColor3 = color
	t.Position = pos
	t.Size = sz
	t.TextXAlignment = align or Enum.TextXAlignment.Left
	t.TextYAlignment = Enum.TextYAlignment.Center
	t.ZIndex = 15
	t.Parent = parent
	return t
end

------------------------------------------------------------
-- PAINEL — proporção idêntica à referência (~1.38:1)
------------------------------------------------------------
local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Size = UDim2.fromOffset(460, 332)
panel.Position = UDim2.fromScale(0.5, 0.52)
panel.BackgroundColor3 = BLACK
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Visible = false
panel.ZIndex = 1
panel.Parent = gui
corner(panel, 12)
stroke(panel, RED, 1.5)

local bg = Instance.new("ImageLabel")
bg.BackgroundTransparency = 1
bg.Size = UDim2.fromScale(1, 1)
bg.Image = TEXTURE
bg.ScaleType = Enum.ScaleType.Crop
bg.ImageTransparency = 0.1
bg.ZIndex = 1
bg.Parent = panel

local wash = Instance.new("Frame")
wash.Size = UDim2.fromScale(1, 1)
wash.BackgroundColor3 = Color3.new(0, 0, 0)
wash.BackgroundTransparency = 0.4
wash.BorderSizePixel = 0
wash.ZIndex = 2
wash.Parent = panel
corner(wash, 12)

------------------------------------------------------------
-- HEADER (compacto)
------------------------------------------------------------
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 52)
header.BackgroundColor3 = Color3.new(0, 0, 0)
header.BackgroundTransparency = 0.38
header.BorderSizePixel = 0
header.ZIndex = 5
header.Parent = panel

txt(header, "♛", 26, Enum.Font.GothamBold, RED,
	UDim2.new(0, 10, 0, 5), UDim2.new(0, 34, 0, 34), Enum.TextXAlignment.Center)

txt(header, "IMPÉRIO", 22, Enum.Font.GothamBlack, RED,
	UDim2.new(0, 46, 0, 3), UDim2.new(0.5, -28, 0, 26))

txt(header, "ANTI LAG HUB  •  Yuri Developer", 9, Enum.Font.Gotham, WHITE,
	UDim2.new(0, 46, 0, 28), UDim2.new(0.55, -28, 0, 16))

local function hBtn(t, x)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(28, 24)
	b.Position = UDim2.new(1, x, 0, 13)
	b.BackgroundColor3 = Color3.fromRGB(12, 8, 10)
	b.Text = t
	b.TextColor3 = RED
	b.TextSize = 15
	b.Font = Enum.Font.GothamBold
	b.ZIndex = 16
	b.Parent = header
	corner(b, 6)
	stroke(b, RED, 1)
	return b
end
local btnMin = hBtn("−", -66)
local btnClose = hBtn("×", -34)

------------------------------------------------------------
-- BODY
------------------------------------------------------------
local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.new(0, 7, 0, 56)
body.Size = UDim2.new(1, -14, 1, -63)
body.ZIndex = 5
body.Parent = panel

-- SIDEBAR (~21% da largura do painel)
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 96, 1, 0)
sidebar.BackgroundColor3 = Color3.new(0, 0, 0)
sidebar.BackgroundTransparency = 0.3
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 6
sidebar.Parent = body
corner(sidebar, 9)
stroke(sidebar, Color3.fromRGB(80, 10, 18), 1)

local content = Instance.new("Frame")
content.Position = UDim2.new(0, 103, 0, 0)
content.Size = UDim2.new(1, -103, 1, 0)
content.BackgroundColor3 = Color3.new(0, 0, 0)
content.BackgroundTransparency = 0.3
content.BorderSizePixel = 0
content.ClipsDescendants = true
content.ZIndex = 6
content.Parent = body
corner(content, 9)
stroke(content, Color3.fromRGB(70, 8, 15), 1)

------------------------------------------------------------
-- CATEGORIAS
------------------------------------------------------------
local cats = {
	{key = "Geral",     name = "⌂  Geral"},
	{key = "Gráficos",  name = "▧  Gráficos"},
	{key = "Movimento", name = "♟  Movimento"},
	{key = "Extra",     name = "⚙  Extra"},
}
local active = "Geral"
local catBtns = {}

local function catBtn(info, i)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -6, 0, 30)
	b.Position = UDim2.new(0, 3, 0, 5 + (i-1)*35)
	b.BackgroundColor3 = (info.key == active) and RED_DARK or Color3.fromRGB(8, 6, 9)
	b.BackgroundTransparency = (info.key == active) and 0.05 or 0.55
	b.BorderSizePixel = 0
	b.Text = info.name
	b.TextColor3 = (info.key == active) and WHITE or MUTED
	b.TextSize = 11
	b.Font = Enum.Font.GothamSemibold
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.ZIndex = 10
	b.Parent = sidebar
	corner(b, 7)
	if info.key == active then stroke(b, RED, 1) end
	catBtns[info.key] = b
	return b
end
for i, c in ipairs(cats) do catBtn(c, i) end

------------------------------------------------------------
-- SCROLL + CARDS (altura idêntica à referência)
------------------------------------------------------------
local scroll = Instance.new("ScrollingFrame")
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.Position = UDim2.new(0, 4, 0, 4)
scroll.Size = UDim2.new(1, -12, 1, -8)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = RED
scroll.ZIndex = 7
scroll.Parent = content

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 4)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 1)
pad.PaddingBottom = UDim.new(0, 2)
pad.Parent = scroll

-- Lógica
local states = {antiLag=false, particles=false, shadows=false, graySky=false, fps=false}
local optBtns = {}
local origPart, origPost, origShad = {}, {}, {}
local origLight = {
	GlobalShadows = Lighting.GlobalShadows,
	EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
	EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
}
local origSky, origAtmo = {}, {}
local conns = {}
local function track(c) table.insert(conns, c) return c end

local function isPart(o)
	return o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam")
		or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles")
end

local function applyFX()
	local noP = states.antiLag or states.particles
	local noPost = states.antiLag
	for _, o in ipairs(Workspace:GetDescendants()) do
		if isPart(o) then
			if origPart[o] == nil then origPart[o] = o.Enabled end
			o.Enabled = not noP and origPart[o]
		elseif o:IsA("PostEffect") then
			if origPost[o] == nil then origPost[o] = o.Enabled end
			o.Enabled = not noPost and origPost[o]
		end
	end
	Lighting.EnvironmentDiffuseScale  = states.antiLag and 0 or origLight.EnvironmentDiffuseScale
	Lighting.EnvironmentSpecularScale = states.antiLag and 0 or origLight.EnvironmentSpecularScale
end

local function applyShad()
	if states.shadows then
		Lighting.GlobalShadows = false
		for _, o in ipairs(Workspace:GetDescendants()) do
			if o:IsA("BasePart") then
				if origShad[o] == nil then origShad[o] = o.CastShadow end
				o.CastShadow = false
			end
		end
	else
		Lighting.GlobalShadows = origLight.GlobalShadows
		for o, v in pairs(origShad) do if o and o.Parent then o.CastShadow = v end end
		table.clear(origShad)
	end
end

local function applySky()
	if states.graySky then
		for _, o in ipairs(Lighting:GetChildren()) do
			if o:IsA("Sky") then
				if origSky[o] == nil then origSky[o] = o.Parent end
				o.Parent = nil
			elseif o:IsA("Atmosphere") then
				if origAtmo[o] == nil then
					origAtmo[o] = {Color=o.Color, Decay=o.Decay, Haze=o.Haze, Glare=o.Glare}
				end
				o.Color = Color3.fromRGB(140,140,140)
				o.Decay = Color3.fromRGB(90,90,90)
				o.Haze = math.max(o.Haze, 1)
				o.Glare = 0
			end
		end
	else
		for o, p in pairs(origSky) do if o then o.Parent = p or Lighting end end
		table.clear(origSky)
		for o, v in pairs(origAtmo) do
			if o and o.Parent then o.Color,o.Decay,o.Haze,o.Glare = v.Color,v.Decay,v.Haze,v.Glare end
		end
		table.clear(origAtmo)
	end
end

local statsF

local function update(key, on)
	states[key] = on
	local e = optBtns[key]
	if e then
		e.knob.Position = on and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
		e.track.BackgroundColor3 = on and RED or Color3.fromRGB(48, 44, 52)
		e.stroke.Color = on and RED or Color3.fromRGB(60, 12, 18)
	end
	applyFX()
	applyShad()
	applySky()
	if statsF then statsF.Visible = states.fps end
end

local options = {
	{key="antiLag",   title="Anti Lag",           desc="Melhora o desempenho do jogo.",      icon="ϟ", cat="Geral"},
	{key="particles", title="Remover partículas", desc="Desativa partículas e efeitos.",     icon="✦", cat="Gráficos"},
	{key="shadows",   title="Remover sombras",    desc="Remove sombras dos objetos.",        icon="☀", cat="Gráficos"},
	{key="graySky",   title="Céu cinza",          desc="Deixa o céu cinza para menos luz.",  icon="☁", cat="Gráficos"},
	{key="fps",       title="FPS e Ping",         desc="Mostra FPS e ping no canto da tela.",icon="▥", cat="Extra"},
}

local function card(info, order)
	local f = Instance.new("Frame")
	f.Name = info.key
	f.Size = UDim2.new(1, -2, 0, 46)
	f.BackgroundColor3 = CARD
	f.BackgroundTransparency = 0.1
	f.BorderSizePixel = 0
	f.LayoutOrder = order
	f.ZIndex = 8
	f.Parent = scroll
	corner(f, 9)
	local cs = stroke(f, Color3.fromRGB(75, 10, 18), 1)

	local ic = Instance.new("Frame")
	ic.Size = UDim2.fromOffset(30, 30)
	ic.Position = UDim2.new(0, 6, 0.5, -15)
	ic.BackgroundColor3 = Color3.fromRGB(20, 0, 5)
	ic.BorderSizePixel = 0
	ic.ZIndex = 9
	ic.Parent = f
	corner(ic, 15)
	stroke(ic, RED, 1)
	txt(ic, info.icon, 14, Enum.Font.GothamBold, RED,
		UDim2.fromScale(0,0), UDim2.fromScale(1,1), Enum.TextXAlignment.Center)

	txt(f, info.title, 12, Enum.Font.GothamBold, WHITE,
		UDim2.new(0, 42, 0, 3), UDim2.new(1, -110, 0, 18))

	txt(f, info.desc, 9, Enum.Font.Gotham, Color3.fromRGB(180,175,185),
		UDim2.new(0, 42, 0, 22), UDim2.new(1, -110, 0, 16))

	-- switch
	local track = Instance.new("Frame")
	track.AnchorPoint = Vector2.new(1, 0.5)
	track.Position = UDim2.new(1, -7, 0.5, 0)
	track.Size = UDim2.fromOffset(38, 20)
	track.BackgroundColor3 = Color3.fromRGB(48, 44, 52)
	track.BorderSizePixel = 0
	track.ZIndex = 10
	track.Parent = f
	corner(track, 10)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(16, 16)
	knob.Position = UDim2.new(0, 3, 0.5, -8)
	knob.BackgroundColor3 = WHITE
	knob.BorderSizePixel = 0
	knob.ZIndex = 11
	knob.Parent = track
	corner(knob, 8)

	local hit = Instance.new("TextButton")
	hit.BackgroundTransparency = 1
	hit.Size = UDim2.fromScale(1, 1)
	hit.Text = ""
	hit.ZIndex = 12
	hit.Parent = track

	optBtns[info.key] = {track=track, knob=knob, stroke=cs, card=f, info=info}
	hit.Activated:Connect(function()
		update(info.key, not states[info.key])
	end)
end

for i, o in ipairs(options) do card(o, i) end

local function setCat(cat)
	active = cat
	for n, b in pairs(catBtns) do
		local s = n == cat
		b.BackgroundColor3 = s and RED_DARK or Color3.fromRGB(8, 6, 9)
		b.BackgroundTransparency = s and 0.05 or 0.55
		b.TextColor3 = s and WHITE or MUTED
	end
	for _, o in ipairs(options) do
		optBtns[o.key].card.Visible = (cat == "Geral") or (o.cat == cat)
	end
	scroll.CanvasPosition = Vector2.zero
end

for n, b in pairs(catBtns) do
	b.Activated:Connect(function() setCat(n) end)
end

------------------------------------------------------------
-- FPS WIDGET
------------------------------------------------------------
statsF = Instance.new("Frame")
statsF.Name = "FPS"
statsF.AnchorPoint = Vector2.new(0.5, 0.5)
statsF.Position = UDim2.new(0.88, 0, 0.07, 0)
statsF.Size = UDim2.fromOffset(185, 40)
statsF.BackgroundColor3 = BLACK
statsF.BackgroundTransparency = 0.08
statsF.BorderSizePixel = 0
statsF.Visible = false
statsF.Active = true
statsF.ZIndex = 30
statsF.Parent = gui
corner(statsF, 11)
stroke(statsF, RED, 1.5)

local stBg = Instance.new("ImageLabel")
stBg.BackgroundTransparency = 1
stBg.Size = UDim2.fromScale(1, 1)
stBg.Image = TEXTURE
stBg.ImageTransparency = 0.5
stBg.ScaleType = Enum.ScaleType.Crop
stBg.ZIndex = 30
stBg.Parent = statsF
corner(stBg, 11)

txt(statsF, "♛", 16, Enum.Font.GothamBold, RED,
	UDim2.new(0, 4, 0, 2), UDim2.new(0, 24, 0, 20), Enum.TextXAlignment.Center)

local fpsL = txt(statsF, "FPS: -- | Ping: -- ms", 10, Enum.Font.GothamBold, WHITE,
	UDim2.new(0, 28, 0, 1), UDim2.new(1, -32, 0, 16))

txt(statsF, "Arraste para mover", 8, Enum.Font.Gotham, MUTED,
	UDim2.new(0, 28, 0, 18), UDim2.new(1, -32, 0, 14))

local fc, ft, cf = 0, 0, 0
track(RunService.RenderStepped:Connect(function(dt)
	fc += 1
	ft += dt
	if ft >= 1 then
		cf = math.floor(fc / ft + 0.5)
		fc, ft = 0, 0
	end
	if states.fps then
		local p = "--"
		local ok, r = pcall(function()
			return Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
		end)
		if ok and r then
			local n = tostring(r):match("[%d%.]+")
			if n then p = n end
		end
		fpsL.Text = string.format("FPS: %d | Ping: %s ms", cf, p)
	end
end))

local d, di, ds, sp = false, nil, nil, nil
statsF.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		d = true; di = i; ds = i.Position; sp = statsF.Position
	end
end)
track(UserInputService.InputChanged:Connect(function(i)
	if not d or not ds or not sp then return end
	local m = (di.UserInputType == Enum.UserInputType.MouseButton1 and i.UserInputType == Enum.UserInputType.MouseMovement)
		or (di.UserInputType == Enum.UserInputType.Touch and i.UserInputType == Enum.UserInputType.Touch)
	if m then
		local delta = i.Position - ds
		local cam = Workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
		local nx = (sp.X.Scale * vp.X) + sp.X.Offset + delta.X
		local ny = (sp.Y.Scale * vp.Y) + sp.Y.Offset + delta.Y
		local hw, hh = statsF.AbsoluteSize.X/2, statsF.AbsoluteSize.Y/2
		nx = math.clamp(nx, hw+4, vp.X-hw-4)
		ny = math.clamp(ny, hh+4, vp.Y-hh-4)
		statsF.Position = UDim2.fromOffset(nx, ny)
	end
end))
track(UserInputService.InputEnded:Connect(function(i)
	if i == di or (d and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch)) then
		d = false; di = nil
	end
end))

------------------------------------------------------------
-- BOTÃO ABRIR
------------------------------------------------------------
local open = Instance.new("TextButton")
open.Size = UDim2.fromOffset(46, 46)
open.Position = UDim2.new(0, 12, 0.5, -23)
open.BackgroundColor3 = BLACK
open.BackgroundTransparency = 0.1
open.BorderSizePixel = 0
open.Text = "♛"
open.TextColor3 = RED
open.TextSize = 22
open.Font = Enum.Font.GothamBold
open.ZIndex = 40
open.Parent = gui
corner(open, 11)
stroke(open, RED, 1.5)

local openState = false
local function toggle(force)
	if force ~= nil then openState = force else openState = not openState end
	panel.Visible = openState
	open.Visible = not openState
end
open.Activated:Connect(function() toggle(true) end)
btnMin.Activated:Connect(function() toggle(false) end)
btnClose.Activated:Connect(function() toggle(false) end)

local pd, ps, pp = false, nil, nil
header.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		pd = true; ps = i.Position; pp = panel.Position
	end
end)
track(UserInputService.InputChanged:Connect(function(i)
	if not pd or not ps or not pp then return end
	if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
		local delta = i.Position - ps
		local cam = Workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
		local nx = (pp.X.Scale * vp.X) + pp.X.Offset + delta.X
		local ny = (pp.Y.Scale * vp.Y) + pp.Y.Offset + delta.Y
		panel.Position = UDim2.fromOffset(nx, ny)
		panel.AnchorPoint = Vector2.new(0.5, 0.5)
	end
end))
track(UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		pd = false
	end
end))

track(UserInputService.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.RightControl or i.KeyCode == Enum.KeyCode.F4 then
		toggle()
	end
end))

setCat("Geral")

player.AncestryChanged:Connect(function()
	if not player.Parent then
		for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	end
end)

print("[IMPÉRIO Anti Lag Hub] Carregado • Yuri Developer")
