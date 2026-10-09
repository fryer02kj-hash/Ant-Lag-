--[[
	Steal An Egg - Painel Steal Egg
	Detecta a velocidade máxima do jogador e usa ela na ida e na volta

	LocalScript / Executor
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- ============== CONFIG ==============
local SCAN_INTERVAL = 1.5
local SAFE_ZONE_OFFSET = Vector3.new(0, 3, 0)
-- ====================================

local old = player.PlayerGui:FindFirstChild("StealEggPanel")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "StealEggPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player.PlayerGui

local RED = Color3.fromRGB(255, 50, 50)
local DARK = Color3.fromRGB(15, 12, 18)
local CARD = Color3.fromRGB(25, 20, 30)
local WHITE = Color3.fromRGB(240, 240, 245)
local MUTED = Color3.fromRGB(160, 155, 170)

local function corner(o, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = o
end

local function stroke(o, col, th)
	local s = Instance.new("UIStroke")
	s.Color = col or RED
	s.Thickness = th or 1
	s.Parent = o
end

-- ========== PAINEL ==========
local panel = Instance.new("Frame")
panel.Name = "Main"
panel.Size = UDim2.fromOffset(280, 320)
panel.Position = UDim2.new(0, 20, 0.5, -160)
panel.BackgroundColor3 = DARK
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = gui
corner(panel, 12)
stroke(panel, RED, 1.5)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = Color3.fromRGB(30, 10, 15)
header.BorderSizePixel = 0
header.Parent = panel
corner(header, 12)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "🥚 Steal Egg"
title.TextColor3 = RED
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -32, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 15, 20)
closeBtn.Text = "×"
closeBtn.TextColor3 = RED
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = header
corner(closeBtn, 6)
closeBtn.Activated:Connect(function()
	panel.Visible = false
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "List"
scroll.Size = UDim2.new(1, -16, 1, -90)
scroll.Position = UDim2.new(0, 8, 0, 42)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = RED
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = panel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scroll

local listPad = Instance.new("UIPadding")
listPad.PaddingTop = UDim.new(0, 2)
listPad.PaddingBottom = UDim.new(0, 4)
listPad.Parent = scroll

local stealBtn = Instance.new("TextButton")
stealBtn.Name = "StealBtn"
stealBtn.Size = UDim2.new(1, -16, 0, 36)
stealBtn.Position = UDim2.new(0, 8, 1, -44)
stealBtn.BackgroundColor3 = RED
stealBtn.Text = "Steal Egg"
stealBtn.TextColor3 = WHITE
stealBtn.TextSize = 15
stealBtn.Font = Enum.Font.GothamBold
stealBtn.Parent = panel
corner(stealBtn, 8)

-- ========== LÓGICA ==========
local selectedEgg = nil
local eggButtons = {}
local isStealing = false

-- Detecta a velocidade máxima atual do jogador
local function getMaxSpeed()
	character = player.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return 16 end

	local speed = humanoid.WalkSpeed

	-- Tenta achar valores de velocidade do jogo (atributos / values comuns)
	local candidates = {
		character:GetAttribute("Speed"),
		character:GetAttribute("WalkSpeed"),
		character:GetAttribute("MaxSpeed"),
		player:GetAttribute("Speed"),
		player:GetAttribute("WalkSpeed"),
	}

	-- Procura NumberValues comuns
	for _, name in ipairs({"Speed", "WalkSpeed", "MaxSpeed", "PlayerSpeed", "CurrentSpeed"}) do
		local v = character:FindFirstChild(name) or player:FindFirstChild(name)
		if v and v:IsA("NumberValue") then
			table.insert(candidates, v.Value)
		end
	end

	for _, v in ipairs(candidates) do
		if typeof(v) == "number" and v > speed then
			speed = v
		end
	end

	-- Garante um mínimo decente
	if speed < 16 then speed = 16 end
	return speed
end

local function getSafeZone()
	local plots = Workspace:FindFirstChild("Plots")
		or Workspace:FindFirstChild("Bases")
		or Workspace:FindFirstChild("PlayerPlots")
		or Workspace:FindFirstChild("Tycoons")

	if plots then
		for _, p in ipairs(plots:GetChildren()) do
			local owner = p:GetAttribute("Owner") or p:GetAttribute("OwnerId")
			if owner == player.UserId or owner == player.Name or p.Name == player.Name then
				local spawn = p:FindFirstChild("Spawn")
					or p:FindFirstChild("SpawnLocation")
					or p:FindFirstChildWhichIsA("SpawnLocation")
				if spawn then
					return (spawn:IsA("BasePart") and spawn.Position or spawn:GetPivot().Position) + SAFE_ZONE_OFFSET
				end
				return p:GetPivot().Position + Vector3.new(0, 5, 0)
			end
		end
	end

	-- Fallback: posição atual
	if root then return root.Position end
	return Vector3.new(0, 5, 0)
end

local valueMap = {
	["Divine"] = 1000000000,
	["Eternal"] = 500000000,
	["Secret"] = 100000000,
	["Cosmic"] = 10000000,
	["Mythic"] = 500000,
	["Legendary"] = 50000,
	["Epic"] = 5000,
	["Rare"] = 500,
	["Uncommon"] = 50,
	["Common"] = 5,
}

local function estimateValue(egg)
	local name = egg.Name:lower()
	for rarity, val in pairs(valueMap) do
		if name:find(rarity:lower()) then
			return val
		end
	end
	local size = 0
	if egg:IsA("Model") then
		local _, sz = egg:GetBoundingBox()
		size = sz.Magnitude
	elseif egg:IsA("BasePart") then
		size = egg.Size.Magnitude
	end
	return size * 100
end

local function findEggs()
	local eggs = {}
	local function scan(parent, depth)
		if depth > 5 then return end
		for _, obj in ipairs(parent:GetChildren()) do
			local n = obj.Name:lower()
			if (n:find("egg") or n:find("ovo")) and (obj:IsA("Model") or obj:IsA("BasePart")) then
				table.insert(eggs, obj)
			end
			if obj:IsA("Folder") or obj:IsA("Model") then
				scan(obj, depth + 1)
			end
		end
	end
	scan(Workspace, 0)
	return eggs
end

local function clearList()
	for _, b in pairs(eggButtons) do
		if b and b.Parent then b:Destroy() end
	end
	table.clear(eggButtons)
	selectedEgg = nil
end

local function refreshList()
	clearList()
	local eggs = findEggs()
	table.sort(eggs, function(a, b)
		return estimateValue(a) > estimateValue(b)
	end)

	for i, egg in ipairs(eggs) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -4, 0, 32)
		btn.BackgroundColor3 = CARD
		btn.BorderSizePixel = 0
		btn.Text = ""
		btn.LayoutOrder = i
		btn.Parent = scroll
		corner(btn, 6)

		local nameLbl = Instance.new("TextLabel")
		nameLbl.BackgroundTransparency = 1
		nameLbl.Size = UDim2.new(1, -10, 1, 0)
		nameLbl.Position = UDim2.new(0, 8, 0, 0)
		nameLbl.Text = egg.Name
		nameLbl.TextColor3 = WHITE
		nameLbl.TextSize = 12
		nameLbl.Font = Enum.Font.Gotham
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
		nameLbl.Parent = btn

		btn.Activated:Connect(function()
			for _, b in pairs(eggButtons) do
				if b then b.BackgroundColor3 = CARD end
			end
			btn.BackgroundColor3 = Color3.fromRGB(60, 20, 30)
			selectedEgg = egg
		end)

		table.insert(eggButtons, btn)
	end
end

local function setSpeed(spd)
	character = player.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = spd
	end
end

local function moveTo(pos, speed)
	character = player.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not humanoid then return false end

	setSpeed(speed)
	humanoid:MoveTo(pos)

	local start = tick()
	while (root.Position - pos).Magnitude > 8 and tick() - start < 30 do
		if not humanoid or humanoid.Health <= 0 then return false end
		-- Mantém a velocidade máxima o tempo todo
		setSpeed(speed)
		humanoid:MoveTo(pos)
		task.wait(0.1)
	end
	return true
end

local function stealSelected()
	if isStealing then return end
	if not selectedEgg or not selectedEgg.Parent then
		stealBtn.Text = "Selecione um ovo!"
		task.wait(1.2)
		stealBtn.Text = "Steal Egg"
		return
	end

	isStealing = true
	stealBtn.Text = "Roubando..."
	stealBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)

	character = player.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not humanoid then
		isStealing = false
		stealBtn.Text = "Steal Egg"
		stealBtn.BackgroundColor3 = RED
		return
	end

	-- Detecta velocidade máxima atual (funciona com 100B também)
	local maxSpeed = getMaxSpeed()
	print("[Steal Egg] Velocidade máxima detectada:", maxSpeed)

	-- 1. Vai para a Safe Zone / linha de começo
	local safePos = getSafeZone()
	moveTo(safePos, maxSpeed)
	task.wait(0.25)

	-- 2. Corre até o ovo na velocidade máxima
	local eggPos
	if selectedEgg:IsA("Model") then
		eggPos = selectedEgg:GetPivot().Position
	else
		eggPos = selectedEgg.Position
	end
	moveTo(eggPos + Vector3.new(0, 2, 0), maxSpeed)
	task.wait(0.2)

	-- 3. Tenta pegar o ovo
	local prompt = selectedEgg:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prompt then
		pcall(function() fireproximityprompt(prompt) end)
	end
	-- Força proximidade
	if root then
		root.CFrame = CFrame.new(eggPos + Vector3.new(0, 3, 0))
	end
	task.wait(0.35)

	-- 4. Volta na velocidade máxima também
	moveTo(safePos, maxSpeed)
	task.wait(0.2)

	isStealing = false
	stealBtn.Text = "Steal Egg"
	stealBtn.BackgroundColor3 = RED
	refreshList()
end

stealBtn.Activated:Connect(stealSelected)

task.spawn(function()
	while gui.Parent do
		if panel.Visible and not isStealing then
			refreshList()
		end
		task.wait(SCAN_INTERVAL)
	end
end)

-- Arrastar painel
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = panel.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")
end)

refreshList()
print("[Steal Egg Panel] Carregado — detecta velocidade máxima automaticamente")
