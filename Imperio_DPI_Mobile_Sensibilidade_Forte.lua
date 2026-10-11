--[[
    IMPÉRIO DPI MOBILE
    LocalScript para o SEU próprio jogo Roblox.
    Instalação: StarterPlayer > StarterPlayerScripts

    Nota: Roblox não oferece uma propriedade pública que multiplique diretamente
    a sensibilidade da câmera touch padrão. Este script usa um controlador de
    câmera personalizado enquanto ativo. Teste no Roblox Studio antes de publicar.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Evita duplicar a interface/controlador ao executar novamente.
local oldGui = playerGui:FindFirstChild("ImperioDPIMobile")
if oldGui then oldGui:Destroy() end
pcall(function()
    RunService:UnbindFromRenderStep("ImperioDPIMobileCamera")
end)

local RED = Color3.fromRGB(255, 18, 42)
local RED_DARK = Color3.fromRGB(65, 0, 10)
local BLACK = Color3.fromRGB(5, 4, 7)
local WHITE = Color3.fromRGB(245, 242, 245)
local MUTED = Color3.fromRGB(155, 150, 160)
local CARD = Color3.fromRGB(9, 6, 10)
local PANEL_DARK = Color3.fromRGB(18, 13, 17)

local gui = Instance.new("ScreenGui")
gui.Name = "ImperioDPIMobile"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 201
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = object
    return c
end

local function stroke(object, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or RED
    s.Thickness = thickness or 1
    s.Parent = object
    return s
end

local function label(parent, text, size, font, color, position, dimensions, xAlign)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextSize = size
    t.Font = font
    t.TextColor3 = color
    t.Position = position
    t.Size = dimensions
    t.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Center
    t.TextWrapped = true
    t.ZIndex = 10
    t.Parent = parent
    return t
end

-- Launcher flutuante, feito para toque.
local launcher = Instance.new("TextButton")
launcher.Name = "Launcher"
launcher.Size = UDim2.fromOffset(50, 50)
launcher.Position = UDim2.new(0, 14, 0.56, 0)
launcher.BackgroundColor3 = BLACK
launcher.BorderSizePixel = 0
launcher.Text = "♛"
launcher.TextColor3 = RED
launcher.TextSize = 28
launcher.Font = Enum.Font.GothamBlack
launcher.AutoButtonColor = true
launcher.ZIndex = 30
launcher.Parent = gui
corner(launcher, 12)
stroke(launcher, RED, 1.5)

-- Painel com a mesma estrutura visual do Império Anti Lag Hub.
local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Size = UDim2.fromOffset(460, 290)
panel.Position = UDim2.fromScale(0.5, 0.52)
panel.BackgroundColor3 = BLACK
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Visible = false
panel.ZIndex = 1
panel.Parent = gui
corner(panel, 12)
stroke(panel, RED, 1.5)

local wash = Instance.new("Frame")
wash.Size = UDim2.fromScale(1, 1)
wash.BackgroundColor3 = Color3.new(0, 0, 0)
wash.BackgroundTransparency = 0.3
wash.BorderSizePixel = 0
wash.ZIndex = 2
wash.Parent = panel
corner(wash, 12)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.new(0, 0, 0)
header.BackgroundTransparency = 0.2
header.BorderSizePixel = 0
header.ZIndex = 5
header.Parent = panel

label(header, "♛", 24, Enum.Font.GothamBlack, RED,
    UDim2.new(0, 10, 0, 4), UDim2.fromOffset(32, 32), Enum.TextXAlignment.Center)
label(header, "IMPÉRIO DPI", 20, Enum.Font.GothamBlack, RED,
    UDim2.new(0, 44, 0, 3), UDim2.new(0.6, -20, 0, 24))
label(header, "CONTROLE DE CÂMERA • MOBILE", 9, Enum.Font.Gotham, WHITE,
    UDim2.new(0, 45, 0, 26), UDim2.new(0.7, -20, 0, 16))

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 32)
close.Position = UDim2.new(1, -39, 0, 8)
close.BackgroundColor3 = RED_DARK
close.BorderSizePixel = 0
close.Text = "×"
close.TextSize = 23
close.Font = Enum.Font.GothamBold
close.TextColor3 = WHITE
close.ZIndex = 20
close.Parent = header
corner(close, 8)

local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.new(0, 7, 0, 52)
body.Size = UDim2.new(1, -14, 1, -59)
body.ZIndex = 5
body.Parent = panel

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 96, 1, 0)
sidebar.BackgroundColor3 = Color3.new(0, 0, 0)
sidebar.BackgroundTransparency = 0.2
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 6
sidebar.Parent = body
corner(sidebar, 9)
stroke(sidebar, Color3.fromRGB(80, 10, 18), 1)

local content = Instance.new("Frame")
content.Position = UDim2.new(0, 103, 0, 0)
content.Size = UDim2.new(1, -103, 1, 0)
content.BackgroundColor3 = PANEL_DARK
content.BackgroundTransparency = 0.08
content.BorderSizePixel = 0
content.ClipsDescendants = true
content.ZIndex = 6
content.Parent = body
corner(content, 9)
stroke(content, Color3.fromRGB(70, 8, 15), 1)

local cat = Instance.new("TextButton")
cat.Size = UDim2.new(1, -6, 0, 32)
cat.Position = UDim2.new(0, 3, 0, 5)
cat.BackgroundColor3 = RED_DARK
cat.BackgroundTransparency = 0.05
cat.BorderSizePixel = 0
cat.Text = "Câmera"
cat.TextColor3 = WHITE
cat.TextSize = 12
cat.Font = Enum.Font.GothamSemibold
cat.ZIndex = 10
cat.Parent = sidebar
corner(cat, 7)
stroke(cat, RED, 1)

local pageTitle = label(content, "SENSIBILIDADE TOUCH", 13, Enum.Font.GothamBold, RED,
    UDim2.new(0, 12, 0, 10), UDim2.new(1, -24, 0, 23))
local description = label(content, "Ajuste quanto a câmera gira ao arrastar o dedo no lado direito da tela.", 11,
    Enum.Font.Gotham, MUTED, UDim2.new(0, 12, 0, 36), UDim2.new(1, -24, 0, 38))
description.TextYAlignment = Enum.TextYAlignment.Top

local valueText = label(content, "Sensibilidade: 2.0x", 14, Enum.Font.GothamSemibold, WHITE,
    UDim2.new(0, 12, 0, 82), UDim2.new(1, -24, 0, 24))

local track = Instance.new("TextButton")
track.Name = "SensitivityTrack"
track.Size = UDim2.new(1, -34, 0, 10)
track.Position = UDim2.new(0, 17, 0, 119)
track.BackgroundColor3 = Color3.fromRGB(65, 55, 62)
track.BorderSizePixel = 0
track.Text = ""
track.AutoButtonColor = false
track.ZIndex = 12
track.Parent = content
corner(track, 6)

local fill = Instance.new("Frame")
fill.Size = UDim2.new((2.0 - MIN_SENSITIVITY) / (MAX_SENSITIVITY - MIN_SENSITIVITY), 0, 1, 0)
fill.BackgroundColor3 = RED
fill.BorderSizePixel = 0
fill.ZIndex = 13
fill.Parent = track
corner(fill, 6)

local knob = Instance.new("Frame")
knob.Size = UDim2.fromOffset(20, 20)
knob.Position = UDim2.new((2.0 - MIN_SENSITIVITY) / (MAX_SENSITIVITY - MIN_SENSITIVITY), -10, 0.5, -10)
knob.BackgroundColor3 = WHITE
knob.BorderSizePixel = 0
knob.ZIndex = 14
knob.Parent = track
corner(knob, 10)
stroke(knob, RED, 1.5)

local lowText = label(content, "0.5x", 10, Enum.Font.Gotham, MUTED,
    UDim2.new(0, 12, 0, 135), UDim2.fromOffset(40, 18))
local highText = label(content, "4.0x", 10, Enum.Font.Gotham, MUTED,
    UDim2.new(1, -52, 0, 135), UDim2.fromOffset(40, 18), Enum.TextXAlignment.Right)

local statusText = label(content, "Câmera personalizada: ATIVA", 11, Enum.Font.GothamSemibold, RED,
    UDim2.new(0, 12, 0, 160), UDim2.new(1, -24, 0, 20))

local reset = Instance.new("TextButton")
reset.Size = UDim2.new(1, -24, 0, 31)
reset.Position = UDim2.new(0, 12, 1, -43)
reset.BackgroundColor3 = RED_DARK
reset.BorderSizePixel = 0
reset.Text = "REDEFINIR • 2.0x"
reset.Font = Enum.Font.GothamBold
reset.TextSize = 12
reset.TextColor3 = WHITE
reset.ZIndex = 12
reset.Parent = content
corner(reset, 8)
stroke(reset, Color3.fromRGB(110, 10, 25), 1)

-- Sensibilidade e slider.
local sensitivity = 2.0
local MIN_SENSITIVITY, MAX_SENSITIVITY = 0.5, 8.0
local sliderTouch = nil

local function setSensitivityFromX(x)
    local width = track.AbsoluteSize.X
    if width <= 0 then return end
    local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
    sensitivity = math.floor((MIN_SENSITIVITY + alpha * (MAX_SENSITIVITY - MIN_SENSITIVITY)) * 10 + 0.5) / 10
    local normalized = (sensitivity - MIN_SENSITIVITY) / (MAX_SENSITIVITY - MIN_SENSITIVITY)
    fill.Size = UDim2.new(normalized, 0, 1, 0)
    knob.Position = UDim2.new(normalized, -10, 0.5, -10)
    valueText.Text = string.format("Sensibilidade: %.1fx", sensitivity)
end

track.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        sliderTouch = input
        setSensitivityFromX(input.Position.X)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderTouch and input == sliderTouch and input.UserInputType == Enum.UserInputType.Touch then
        setSensitivityFromX(input.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if sliderTouch and input == sliderTouch then
        sliderTouch = nil
    end
end)

reset.Activated:Connect(function()
    sensitivity = 1.0
    local normalized = (2.0 - MIN_SENSITIVITY) / (MAX_SENSITIVITY - MIN_SENSITIVITY)
    fill.Size = UDim2.new(normalized, 0, 1, 0)
    knob.Position = UDim2.new(normalized, -10, 0.5, -10)
    sensitivity = 2.0
    valueText.Text = "Sensibilidade: 2.0x"
end)

-- Abre/fecha e arrasta a interface usando toque.
launcher.Activated:Connect(function()
    panel.Visible = not panel.Visible
end)
close.Activated:Connect(function()
    panel.Visible = false
end)

local function makeDraggable(object, handle)
    local activeTouch, startPosition, startObjectPosition
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            activeTouch = input
            startPosition = input.Position
            startObjectPosition = object.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if activeTouch and input == activeTouch then
            local delta = input.Position - startPosition
            object.Position = UDim2.new(
                startObjectPosition.X.Scale, startObjectPosition.X.Offset + delta.X,
                startObjectPosition.Y.Scale, startObjectPosition.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if activeTouch and input == activeTouch then activeTouch = nil end
    end)
end
makeDraggable(launcher, launcher)
makeDraggable(panel, header)

-- Controlador de câmera exclusivo para toque no lado direito.
local cameraEnabled = true
local activeCameraTouch = nil
local lastTouchPosition = nil
local yaw, pitch = 0, 0
local cameraDistance = 10
local minPitch, maxPitch = math.rad(-70), math.rad(70)
local camera = workspace.CurrentCamera
local previousCameraType = nil
local previousCameraSubject = nil

local function getFocusPosition()
    local character = player.Character
    if not character then return nil end
    local head = character:FindFirstChild("Head")
    local root = character:FindFirstChild("HumanoidRootPart")
    if head then return head.Position end
    if root then return root.Position + Vector3.new(0, 1.5, 0) end
    return nil
end

local function syncAngles()
    camera = workspace.CurrentCamera
    if not camera then return end
    local look = camera.CFrame.LookVector
    yaw = math.atan2(-look.X, -look.Z)
    pitch = math.clamp(math.asin(math.clamp(look.Y, -1, 1)), minPitch, maxPitch)
end

local function enableCameraController()
    camera = workspace.CurrentCamera
    if not camera then return end
    previousCameraType = camera.CameraType
    previousCameraSubject = camera.CameraSubject
    syncAngles()
    cameraEnabled = true
    statusText.Text = "Câmera personalizada: ATIVA"
    statusText.TextColor3 = RED
end

local function disableCameraController()
    cameraEnabled = false
    activeCameraTouch = nil
    lastTouchPosition = nil
    camera = workspace.CurrentCamera
    if camera then
        camera.CameraType = Enum.CameraType.Custom
        if previousCameraSubject then
            camera.CameraSubject = previousCameraSubject
        elseif player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then camera.CameraSubject = hum end
        end
    end
    statusText.Text = "Câmera personalizada: DESATIVADA"
    statusText.TextColor3 = MUTED
end

UserInputService.TouchStarted:Connect(function(input, processed)
    if processed or not cameraEnabled or panel.Visible then return end
    camera = workspace.CurrentCamera
    if not camera then return end
    local position = Vector2.new(input.Position.X, input.Position.Y)
    -- Mantém o lado esquerdo disponível para o joystick de movimento.
    if position.X >= camera.ViewportSize.X * 0.42 then
        activeCameraTouch = input
        lastTouchPosition = position
    end
end)

UserInputService.TouchMoved:Connect(function(input)
    if not cameraEnabled or input ~= activeCameraTouch or not lastTouchPosition then return end
    camera = workspace.CurrentCamera
    if not camera then return end
    local position = Vector2.new(input.Position.X, input.Position.Y)
    local delta = position - lastTouchPosition
    lastTouchPosition = position
    local width = math.max(camera.ViewportSize.X, 1)
    local radiansPerPixel = (2 * math.pi) / width
    yaw = yaw - delta.X * radiansPerPixel * sensitivity
    pitch = math.clamp(pitch + delta.Y * radiansPerPixel * sensitivity, minPitch, maxPitch)
end)

UserInputService.TouchEnded:Connect(function(input)
    if input == activeCameraTouch then
        activeCameraTouch = nil
        lastTouchPosition = nil
    end
end)

RunService:BindToRenderStep("ImperioDPIMobileCamera", Enum.RenderPriority.Camera.Value + 1, function()
    if not cameraEnabled then return end
    camera = workspace.CurrentCamera
    if not camera then return end
    local focus = getFocusPosition()
    if not focus then return end

    camera.CameraType = Enum.CameraType.Scriptable
    local horizontalDistance = cameraDistance * math.cos(pitch)
    local offset = Vector3.new(
        math.sin(yaw) * horizontalDistance,
        math.sin(pitch) * cameraDistance,
        math.cos(yaw) * horizontalDistance
    )
    camera.CFrame = CFrame.lookAt(focus + offset, focus)
    camera.Focus = CFrame.new(focus)
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if cameraEnabled then
        syncAngles()
    end
end)

-- Ajusta o tamanho do painel para telas pequenas sem quebrar o layout.
local function fitPanel()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    local scale = math.min(1, (viewport.X - 16) / 460, (viewport.Y - 16) / 290)
    local uiScale = panel:FindFirstChildOfClass("UIScale")
    if not uiScale then
        uiScale = Instance.new("UIScale")
        uiScale.Parent = panel
    end
    uiScale.Scale = math.clamp(scale, 0.62, 1)
end
fitPanel()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitPanel)
end

script.Destroying:Connect(function()
    pcall(function()
        RunService:UnbindFromRenderStep("ImperioDPIMobileCamera")
    end)
    local cam = workspace.CurrentCamera
    if cam then
        cam.CameraType = Enum.CameraType.Custom
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then cam.CameraSubject = hum end
        end
    end
end)

print("[Império DPI Mobile] Carregado. Use o botão ♛ para abrir o painel.")
