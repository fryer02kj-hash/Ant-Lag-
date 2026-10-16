--[[
Império Sensitivy 2.6 • Mobile Edition
Desenvolvido por Enthony Developer
LocalScript: StarterPlayer > StarterPlayerScripts
Nota: alguns efeitos/qualidade dependem da experiência; um LocalScript comum
não pode alterar universalmente a sensibilidade nativa da câmera.
]]
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local Stats=game:GetService("Stats")
local Workspace=game:GetService("Workspace")
local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local BLUE=Color3.fromRGB(24,72,150)
local DARKBLUE=Color3.fromRGB(10,28,65)
local BG=Color3.fromRGB(8,9,13)
local CARD=Color3.fromRGB(23,24,31)
local WHITE=Color3.fromRGB(245,245,248)
local MUTED=WHITE
local GRAY=Color3.fromRGB(49,50,61)
local INVITE="https://discord.gg/MaCKa3NCUT"
local DEFAULT_SENSITIVITY=1
local sensitivity=DEFAULT_SENSITIVITY
local sensitivityEnabled=false
local old=playerGui:FindFirstChild("ImperioAntiLagGui")
if old then old:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="ImperioAntiLagGui"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true
gui.DisplayOrder=200; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=playerGui

local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=o end
local function stroke(o,col,th) local s=Instance.new("UIStroke"); s.Color=col; s.Thickness=th or 1; s.Parent=o; return s end
local function text(parent,str,size,col,pos,dim,font,align)
 local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=str; t.TextSize=size
 t.TextColor3=Color3.fromRGB(255,255,255); t.TextStrokeTransparency=1; t.TextStrokeColor3=Color3.fromRGB(255,255,255); t.Font=font or Enum.Font.Gotham; t.TextXAlignment=align or Enum.TextXAlignment.Left
 t.TextYAlignment=Enum.TextYAlignment.Center; t.Position=pos; t.Size=dim; t.ZIndex=10; t.Parent=parent; return t
end
local function btn(parent,str,pos,dim,col)
 local b=Instance.new("TextButton"); b.Text=str; b.TextSize=12; b.TextColor3=Color3.fromRGB(255,255,255); b.TextStrokeTransparency=1; b.TextStrokeColor3=Color3.fromRGB(255,255,255)
 b.Font=Enum.Font.GothamSemibold; b.BackgroundColor3=col or CARD; b.BorderSizePixel=0
 b.Position=pos; b.Size=dim; b.AutoButtonColor=true; b.ZIndex=12; b.Parent=parent
 corner(b,7); stroke(b,DARKBLUE,1); return b
end

local panel=Instance.new("Frame"); panel.Name="MainPanel"; panel.AnchorPoint=Vector2.new(.5,.5)
panel.Position=UDim2.fromScale(.5,.52); panel.Size=UDim2.fromOffset(460,315); panel.BackgroundColor3=BG
panel.BorderSizePixel=0; panel.ClipsDescendants=true; panel.Visible=false; panel.ZIndex=1; panel.Parent=gui
corner(panel,13); stroke(panel,BLUE,1.5)
local header=Instance.new("Frame"); header.Size=UDim2.new(1,0,0,50); header.BackgroundColor3=Color3.fromRGB(5,5,8)
header.BorderSizePixel=0; header.ZIndex=4; header.Active=true; header.Parent=panel
text(header,"🧢",22,WHITE,UDim2.new(0,10,0,4),UDim2.fromOffset(32,32),Enum.Font.Gotham,Enum.TextXAlignment.Center)
text(header,"IMPÉRIO SENSITIVY",16,WHITE,UDim2.new(0,45,0,3),UDim2.fromOffset(250,24),Enum.Font.GothamBlack)
text(header,"Enthony Developer",9,WHITE,UDim2.new(0,46,0,27),UDim2.fromOffset(190,15))
text(header,"MOBILE EDITION",10,WHITE,UDim2.new(1,-52,0,12),UDim2.fromOffset(40,22),Enum.Font.GothamBold,Enum.TextXAlignment.Center)
local body=Instance.new("Frame"); body.BackgroundTransparency=1; body.Position=UDim2.new(0,8,0,57)
body.Size=UDim2.new(1,-16,1,-65); body.ZIndex=5; body.Parent=panel
local sidebar=Instance.new("Frame"); sidebar.Size=UDim2.new(0,105,1,0); sidebar.BackgroundColor3=Color3.fromRGB(16,17,23)
sidebar.BorderSizePixel=0; sidebar.ZIndex=6; sidebar.Parent=body; corner(sidebar,9); stroke(sidebar,DARKBLUE,1)
local content=Instance.new("Frame"); content.Position=UDim2.new(0,112,0,0); content.Size=UDim2.new(1,-112,1,0)
content.BackgroundColor3=Color3.fromRGB(16,17,23); content.BorderSizePixel=0; content.ClipsDescendants=true
content.ZIndex=6; content.Parent=body; corner(content,9); stroke(content,DARKBLUE,1)

local pages,nav={},{}
for i,name in ipairs({"Home","Desempenho","Sobre"}) do
 local b=btn(sidebar,name,UDim2.new(0,5,0,7+(i-1)*39),UDim2.new(1,-10,0,32),name=="Home" and DARKBLUE or CARD)
 nav[name]=b
 local p=Instance.new("ScrollingFrame"); p.Name=name.."Page"; p.BackgroundTransparency=1; p.BorderSizePixel=0
 p.Position=UDim2.fromOffset(5,5); p.Size=UDim2.new(1,-10,1,-10); p.CanvasSize=UDim2.new(0,0,0,0)
 p.AutomaticCanvasSize=Enum.AutomaticSize.Y; p.ScrollBarThickness=3; p.ScrollBarImageColor3=BLUE
 p.Visible=name=="Home"; p.ZIndex=7; p.Parent=content
 local layout=Instance.new("UIListLayout"); layout.Padding=UDim.new(0,7); layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Parent=p
 local pad=Instance.new("UIPadding"); pad.PaddingTop=UDim.new(0,2); pad.PaddingBottom=UDim.new(0,5); pad.PaddingLeft=UDim.new(0,2); pad.PaddingRight=UDim.new(0,2); pad.Parent=p
 pages[name]=p
end
local function showPage(name)
 for n,p in pairs(pages) do p.Visible=n==name end
 for n,b in pairs(nav) do b.BackgroundColor3=n==name and DARKBLUE or CARD; b.TextColor3=n==name and WHITE or MUTED end
end
for n,b in pairs(nav) do b.Activated:Connect(function() showPage(n) end) end

local states={antiLag=false,shadows=false,particles=false,fps=false,visualEffects=false,lowQuality=false,postProcessing=false,smokeFire=false,fog=false,scenery=false}
local original={GlobalShadows=Lighting.GlobalShadows,Diffuse=Lighting.EnvironmentDiffuseScale,Specular=Lighting.EnvironmentSpecularScale,FogStart=Lighting.FogStart,FogEnd=Lighting.FogEnd,Brightness=Lighting.Brightness,ClockTime=Lighting.ClockTime}
local savedEnabled,savedParts,savedDecals,savedAtmos,savedShadows={},{},{},{},{}
local savedMeshes={}
local switches={}
local function isParticle(o) return o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") or o:IsA("Sparkles") end
local function restoreGraphics()
 for o,v in pairs(savedEnabled) do if o and o.Parent then pcall(function() o.Enabled=v end) end end; table.clear(savedEnabled)
 for o,v in pairs(savedParts) do if o and o.Parent then pcall(function() o.Material=v.Material; o.Reflectance=v.Reflectance end) end end; table.clear(savedParts)
 for o,v in pairs(savedDecals) do if o and o.Parent then pcall(function() o.Transparency=v end) end end; table.clear(savedDecals)
 for o,v in pairs(savedMeshes) do if o and o.Parent then pcall(function() o.RenderFidelity=v end) end end; table.clear(savedMeshes)
 for o,v in pairs(savedAtmos) do if o and o.Parent then pcall(function() o.Density=v.Density; o.Haze=v.Haze; o.Glare=v.Glare end) end end; table.clear(savedAtmos)
 for o,v in pairs(savedShadows) do if o and o.Parent then pcall(function() o.CastShadow=v end) end end; table.clear(savedShadows)
 Lighting.GlobalShadows=original.GlobalShadows; Lighting.EnvironmentDiffuseScale=original.Diffuse
 Lighting.EnvironmentSpecularScale=original.Specular; Lighting.FogStart=original.FogStart; Lighting.FogEnd=original.FogEnd
 Lighting.Brightness=original.Brightness; Lighting.ClockTime=original.ClockTime
end
local function applyGraphics()
 local noParticles=states.antiLag or states.particles or states.visualEffects or states.smokeFire
 local noPost=states.antiLag or states.visualEffects or states.postProcessing
 for _,o in ipairs(Workspace:GetDescendants()) do
  if isParticle(o) or o:IsA("PostEffect") or o:IsA("Fire") or o:IsA("Smoke") then
   if savedEnabled[o]==nil then savedEnabled[o]=o.Enabled end
   local disable=(isParticle(o) and noParticles) or (o:IsA("PostEffect") and noPost) or ((o:IsA("Fire") or o:IsA("Smoke")) and (states.antiLag or states.smokeFire or states.visualEffects))
   if disable then o.Enabled=false else o.Enabled=savedEnabled[o] end
  end
  if (states.antiLag or states.lowQuality or states.scenery) and o:IsA("BasePart") then
   if savedParts[o]==nil then savedParts[o]={Material=o.Material,Reflectance=o.Reflectance} end
   o.Material=Enum.Material.Plastic; o.Reflectance=0
   if o:IsA("MeshPart") and savedMeshes[o]==nil then savedMeshes[o]=o.RenderFidelity; pcall(function() o.RenderFidelity=Enum.RenderFidelity.Performance end) end
  elseif (states.antiLag or states.lowQuality or states.scenery) and (o:IsA("Decal") or o:IsA("Texture")) then
   if savedDecals[o]==nil then savedDecals[o]=o.Transparency end; o.Transparency=1
  end
  if states.antiLag or states.shadows then
   if o:IsA("BasePart") then if savedShadows[o]==nil then savedShadows[o]=o.CastShadow end; o.CastShadow=false end
  end
 end
 Lighting.EnvironmentDiffuseScale=states.antiLag and 0 or original.Diffuse
 Lighting.EnvironmentSpecularScale=states.antiLag and 0 or original.Specular
 if states.antiLag or states.shadows then Lighting.GlobalShadows=false else
  Lighting.GlobalShadows=original.GlobalShadows
  for o,v in pairs(savedShadows) do if o and o.Parent then pcall(function() o.CastShadow=v end) end end; table.clear(savedShadows)
 end
 if states.antiLag or states.fog then
  Lighting.FogStart=0; Lighting.FogEnd=1000000
  for _,o in ipairs(Lighting:GetChildren()) do if o:IsA("Atmosphere") then
   if savedAtmos[o]==nil then savedAtmos[o]={Density=o.Density,Haze=o.Haze,Glare=o.Glare} end
   o.Density=0; o.Haze=0; o.Glare=0
  end end
 else
  Lighting.FogStart=original.FogStart; Lighting.FogEnd=original.FogEnd
  for o,v in pairs(savedAtmos) do if o and o.Parent then pcall(function() o.Density=v.Density; o.Haze=v.Haze; o.Glare=v.Glare end) end end; table.clear(savedAtmos)
 end
end

local fpsFrame,fpsLabel
local function updateAll() applyGraphics(); if fpsFrame then fpsFrame.Visible=states.fps end end
local function makeSwitch(parent,on)
 local track=Instance.new("Frame"); track.Size=UDim2.fromOffset(38,22); track.BackgroundColor3=on and BLUE or GRAY
 track.BorderSizePixel=0; track.ZIndex=14; track.Parent=parent; corner(track,11)
 local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(18,18); knob.Position=on and UDim2.new(1,-20,.5,-9) or UDim2.new(0,2,.5,-9)
 knob.BackgroundColor3=WHITE; knob.BorderSizePixel=0; knob.ZIndex=15; knob.Parent=track; corner(knob,9)
 local hit=Instance.new("TextButton"); hit.BackgroundTransparency=1; hit.Text=""; hit.Size=UDim2.fromScale(1,1); hit.ZIndex=16; hit.Parent=track
 local function paint(v) track.BackgroundColor3=v and BLUE or GRAY; knob.Position=v and UDim2.new(1,-20,.5,-9) or UDim2.new(0,2,.5,-9) end
 return hit,paint
end

local options={
 {"antiLag","Anti Lag","Otimiza gráficos e desativa texturas locais."},
 {"shadows","Sombras","Desativa sombras dos objetos."},
 {"particles","Partículas","Desativa partículas, trilhas e feixes."},
 {"fps","Contador FPS","Mostra FPS e ping no canto superior direito."},
 {"visualEffects","Remover efeitos visuais","Desativa efeitos visuais suportados."},
 {"lowQuality","Reduzir qualidade gráfica","Reduz materiais e reflexos locais."},
 {"postProcessing","Desativar pós-processamento","Desativa efeitos de pós-processamento."},
 {"smokeFire","Remover fumaça e fogo","Desativa fumaça e fogo encontrados."},
 {"fog","Desativar neblina","Reduz neblina/atmosfera quando possível."},
 {"scenery","Reduzir detalhes do cenário","Simplifica materiais e oculta texturas locais."},
}
for i,info in ipairs(options) do
 local row=Instance.new("Frame"); row.Name=info[1]; row.Size=UDim2.new(1,-2,0,48); row.BackgroundColor3=CARD
 row.BorderSizePixel=0; row.LayoutOrder=i; row.ZIndex=8; row.Parent=pages.Desempenho; corner(row,8); stroke(row,DARKBLUE,1)
 text(row,info[2],11,WHITE,UDim2.new(0,9,0,4),UDim2.new(1,-65,0,18),Enum.Font.GothamBold)
 text(row,info[3],8,MUTED,UDim2.new(0,9,0,23),UDim2.new(1,-65,0,17))
 local holder=Instance.new("Frame"); holder.BackgroundTransparency=1; holder.AnchorPoint=Vector2.new(1,.5); holder.Position=UDim2.new(1,-8,.5,0); holder.Size=UDim2.fromOffset(38,22); holder.ZIndex=13; holder.Parent=row
 local hit,paint=makeSwitch(holder,false); switches[info[1]]=paint
 hit.Activated:Connect(function() states[info[1]]=not states[info[1]]; paint(states[info[1]]); updateAll() end)
end

-- Home
text(pages.Home,"Império Sensitivy 2.6 • Mobile Edition",15,WHITE,UDim2.new(),UDim2.new(1,0,0,28),Enum.Font.GothamBold)
text(pages.Home,"Ajuste a sensibilidade da câmera",10,MUTED,UDim2.new(),UDim2.new(1,0,0,22))
local sensButton=btn(pages.Home,"IMPÉRIO SENSITIVY • DESATIVADA",UDim2.new(),UDim2.new(1,0,0,36),DARKBLUE)
local sliderArea=Instance.new("Frame"); sliderArea.BackgroundTransparency=1; sliderArea.Size=UDim2.new(1,0,0,54); sliderArea.Parent=pages.Home; sliderArea.ZIndex=10
local percentBubble=Instance.new("TextLabel"); percentBubble.AnchorPoint=Vector2.new(.5,1); percentBubble.Position=UDim2.new(0,0,0,20); percentBubble.Size=UDim2.fromOffset(58,22); percentBubble.BackgroundColor3=DARKBLUE; percentBubble.BorderSizePixel=0; percentBubble.Text="1.00"; percentBubble.TextColor3=WHITE; percentBubble.TextSize=11; percentBubble.Font=Enum.Font.GothamBold; percentBubble.ZIndex=14; percentBubble.Parent=sliderArea; corner(percentBubble,6)
local slider=Instance.new("Frame"); slider.Position=UDim2.new(0,8,0,30); slider.Size=UDim2.new(1,-16,0,8); slider.BackgroundColor3=GRAY; slider.BorderSizePixel=0; slider.ZIndex=10; slider.Parent=sliderArea; corner(slider,4)
local fill=Instance.new("Frame"); fill.Size=UDim2.new(0,0,1,0); fill.BackgroundColor3=BLUE; fill.BorderSizePixel=0; fill.ZIndex=11; fill.Parent=slider; corner(fill,4)
local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(18,18); knob.AnchorPoint=Vector2.new(.5,.5); knob.Position=UDim2.new(0,0,.5,0); knob.BackgroundColor3=WHITE; knob.BorderSizePixel=0; knob.ZIndex=15; knob.Parent=slider; corner(knob,9); stroke(knob,BLUE,1.5)
local sliderHit=Instance.new("TextButton"); sliderHit.BackgroundTransparency=1; sliderHit.Text=""; sliderHit.Size=UDim2.new(1,16,0,30); sliderHit.Position=UDim2.new(0,-8,.5,-15); sliderHit.ZIndex=16; sliderHit.Active=true; sliderHit.Parent=slider
local rangeLabels=Instance.new("Frame"); rangeLabels.BackgroundTransparency=1; rangeLabels.Position=UDim2.new(0,8,0,40); rangeLabels.Size=UDim2.new(1,-16,0,14); rangeLabels.ZIndex=10; rangeLabels.Parent=sliderArea
local minLabel=text(rangeLabels,"1.00",9,MUTED,UDim2.new(0,0,0,0),UDim2.fromOffset(40,14),Enum.Font.GothamSemibold)
local maxLabel=text(rangeLabels,"120.00",9,MUTED,UDim2.new(1,-44,0,0),UDim2.fromOffset(44,14),Enum.Font.GothamSemibold,Enum.TextXAlignment.Right)
local function setSlider(x)
 local left=slider.AbsolutePosition.X
 local width=math.max(slider.AbsoluteSize.X,1)
 local alpha=math.clamp((x-left)/width,0,1)
 sensitivity=math.clamp(math.floor((1+alpha*119)*100+0.5)/100,1,120)
 percentBubble.Text=string.format("%.2f",sensitivity)
 percentBubble.Position=UDim2.new(0,8+alpha*(slider.AbsoluteSize.X),0,20)
 fill.Size=UDim2.new(alpha,0,1,0)
 knob.Position=UDim2.new(alpha,0,.5,0)
end
local sliderDrag,sliderTouch=false,nil
sliderHit.InputBegan:Connect(function(i)
 if i.UserInputType==Enum.UserInputType.Touch then
  sliderDrag=true; sliderTouch=i; setSlider(i.Position.X)
 elseif i.UserInputType==Enum.UserInputType.MouseButton1 then
  sliderDrag=true; sliderTouch=nil; setSlider(i.Position.X)
 end
end)
UIS.InputChanged:Connect(function(i)
 if not sliderDrag then return end
 if i.UserInputType==Enum.UserInputType.MouseMovement or (sliderTouch and i==sliderTouch) then setSlider(i.Position.X) end
end)
UIS.InputEnded:Connect(function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or (sliderTouch and i==sliderTouch) then sliderDrag=false; sliderTouch=nil end
end)
-- Sensibilidade 2.4:
-- Não altera Camera.CFrame nem cria rotação por RenderStep.
-- Quando o PlayerModule padrão está disponível, ajusta o delta antes de
-- o controlador nativo mover a câmera; se não estiver, informa no output.
local sensitivityCameraInput=nil
local sensitivityOriginalGetRotation=nil
local sensitivityPatchedGetRotation=nil

local sensitivityEnvironment=_G
pcall(function()
 if typeof(getgenv)=="function" then sensitivityEnvironment=getgenv() end
end)
if sensitivityEnvironment.__ImperioSensitivyCleanup then
 pcall(sensitivityEnvironment.__ImperioSensitivyCleanup)
end

local function restoreNativeSensitivity()
 if sensitivityCameraInput and sensitivityOriginalGetRotation
  and sensitivityCameraInput.getRotation==sensitivityPatchedGetRotation then
  sensitivityCameraInput.getRotation=sensitivityOriginalGetRotation
 end
 sensitivityCameraInput=nil
 sensitivityOriginalGetRotation=nil
 sensitivityPatchedGetRotation=nil
end

local function disconnectSensitivity()
 restoreNativeSensitivity()
end
sensitivityEnvironment.__ImperioSensitivyCleanup=disconnectSensitivity

local function findCameraInput()
 local playerScripts=player:FindFirstChild("PlayerScripts")
 if not playerScripts then return nil end
 local playerModule=playerScripts:FindFirstChild("PlayerModule")
 if not playerModule then return nil end
 local cameraInputModule=playerModule:FindFirstChild("CameraInput",true)
 if not cameraInputModule or not cameraInputModule:IsA("ModuleScript") then
  return nil
 end
 local ok,result=pcall(require,cameraInputModule)
 if ok and type(result)=="table" and type(result.getRotation)=="function" then
  return result
 end
 return nil
end

local function applyNativeSensitivity()
 if not sensitivityEnabled then
  restoreNativeSensitivity()
  return
 end

 if not sensitivityCameraInput then
  sensitivityCameraInput=findCameraInput()
  if not sensitivityCameraInput then
   warn("[Império Sensitivy 2.6] CameraInput nativo não encontrado; sensibilidade não foi alterada.")
   return
  end
  sensitivityOriginalGetRotation=sensitivityCameraInput.getRotation
  local original=sensitivityOriginalGetRotation
  sensitivityPatchedGetRotation=function(...)
   local result=original(...)
   if typeof(result)=="Vector2" then
    -- Escala recalibrada: 1.00 fica mais lento e 120.00 mais rápido.
    -- Só altera o delta nativo; não acumula nem modifica Camera.CFrame.
    local alpha=math.clamp((sensitivity-1)/119,0,1)
    local multiplier=0.35+(alpha*1.65)
    return result*multiplier
   end
   return result
  end
  sensitivityCameraInput.getRotation=sensitivityPatchedGetRotation
 end
end

local function setSensitivityEnabled(enabled)
 sensitivityEnabled=enabled
 if enabled then
  applyNativeSensitivity()
 else
  restoreNativeSensitivity()
 end
end

sensButton.Activated:Connect(function()
 setSensitivityEnabled(not sensitivityEnabled)
 sensButton.Text=sensitivityEnabled and "IMPÉRIO SENSITIVY • ATIVADA" or "IMPÉRIO SENSITIVY • DESATIVADA"
 sensButton.BackgroundColor3=sensitivityEnabled and BLUE or DARKBLUE
end)

-- Sobre
local logoCard=Instance.new("Frame"); logoCard.Size=UDim2.new(1,0,0,82); logoCard.BackgroundColor3=CARD; logoCard.BorderSizePixel=0; logoCard.LayoutOrder=1; logoCard.ZIndex=8; logoCard.Parent=pages.Sobre; corner(logoCard,9); stroke(logoCard,DARKBLUE,1)
local logo=Instance.new("Frame"); logo.Size=UDim2.fromOffset(43,43); logo.Position=UDim2.new(.5,-21,0,5); logo.BackgroundColor3=Color3.fromRGB(12,35,75); logo.BorderSizePixel=0; logo.ZIndex=9; logo.Parent=logoCard; corner(logo,10)
text(logo,"🧢",23,WHITE,UDim2.fromScale(0,0),UDim2.fromScale(1,1),Enum.Font.Gotham,Enum.TextXAlignment.Center)
text(logoCard,"Império Sensitivy",12,WHITE,UDim2.new(0,0,0,49),UDim2.new(1,0,0,17),Enum.Font.GothamBold,Enum.TextXAlignment.Center)
text(logoCard,"Mobile Edition",9,WHITE,UDim2.new(0,0,0,65),UDim2.new(1,0,0,14),Enum.Font.Gotham,Enum.TextXAlignment.Center)
local dev=Instance.new("Frame"); dev.Size=UDim2.new(1,0,0,52); dev.BackgroundColor3=CARD; dev.BorderSizePixel=0; dev.LayoutOrder=2; dev.ZIndex=8; dev.Parent=pages.Sobre; corner(dev,8)
text(dev,"Desenvolvido por",9,MUTED,UDim2.new(0,10,0,5),UDim2.new(1,-20,0,16))
text(dev,"Enthony Developer",12,WHITE,UDim2.new(0,10,0,22),UDim2.new(1,-20,0,21),Enum.Font.GothamBold)
local info=Instance.new("Frame"); info.Size=UDim2.new(1,0,0,72); info.BackgroundColor3=CARD; info.BorderSizePixel=0; info.LayoutOrder=3; info.ZIndex=8; info.Parent=pages.Sobre; corner(info,8)
text(info,"●  Interface: ativa",10,WHITE,UDim2.new(0,10,0,5),UDim2.new(1,-20,0,18))
text(info,"●  Opções de desempenho: 10",10,WHITE,UDim2.new(0,10,0,26),UDim2.new(1,-20,0,18))
text(info,"●  Plataforma: Roblox",10,WHITE,UDim2.new(0,10,0,47),UDim2.new(1,-20,0,18))
local copy=btn(pages.Sobre,"Copiar servidor",UDim2.new(),UDim2.new(1,0,0,34)); copy.LayoutOrder=4
copy.Activated:Connect(function()
 if typeof(setclipboard)=="function" then local ok=pcall(setclipboard,INVITE); copy.Text=ok and "Convite copiado!" or "Clipboard indisponível"
 else copy.Text="discord.gg/MaCKa3NCUT" end
end)
local updates=btn(pages.Sobre,"Verificar atualizações",UDim2.new(),UDim2.new(1,0,0,34)); updates.LayoutOrder=5
updates.Activated:Connect(function()
 updates.Text="Versão instalada: 2.0"
 task.delay(2.5,function() if updates.Parent then updates.Text="Verificar atualizações" end end)
end)
local restore=btn(pages.Sobre,"Restaurar configurações",UDim2.new(),UDim2.new(1,0,0,34),DARKBLUE); restore.LayoutOrder=6
local confirm=Instance.new("Frame"); confirm.Size=UDim2.new(1,0,0,78); confirm.BackgroundColor3=Color3.fromRGB(10,24,48); confirm.BorderSizePixel=0; confirm.Visible=false; confirm.LayoutOrder=7; confirm.ZIndex=20; confirm.Parent=pages.Sobre; corner(confirm,8); stroke(confirm,BLUE,1)
text(confirm,"Restaurar todas as opções?",11,WHITE,UDim2.new(0,8,0,3),UDim2.new(1,-16,0,22),Enum.Font.GothamBold)
local yes=btn(confirm,"Confirmar",UDim2.new(0,8,0,35),UDim2.new(.5,-12,0,30),DARKBLUE)
local no=btn(confirm,"Cancelar",UDim2.new(.5,4,0,35),UDim2.new(.5,-12,0,30),CARD)
restore.Activated:Connect(function() confirm.Visible=not confirm.Visible; restore.Text=confirm.Visible and "Cancelar restauração" or "Restaurar configurações" end)
no.Activated:Connect(function() confirm.Visible=false; restore.Text="Restaurar configurações" end)
yes.Activated:Connect(function()
 for k in pairs(states) do states[k]=false; if switches[k] then switches[k](false) end end
 restoreGraphics()
 sensitivity=DEFAULT_SENSITIVITY; setSensitivityEnabled(false)
 sensButton.Text="IMPÉRIO SENSITIVY • DESATIVADA"; sensButton.BackgroundColor3=DARKBLUE
 local resetAlpha=math.clamp((DEFAULT_SENSITIVITY-1)/119,0,1); percentBubble.Text=string.format("%.2f",DEFAULT_SENSITIVITY); percentBubble.Position=UDim2.new(0,8+resetAlpha*slider.AbsoluteSize.X,0,20); fill.Size=UDim2.new(resetAlpha,0,1,0); knob.Position=UDim2.new(resetAlpha,0,.5,0)
 -- Desfaz também os efeitos locais e os estados visuais de todos os switches.
 for _,paint in pairs(switches) do paint(false) end
 states.fps=false
 if fpsFrame then fpsFrame.Visible=false end
 confirm.Visible=false; restore.Text="Tudo restaurado"
 task.delay(1.8,function() if restore.Parent then restore.Text="Restaurar configurações" end end)
end)

-- Contador FPS / ping real quando disponível
fpsFrame=Instance.new("Frame"); fpsFrame.Name="FPSCounter"; fpsFrame.AnchorPoint=Vector2.new(1,0); fpsFrame.Position=UDim2.new(1,-12,0,12)
fpsFrame.Size=UDim2.fromOffset(174,34); fpsFrame.BackgroundColor3=BG; fpsFrame.BackgroundTransparency=0.28; fpsFrame.BorderSizePixel=0; fpsFrame.Visible=false; fpsFrame.Active=true; fpsFrame.ZIndex=30; fpsFrame.Parent=gui; corner(fpsFrame,9); local fpsOutline=stroke(fpsFrame,BLUE,1.5); fpsOutline.Transparency=0.38
fpsLabel=text(fpsFrame,"FPS: -- | Ping: -- ms",10,WHITE,UDim2.new(0,7,0,0),UDim2.new(1,-14,1,0),Enum.Font.GothamBold,Enum.TextXAlignment.Center)
local frames,elapsed,fps=0,0,0
RunService.RenderStepped:Connect(function(dt)
 frames+=1; elapsed+=dt
 if elapsed>=1 then fps=math.floor(frames/elapsed+.5); frames=0; elapsed=0 end
 if states.fps then
  local ping="--"; local ok,value=pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValueString() end)
  if ok and value then local n=tostring(value):match("%d+"); if n then ping=n end end
  fpsLabel.Text=string.format("FPS: %d | Ping: %s ms",fps,ping)
 end
end)
local dragFPS,dragStart,dragPos=false,nil,nil
fpsFrame.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragFPS=true; dragStart=i.Position; dragPos=fpsFrame.Position end end)
UIS.InputChanged:Connect(function(i)
 if not dragFPS or not dragStart or not dragPos then return end
 if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
  local d=i.Position-dragStart; local cam=Workspace.CurrentCamera; local vp=cam and cam.ViewportSize or Vector2.new(800,600)
  local x=math.clamp(dragPos.X.Offset+d.X,fpsFrame.AbsoluteSize.X+4,vp.X); local y=math.clamp(dragPos.Y.Offset+d.Y,4,vp.Y-fpsFrame.AbsoluteSize.Y-4)
  fpsFrame.Position=UDim2.fromOffset(x,y)
 end
end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragFPS=false end end)

-- Botão flutuante e arrastar painel
local open=btn(gui,"🧢",UDim2.new(0,12,.5,-20),UDim2.fromOffset(40,40),Color3.fromRGB(0,0,0)); open.Name="OpenButton"; open.TextSize=22; open.TextColor3=WHITE; open.TextStrokeTransparency=1; open.TextStrokeColor3=WHITE; open.BackgroundColor3=Color3.fromRGB(0,0,0); open.ZIndex=40
-- O quadradinho mantém o tamanho original e pode ser arrastado por toque ou mouse.
local isOpen=false
local openPress,openStart,openPos,openDragged=false,nil,nil,false
open.InputBegan:Connect(function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
  openPress=true; openDragged=false; openStart=i.Position; openPos=open.Position
 end
end)
UIS.InputChanged:Connect(function(i)
 if openPress and openStart and openPos and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
  local d=i.Position-openStart
  if math.abs(d.X)>5 or math.abs(d.Y)>5 then openDragged=true end
  if openDragged then
   local cam=Workspace.CurrentCamera; local vp=cam and cam.ViewportSize or Vector2.new(800,600)
   local x=math.clamp(vp.X*openPos.X.Scale+openPos.X.Offset+d.X,0,vp.X-open.AbsoluteSize.X)
   local y=math.clamp(vp.Y*openPos.Y.Scale+openPos.Y.Offset+d.Y,0,vp.Y-open.AbsoluteSize.Y)
   open.Position=UDim2.fromOffset(x,y)
  end
 end
end)
UIS.InputEnded:Connect(function(i)
 if openPress and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
  if not openDragged then isOpen=not isOpen; panel.Visible=isOpen end
  openPress=false; openStart=nil; openPos=nil
 end
end)
local dragging,pStart,pPos,dragInput=false,nil,nil,nil
header.InputBegan:Connect(function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
  dragging=true; pStart=i.Position; pPos=panel.Position
  if i.UserInputType==Enum.UserInputType.Touch then dragInput=i end
 end
end)
UIS.InputChanged:Connect(function(i)
 if not dragging or not pStart or not pPos then return end
 if i.UserInputType==Enum.UserInputType.MouseMovement or (dragInput and i==dragInput) then
  local d=i.Position-pStart; local cam=Workspace.CurrentCamera; local vp=cam and cam.ViewportSize or Vector2.new(800,600)
  local x=math.clamp(vp.X*pPos.X.Scale+pPos.X.Offset+d.X,panel.AbsoluteSize.X/2,vp.X-panel.AbsoluteSize.X/2)
  local y=math.clamp(vp.Y*pPos.Y.Scale+pPos.Y.Offset+d.Y,panel.AbsoluteSize.Y/2,vp.Y-panel.AbsoluteSize.Y/2)
  panel.Position=UDim2.fromOffset(x,y)
 end
end)
UIS.InputEnded:Connect(function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or (dragInput and i==dragInput) then
  dragging=false; dragInput=nil; pStart=nil; pPos=nil
 end
end)
UIS.InputBegan:Connect(function(i,gp) if not gp and (i.KeyCode==Enum.KeyCode.RightControl or i.KeyCode==Enum.KeyCode.F4) then isOpen=not isOpen; panel.Visible=isOpen end end)
showPage("Home")
print("[Império Sensitivy 2.3 • Mobile Edition] Carregado • Enthony Developer")
