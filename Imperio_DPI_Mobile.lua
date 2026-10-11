-- IMPERIO DPI - mobile-only sensitivity control for your own Roblox experience
-- Place as a LocalScript in StarterPlayer > StarterPlayerScripts.
-- IMPORTANT: this is a custom camera controller. It intentionally replaces the
-- default camera behavior while enabled, because Roblox exposes no public
-- property that directly multiplies the default touch-camera sensitivity.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera
local playerModule
local controls

local function getControls()
    local ok, result = pcall(function()
        local ps = player:WaitForChild("PlayerScripts")
        local pm = require(ps:WaitForChild("PlayerModule"))
        return pm:GetControls()
    end)
    if ok then
        controls = result
    end
end
getControls()

local oldGui = playerGui:FindFirstChild("ImperioDPI")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ImperioDPI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local RED = Color3.fromRGB(220, 35, 55)
local BLACK = Color3.fromRGB(14, 14, 17)
local PANEL = Color3.fromRGB(26, 26, 31)
local WHITE = Color3.fromRGB(245, 245, 245)
local GRAY = Color3.fromRGB(180, 180, 188)

local function round(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end

local function outline(obj, thickness)
    local s = Instance.new("UIStroke")
    s.Color = RED
    s.Thickness = thickness or 1.5
    s.Parent = obj
end

local launcher = Instance.new("TextButton")
launcher.Name = "Launcher"
launcher.Size = UDim2.fromOffset(52, 52)
launcher.Position = UDim2.new(0, 16, 0.55, 0)
launcher.BackgroundColor3 = BLACK
launcher.Text = "🥀"
launcher.TextSize = 25
launcher.TextColor3 = WHITE
launcher.Parent = gui
round(launcher, 13)
outline(launcher, 2)

local panel = Instance.new("Frame")
panel.Name = "Main"
panel.Size = UDim2.fromOffset(310, 255)
panel.Position = UDim2.new(0.5, -155, 0.5, -127)
panel.BackgroundColor3 = BLACK
panel.Visible = false
panel.Parent = gui
round(panel, 14)
outline(panel, 1.5)

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -52, 0, 42)
header.Position = UDim2.fromOffset(12, 0)
header.BackgroundTransparency = 1
header.Text = "IMPÉRIO DPI"
header.Font = Enum.Font.GothamBold
header.TextSize = 18
header.TextColor3 = WHITE
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = panel

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 32)
close.Position = UDim2.new(1, -40, 0, 5)
close.BackgroundColor3 = PANEL
close.Text = "×"
close.TextSize = 22
close.TextColor3 = WHITE
close.Parent = panel
round(close, 8)

local line = Instance.new("Frame")
line.Size = UDim2.new(1, -20, 0, 2)
line.Position = UDim2.fromOffset(10, 43)
line.BackgroundColor3 = RED
line.BorderSizePixel = 0
line.Parent = panel

local tab = Instance.new("TextLabel")
tab.Size = UDim2.new(1, -24, 0, 24)
tab.Position = UDim2.fromOffset(12, 54)
tab.BackgroundTransparency = 1
tab.Text = "CÂMERA • CONTROLE POR TOQUE"
tab.Font = Enum.Font.GothamSemibold
tab.TextSize = 12
tab.TextColor3 = RED
tab.TextXAlignment = Enum.TextXAlignment.Left
tab.Parent = panel

local valueText = Instance.new("TextLabel")
valueText.Size = UDim2.new(1, -24, 0, 25)
valueText.Position = UDim2.fromOffset(12, 88)
valueText.BackgroundTransparency = 1
valueText.Text = "Sensibilidade: 1.0x"
valueText.Font = Enum.Font.Gotham
valueText.TextSize = 14
valueText.TextColor3 = WHITE
valueText.TextXAlignment = Enum.TextXAlignment.Left
valueText.Parent = panel

local track = Instance.new("Frame")
track.Size = UDim2.new(1, -36, 0, 8)
track.Position = UDim2.fromOffset(18, 125)
track.BackgroundColor3 = Color3.fromRGB(65, 65, 72)
track.BorderSizePixel = 0
track.Parent = panel
round(track, 6)

local fill = Instance.new("Frame")
fill.Size = UDim2.new(1/7, 0, 1, 0)
fill.BackgroundColor3 = RED
fill.BorderSizePixel = 0
fill.Parent = track
round(fill, 6)

local knob = Instance.new("Frame")
knob.Size = UDim2.fromOffset(20, 20)
knob.Position = UDim2.new(1/7, -10, 0.5, -10)
knob.BackgroundColor3 = WHITE
knob.Parent = track
round(knob, 10)
outline(knob, 2)

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -24, 0, 48)
info.Position = UDim2.fromOffset(12, 150)
info.BackgroundTransparency = 1
info.Text = "Aumente para a câmera girar mais com o mesmo arrasto do dedo. Este script usa uma câmera personalizada."
info.TextWrapped = true
info.Font = Enum.Font.Gotham
info.TextSize = 11
info.TextColor3 = GRAY
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.Parent = panel

local reset = Instance.new("TextButton")
reset.Size = UDim2.new(1, -24, 0, 30)
reset.Position = UDim2.fromOffset(12, 211)
reset.BackgroundColor3 = PANEL
reset.Text = "REDEFINIR • 1.0x"
reset.Font = Enum.Font.GothamBold
reset.TextSize = 12
reset.TextColor3 = WHITE
reset.Parent = panel
round(reset, 8)

local sensitivity = 1.0
local minSensitivity, maxSensitivity = 0.5, 4.0
local sliderDragging = false

local function updateSlider(x)
    local width = track.AbsoluteSize.X
    if width <= 0 then return end
    local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
    sensitivity = math.floor((minSensitivity + alpha * (maxSensitivity - minSensitivity)) * 10 + 0.5) / 10
    fill.Size = UDim2.new(alpha, 0, 1, 0)
    knob.Position = UDim2.new(alpha, -10, 0.5, -10)
    valueText.Text = string.format("Sensibilidade: %.1fx", sensitivity)
end

local function startSlider(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        updateSlider(input.Position.X)
    end
end
track.InputBegan:Connect(startSlider)
knob.InputBegan:Connect(startSlider)
UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and input.UserInputType == Enum.UserInputType.Touch then
        updateSlider(input.Position.X)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)
reset.Activated:Connect(function()
    sensitivity = 1.0
    fill.Size = UDim2.new(1/7, 0, 1, 0)
    knob.Position = UDim2.new(1/7, -10, 0.5, -10)
    valueText.Text = "Sensibilidade: 1.0x"
end)
launcher.Activated:Connect(function() panel.Visible = not panel.Visible end)
close.Activated:Connect(function() panel.Visible = false end)

-- Drag UI with touch
local function draggable(object, handle)
    local activeTouch, startPos, startObjPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            activeTouch = input
            startPos = input.Position
            startObjPos = object.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if activeTouch and input == activeTouch then
            local delta = input.Position - startPos
            object.Position = UDim2.new(startObjPos.X.Scale, startObjPos.X.Offset + delta.X,
                startObjPos.Y.Scale, startObjPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input == activeTouch then activeTouch = nil end
    end)
end
draggable(launcher, launcher)
draggable(panel, header)

-- Custom mobile camera controller:
-- The player drags on the right half of the screen to rotate the view.
-- Left-side touches remain available for Roblox's movement joystick.
-- This replaces the default camera controller while active, so integrate and test
-- carefully in your own experience. Character movement controls remain enabled.
local enabled = true
local activeCameraTouch = nil
local lastTouchPos = nil
local yaw = 0
local pitch = 0
local cameraDistance = 10
local minPitch, maxPitch = math.rad(-70), math.rad(70)

local function getCharacterFocus()
    local character = player.Character
    local head = character and character:FindFirstChild("Head")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if head then return head.Position end
    if root then return root.Position + Vector3.new(0, 2, 0) end
    if humanoid then return humanoid.RootPart.Position + Vector3.new(0, 2, 0) end
    return nil
end

local function syncAnglesFromCamera()
    local look = camera.CFrame.LookVector
    yaw = math.atan2(-look.X, -look.Z)
    pitch = math.asin(math.clamp(look.Y, -1, 1))
end
syncAnglesFromCamera()

UserInputService.TouchStarted:Connect(function(input, processed)
    if processed or panel.Visible then return end
    local pos = Vector2.new(input.Position.X, input.Position.Y)
    if pos.X > camera.ViewportSize.X * 0.42 then
        activeCameraTouch = input
        lastTouchPos = pos
    end
end)

UserInputService.TouchMoved:Connect(function(input, processed)
    if input ~= activeCameraTouch or not lastTouchPos then return end
    local pos = Vector2.new(input.Position.X, input.Position.Y)
    local delta = pos - lastTouchPos
    lastTouchPos = pos
    local viewport = camera.ViewportSize
    local scale = 2 * math.pi / math.max(viewport.X, 1)
    yaw = yaw - delta.X * scale * sensitivity
    pitch = math.clamp(pitch - delta.Y * scale * sensitivity, minPitch, maxPitch)
end)

UserInputService.TouchEnded:Connect(function(input)
    if input == activeCameraTouch then
        activeCameraTouch = nil
        lastTouchPos = nil
    end
end)

local renderName = "ImperioDPIMobileCamera"
RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 1, function()
    if not enabled then return end
    camera = workspace.CurrentCamera
    if not camera then return end
    local focus = getCharacterFocus()
    if not focus then return end
    camera.CameraType = Enum.CameraType.Scriptable
    local horizontal = Vector3.new(math.sin(yaw), 0, math.cos(yaw))
    local offset = Vector3.new(
        math.sin(yaw) * math.cos(pitch),
        math.sin(pitch),
        math.cos(yaw) * math.cos(pitch)
    ) * cameraDistance
    camera.CFrame = CFrame.lookAt(focus + offset, focus)
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    camera = workspace.CurrentCamera
    if camera then syncAnglesFromCamera() end
end)

script.Destroying:Connect(function()
    RunService:UnbindFromRenderStep(renderName)
    if workspace.CurrentCamera then
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end)
