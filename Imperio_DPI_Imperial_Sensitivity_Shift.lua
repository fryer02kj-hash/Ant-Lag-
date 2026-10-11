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
panel.Size = UDim2.fromOffset(460, 320)          -- altura compacta para incluir Imperial Shift
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

txt(header, "DPI HUB  •  MOBILE", 9, Enum.Font.Gotham, WHITE,
	UDim2.new(0, 16, 0, 26), UDim2.new(0.6, -20, 0, 16))

------------------------------------------------------------
-- BODY / IMPÉRIO DPI
------------------------------------------------------------
local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.new(0, 7, 0, 52)
body.Size = UDim2.new(1, -14, 1, -59)
body.ZIndex = 5
body.Parent = panel

-- Interface simplificada: somente DPI, controle deslizante e câmera potente.
local content = Instance.new("Frame")
content.Position = UDim2.new(0, 8, 0, 0)
content.Size = UDim2.new(1, -16, 1, 0)
content.BackgroundColor3 = Color3.new(0, 0, 0)
content.BackgroundTransparency = 0.3
content.BorderSizePixel = 0
content.ClipsDescendants = true
content.ZIndex = 6
content.Parent = body
corner(content, 9)
stroke(content, Color3.fromRGB(70, 8, 15), 1)

local active = "DPI"
local pages = {}
local function makeText(parent, text, size, color, pos, size2, font)
    return txt(parent, text, size, font or Enum.Font.Gotham, color, pos, size2)
end
local page = Instance.new("ScrollingFrame")
page.Name = "DPI"
page.BackgroundTransparency = 1
page.BorderSizePixel = 0
page.Position = UDim2.new(0, 5, 0, 5)
page.Size = UDim2.new(1, -10, 1, -10)
page.CanvasSize = UDim2.new(0, 0, 0, 0)
page.AutomaticCanvasSize = Enum.AutomaticSize.Y
page.ScrollBarThickness = 3
page.ScrollBarImageColor3 = RED
page.Visible = true
page.ZIndex = 7
page.Parent = content
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = page
pages["DPI"] = page

local function card(parent, title, description, order, height)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -2, 0, height or 72)
    f.BackgroundColor3 = CARD
    f.BackgroundTransparency = 0.12
    f.BorderSizePixel = 0
    f.LayoutOrder = order or 1
    f.ZIndex = 8
    f.Parent = parent
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
    local label = makeText(f, title, 12, WHITE, UDim2.new(0, 17, 0, 5), UDim2.new(1, -25, 0, 21), Enum.Font.GothamSemibold)
    label.Name = "SensitivityLabel"
    makeText(f, description, 9, MUTED, UDim2.new(0, 17, 0, 27), UDim2.new(1, -25, 0, 22)).ZIndex = 10
    return f
end

-- Botão da câmera no topo; o slider vem logo abaixo.
local cameraToggle = Instance.new("TextButton")
cameraToggle.Name = "ToggleCustomCamera"
cameraToggle.LayoutOrder = 1
cameraToggle.Text = "imperial Sensitivity"
cameraToggle.Font = Enum.Font.GothamBold
cameraToggle.TextSize = 14
cameraToggle.TextColor3 = WHITE
cameraToggle.BackgroundColor3 = RED_DARK
cameraToggle.BorderSizePixel = 0
cameraToggle.Size = UDim2.new(1, -2, 0, 48)
cameraToggle.ZIndex = 20
cameraToggle.Parent = page
corner(cameraToggle, 8)
stroke(cameraToggle, RED, 1)

local sliderCard = card(page, "Sensibilidade: 2.0x", "Arraste para ajustar de 0.5x até 120x.", 2, 84)

-- Alternância Imperial Shift, logo abaixo do controle de sensibilidade.
local shiftToggle = Instance.new("TextButton")
shiftToggle.Name = "ImperialShiftToggle"
shiftToggle.LayoutOrder = 3
shiftToggle.Size = UDim2.new(1, -2, 0, 44)
shiftToggle.BackgroundColor3 = CARD
shiftToggle.BackgroundTransparency = 0.12
shiftToggle.BorderSizePixel = 0
shiftToggle.Text = ""
shiftToggle.ZIndex = 10
shiftToggle.Parent = page
corner(shiftToggle, 8)
stroke(shiftToggle, Color3.fromRGB(105, 8, 22), 1)
local shiftAccent = Instance.new("Frame")
shiftAccent.Size = UDim2.new(0, 3, 1, -14)
shiftAccent.Position = UDim2.new(0, 7, 0, 7)
shiftAccent.BackgroundColor3 = RED
shiftAccent.BorderSizePixel = 0
shiftAccent.ZIndex = 11
shiftAccent.Parent = shiftToggle
corner(shiftAccent, 2)
local shiftLabel = txt(shiftToggle, "Imperial Shift", 12, Enum.Font.GothamSemibold, WHITE,
    UDim2.new(0, 17, 0, 0), UDim2.new(0.72, 0, 1, 0))
local shiftStateLabel = txt(shiftToggle, "OFF", 11, Enum.Font.GothamBold, MUTED,
    UDim2.new(1, -58, 0, 0), UDim2.new(0, 42, 1, 0), Enum.TextXAlignment.Center)
shiftLabel.ZIndex = 12
shiftStateLabel.ZIndex = 12

local imperialShiftEnabled = false
local centerDot = Instance.new("Frame")
centerDot.Name = "ImperialShiftCenterDot"
centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
centerDot.Position = UDim2.fromScale(0.5, 0.5)
centerDot.Size = UDim2.fromOffset(6, 6)
centerDot.BackgroundColor3 = WHITE
centerDot.BorderSizePixel = 0
centerDot.Visible = false
centerDot.ZIndex = 100
centerDot.Parent = gui
corner(centerDot, 99)
stroke(centerDot, RED, 1.5)
shiftToggle.Activated:Connect(function()
    imperialShiftEnabled = not imperialShiftEnabled
    centerDot.Visible = imperialShiftEnabled
    shiftStateLabel.Text = imperialShiftEnabled and "ON" or "OFF"
    shiftStateLabel.TextColor3 = imperialShiftEnabled and RED or MUTED
    shiftToggle.BackgroundColor3 = imperialShiftEnabled and RED_DARK or CARD
end)

------------------------------------------------------------

-- CONTROLES FUNCIONAIS DE DPI
local sensitivity = 2.0
local minSensitivity, maxSensitivity = 0.5, 120.0
local sliderFill, sliderKnob, sensitivityValue, dpiStatus
sensitivityValue = sliderCard:FindFirstChild("SensitivityLabel")
dpiStatus = sensitivityValue
local cameraMode = false
local cameraConnection
local savedCameraType, savedCameraSubject
local yaw, pitch = 0, 0
local activeTouch
local lastTouchPosition
local cameraDistance = 8
local minCameraDistance, maxCameraDistance = 2, 20
local cameraHeight = 3
local pinchTouches = {}
local pinchStartDistance = nil
local pinchStartCameraDistance = nil
local function clampSensitivity(v)
    return math.clamp(math.floor(v * 10 + 0.5) / 10, minSensitivity, maxSensitivity)
end

local function updateSensitivity(v)
    sensitivity = clampSensitivity(v)
    if sensitivityValue then sensitivityValue.Text = string.format("%.1fx", sensitivity) end
    if dpiStatus then dpiStatus.Text = string.format("Sensibilidade: %.1fx", sensitivity) end
    if sliderFill and sliderKnob then
        local alpha = (sensitivity - minSensitivity) / (maxSensitivity - minSensitivity)
        sliderFill.Size = UDim2.new(alpha, 0, 1, 0)
        sliderKnob.Position = UDim2.new(alpha, -7, 0.5, -7)
    end
end

-- Find the existing DPI slider card and add a working slider overlay.
local dpiPage = pages["DPI"]
local sliderHost = sliderCard
local sliderTrack
if dpiPage then
    for _, obj in ipairs(dpiPage:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Text:find("Sensibilidade") then
            local parent = obj.Parent
            if parent and parent:IsA("Frame") then
                sliderHost = parent
                break
            end
        end
    end
end

if sliderHost then
    sliderTrack = Instance.new("TextButton")
    sliderTrack.Name = "SensitivitySlider"
    sliderTrack.Text = ""
    sliderTrack.AutoButtonColor = false
    sliderTrack.BackgroundColor3 = Color3.fromRGB(50, 45, 54)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Size = UDim2.new(1, -28, 0, 12)
    sliderTrack.Position = UDim2.new(0, 14, 1, -26)
    sliderTrack.ZIndex = 30
    sliderTrack.Parent = sliderHost
    corner(sliderTrack, 6)

    sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.BackgroundColor3 = RED
    sliderFill.BorderSizePixel = 0
    sliderFill.Size = UDim2.new(0.2, 0, 1, 0)
    sliderFill.ZIndex = 31
    sliderFill.Parent = sliderTrack
    corner(sliderFill, 6)

    sliderKnob = Instance.new("Frame")
    sliderKnob.Name = "Knob"
    sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderKnob.Position = UDim2.new(0.2, 0, 0.5, 0)
    sliderKnob.Size = UDim2.fromOffset(16, 16)
    sliderKnob.BackgroundColor3 = WHITE
    sliderKnob.BorderSizePixel = 0
    sliderKnob.ZIndex = 32
    sliderKnob.Parent = sliderTrack
    corner(sliderKnob, 8)
    stroke(sliderKnob, RED, 2)

    local function setFromX(x)
        local alpha = math.clamp((x - sliderTrack.AbsolutePosition.X) / math.max(sliderTrack.AbsoluteSize.X, 1), 0, 1)
        updateSensitivity(minSensitivity + alpha * (maxSensitivity - minSensitivity))
    end
    sliderTrack.Activated:Connect(function()
        local mouse = UserInputService:GetMouseLocation()
        setFromX(mouse.X)
    end)
    local sliderTouch = nil
    local sliderMouseDown = false
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            sliderTouch = input
            setFromX(input.Position.X)
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderMouseDown = true
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliderTouch and input == sliderTouch then
            setFromX(input.Position.X)
        elseif sliderMouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input == sliderTouch then sliderTouch = nil end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliderMouseDown = false end
    end)
end

-- Camera sensitivity: use Roblox's standard camera unless the user enables this
-- custom touch-camera mode. The mode follows the character and applies the selected multiplier.
local function stopCustomCamera()
    cameraMode = false
    if cameraConnection then cameraConnection:Disconnect(); cameraConnection = nil end
    local cam = Workspace.CurrentCamera
    if cam then
        cam.CameraType = savedCameraType or Enum.CameraType.Custom
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        cam.CameraSubject = savedCameraSubject or humanoid
    end
    activeTouch, lastTouchPosition = nil, nil
    table.clear(pinchTouches)
    pinchStartDistance, pinchStartCameraDistance = nil, nil
end

local function startCustomCamera()
    local cam = Workspace.CurrentCamera
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not cam or not root or not humanoid then
        if dpiStatus then dpiStatus.Text = "Aguarde o personagem carregar" end
        return
    end
    if cameraMode then stopCustomCamera(); return end
    savedCameraType, savedCameraSubject = cam.CameraType, cam.CameraSubject
    local look = cam.CFrame.LookVector
    yaw = math.atan2(-look.X, -look.Z)
    pitch = math.asin(math.clamp(look.Y, -0.98, 0.98))
    cameraMode = true
    cam.CameraType = Enum.CameraType.Scriptable
    cameraConnection = RunService.RenderStepped:Connect(function()
        local c = Workspace.CurrentCamera
        local ch = player.Character
        local r = ch and ch:FindFirstChild("HumanoidRootPart")
        if not c or not r or not cameraMode then return end
        local focus = r.Position + Vector3.new(0, cameraHeight, 0)
        local rot = CFrame.fromOrientation(pitch, yaw, 0)
        local offset = rot:VectorToWorldSpace(Vector3.new(0, 0, cameraDistance))
        c.CFrame = CFrame.lookAt(focus + offset, focus)
    end)
end

UserInputService.TouchStarted:Connect(function(input, processed)
    if processed or not cameraMode then return end
    local vp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize
    if vp and input.Position.X > vp.X * 0.32 then
        activeTouch = input
        lastTouchPosition = input.Position
    end
end)
UserInputService.TouchMoved:Connect(function(input, processed)
    if not cameraMode or not activeTouch or input ~= activeTouch then return end
    local delta = input.Position - lastTouchPosition
    lastTouchPosition = input.Position
    local power = 0.0018 * sensitivity
    yaw = yaw - delta.X * power
    pitch = math.clamp(pitch - delta.Y * power, math.rad(-75), math.rad(75))
end)
UserInputService.TouchEnded:Connect(function(input)
    if input == activeTouch then activeTouch, lastTouchPosition = nil, nil end
    pinchTouches[input] = nil
    local remaining = 0
    for _ in pairs(pinchTouches) do remaining += 1 end
    if remaining < 2 then
        pinchStartDistance = nil
        pinchStartCameraDistance = nil
    end
end)

-- Pinça com dois dedos no celular e roda do mouse para aproximar/afastar.
UserInputService.TouchStarted:Connect(function(input)
    if not cameraMode then return end
    pinchTouches[input] = input.Position
    local touches = {}
    for touch, pos in pairs(pinchTouches) do
        touches[#touches + 1] = {touch = touch, pos = pos}
    end
    if #touches >= 2 then
        pinchStartDistance = (touches[1].pos - touches[2].pos).Magnitude
        pinchStartCameraDistance = cameraDistance
        activeTouch = nil
        lastTouchPosition = nil
    end
end)
UserInputService.TouchMoved:Connect(function(input)
    if not cameraMode or not pinchTouches[input] then return end
    pinchTouches[input] = input.Position
    local touches = {}
    for touch, pos in pairs(pinchTouches) do
        touches[#touches + 1] = pos
    end
    if #touches >= 2 and pinchStartDistance and pinchStartDistance > 0 and pinchStartCameraDistance then
        local currentDistance = (touches[1] - touches[2]).Magnitude
        cameraDistance = math.clamp(pinchStartCameraDistance * (pinchStartDistance / math.max(currentDistance, 1)), minCameraDistance, maxCameraDistance)
    end
end)

UserInputService.InputChanged:Connect(function(input, processed)
    if processed or not cameraMode then return end
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        cameraDistance = math.clamp(cameraDistance - input.Position.Z, minCameraDistance, maxCameraDistance)
    end
end)

cameraToggle.Activated:Connect(function()
    if cameraMode then
        stopCustomCamera()
        cameraToggle.Text = "imperial Sensitivity"
    else
        startCustomCamera()
        if cameraMode then cameraToggle.Text = "imperial Sensitivity • ATIVA" end
    end
end)

-- Ensure custom camera is released on respawn or script cleanup.
player.CharacterAdded:Connect(function()
    if cameraMode then
        stopCustomCamera()
    end
end)

updateSensitivity(2.0)


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

print("[IMPÉRIO DPI] Carregado • sensibilidade e controles interativos")
