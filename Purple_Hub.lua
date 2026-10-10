-- Purple Hub | Delta Executor
-- Interface local para Roblox. Salve como Purple_Hub.lua e execute no Delta.
-- Nota: recursos locais dependem do jogo; ações controladas pelo servidor não podem ser garantidas.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
if not player then return end

local PURPLE = Color3.fromRGB(145, 70, 255)
local DARK = Color3.fromRGB(20, 17, 29)
local PANEL = Color3.fromRGB(31, 26, 43)
local TEXT = Color3.fromRGB(245, 240, 255)
local MUTED = Color3.fromRGB(180, 166, 201)

local gui = Instance.new("ScreenGui")
gui.Name = "PurpleHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(500, 330)
frame.Position = UDim2.new(0.5, -250, 0.5, -165)
frame.BackgroundColor3 = DARK
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = PURPLE
stroke.Thickness = 1.5

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 43)
top.BackgroundColor3 = Color3.fromRGB(43, 30, 61)
top.BorderSizePixel = 0
top.Parent = frame
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)
local cover = Instance.new("Frame")
cover.Size = UDim2.new(1, 0, 0, 12)
cover.Position = UDim2.new(0, 0, 1, -12)
cover.BackgroundColor3 = top.BackgroundColor3
cover.BorderSizePixel = 0
cover.Parent = top

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(14, 0)
title.Size = UDim2.new(1, -100, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "PURPLE HUB  •  STEAL A EGG"
title.TextColor3 = TEXT
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 28)
close.Position = UDim2.new(1, -38, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(88, 44, 116)
close.Text = "×"
close.TextColor3 = TEXT
close.TextSize = 22
close.Font = Enum.Font.GothamBold
close.BorderSizePixel = 0
close.Parent = top
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Arrastar janela (mouse e touch)
do
    local dragging, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local sidebar = Instance.new("Frame")
sidebar.Position = UDim2.fromOffset(10, 53)
sidebar.Size = UDim2.fromOffset(130, 265)
sidebar.BackgroundColor3 = PANEL
sidebar.BorderSizePixel = 0
sidebar.Parent = frame
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 9)

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(150, 53)
content.Size = UDim2.new(1, -160, 1, -63)
content.BackgroundColor3 = PANEL
content.BorderSizePixel = 0
content.Parent = frame
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 9)

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.new(0, 12, 1, -25)
status.Size = UDim2.new(1, -24, 0, 17)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextColor3 = MUTED
status.TextXAlignment = Enum.TextXAlignment.Left
status.Text = "Pronto • interface local"
status.Parent = content

local pages, tabButtons = {}, {}
local activePage
local function makePage(name)
    local page = Instance.new("Frame")
    page.Name = name
    page.BackgroundTransparency = 1
    page.Position = UDim2.fromOffset(10, 10)
    page.Size = UDim2.new(1, -20, 1, -43)
    page.Visible = false
    page.Parent = content
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    pages[name] = page
    return page
end

local function setStatus(s)
    if status and status.Parent then status.Text = s end
end

local function showPage(name)
    for n, p in pairs(pages) do p.Visible = n == name end
    for n, b in pairs(tabButtons) do b.BackgroundColor3 = n == name and PURPLE or Color3.fromRGB(51, 40, 67) end
    activePage = name
end

local function addTab(name, label, order)
    local b = Instance.new("TextButton")
    b.LayoutOrder = order
    b.Position = UDim2.fromOffset(7, 7)
    b.Size = UDim2.new(1, -14, 0, 38)
    b.BackgroundColor3 = Color3.fromRGB(51, 40, 67)
    b.BorderSizePixel = 0
    b.Text = label
    b.TextColor3 = TEXT
    b.TextSize = 13
    b.Font = Enum.Font.GothamSemibold
    b.Parent = sidebar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    tabButtons[name] = b
    b.MouseButton1Click:Connect(function() showPage(name) end)
end
local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 7)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.VerticalAlignment = Enum.VerticalAlignment.Top
local sidePadding = Instance.new("UIPadding", sidebar)
sidePadding.PaddingTop = UDim.new(0, 8)

local function addButton(page, label, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(62, 46, 83)
    b.BorderSizePixel = 0
    b.Text = label
    b.TextColor3 = TEXT
    b.TextSize = 12
    b.Font = Enum.Font.GothamSemibold
    b.Parent = page
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    b.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then setStatus("Erro: " .. tostring(err):sub(1, 60)) end
    end)
    return b
end

local function addLabel(page, label)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 30)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = MUTED
    l.TextSize = 12
    l.Font = Enum.Font.Gotham
    l.TextWrapped = true
    l.Parent = page
    return l
end

local home = makePage("Início")
local movement = makePage("Movimento")
local visuals = makePage("Visuais")
local misc = makePage("Extras")
addTab("Início", "⌂   Início", 1)
addTab("Movimento", "➤   Movimento", 2)
addTab("Visuais", "◎   Visuais", 3)
addTab("Extras", "⚙   Extras", 4)

addLabel(home, "Purple Hub carregado.")
addLabel(home, "Ferramentas locais: velocidade, pulo, localizar ovos visíveis e limpar marcadores.")
addButton(home, "Verificar personagem", function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then setStatus("Personagem OK • vida " .. math.floor(hum.Health))
    else setStatus("Personagem ainda não carregou") end
end)
addButton(home, "Recentrar janela", function()
    frame.Position = UDim2.new(0.5, -250, 0.5, -165)
    setStatus("Janela centralizada")
end)

local speedOn = false
local jumpOn = false
local savedWalk, savedJump
local speedBtn = addButton(movement, "Velocidade: OFF", function() end)
local jumpBtn = addButton(movement, "Pulo aumentado: OFF", function() end)
addLabel(movement, "Aplica valores no personagem local; o jogo pode restaurá-los.")
speedBtn.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if speedOn then
            savedWalk = hum.WalkSpeed
            hum.WalkSpeed = 28
            speedBtn.Text = "Velocidade: ON (28)"
            setStatus("Velocidade local ativada")
        else
            hum.WalkSpeed = savedWalk or 16
            speedBtn.Text = "Velocidade: OFF"
            setStatus("Velocidade restaurada")
        end
    else
        speedOn = false
        setStatus("Personagem não encontrado")
    end
end)
jumpBtn.MouseButton1Click:Connect(function()
    jumpOn = not jumpOn
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if jumpOn then
            savedJump = hum.UseJumpPower and hum.JumpPower or hum.JumpHeight
            if hum.UseJumpPower then hum.JumpPower = 75 else hum.JumpHeight = 14 end
            jumpBtn.Text = "Pulo aumentado: ON"
            setStatus("Pulo local ativado")
        else
            if hum.UseJumpPower then hum.JumpPower = savedJump or 50 else hum.JumpHeight = savedJump or 7.2 end
            jumpBtn.Text = "Pulo aumentado: OFF"
            setStatus("Pulo restaurado")
        end
    else
        jumpOn = false
        setStatus("Personagem não encontrado")
    end
end)

local highlights = {}
local function clearHighlights()
    for obj, h in pairs(highlights) do
        if h and h.Parent then h:Destroy() end
        highlights[obj] = nil
    end
end
local function looksLikeEgg(obj)
    local n = string.lower(obj.Name)
    return string.find(n, "egg", 1, true) or string.find(n, "ovo", 1, true)
end
addLabel(visuals, "Destaca objetos visíveis cujo nome contenha 'egg' ou 'ovo'.")
addButton(visuals, "Destacar ovos encontrados", function()
    clearHighlights()
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if count >= 150 then break end
        if looksLikeEgg(obj) and (obj:IsA("Model") or obj:IsA("BasePart")) then
            local h = Instance.new("Highlight")
            h.Name = "PurpleHubEggHighlight"
            h.FillColor = PURPLE
            h.OutlineColor = Color3.fromRGB(230, 200, 255)
            h.FillTransparency = 0.55
            h.DepthMode = Enum.HighlightDepthMode.Occluded
            h.Adornee = obj
            h.Parent = gui
            highlights[obj] = h
            count += 1
        end
    end
    setStatus(count > 0 and ("Marcadores criados: " .. count) or "Nenhum objeto com nome egg/ovo encontrado")
end)
addButton(visuals, "Limpar marcadores", function()
    clearHighlights()
    setStatus("Marcadores removidos")
end)

addLabel(misc, "Utilidades de interface, sem ações automáticas no servidor.")
addButton(misc, "Mostrar / ocultar painel", function()
    frame.Visible = not frame.Visible
end)
addButton(misc, "Remover Purple Hub", function()
    clearHighlights()
    gui:Destroy()
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    if speedOn then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 28 end
    end
    if jumpOn then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.UseJumpPower then hum.JumpPower = 75 else hum.JumpHeight = 14 end
        end
    end
end)

showPage("Início")
setStatus("Purple Hub pronto • Delta")
