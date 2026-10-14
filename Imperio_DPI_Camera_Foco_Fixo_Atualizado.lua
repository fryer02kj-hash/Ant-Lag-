--[[
	IMPÉRIO Anti Lag Hub
	Yuri Developer
	Versão revisada — controles de câmera, sensibilidade e Imperial Shift.

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

-- Amplia o alcance de zoom da câmera padrão do Roblox no cliente.
player.CameraMinZoomDistance = 3
player.CameraMaxZoomDistance = 60

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
panel.Size = UDim2.fromOffset(330, 250)          -- painel compacto para celular
panel.Position = UDim2.fromScale(0.5, 0.52)
panel.BackgroundColor3 = BLACK
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Visible = false
panel.ZIndex = 1
panel.Parent = gui
corner(panel, 22)
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
corner(wash, 22)

------------------------------------------------------------
-- HEADER (sem − e ×)
------------------------------------------------------------
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
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
    corner(f, 14)
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
cameraToggle.Text = "Imperial Sensitivity • DISABLED"
cameraToggle.Font = Enum.Font.GothamBold
cameraToggle.TextSize = 14
cameraToggle.TextColor3 = WHITE
cameraToggle.BackgroundColor3 = RED_DARK
cameraToggle.BorderSizePixel = 0
cameraToggle.Size = UDim2.new(1, -2, 0, 40)
cameraToggle.ZIndex = 20
cameraToggle.Parent = page
corner(cameraToggle, 14)
stroke(cameraToggle, RED, 1)

local sliderCard = card(page, "", "", 2, 84)
-- Mantém o cartão limpo: somente o controle deslizante fica visível.
for _, child in ipairs(sliderCard:GetChildren()) do
    if child:IsA("TextLabel") then child.Visible = false end
end

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
corner(shiftToggle, 14)
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
shiftLabel.ZIndex = 12
-- Chave visual ON/OFF dentro do painel: controla apenas a visibilidade do botão flutuante.
local panelSwitch = Instance.new("Frame")
panelSwitch.Name = "ImperialShiftPanelSwitch"
panelSwitch.Size = UDim2.fromOffset(58, 30)
panelSwitch.Position = UDim2.new(1, -70, 0.5, -15)
panelSwitch.BackgroundColor3 = Color3.fromRGB(5, 4, 7)
panelSwitch.BorderSizePixel = 0
panelSwitch.ZIndex = 13
panelSwitch.Parent = shiftToggle
corner(panelSwitch, 15)
stroke(panelSwitch, MUTED, 1)
local panelSwitchKnob = Instance.new("Frame")
panelSwitchKnob.Name = "SwitchKnob"
panelSwitchKnob.Size = UDim2.fromOffset(22, 22)
panelSwitchKnob.Position = UDim2.new(0, 4, 0.5, -11)
panelSwitchKnob.BackgroundColor3 = MUTED
panelSwitchKnob.BorderSizePixel = 0
panelSwitchKnob.ZIndex = 14
panelSwitchKnob.Parent = panelSwitch
corner(panelSwitchKnob, 99)

-- Imperial Shift: o controle interno apenas mostra/oculta o botão externo.
-- O botão externo (chave sem texto) liga/desliga o Shift Lock personalizado do script.
-- Roblox não fornece uma API universal para alterar a configuração interna de outro jogo.
local shiftPanelButtonVisible = true
local shiftLockEnabled = false
local shiftLockConnection = nil
local previousAutoRotate = nil
local cameraMode = false

-- Indicador central: substitui o antigo pontinho pelo emoji solicitado.
-- Ele é apenas visual; o botão flutuante continua sendo o controle ON/OFF.
local centerDot = Instance.new("TextLabel")
centerDot.Name = "ImperialShiftCenterRose"
centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
centerDot.Position = UDim2.fromScale(0.5, 0.5)
centerDot.Size = UDim2.fromOffset(20, 20)
centerDot.BackgroundTransparency = 1
centerDot.Text = "⊙"
centerDot.TextSize = 18
centerDot.Font = Enum.Font.GothamBold
centerDot.TextColor3 = WHITE
centerDot.Visible = false
centerDot.ZIndex = 100
centerDot.Parent = gui

-- Chave flutuante sem nome: trilho e bolinha que desliza entre OFF/ON.
local shiftFloating = Instance.new("TextButton")
shiftFloating.Name = "ImperialShiftLockToggle"
shiftFloating.Size = UDim2.fromOffset(58, 30)
shiftFloating.Position = UDim2.new(1, -72, 0.55, 0)
shiftFloating.BackgroundColor3 = CARD
shiftFloating.BorderSizePixel = 0
shiftFloating.Text = ""
shiftFloating.AutoButtonColor = false
shiftFloating.ZIndex = 45
shiftFloating.Parent = gui
corner(shiftFloating, 15)
local shiftTrackStroke = stroke(shiftFloating, RED, 1.25)
local shiftKnob = Instance.new("Frame")
shiftKnob.Name = "SwitchKnob"
shiftKnob.Size = UDim2.fromOffset(22, 22)
shiftKnob.Position = UDim2.new(0, 4, 0.5, -11)
shiftKnob.BackgroundColor3 = MUTED
shiftKnob.BorderSizePixel = 0
shiftKnob.ZIndex = 47
shiftKnob.Parent = shiftFloating
corner(shiftKnob, 99)

local function updateShiftSwitch()
    shiftFloating.BackgroundColor3 = shiftLockEnabled and RED_DARK or CARD
    shiftKnob.Position = shiftLockEnabled and UDim2.new(1, -26, 0.5, -11) or UDim2.new(0, 4, 0.5, -11)
    shiftKnob.BackgroundColor3 = shiftLockEnabled and WHITE or MUTED
    shiftTrackStroke.Color = shiftLockEnabled and RED or MUTED
    centerDot.Visible = shiftLockEnabled or cameraMode
end

local function setShiftLock(enabled)
    -- Estado é definido uma única vez; ao desligar, desconecta e restaura AutoRotate.
    shiftLockEnabled = enabled == true
    if shiftLockConnection then
        shiftLockConnection:Disconnect()
        shiftLockConnection = nil
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if shiftLockEnabled then
            if previousAutoRotate == nil then
                previousAutoRotate = humanoid.AutoRotate
            end
            humanoid.AutoRotate = false
        else
            humanoid.AutoRotate = previousAutoRotate ~= nil and previousAutoRotate or true
            previousAutoRotate = nil
        end
    end

    if shiftLockEnabled then
        shiftLockConnection = RunService.RenderStepped:Connect(function()
            if not shiftLockEnabled then return end
            local cam = Workspace.CurrentCamera
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not cam or not root or not hum or hum.Health <= 0 then return end
            local look = cam.CFrame.LookVector
            local flat = Vector3.new(look.X, 0, look.Z)
            if flat.Magnitude > 0.001 then
                root.CFrame = CFrame.lookAt(root.Position, root.Position + flat.Unit)
            end
        end)
    end
    updateShiftSwitch()
end

local function updatePanelSwitch()
    panelSwitch.BackgroundColor3 = shiftPanelButtonVisible and RED_DARK or Color3.fromRGB(5, 4, 7)
    panelSwitchKnob.Position = shiftPanelButtonVisible and UDim2.new(1, -26, 0.5, -11) or UDim2.new(0, 4, 0.5, -11)
    panelSwitchKnob.BackgroundColor3 = shiftPanelButtonVisible and WHITE or MUTED
end
shiftToggle.Activated:Connect(function()
    -- A chave interna só mostra/esconde o botão externo; não ativa Shift Lock.
    shiftPanelButtonVisible = not shiftPanelButtonVisible
    shiftFloating.Visible = shiftPanelButtonVisible
    updatePanelSwitch()
end)
updatePanelSwitch()
shiftFloating.Activated:Connect(function()
    setShiftLock(not shiftLockEnabled)
end)
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    -- Não reativa automaticamente após respawn; restaura o estado visual e AutoRotate.
    if shiftLockEnabled then
        previousAutoRotate = nil
        setShiftLock(true)
    else
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
        previousAutoRotate = nil
        updateShiftSwitch()
    end
end)
setShiftLock(false)

------------------------------------------------------------

-- CONTROLES FUNCIONAIS DE DPI
local sensitivity = 2.0
local minSensitivity, maxSensitivity = 1.0, 120.0
local sliderFill, sliderKnob, sensitivityValue, dpiStatus
local sliderTrack
sensitivityValue = sliderCard:FindFirstChild("SensitivityLabel")
dpiStatus = sensitivityValue
local cameraConnection
local savedCameraType, savedCameraSubject
local yaw, pitch = 0, 0
local activeTouch
local lastTouchPosition
local cameraDistance = 12
local minCameraDistance, maxCameraDistance = 3, 60
local cameraHeight = 2.5
local pinchTouches = {}
local pinchStartDistance = nil
local pinchStartCameraDistance = nil
local function clampSensitivity(v)
    return math.clamp(math.floor(v * 100 + 0.5) / 100, minSensitivity, maxSensitivity)
end

local function updateSensitivity(v)
    sensitivity = clampSensitivity(v)
    if sensitivityValue then sensitivityValue.Text = string.format("%.2f", sensitivity) end
    if sliderFill and sliderKnob then
        local alpha = (sensitivity - minSensitivity) / (maxSensitivity - minSensitivity)
        sliderFill.Size = UDim2.new(alpha, 0, 1, 0)
        sliderKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
        local bubble = sliderTrack and sliderTrack:FindFirstChild("SensitivityValueBubble")
        if bubble then
            bubble.Text = string.format("%.2f", sensitivity)
            bubble.Position = UDim2.new(alpha, 0, 0, -8)
        end
    end
end

-- Find the existing DPI slider card and add a working slider overlay.
local sliderHost = sliderCard
if sliderHost then
    sliderTrack = Instance.new("TextButton")
    sliderTrack.Name = "SensitivitySlider"
    sliderTrack.Text = ""
    sliderTrack.AutoButtonColor = false
    sliderTrack.BackgroundColor3 = Color3.fromRGB(50, 45, 54)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Size = UDim2.new(1, -28, 0, 14)
    sliderTrack.Position = UDim2.new(0, 14, 0.5, -7)
    sliderTrack.ZIndex = 30
    sliderTrack.Parent = sliderHost
    corner(sliderTrack, 8)

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

    -- Valor flutuante acompanha a bolinha durante o arraste.
    local valueBubble = Instance.new("TextLabel")
    valueBubble.Name = "SensitivityValueBubble"
    valueBubble.AnchorPoint = Vector2.new(0.5, 1)
    valueBubble.Size = UDim2.fromOffset(62, 24)
    valueBubble.Position = UDim2.new(0.2, 0, 0, -8)
    valueBubble.BackgroundColor3 = RED
    valueBubble.BorderSizePixel = 0
    valueBubble.Text = "2.00"
    valueBubble.TextColor3 = WHITE
    valueBubble.TextSize = 12
    valueBubble.Font = Enum.Font.GothamBold
    valueBubble.ZIndex = 35
    valueBubble.Parent = sliderTrack
    corner(valueBubble, 8)

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
    updateShiftSwitch()
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
    -- Preserve the exact current framing on activation. Use Roblox's actual camera
    -- focus (not a guessed height), then keep that focus offset relative to the root.
    local initialFocus = cam.Focus.Position
    if (initialFocus - root.Position).Magnitude > 20 then
        initialFocus = root.Position + Vector3.new(0, cameraHeight, 0)
    end
    local focusOffset = initialFocus - root.Position
    local focus = root.Position + focusOffset
    local fromFocus = cam.CFrame.Position - focus
    local distance = fromFocus.Magnitude
    if distance > 0.1 then
        cameraDistance = math.clamp(distance, minCameraDistance, maxCameraDistance)
        local direction = fromFocus.Unit
        yaw = math.atan2(direction.X, direction.Z)
        pitch = math.asin(math.clamp(-direction.Y, -0.98, 0.98))
    else
        local look = cam.CFrame.LookVector
        yaw = math.atan2(-look.X, -look.Z)
        pitch = math.asin(math.clamp(look.Y, -0.98, 0.98))
    end
    cameraMode = true
    updateShiftSwitch()
    cam.CameraType = Enum.CameraType.Scriptable
    cameraConnection = RunService.RenderStepped:Connect(function()
        local c = Workspace.CurrentCamera
        local ch = player.Character
        local r = ch and ch:FindFirstChild("HumanoidRootPart")
        if not c or not r or not cameraMode then return end
        local focus = r.Position + focusOffset
        local rot = CFrame.fromOrientation(pitch, yaw, 0)
        local offset = rot:VectorToWorldSpace(Vector3.new(0, 0, cameraDistance))
        c.CFrame = CFrame.lookAt(focus + offset, focus)
    end)
end

-- Rotação da câmera: pode começar em qualquer lado da tela, mas toques processados
-- pelo joystick/UI à esquerda são ignorados. Pinça de zoom só é reconhecida à direita.
local function isRightSideTouch(input)
    local vp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize
    return vp ~= nil and input.Position.X >= vp.X * 0.52
end

local function isMovementStickZone(input)
    local vp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize
    if not vp then return false end
    -- Área aproximada do joystick padrão: canto inferior esquerdo.
    return input.Position.X <= vp.X * 0.32 and input.Position.Y >= vp.Y * 0.55
end

UserInputService.TouchStarted:Connect(function(input, processed)
    if not cameraMode then return end
    if isRightSideTouch(input) then pinchTouches[input] = input.Position end
    local touches = {}
    for touch, pos in pairs(pinchTouches) do
        if isRightSideTouch(touch) then
            touches[#touches + 1] = {touch = touch, pos = pos}
        end
    end
    if #touches >= 2 then
        pinchStartDistance = (touches[1].pos - touches[2].pos).Magnitude
        pinchStartCameraDistance = cameraDistance
        activeTouch, lastTouchPosition = nil, nil
    elseif not isMovementStickZone(input) then
        -- Rotação por toda a tela, exceto a zona típica do joystick; zoom continua só à direita.
        activeTouch = input
        lastTouchPosition = input.Position
    end
end)

UserInputService.TouchMoved:Connect(function(input, processed)
    if not cameraMode then return end
    if pinchTouches[input] then
        pinchTouches[input] = input.Position
        local touches = {}
        for touch, pos in pairs(pinchTouches) do
            if isRightSideTouch(touch) then touches[#touches + 1] = pos end
        end
        if #touches >= 2 and pinchStartDistance and pinchStartDistance > 0 and pinchStartCameraDistance then
            local currentDistance = (touches[1] - touches[2]).Magnitude
            -- Abrir os dedos afasta a câmera; juntar os dedos aproxima.
            cameraDistance = math.clamp(pinchStartCameraDistance * (pinchStartDistance / math.max(currentDistance, 1)), minCameraDistance, maxCameraDistance)
            return
        end
    end
    if activeTouch == input and lastTouchPosition then
        local delta = input.Position - lastTouchPosition
        lastTouchPosition = input.Position
        local power = 0.0018 * sensitivity
        yaw = yaw - delta.X * power
        -- A câmera orbita o foco: este sinal faz arrastar para baixo olhar para baixo.
        pitch = math.clamp(pitch - delta.Y * power, math.rad(-75), math.rad(75))
    end
end)

UserInputService.TouchEnded:Connect(function(input)
    if input == activeTouch then activeTouch, lastTouchPosition = nil, nil end
    pinchTouches[input] = nil
    local touches = {}
    for touch, pos in pairs(pinchTouches) do
        if isRightSideTouch(touch) then touches[#touches + 1] = pos end
    end
    if #touches < 2 then
        pinchStartDistance, pinchStartCameraDistance = nil, nil
        local remainingTouch
        for touch in pairs(pinchTouches) do
            if isRightSideTouch(touch) then remainingTouch = touch break end
        end
        if remainingTouch and not isMovementStickZone(remainingTouch) then
            activeTouch, lastTouchPosition = remainingTouch, remainingTouch.Position
        end
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
        cameraToggle.Text = "Imperial Sensitivity • DISABLED"
    else
        startCustomCamera()
        if cameraMode then cameraToggle.Text = "Imperial Sensitivity • ENABLE" end
    end
end)

-- Ensure custom camera is released on respawn or script cleanup.
player.CharacterAdded:Connect(function()
    if cameraMode then
        stopCustomCamera()
    end
end)

updateSensitivity(2.0)
cameraToggle.Text = "Imperial Sensitivity • DISABLED"


-- BOTÃO FLUTUANTE: ícone compacto de mira para o tema de sensibilidade
------------------------------------------------------------
local open = Instance.new("TextButton")
open.Name = "ImperioFloatingButton"
open.Size = UDim2.fromOffset(40, 40)
open.Position = UDim2.new(0, 12, 0.5, -20)
open.BackgroundColor3 = BLACK
open.BackgroundTransparency = 0.1
open.BorderSizePixel = 0
open.Text = "⚡"
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
local draggingShiftButton, shiftButtonStart, shiftButtonOrigin = false, nil, nil
shiftFloating.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingShiftButton, shiftButtonStart, shiftButtonOrigin = true, input.Position, shiftFloating.Position
    end
end)
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
    elseif draggingShiftButton and shiftButtonStart and shiftButtonOrigin then
        local d = input.Position - shiftButtonStart
        shiftFloating.Position = UDim2.new(shiftButtonOrigin.X.Scale, shiftButtonOrigin.X.Offset + d.X, shiftButtonOrigin.Y.Scale, shiftButtonOrigin.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingPanel, panelStart, panelOrigin = false, nil, nil
        draggingButton, buttonStart, buttonOrigin = false, nil, nil
        draggingShiftButton, shiftButtonStart, shiftButtonOrigin = false, nil, nil
    end
end)

print("[IMPÉRIO DPI] Carregado • câmera, slider e Imperial Shift")
