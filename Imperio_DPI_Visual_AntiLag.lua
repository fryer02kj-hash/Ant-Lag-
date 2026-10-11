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

local old = playerGui:FindFirstChild("ImperioDpiGui")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ImperioDpiGui"
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

txt(header, "DPI HUB  •  Yuri Developer", 9, Enum.Font.Gotham, WHITE,
	UDim2.new(0, 16, 0, 26), UDim2.new(0.6, -20, 0, 16))

------------------------------------------------------------
-- BODY / VISUAL-ONLY DPI HUB
------------------------------------------------------------
local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.new(0, 7, 0, 52)
body.Size = UDim2.new(1, -14, 1, -59)
body.ZIndex = 5
body.Parent = panel

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 112, 1, 0)
sidebar.BackgroundColor3 = Color3.new(0, 0, 0)
sidebar.BackgroundTransparency = 0.3
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 6
sidebar.Parent = body
corner(sidebar, 9)
stroke(sidebar, Color3.fromRGB(80, 10, 18), 1)

local content = Instance.new("Frame")
content.Position = UDim2.new(0, 119, 0, 0)
content.Size = UDim2.new(1, -119, 1, 0)
content.BackgroundColor3 = Color3.new(0, 0, 0)
content.BackgroundTransparency = 0.3
content.BorderSizePixel = 0
content.ClipsDescendants = true
content.ZIndex = 6
content.Parent = body
corner(content, 9)
stroke(content, Color3.fromRGB(70, 8, 15), 1)

local cats = {
    {key="DPI", name="DPI"},
    {key="Câmera", name="Câmera"},
    {key="Controles", name="Controles"},
    {key="Visual", name="Visual"},
    {key="Extras", name="Extras"},
    {key="Configurações", name="Configurações"},
}
local active = "DPI"
local catBtns = {}
local pages = {}

local function makeText(parent, text, size, color, pos, size2, font)
    return txt(parent, text, size, font or Enum.Font.Gotham, color, pos, size2)
end

for i, info in ipairs(cats) do
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
    b.TextXAlignment = Enum.TextXAlignment.Center
    b.ZIndex = 10
    b.Parent = sidebar
    corner(b, 7)
    if info.key == active then stroke(b, RED, 1) end
    catBtns[info.key] = b

    local page = Instance.new("ScrollingFrame")
    page.Name = info.key
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Position = UDim2.new(0, 5, 0, 5)
    page.Size = UDim2.new(1, -10, 1, -10)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = RED
    page.Visible = (info.key == active)
    page.ZIndex = 7
    page.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    pages[info.key] = page
end

local function card(page, title, description, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -2, 0, 57)
    f.BackgroundColor3 = CARD
    f.BackgroundTransparency = 0.12
    f.BorderSizePixel = 0
    f.LayoutOrder = order or 1
    f.ZIndex = 8
    f.Parent = page
    corner(f, 8)
    stroke(f, Color3.fromRGB(105, 8, 22), 1)
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 1, -14)
    accent.Position = UDim2.new(0, 7, 0, 7)
    accent.BackgroundColor3 = RED
    accent.BorderSizePixel = 0
    accent.ZIndex = 9
    accent.Parent = f
    corner(accent, 2)
    makeText(f, title, 12, WHITE, UDim2.new(0, 17, 0, 5), UDim2.new(1, -25, 0, 21), Enum.Font.GothamSemibold).ZIndex = 10
    makeText(f, description, 9, MUTED, UDim2.new(0, 17, 0, 27), UDim2.new(1, -25, 0, 22)).ZIndex = 10
    return f
end

-- Tudo abaixo é apenas visual: os controles não alteram câmera nem configurações do jogo.
local p = pages["DPI"]
card(p, "DPI & SENSIBILIDADE", "Interface visual • funções ainda desativadas", 1)
local sliderCard = card(p, "Sensibilidade: 2.0x", "Faixa visual: 0.5x — 8.0x", 2)
local track = Instance.new("Frame")
track.Position = UDim2.new(0, 18, 1, -12)
track.Size = UDim2.new(1, -36, 0, 4)
track.BackgroundColor3 = Color3.fromRGB(55, 50, 58)
track.BorderSizePixel = 0
track.ZIndex = 11
track.Parent = sliderCard
corner(track, 3)
local fill = Instance.new("Frame")
fill.Size = UDim2.new(0.2, 0, 1, 0)
fill.BackgroundColor3 = RED
fill.BorderSizePixel = 0
fill.ZIndex = 12
fill.Parent = track
corner(fill, 3)
card(p, "Presets rápidos", "0.5x  •  1.0x  •  2.0x  •  4.0x  •  8.0x", 3)
card(p, "DPI atual: 2.0x", "Os valores são demonstrativos por enquanto.", 4)

card(pages["Câmera"], "CÂMERA", "Ajustes visuais de câmera serão configurados depois.", 1)
card(pages["Câmera"], "Sensibilidade horizontal", "Controle demonstrativo • sem efeito real.", 2)
card(pages["Câmera"], "Sensibilidade vertical", "Direção planejada: arrastar para baixo olha para baixo.", 3)
card(pages["Controles"], "CONTROLES MOBILE", "Layout preparado para toque no Android.", 1)
card(pages["Controles"], "Botão flutuante", "Arraste e abra/feche o painel.", 2)
card(pages["Controles"], "Gestos de toque", "Configurações ainda somente visuais.", 3)
card(pages["Visual"], "VISUAL", "Opções futuras de aparência da interface.", 1)
card(pages["Visual"], "Tema preto e vermelho", "Estilo original do Império Anti Lag preservado.", 2)
card(pages["Extras"], "EXTRAS", "Espaço reservado para recursos futuros.", 1)
card(pages["Extras"], "Perfis de sensibilidade", "Somente demonstração visual.", 2)
card(pages["Configurações"], "CONFIGURAÇÕES", "Preferências da interface.", 1)
card(pages["Configurações"], "Restaurar padrão", "Botão visual • ainda não executa ações.", 2)

local function refreshTabs()
    for key, b in pairs(catBtns) do
        local selected = (key == active)
        b.BackgroundColor3 = selected and RED_DARK or Color3.fromRGB(8, 6, 9)
        b.BackgroundTransparency = selected and 0.05 or 0.55
        b.TextColor3 = selected and WHITE or MUTED
    end
    for key, page in pairs(pages) do page.Visible = (key == active) end
end
for key, b in pairs(catBtns) do
    b.Activated:Connect(function()
        active = key
        refreshTabs()
    end)
end

------------------------------------------------------------
-- BOTÃO FLUTUANTE: emoji solicitado 🥀
------------------------------------------------------------
local open = Instance.new("TextButton")
open.Name = "ImperioFloatingButton"
open.Size = UDim2.fromOffset(40, 40)
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
corner(open, 10)
stroke(open, RED, 1.5)

local openState = false
open.Activated:Connect(function()
    openState = not openState
    panel.Visible = openState
end)

-- Arrastar o painel pelo cabeçalho e o botão flutuante pelo toque/clique.
local draggingPanel, panelStart, panelOrigin = false, nil, nil
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingPanel, panelStart, panelOrigin = true, input.Position, panel.Position
    end
end)
local draggingButton, buttonStart, buttonOrigin = false, nil, nil
open.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingButton, buttonStart, buttonOrigin = true, input.Position, open.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    if draggingPanel and panelStart and panelOrigin then
        local d = input.Position - panelStart
        panel.Position = UDim2.new(panelOrigin.X.Scale, panelOrigin.X.Offset + d.X, panelOrigin.Y.Scale, panelOrigin.Y.Offset + d.Y)
    elseif draggingButton and buttonStart and buttonOrigin then
        local d = input.Position - buttonStart
        open.Position = UDim2.new(buttonOrigin.X.Scale, buttonOrigin.X.Offset + d.X, buttonOrigin.Y.Scale, buttonOrigin.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingPanel, panelStart, panelOrigin = false, nil, nil
        draggingButton, buttonStart, buttonOrigin = false, nil, nil
    end
end)

print("[IMPÉRIO DPI] Interface visual carregada • funções de jogo desativadas")
