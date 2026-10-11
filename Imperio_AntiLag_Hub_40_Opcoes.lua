--[[
	IMPÉRIO Anti Lag Hub
	Yuri Developer
	Versão ajustada — altura menor, FPS limpo, botão toggle, etc.

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
-- PAINEL (altura reduzida, largura igual)
------------------------------------------------------------
local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Size = UDim2.fromOffset(460, 290)          -- altura menor
panel.Position = UDim2.fromScale(0.5, 0.52)
panel.BackgroundColor3 = BLACK
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Visible = false
panel.ZIndex = 1
panel.Parent = gui
corner(panel, 16)
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
corner(wash, 16)

------------------------------------------------------------
-- HEADER (sem − e ×)
------------------------------------------------------------
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.new(0, 0, 0)
header.BackgroundTransparency = 0.38
header.BorderSizePixel = 0
header.ZIndex = 5
header.Parent = panel

txt(header, "IMPÉRIO", 20, Enum.Font.GothamBlack, RED,
	UDim2.new(0, 16, 0, 3), UDim2.new(0.55, -20, 0, 24))

txt(header, "ANTI LAG HUB  •  Yuri Developer", 9, Enum.Font.Gotham, WHITE,
	UDim2.new(0, 16, 0, 26), UDim2.new(0.6, -20, 0, 16))

------------------------------------------------------------
-- BODY
------------------------------------------------------------
local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.new(0, 7, 0, 52)
body.Size = UDim2.new(1, -14, 1, -59)
body.ZIndex = 5
body.Parent = panel

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
-- CATEGORIAS (só texto, sem emoji)
------------------------------------------------------------
local cats = {
	{key = "Geral",     name = "Geral"},
	{key = "Gráficos",  name = "Gráficos"},
	{key = "Movimento", name = "Movimento"},
	{key = "Extra",     name = "Extra"},
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
	b.TextSize = 12
	b.Font = Enum.Font.GothamSemibold
	b.TextXAlignment = Enum.TextXAlignment.Center
	b.ZIndex = 10
	b.Parent = sidebar
	corner(b, 7)
	if info.key == active then stroke(b, RED, 1) end
	catBtns[info.key] = b
	return b
end
for i, c in ipairs(cats) do catBtn(c, i) end

------------------------------------------------------------
-- SCROLL + CARDS
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

-- Estados e lógica
local states = {
	antiLag = false, particles = false, shadows = false, graySky = false, fps = false,
	fullbright = false, noFog = false, lowQuality = false,
	postEffects = false, decals = false, textures = false, terrainDecor = false,
	waterWaves = false, materials = false, localAccessories = false, otherAccessories = false,
	otherParticles = false, characterParticles = false, trails = false, beams = false,
	characterShadows = false, hideTools = false, hideNameplates = false, hideClothing = false,
	otherDecals = false, otherTextures = false, disableAtmosphere = false, disableClouds = false,
	meshTextures = false, reduceLights = false, disableFireSmoke = false, disableHighlights = false,
	disableSounds = false, hideBillboards = false, hideSurfaceGui = false, lowWater = false,
	compact = false, panelDrag = true, buttonDrag = true, clock = false, coordinates = false, opaquePanel = false
}
local optBtns = {}
local origPart, origPost, origShad = {}, {}, {}
local origLight = {
	GlobalShadows = Lighting.GlobalShadows,
	EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
	EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
	Brightness = Lighting.Brightness,
	FogEnd = Lighting.FogEnd,
	FogStart = Lighting.FogStart,
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

local function applyFullbright()
	if states.fullbright then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
	else
		Lighting.Brightness = origLight.Brightness
		Lighting.FogEnd = origLight.FogEnd
	end
end

local function applyNoFog()
	if states.noFog then
		Lighting.FogEnd = 100000
		Lighting.FogStart = 100000
	else
		Lighting.FogEnd = origLight.FogEnd
		Lighting.FogStart = origLight.FogStart
	end
end

local function applyLowQuality()
	if states.lowQuality then
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	else
		settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
	end
end

-- Snapshot/restore engine: não destrói instâncias; guarda valores originais para reverter.
local originalProps = setmetatable({}, {__mode="k"})
local terrain = Workspace:FindFirstChildOfClass("Terrain")
local terrainOriginal = {}
local function remember(o, prop)
 if not originalProps[o] then originalProps[o] = {} end
 if originalProps[o][prop] == nil then pcall(function() originalProps[o][prop] = o[prop] end) end
end
local function setProp(o, prop, value)
 remember(o, prop); pcall(function() o[prop] = value end)
end
local function restoreProp(o, prop)
 local props = originalProps[o]; if props and props[prop] ~= nil then pcall(function() o[prop] = props[prop] end); props[prop] = nil end
end
local function belongsToCharacter(o, otherOnly)
 local m = o:FindFirstAncestorOfClass("Model")
 if not m or not m:FindFirstChildOfClass("Humanoid") then return false end
 if otherOnly then return m ~= player.Character end
 return true
end
local function applyExtraOptimizations()
 local descendants = Workspace:GetDescendants()
 for _,o in ipairs(descendants) do
  local class = o.ClassName
  local disable = false
  if states.postEffects and o:IsA("PostEffect") then disable=true end
  if (states.decals or states.otherDecals) and (o:IsA("Decal") or (states.otherTextures and o:IsA("Texture"))) then setProp(o,"Transparency",1)
  elseif states.textures and o:IsA("Texture") then setProp(o,"Transparency",1) end
  if states.meshTextures and o:IsA("MeshPart") then setProp(o,"TextureID","") end
  if states.materials and o:IsA("BasePart") then setProp(o,"Material",Enum.Material.SmoothPlastic) end
  if states.reduceLights and (o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight")) then setProp(o,"Enabled",false) end
  if states.disableAtmosphere and o:IsA("Atmosphere") then setProp(o,"Density",0); setProp(o,"Haze",0); setProp(o,"Glare",0) end
  if states.disableClouds and o:IsA("Clouds") then setProp(o,"Cover",0); setProp(o,"Density",0) end
  if states.waterWaves or states.lowWater then
   if terrain and o == terrain then
    if terrainOriginal.WaterWaveSize == nil then pcall(function() terrainOriginal.WaterWaveSize=terrain.WaterWaveSize; terrainOriginal.WaterWaveSpeed=terrain.WaterWaveSpeed; terrainOriginal.Decoration=terrain.Decoration end) end
    pcall(function() terrain.WaterWaveSize=0; terrain.WaterWaveSpeed=0 end)
    if states.terrainDecor then pcall(function() terrain.Decoration=false end) end
   end
  end
  if states.terrainDecor and terrain and o == terrain then pcall(function() terrain.Decoration=false end) end
  if states.disableFireSmoke and (o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles")) then disable=true end
  if states.disableHighlights and o:IsA("Highlight") then disable=true end
  if states.disableSounds and o:IsA("Sound") then setProp(o,"Volume",0) end
  if states.hideBillboards and o:IsA("BillboardGui") then setProp(o,"Enabled",false) end
  if states.hideSurfaceGui and o:IsA("SurfaceGui") then setProp(o,"Enabled",false) end
  if states.trails and o:IsA("Trail") then disable=true end
  if states.beams and o:IsA("Beam") then disable=true end
  if states.otherParticles and belongsToCharacter(o,true) and (o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam")) then disable=true end
  if states.characterParticles and belongsToCharacter(o,false) and player.Character and o:IsDescendantOf(player.Character) and (o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam")) then disable=true end
  if (states.localAccessories and player.Character and o:IsDescendantOf(player.Character) or states.otherAccessories and belongsToCharacter(o,true)) and (o:IsA("Accessory") or o:IsA("BasePart") and o.Parent and o.Parent:IsA("Accessory")) then
   if o:IsA("BasePart") then setProp(o,"LocalTransparencyModifier",1) end
  end
  if states.characterShadows and o:IsA("BasePart") and belongsToCharacter(o,false) then setProp(o,"CastShadow",false) end
  if states.hideTools and o:IsA("Tool") then for _,d in ipairs(o:GetDescendants()) do if d:IsA("BasePart") then setProp(d,"LocalTransparencyModifier",1) end end end
  if states.hideClothing and (o:IsA("Shirt") or o:IsA("Pants") or o:IsA("ShirtGraphic")) then setProp(o,"Parent",nil) end
  if disable then setProp(o,"Enabled",false) end
 end
 -- Restore properties for any optimization switched off.
 for o, props in pairs(originalProps) do
  if o and o.Parent then
   for prop,_ in pairs(props) do
    local shouldRestore = (prop=="Transparency" and not (states.decals or states.otherDecals or states.textures))
      or (prop=="TextureID" and not states.meshTextures) or (prop=="Material" and not states.materials)
      or (prop=="Volume" and not states.disableSounds) or (prop=="LocalTransparencyModifier" and not (states.localAccessories or states.otherAccessories or states.hideTools))
      or (prop=="CastShadow" and not states.characterShadows) or (prop=="Enabled" and not (states.postEffects or states.disableFireSmoke or states.disableHighlights or states.trails or states.beams or states.otherParticles or states.characterParticles or states.reduceLights or states.hideBillboards or states.hideSurfaceGui or states.disableAtmosphere or states.disableClouds))
      or ((prop=="Density" or prop=="Haze" or prop=="Glare") and not states.disableAtmosphere)
      or ((prop=="Cover") and not states.disableClouds)
   if shouldRestore then restoreProp(o,prop) end
   end
  end
 end
 if terrain and terrainOriginal.WaterWaveSize ~= nil and not (states.waterWaves or states.lowWater) then
  pcall(function() terrain.WaterWaveSize=terrainOriginal.WaterWaveSize; terrain.WaterWaveSpeed=terrainOriginal.WaterWaveSpeed end)
  terrainOriginal.WaterWaveSize=nil; terrainOriginal.WaterWaveSpeed=nil
 end
end

local statsF
local clockF, coordF, clockLabel, coordLabel

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
	applyFullbright()
	applyNoFog()
	applyLowQuality()
	applyExtraOptimizations()
	if statsF then statsF.Visible = states.fps end
	if clockF then clockF.Visible = states.clock end
	if coordF then coordF.Visible = states.coordinates end
	if wash then wash.BackgroundTransparency = states.opaquePanel and 0.12 or 0.4 end
	if panel then panel.Size = states.compact and UDim2.fromOffset(400, 250) or UDim2.fromOffset(460, 290) end
end

-- Opções: 10 por categoria. Toggles de desempenho afetam apenas efeitos locais/visuais.
local options = {
 -- Geral (10)
 {key="antiLag",title="Anti Lag",desc="Desativa efeitos visuais pesados locais.",icon="ϟ",cat="Geral"},
 {key="fps",title="FPS e Ping",desc="Mostra FPS e ping estimado.",icon="▥",cat="Geral"},
 {key="lowQuality",title="Qualidade mínima",desc="Solicita qualidade gráfica mínima.",icon="📉",cat="Geral"},
 {key="postEffects",title="Desativar pós-efeitos",desc="Desliga Bloom, Blur e efeitos de tela.",icon="◉",cat="Geral"},
 {key="particles",title="Desativar partículas",desc="Desliga emissores de partículas.",icon="✦",cat="Geral"},
 {key="shadows",title="Desativar sombras",desc="Desliga sombras locais dos objetos.",icon="☀",cat="Geral"},
 {key="noFog",title="Remover névoa",desc="Aumenta o alcance visual local.",icon="🌫",cat="Geral"},
 {key="decals",title="Ocultar decalques",desc="Oculta imagens decorativas Decal.",icon="▧",cat="Geral"},
 {key="textures",title="Ocultar texturas",desc="Oculta texturas decorativas locais.",icon="▦",cat="Geral"},
 {key="terrainDecor",title="Decoração do terreno",desc="Desativa decoração do Terrain quando disponível.",icon="▰",cat="Geral"},
 -- Gráficos (10)
 {key="graySky",title="Céu simplificado",desc="Oculta Sky e simplifica atmosfera.",icon="☁",cat="Gráficos"},
 {key="fullbright",title="Fullbright",desc="Ajusta iluminação local para visibilidade.",icon="☀",cat="Gráficos"},
 {key="waterWaves",title="Reduzir ondas da água",desc="Desativa ondas do Terrain quando possível.",icon="≈",cat="Gráficos"},
 {key="materials",title="Materiais simples",desc="Troca materiais visuais por SmoothPlastic.",icon="▤",cat="Gráficos"},
 {key="disableAtmosphere",title="Desativar atmosfera",desc="Desliga Atmosphere localmente.",icon="☁",cat="Gráficos"},
 {key="disableClouds",title="Desativar nuvens",desc="Oculta Clouds do Terrain.",icon="☁",cat="Gráficos"},
 {key="meshTextures",title="Texturas de malhas",desc="Oculta texturas de MeshPart localmente.",icon="◇",cat="Gráficos"},
 {key="reduceLights",title="Reduzir luzes",desc="Desliga luzes locais Point/Spot/Surface.",icon="✧",cat="Gráficos"},
 {key="otherDecals",title="Imagens de objetos",desc="Oculta Decals e Textures do mapa.",icon="▧",cat="Gráficos"},
 {key="otherTextures",title="Superfícies visuais",desc="Oculta texturas e SurfaceAppearance compatíveis.",icon="▦",cat="Gráficos"},
 -- Movimento (10): otimizações de renderização de personagens, sem alterar velocidade/controles
 {key="localAccessories",title="Acessórios próprios",desc="Oculta acessórios cosméticos do seu personagem.",icon="♙",cat="Movimento"},
 {key="otherAccessories",title="Acessórios de jogadores",desc="Oculta acessórios de outros personagens.",icon="♟",cat="Movimento"},
 {key="otherParticles",title="Efeitos de jogadores",desc="Desativa partículas em personagens de outros jogadores.",icon="✦",cat="Movimento"},
 {key="characterParticles",title="Efeitos do personagem",desc="Desativa partículas no seu personagem.",icon="✧",cat="Movimento"},
 {key="trails",title="Rastros",desc="Desativa Trails de personagens e mapa.",icon="〰",cat="Movimento"},
 {key="beams",title="Feixes",desc="Desativa Beams decorativos.",icon="╱",cat="Movimento"},
 {key="characterShadows",title="Sombras de personagens",desc="Remove sombras de personagens localmente.",icon="♟",cat="Movimento"},
 {key="hideTools",title="Ferramentas visuais",desc="Oculta ferramentas equipadas visualmente.",icon="⚒",cat="Movimento"},
 {key="hideNameplates",title="Placas de nome",desc="Oculta Humanoid DisplayDistanceType/placas locais.",icon="☷",cat="Movimento"},
 {key="hideClothing",title="Roupas de personagens",desc="Oculta roupas clássicas para reduzir detalhes.",icon="▣",cat="Movimento"},
 -- Extra (10)
 {key="disableFireSmoke",title="Fogo e fumaça",desc="Desativa Fire, Smoke e Sparkles.",icon="♨",cat="Extra"},
 {key="disableHighlights",title="Contornos brilhantes",desc="Desativa Highlights locais.",icon="✧",cat="Extra"},
 {key="disableSounds",title="Sons decorativos",desc="Silencia sons locais não essenciais.",icon="♫",cat="Extra"},
 {key="hideBillboards",title="BillboardGui",desc="Oculta placas flutuantes decorativas.",icon="▤",cat="Extra"},
 {key="hideSurfaceGui",title="SurfaceGui",desc="Oculta interfaces decorativas em superfícies.",icon="▧",cat="Extra"},
 {key="lowWater",title="Água simplificada",desc="Reduz propriedades visuais da água quando disponíveis.",icon="≈",cat="Extra"},
 {key="compact",title="Painel compacto",desc="Reduz o tamanho da interface do hub.",icon="▣",cat="Extra"},
 {key="clock",title="Relógio",desc="Mostra a hora local; não altera o desempenho do jogo.",icon="◷",cat="Extra"},
 {key="coordinates",title="Coordenadas",desc="Mostra posição local do personagem.",icon="⌖",cat="Extra"},
 {key="opaquePanel",title="Painel opaco",desc="Reduz transparência da interface do hub.",icon="◧",cat="Extra"},
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
		optBtns[o.key].card.Visible = (o.cat == cat)
	end
	scroll.CanvasPosition = Vector2.zero
end

for n, b in pairs(catBtns) do
	b.Activated:Connect(function() setCat(n) end)
end

------------------------------------------------------------
-- FPS WIDGET (sem "Arraste para mover", ms inteiro)
------------------------------------------------------------
statsF = Instance.new("Frame")
statsF.Name = "FPS"
statsF.AnchorPoint = Vector2.new(0.5, 0.5)
statsF.Position = UDim2.new(0.88, 0, 0.07, 0)
statsF.Size = UDim2.fromOffset(170, 32)
statsF.BackgroundColor3 = BLACK
statsF.BackgroundTransparency = 0.08
statsF.BorderSizePixel = 0
statsF.Visible = false
statsF.Active = true
statsF.ZIndex = 30
statsF.Parent = gui
corner(statsF, 10)
stroke(statsF, RED, 1.5)

local stBg = Instance.new("ImageLabel")
stBg.BackgroundTransparency = 1
stBg.Size = UDim2.fromScale(1, 1)
stBg.Image = TEXTURE
stBg.ImageTransparency = 0.5
stBg.ScaleType = Enum.ScaleType.Crop
stBg.ZIndex = 30
stBg.Parent = statsF
corner(stBg, 10)

txt(statsF, "♛", 14, Enum.Font.GothamBold, RED,
	UDim2.new(0, 4, 0, 2), UDim2.new(0, 22, 0, 22), Enum.TextXAlignment.Center)

local fpsL = txt(statsF, "FPS: -- | Ping: -- ms", 11, Enum.Font.GothamBold, WHITE,
	UDim2.new(0, 26, 0, 0), UDim2.new(1, -30, 1, 0))

clockF = Instance.new("Frame")
clockF.Name = "ClockWidget"
clockF.AnchorPoint = Vector2.new(1, 0)
clockF.Position = UDim2.new(1, -12, 0, 48)
clockF.Size = UDim2.fromOffset(112, 28)
clockF.BackgroundColor3 = BLACK
clockF.BackgroundTransparency = 0.08
clockF.BorderSizePixel = 0
clockF.Visible = false
clockF.ZIndex = 30
clockF.Parent = gui
corner(clockF, 10)
stroke(clockF, RED, 1.5)
clockLabel = txt(clockF, "00:00:00", 11, Enum.Font.GothamBold, WHITE,
	UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Enum.TextXAlignment.Center)

coordF = Instance.new("Frame")
coordF.Name = "CoordinatesWidget"
coordF.AnchorPoint = Vector2.new(1, 0)
coordF.Position = UDim2.new(1, -12, 0, 82)
coordF.Size = UDim2.fromOffset(190, 28)
coordF.BackgroundColor3 = BLACK
coordF.BackgroundTransparency = 0.08
coordF.BorderSizePixel = 0
coordF.Visible = false
coordF.ZIndex = 30
coordF.Parent = gui
corner(coordF, 10)
stroke(coordF, RED, 1.5)
coordLabel = txt(coordF, "X: 0  Y: 0  Z: 0", 10, Enum.Font.GothamBold, WHITE,
	UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Enum.TextXAlignment.Center)

local fc, ft, cf = 0, 0, 0
track(RunService.RenderStepped:Connect(function(dt)
	clockLabel.Text = os.date("%H:%M:%S")
	if states.coordinates then
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local pos = root.Position
			coordLabel.Text = string.format("X: %d  Y: %d  Z: %d", math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
		else
			coordLabel.Text = "Personagem indisponível"
		end
	end
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
			local n = tostring(r):match("%d+")
			if n then p = n end
		end
		fpsL.Text = string.format("FPS: %d | Ping: %s ms", cf, p)
	end
end))

-- arraste FPS
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
-- BOTÃO ABRIR (menor + sempre visível + toggle)
------------------------------------------------------------
local open = Instance.new("TextButton")
open.Size = UDim2.fromOffset(40, 40)          -- menor
open.Position = UDim2.new(0, 12, 0.5, -20)
open.BackgroundColor3 = BLACK
open.BackgroundTransparency = 0.1
open.BorderSizePixel = 0
open.Text = "🥀"
open.TextColor3 = RED
open.TextSize = 22
open.Font = Enum.Font.GothamBold
open.ZIndex = 40
open.Parent = gui
corner(open, 12)
stroke(open, RED, 1.5)

-- Arraste do botão de abertura (toque no celular ou mouse no PC)
local buttonDragging, buttonMoved, buttonStart, buttonOrigin, buttonInput = false, false, nil, nil, nil
open.InputBegan:Connect(function(i)
	if not states.buttonDrag then return end
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		buttonDragging = true
		buttonMoved = false
		buttonInput = i
		buttonStart = i.Position
		buttonOrigin = open.Position
	end
end)
track(UserInputService.InputChanged:Connect(function(i)
	if not buttonDragging or not buttonStart or not buttonOrigin then return end
	local matches = (buttonInput and buttonInput.UserInputType == Enum.UserInputType.Touch and i == buttonInput)
		or (buttonInput and buttonInput.UserInputType == Enum.UserInputType.MouseButton1 and i.UserInputType == Enum.UserInputType.MouseMovement)
	if matches then
		local delta = i.Position - buttonStart
		if delta.Magnitude > 6 then buttonMoved = true end
		local cam = Workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
		local x = buttonOrigin.X.Offset + delta.X
		local y = buttonOrigin.Y.Scale * vp.Y + buttonOrigin.Y.Offset + delta.Y
		x = math.clamp(x, 4, vp.X - open.AbsoluteSize.X - 4)
		y = math.clamp(y, 4, vp.Y - open.AbsoluteSize.Y - 4)
		open.Position = UDim2.fromOffset(x, y)
	end
end))
track(UserInputService.InputEnded:Connect(function(i)
	if buttonDragging and (i == buttonInput or i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
		buttonDragging, buttonInput = false, nil
	end
end))

local openState = false
local function toggle()
	openState = not openState
	panel.Visible = openState
	-- botão NÃO some
end
open.Activated:Connect(function()
	if buttonMoved then buttonMoved = false; return end
	toggle()
end)

-- arraste do painel pelo header
local pd, ps, pp = false, nil, nil
header.InputBegan:Connect(function(i)
	if not states.panelDrag then return end
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
