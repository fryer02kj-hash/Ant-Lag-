--[[
    Blue Sensitivy | Enthony Developer
    LocalScript para Roblox (cliente). Painel mobile com Início, Desempenho e Sobre.
    Nota: efeitos só podem ser alterados localmente e alguns jogos podem sobrescrever as mudanças.
]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local BLUE = Color3.fromRGB(20, 137, 255)
local CYAN = Color3.fromRGB(83, 202, 255)
local BG = Color3.fromRGB(5, 12, 25)
local CARD = Color3.fromRGB(10, 27, 49)
local WHITE = Color3.fromRGB(255, 255, 255)
local MUTED = Color3.fromRGB(137, 170, 205)
local old = playerGui:FindFirstChild("BlueForceGui")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "BlueForceGui"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
gui.DisplayOrder = 200; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = playerGui
local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=o end
local function stroke(o,color,thickness) local s=Instance.new("UIStroke"); s.Color=color; s.Thickness=thickness or 1; s.Parent=o; return s end
local function label(parent,text,size,color,pos,dim,font)
 local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=text; t.TextSize=size; t.TextColor3=WHITE; t.Font=font or Enum.Font.Gotham; t.TextXAlignment=Enum.TextXAlignment.Left; t.TextYAlignment=Enum.TextYAlignment.Center; t.Position=pos; t.Size=dim; t.ZIndex=12; t.Parent=parent; return t
end
local function button(parent,text,pos,dim)
 local b=Instance.new("TextButton"); b.Text=text; b.Font=Enum.Font.GothamSemibold; b.TextSize=12; b.TextColor3=WHITE; b.BackgroundColor3=CARD; b.BorderSizePixel=0; b.Position=pos; b.Size=dim; b.AutoButtonColor=false; b.ZIndex=12; b.Parent=parent; corner(b,7); stroke(b,BLUE,1); return b
end

-- Main panel and persistent title
local panel=Instance.new("Frame"); panel.Name="MainPanel"; panel.AnchorPoint=Vector2.new(.5,.5); panel.Position=UDim2.fromScale(.5,.52); panel.Size=UDim2.fromOffset(460,290); panel.BackgroundColor3=BG; panel.BorderSizePixel=0; panel.Visible=false; panel.ClipsDescendants=true; panel.ZIndex=2; panel.Parent=gui; corner(panel,12); stroke(panel,BLUE,1.5)
local header=Instance.new("Frame"); header.BackgroundColor3=Color3.fromRGB(7,23,44); header.Size=UDim2.new(1,0,0,48); header.BorderSizePixel=0; header.ZIndex=4; header.Parent=panel
label(header,"Blue Sensitivy",20,CYAN,UDim2.new(0,14,0,2),UDim2.new(1,-52,0,25),Enum.Font.GothamBold)
label(header,"Versão 2.0  •  Enthony",10,MUTED,UDim2.new(0,15,0,27),UDim2.new(1,-50,0,16))
local close=button(header,"×",UDim2.new(1,-38,0,8),UDim2.fromOffset(28,28)); close.TextSize=20
local nav=Instance.new("Frame"); nav.BackgroundColor3=Color3.fromRGB(6,18,35); nav.Position=UDim2.new(0,7,0,52); nav.Size=UDim2.new(0,96,1,-59); nav.BorderSizePixel=0; nav.ZIndex=5; nav.Parent=panel; corner(nav,16)
local body=Instance.new("Frame"); body.BackgroundTransparency=1; body.Position=UDim2.new(0,110,0,52); body.Size=UDim2.new(1,-117,1,-59); body.ZIndex=5; body.Parent=panel
local homePage=Instance.new("ScrollingFrame"); homePage.Name="InicioPage"; homePage.BackgroundTransparency=1; homePage.BorderSizePixel=0; homePage.Size=UDim2.fromScale(1,1); homePage.AutomaticCanvasSize=Enum.AutomaticSize.Y; homePage.CanvasSize=UDim2.new(); homePage.ScrollBarThickness=3; homePage.ScrollBarImageColor3=BLUE; homePage.ZIndex=6; homePage.Parent=body
local perfPage=homePage:Clone(); perfPage.Name="DesempenhoPage"; perfPage.Visible=false; perfPage.Parent=body
local aboutPage=homePage:Clone(); aboutPage.Name="SobrePage"; aboutPage.Visible=false; aboutPage.Parent=body
local function setupLayout(page) local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,8); l.SortOrder=Enum.SortOrder.LayoutOrder; l.Parent=page; page:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() end) end
-- Clones may carry only properties, not children, so give each page its own layout.
setupLayout(homePage); setupLayout(perfPage); setupLayout(aboutPage)
local function navItem(text,y,selected)
 local b=button(nav,text,UDim2.new(0,3,0,y),UDim2.new(1,-6,0,30)); b.TextXAlignment=Enum.TextXAlignment.Left; b.TextSize=11; b.Text="  "..text
 if selected then b.BackgroundColor3=Color3.fromRGB(13,69,125) end
 return b
end
local nHome=navItem("Início",5,true); local nPerf=navItem("Desempenho",40,false)
local sep=Instance.new("Frame"); sep.Position=UDim2.new(0,9,0,77); sep.Size=UDim2.new(1,-18,0,1); sep.BackgroundColor3=BLUE; sep.BorderSizePixel=0; sep.ZIndex=8; sep.Parent=nav
local nAbout=navItem("Sobre",85,false)
local pages={homePage,perfPage,aboutPage}; local navs={nHome,nPerf,nAbout}
local function showPage(i)
 for k,p in ipairs(pages) do p.Visible=(k==i) end
 for k,b in ipairs(navs) do b.BackgroundColor3=(k==i) and Color3.fromRGB(13,69,125) or CARD end
end
nHome.Activated:Connect(function() showPage(1) end); nPerf.Activated:Connect(function() showPage(2) end); nAbout.Activated:Connect(function() showPage(3) end); close.Activated:Connect(function() panel.Visible=false end)

local function card(parent,title,order,height)
 local f=Instance.new("Frame"); f.LayoutOrder=order or 1; f.Size=UDim2.new(1,-5,0,height or 66); f.BackgroundColor3=CARD; f.BorderSizePixel=0; f.ZIndex=7; f.Parent=parent; corner(f,9); stroke(f,Color3.fromRGB(22,91,155),1)
 if title and title~="" then label(f,title,12,WHITE,UDim2.new(0,11,0,4),UDim2.new(1,-22,0,22),Enum.Font.GothamSemibold) end
 return f
end
local function makeSwitch(parent,title,order,initial,callback)
 local f=card(parent,title,order,46)
 local track=Instance.new("TextButton"); track.Name="Toggle"; track.Text=""; track.AutoButtonColor=false; track.Position=UDim2.new(1,-49,0,10); track.Size=UDim2.fromOffset(38,20); track.BackgroundColor3=initial and BLUE or Color3.fromRGB(37,54,74); track.BorderSizePixel=0; track.ZIndex=10; track.Parent=f; corner(track,12)
 local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(16,16); knob.Position=initial and UDim2.new(1,-19,0,2) or UDim2.new(0,3,0,2); knob.BackgroundColor3=WHITE; knob.BorderSizePixel=0; knob.ZIndex=11; knob.Parent=track; corner(knob,9)
 local on=initial
 local function render() track.BackgroundColor3=on and BLUE or Color3.fromRGB(37,54,74); knob.Position=on and UDim2.new(1,-19,0,2) or UDim2.new(0,3,0,2) end
 track.Activated:Connect(function() on=not on; render(); callback(on) end)
 return function(value) on=value; render(); callback(on) end
end

-- Home: camera sensitivity slider and on/off toggle.
local cameraEnabled=false
local sensitivity=10.00
local sensCard=card(homePage,"Sensibilidade da câmera",1,91)
local val=label(sensCard,"10.00",13,CYAN,UDim2.new(1,-65,0,5),UDim2.new(0,54,0,22),Enum.Font.GothamBold); val.TextXAlignment=Enum.TextXAlignment.Right
local track=Instance.new("TextButton"); track.Name="SensitivitySlider"; track.Text=""; track.AutoButtonColor=false; track.Position=UDim2.new(0,12,0,48); track.Size=UDim2.new(1,-24,0,9); track.BackgroundColor3=Color3.fromRGB(36,60,84); track.BorderSizePixel=0; track.ZIndex=10; track.Parent=sensCard; corner(track,5)
local fill=Instance.new("Frame"); fill.BackgroundColor3=BLUE; fill.BorderSizePixel=0; fill.Size=UDim2.new((sensitivity-1)/119,0,1,0); fill.ZIndex=11; fill.Parent=track; corner(fill,5)
local knob=Instance.new("Frame"); knob.AnchorPoint=Vector2.new(.5,.5); knob.Position=UDim2.new((sensitivity-1)/119,0,.5,0); knob.Size=UDim2.fromOffset(16,16); knob.BackgroundColor3=WHITE; knob.BorderSizePixel=0; knob.ZIndex=12; knob.Parent=track; corner(knob,9); stroke(knob,BLUE,2)
label(sensCard,"1.00",9,MUTED,UDim2.new(0,12,0,62),UDim2.new(0,45,0,17)); local maxLabel=label(sensCard,"120.00",9,MUTED,UDim2.new(1,-58,0,62),UDim2.new(0,47,0,17)); maxLabel.TextXAlignment=Enum.TextXAlignment.Right
local function setSensitivity(x)
 local a=math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1); sensitivity=math.floor((1+a*119)*100+.5)/100; val.Text=string.format("%.2f",sensitivity); fill.Size=UDim2.new(a,0,1,0); knob.Position=UDim2.new(a,0,.5,0)
end
track.Activated:Connect(function() setSensitivity(UserInputService:GetMouseLocation().X) end)
local sliderTouch,sliderMouse
track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then sliderTouch=i; setSensitivity(i.Position.X) elseif i.UserInputType==Enum.UserInputType.MouseButton1 then sliderMouse=true; setSensitivity(i.Position.X) end end)
UserInputService.InputChanged:Connect(function(i) if sliderTouch and i==sliderTouch then setSensitivity(i.Position.X) elseif sliderMouse and i.UserInputType==Enum.UserInputType.MouseMovement then setSensitivity(i.Position.X) end end)
UserInputService.InputEnded:Connect(function(i) if i==sliderTouch then sliderTouch=nil end; if i.UserInputType==Enum.UserInputType.MouseButton1 then sliderMouse=false end end)

-- Custom camera: rotate with one-finger touch or mouse drag; keep zoom distance fixed.
-- Uses InputBegan/InputChanged/InputEnded so mobile touch updates are tracked consistently.
local camConnection, savedType, savedSubject, focusOffset, yaw, pitch, camDistance
local activeTouch, lastTouch
local mouseDragging, lastMouse
local cameraEnabled=false
local function pointOverGui(pos)
 local ok,objects=pcall(function() return playerGui:GetGuiObjectsAtPosition(pos.X,pos.Y) end)
 if not ok then return false end
 for _,obj in ipairs(objects) do
  if obj:IsDescendantOf(panel) or obj==open or obj:IsDescendantOf(open) then return true end
 end
 return false
end
local function stopCamera()
 cameraEnabled=false
 if camConnection then camConnection:Disconnect(); camConnection=nil end
 local cam=Workspace.CurrentCamera
 if cam then
  cam.CameraType=savedType or Enum.CameraType.Custom
  local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
  cam.CameraSubject=(savedSubject and savedSubject.Parent) and savedSubject or hum
 end
 activeTouch=nil; lastTouch=nil; mouseDragging=false; lastMouse=nil
end
local function startCamera()
 local cam=Workspace.CurrentCamera
 local ch=player.Character
 local root=ch and ch:FindFirstChild("HumanoidRootPart")
 if not cam or not root then return false end
 savedType,savedSubject=cam.CameraType,cam.CameraSubject
 local focus=cam.Focus.Position
 if (focus-root.Position).Magnitude>20 then focus=root.Position+Vector3.new(0,2.5,0) end
 focusOffset=focus-root.Position
 local delta=cam.CFrame.Position-focus
 camDistance=math.max(delta.Magnitude,0.1)
 local d=delta.Magnitude>.1 and delta.Unit or -cam.CFrame.LookVector
 yaw=math.atan2(d.X,d.Z)
 pitch=math.asin(math.clamp(-d.Y,-.98,.98))
 cameraEnabled=true
 cam.CameraType=Enum.CameraType.Scriptable
 camConnection=RunService.RenderStepped:Connect(function()
  local current=Workspace.CurrentCamera
  local character=player.Character
  local r=character and character:FindFirstChild("HumanoidRootPart")
  if not cameraEnabled or not current or not r then return end
  local f=r.Position+focusOffset
  local rotation=CFrame.fromOrientation(pitch,yaw,0)
  current.CFrame=CFrame.lookAt(f+rotation:VectorToWorldSpace(Vector3.new(0,0,camDistance)),f)
  current.Focus=CFrame.new(f)
 end)
 return true
end
makeSwitch(homePage,"Sensibilidade da câmera",2,false,function(on)
 if on then
  if not startCamera() then cameraEnabled=false end
 else
  stopCamera()
 end
end)
local function beginTouch(input)
 if not cameraEnabled or input.UserInputType~=Enum.UserInputType.Touch then return end
 local cam=Workspace.CurrentCamera; local vp=cam and cam.ViewportSize
 if not vp or input.Position.X<vp.X*.52 then return end -- keep the left joystick usable
 if pointOverGui(input.Position) then return end
 -- A second touch is treated as a pinch gesture and won't rotate the view.
 if activeTouch then activeTouch=nil; lastTouch=nil; return end
 activeTouch=input; lastTouch=input.Position
end
UserInputService.InputBegan:Connect(function(input,processed)
 if input.UserInputType==Enum.UserInputType.Touch then
  beginTouch(input)
 elseif input.UserInputType==Enum.UserInputType.MouseButton1 and cameraEnabled and not processed then
  local pos=UserInputService:GetMouseLocation()
  if not pointOverGui(pos) then mouseDragging=true; lastMouse=pos end
 end
end)
UserInputService.InputChanged:Connect(function(input)
 if not cameraEnabled then return end
 if input.UserInputType==Enum.UserInputType.Touch and activeTouch==input and lastTouch then
  local pos=input.Position
  local delta=pos-lastTouch; lastTouch=pos
  local power=.002*(sensitivity/10)
  yaw=yaw-delta.X*power
  pitch=math.clamp(pitch-delta.Y*power,math.rad(-75),math.rad(75))
 elseif input.UserInputType==Enum.UserInputType.MouseMovement and mouseDragging and lastMouse then
  local pos=UserInputService:GetMouseLocation()
  local delta=pos-lastMouse; lastMouse=pos
  local power=.002*(sensitivity/10)
  yaw=yaw-delta.X*power
  pitch=math.clamp(pitch-delta.Y*power,math.rad(-75),math.rad(75))
 end
end)
UserInputService.InputEnded:Connect(function(input)
 if input==activeTouch then activeTouch=nil; lastTouch=nil end
 if input.UserInputType==Enum.UserInputType.MouseButton1 then mouseDragging=false; lastMouse=nil end
end)
player.CharacterAdded:Connect(function()
 if cameraEnabled then task.wait(.5); stopCamera() end
end)

-- Performance overlay and reversible local visual settings.
local fps=0; local frameCount=0; local elapsed=0
local overlay=Instance.new("TextLabel"); overlay.Name="BlueForceFPSOverlay"; overlay.AnchorPoint=Vector2.new(0.5,0.5); overlay.Position=UDim2.new(0.88,0,0.07,0); overlay.Size=UDim2.fromOffset(170,32); overlay.BackgroundColor3=BG; overlay.BackgroundTransparency=.08; overlay.Text="FPS: -- | Ping: -- ms"; overlay.TextColor3=WHITE; overlay.TextSize=11; overlay.Font=Enum.Font.GothamBold; overlay.Visible=false; overlay.Active=true; overlay.ZIndex=50; overlay.Parent=gui; corner(overlay,10); stroke(overlay,BLUE,1.5)
-- Two compact monitoring cards side by side.
local statsRow=Instance.new("Frame"); statsRow.Name="MonitoringCards"; statsRow.LayoutOrder=1; statsRow.Size=UDim2.new(1,-5,0,65); statsRow.BackgroundTransparency=1; statsRow.ZIndex=7; statsRow.Parent=perfPage
local fpsCard=Instance.new("Frame"); fpsCard.Name="FPSCard"; fpsCard.Position=UDim2.new(0,0,0,0); fpsCard.Size=UDim2.new(.49,0,1,0); fpsCard.BackgroundColor3=CARD; fpsCard.BorderSizePixel=0; fpsCard.ZIndex=8; fpsCard.Parent=statsRow; corner(fpsCard,16); stroke(fpsCard,Color3.fromRGB(22,91,155),1.5)
label(fpsCard,"FPS",11,MUTED,UDim2.new(0,10,0,5),UDim2.new(1,-20,0,18),Enum.Font.GothamSemibold)
local fpsLabel=label(fpsCard,"Calculando...",17,WHITE,UDim2.new(0,10,0,25),UDim2.new(1,-20,0,27),Enum.Font.GothamBold)
local pingCard=Instance.new("Frame"); pingCard.Name="PingCard"; pingCard.Position=UDim2.new(.51,0,0,0); pingCard.Size=UDim2.new(.49,0,1,0); pingCard.BackgroundColor3=CARD; pingCard.BorderSizePixel=0; pingCard.ZIndex=8; pingCard.Parent=statsRow; corner(pingCard,16); stroke(pingCard,Color3.fromRGB(22,91,155),1.5)
label(pingCard,"MS / Ping",11,MUTED,UDim2.new(0,10,0,5),UDim2.new(1,-20,0,18),Enum.Font.GothamSemibold)
local pingLabel=label(pingCard,"Calculando...",17,WHITE,UDim2.new(0,10,0,25),UDim2.new(1,-20,0,27),Enum.Font.GothamBold)
makeSwitch(perfPage,"Enable Fps",2,false,function(on) overlay.Visible=on end)
local heading=card(perfPage,"Reduzir movimentos",3,35)
local originals={}; local grayOn=false; local shadowsOn=false; local particlesOn=false; local effectsOn=false; local texturesOn=false
local savedLighting
local function setGray(on)
 if on and not savedLighting then savedLighting={Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient,ColorShift_Top=Lighting.ColorShift_Top,ColorShift_Bottom=Lighting.ColorShift_Bottom} end
 grayOn=on
 if on then Lighting.Ambient=Color3.fromRGB(105,105,105); Lighting.OutdoorAmbient=Color3.fromRGB(90,90,90); Lighting.ColorShift_Top=Color3.fromRGB(90,90,90); Lighting.ColorShift_Bottom=Color3.fromRGB(70,70,70)
 elseif savedLighting then for k,v in pairs(savedLighting) do Lighting[k]=v end; savedLighting=nil end
end
makeSwitch(perfPage,"Céu cinza",4,false,setGray)
local savedGlobalShadows=Lighting.GlobalShadows
makeSwitch(perfPage,"Sombras",5,false,function(on) shadowsOn=on; if on then savedGlobalShadows=Lighting.GlobalShadows; Lighting.GlobalShadows=false else Lighting.GlobalShadows=savedGlobalShadows end end)
local function toggleDescendants(classNames,on,key)
 for _,obj in ipairs(Workspace:GetDescendants()) do
  for _,class in ipairs(classNames) do if obj:IsA(class) then
   if originals[obj]==nil then originals[obj]={}; originals[obj][key]=obj.Enabled end
   pcall(function() obj.Enabled=not on and originals[obj][key] or false end)
  end end
 end
end
makeSwitch(perfPage,"Partículas",6,false,function(on) particlesOn=on; toggleDescendants({"ParticleEmitter","Trail","Beam","Smoke","Fire","Sparkles"},on,"Enabled") end)
makeSwitch(perfPage,"Efeitos visuais",7,false,function(on) effectsOn=on; toggleDescendants({"BloomEffect","BlurEffect","ColorCorrectionEffect","DepthOfFieldEffect","SunRaysEffect"},on,"Enabled") end)
local textureOriginals={}
-- Keep the ground and every player's character/skin untouched.
local function isPlayerSkinOrCharacter(obj)
 for _,otherPlayer in ipairs(Players:GetPlayers()) do
  local character=otherPlayer.Character
  if character and (obj==character or obj:IsDescendantOf(character)) then return true end
 end
 return false
end
local function isGroundPart(part)
 if not part:IsA("BasePart") then return false end
 local n=string.lower(part.Name)
 -- Common names used for floors/ground/baseplates; terrain itself is not a BasePart.
 if n:find("ground",1,true) or n:find("floor",1,true) or n:find("terrain",1,true) or n:find("baseplate",1,true) or n=="chão" or n=="chao" or n=="piso" then return true end
 -- Preserve large, mostly horizontal parts that commonly act as the ground.
 local size=part.Size
 if size.X>=35 and size.Z>=35 and size.Y<=12 then
  local up=part.CFrame.UpVector
  if up.Y>=0.85 then return true end
 end
 return false
end
local function isGroundOrSkin(obj)
 if isPlayerSkinOrCharacter(obj) then return true end
 local current=obj
 while current and current~=Workspace do
  if current:IsA("BasePart") and isGroundPart(current) then return true end
  current=current.Parent
 end
 return false
end
local function applyTextureReduction(obj)
 if not texturesOn or isGroundOrSkin(obj) then return end
 if obj:IsA("BasePart") then
  if textureOriginals[obj]==nil then textureOriginals[obj]={Material=obj.Material,Reflectance=obj.Reflectance} end
  obj.Material=Enum.Material.SmoothPlastic
  obj.Reflectance=0
 elseif obj:IsA("Decal") or obj:IsA("Texture") then
  if textureOriginals[obj]==nil then textureOriginals[obj]={Transparency=obj.Transparency} end
  obj.Transparency=1
 end
end
local function restoreTexture(obj)
 local oldv=textureOriginals[obj]
 if not oldv then return end
 if obj:IsA("BasePart") then
  pcall(function() obj.Material=oldv.Material; obj.Reflectance=oldv.Reflectance end)
 elseif obj:IsA("Decal") or obj:IsA("Texture") then
  pcall(function() obj.Transparency=oldv.Transparency end)
 end
 textureOriginals[obj]=nil
end
local textureDescendantConnection
makeSwitch(perfPage,"Diminuir Texturas",8,false,function(on)
 texturesOn=on
 if textureDescendantConnection then textureDescendantConnection:Disconnect(); textureDescendantConnection=nil end
 if on then
  for _,obj in ipairs(Workspace:GetDescendants()) do applyTextureReduction(obj) end
  -- Also handle map objects that load in after the option is enabled.
  textureDescendantConnection=Workspace.DescendantAdded:Connect(function(obj)
   task.defer(function() if texturesOn and obj.Parent then applyTextureReduction(obj) end end)
  end)
 else
  for obj in pairs(textureOriginals) do restoreTexture(obj) end
 end
end)

-- About page
local aboutCard=card(aboutPage,"Blue Force",1,245)
label(aboutCard,"Painel de personalização",11,MUTED,UDim2.new(0,12,0,32),UDim2.new(1,-24,0,22))
local function infoRow(y,title,value)
 label(aboutCard,title,10,MUTED,UDim2.new(0,12,0,y),UDim2.new(.42,-10,0,22))
 local v=label(aboutCard,value,11,WHITE,UDim2.new(.42,0,0,y),UDim2.new(.55,-10,0,22),Enum.Font.GothamSemibold); v.TextXAlignment=Enum.TextXAlignment.Right
end
infoRow(66,"Versão","2.0"); infoRow(98,"Criador","Enthony"); infoRow(130,"Função","Personalização"); infoRow(162,"Ferramentas","Desempenho e monitoramento"); infoRow(194,"Estado","Versão 2.0")

-- Floating opener: black background with cap emoji.
local open=Instance.new("TextButton"); open.Name="BlueForceFloatingButton"; open.Size=UDim2.fromOffset(40,40); open.Position=UDim2.new(0,12,.5,-20); open.BackgroundColor3=Color3.fromRGB(0,0,0); open.BorderSizePixel=0; open.Text="🧢"; open.TextSize=20; open.Font=Enum.Font.GothamBold; open.AutoButtonColor=false; open.ZIndex=60; open.Parent=gui; corner(open,10); stroke(open,BLUE,1.5)
open.Activated:Connect(function() panel.Visible=not panel.Visible end)
-- Drag panel by header and opener on touch/mobile.
local function makeDraggable(handle,target)
 local dragging=false; local startPos; local origin
 handle.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; startPos=i.Position; origin=target.Position end end)
 UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) and startPos and origin then local d=i.Position-startPos; target.Position=UDim2.new(origin.X.Scale,origin.X.Offset+d.X,origin.Y.Scale,origin.Y.Offset+d.Y) end end)
 UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false; startPos=nil; origin=nil end end)
end
makeDraggable(header,panel); makeDraggable(open,open); makeDraggable(overlay,overlay)
RunService.RenderStepped:Connect(function(dt)
 frameCount+=1; elapsed+=dt
 if elapsed>=.5 then fps=math.floor(frameCount/elapsed+.5); frameCount=0; elapsed=0; local ping=0; pcall(function() ping=math.floor(player:GetNetworkPing()*1000+.5) end); fpsLabel.Text=tostring(fps); pingLabel.Text=tostring(ping); overlay.Text=string.format("FPS: %d | Ping: %d ms",fps,ping) end
end)
-- Restore changes when the GUI is removed.
gui.Destroying:Connect(function() if cameraEnabled then stopCamera() end; if savedLighting then for k,v in pairs(savedLighting) do Lighting[k]=v end end; Lighting.GlobalShadows=savedGlobalShadows end)
print("[Blue Sensitivy 2.0] Carregado • Enthony Developer")
