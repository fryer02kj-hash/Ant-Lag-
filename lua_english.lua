--!
--  STEAL AN EGG :: AUTO FARM  (full source)
--  place 107778070777162
--
--  Cycle:  steal eggs from the area -> run back to base -> place eggs -> hatch -> equip pets
--         -> sell the lowest-earning pets -> run on the treadmill to increase Speed -> repeat
--
--    steal   = fireproximityprompt(prompt "CarryAreaEgg")  range 8 studs
--    claim   = walk/warp into PetArea your own plot -> receive the egg Tool
--    place   = Eggs: RequestPlaceEgg { Uid, LocalCFrame }   (local to CenterPoint)
--    hatch   = Eggs: RequestHatchEgg(uid) -> RequestCompleteHatchEgg(uid)
--    equip   = ActiveAssets: RequestEquip(uid)
--    sell    = ActiveAssets: RequestSell(uid)
--    speed   = stand on plot.TreadmillBottom (+20 Speed/sec per treadmill multiplier)
--
--  Earnings formula (verified with 0.00% error across 13 pets):
--    MoneyPerSecond = EarningRate(category) * Scale^1.85 * Mutation multiplier
--
--  How to use (one-click setup):
--    Simply load this file and it starts running - default preset is "balanced" + AutoStart
--    To customize: set _G.EggConfig = { ... } before loading this file
--    Or use egg_run.lua provided for you (single file; press Execute once)
--
--    Panel buttons:  PAUSE/START  ·  MODE (toggle movement mode)  ·  STOP    (panel can be dragged)
--    Hotkeys:    F2 = pause/resume · F3 = toggle movement mode · F4 = hide/show panel
--
--    _G.EggStart()          = start/resume
--    _G.EggPause()          = toggle pause state
--    _G.EggMode("walk")     = change movement mode live (omit to cycle to the next mode)
--    _G.EggSet{ ChainGrab = 8 }  = edit config while running
--    _G.EggGoTo(Vector3)    = move to a point using the same mover used by the farming routine
--    _G.EggRelease()        = immediately restore character state (if it gets stuck and movement stops working)
--    _G.EggStop()           = stop the script
--
--  Movement modes (CFG.MoveMode):
--    "humtween" <<< default - tween CFrame + replace the Humanoid with a fresh clone
--                  never anchors the character (anchoring caused the old tween mode to be kicked by BAC)
--                  discard the old Humanoid = break connections/states used by detection
--                  WalkSpeed = 0 while moving + clear Assembly velocity after each segment
--    "walk"      - walk normally using MoveTo  safest slowest (= MoveFallback)
--    "tween"     - the original anchored version  **already kicked by BAC (Error 267)**
--    "warp"      - teleport/jump positions  **killed by the game (Health = -1000)**  do not use
--    if knocked back or killed, the script reduces speed and automatically falls back to MoveFallback
--
--  Game-specific cautions (observed during testing):
--    * Never teleport by setting hrp.CFrame over long distances
--      Every tested method: first gets knocked back to base thenkilled by the game (Health = -1000)
--      Even when reduced to exactly match WalkSpeed, it still kills the character because it detects position jumps
--      Pushing AssemblyLinearVelocity above ~2x also results in being killed
--      -> so the script uses tween continuous movement in short segments that follow the ground
--         speed is tied to the actual WalkSpeed (TweenSpeedMul) rather than an artificial speed boost
--    * Must disable ControlModule before calling MoveTo otherwise it sends Move(0,0,0)
--      overwrites it every frame movement is limited to ~4 studs/s instead of 142
--    * After dying, the character does not respawn - you must leave and rejoin the game
--    * Area reset cycle (day/night) the game changes servers every few minutes = VM gets cleared
--      To keep it running automatically SourceUrl must be set and enable SurviveTeleport
--=====================================================================

--=====================================================================
local DEFAULTS = {
    ----------------------------------------------------------------
    -- Areas to steal from
    ----------------------------------------------------------------
    -- "ALL"          = all areas where your current Speed lets you outrun the guard
    -- "Forest"       = target a single area
    -- {"Forest","Lake"} = select multiple areas
    --
    -- All area names (sorted by guard speed, lowest to highest):
    --   Forest 16 · Lake 35 · Desert 62 · Jungle 82 · Snow 98
    --   Volcano 113 · Abyss Ocean 130 · Prehistoric 152 · Cosmic 200
    --   Cherry Blossom 222 · Titan Temple 229.5   <- new area in v447
    Area = "ALL",

    -- true  = do not enter areas where the guard is faster than you (safer - recommended)
    -- Areas are arranged in a straight line along the X axis, from easy to hard (Forest 600 -> Cherry Blossom 3928)
    -- Going to a distant area = requires running through every preceding area  faster guards can catch up with you
    -- Because areas are ordered by guard speed "a safe destination area" = "also means the route there is safe"
    RespectGuardSpeed = true,
    -- Speed must be >= guard * this value to enter that area
    -- 0.85 = allows entry even if slightly slower than the guard (the guard may be asleep and slow to wake, leaving time to escape)
    -- The easiest area (Forest) always accessible regardless of how slow you are - new accounts should start here
    SpeedSafety = 0.85,

    ----------------------------------------------------------------
    -- Movement
    ----------------------------------------------------------------
    -- "walk"  = walk normally using MoveTo  does not touch CFrame/Anchor  <<< default safest
    --           uses the normal API; the server does not detect it, so it can run for a long time without a kick
    -- "tween" = anchor + write CFrame every frame  **already kicked by BAC (Error 267)**
    -- "warp"  = teleport/jump positions  **killed by the game (Health = -1000)**
    -- To get faster without detection = increase Speed on the treadmill to raise WalkSpeed
    -- "humtween" = continuous CFrame tween + replace the Humanoid with a fresh clone  <<< new default
    --              Never anchors the character (anchoring caused the old tween mode to be kicked by BAC)
    --              Cloning the Humanoid and discarding the old one breaks connections/states used by detection hooks
    --              WalkSpeed = 0 while moving + clear Assembly velocity after each segment
    MoveMode = "humtween",
    -- if detected, knocked back, or killed permanently switch to this fallback mode
    MoveFallback = "walk",
    MoveTimeout = 60,           -- maximum seconds to reach the destination before giving up
    ArriveTol = 5,              -- distance in studs considered close enough to count as arrived
    Pathfind = true,            -- automatically calculate a detour when hitting a wall (walk mode)
    WarpSettle = 0.35,          -- wait still after arriving before pressing the prompt

    -- Tween mode settings
    TweenStep = 12,             -- segment length (shorter = follows the ground better)

    -- multiplier of actual WalkSpeed  measured on the server (new account with WalkSpeed 16):
    --   1x = 396 studs no knockback; survived
    --   2x = 756 studs no knockback; survived   <- upper limit that remained safe
    --   3x = dies within 4 seconds                <- do not exceed this
    -- default 1.5 leaves a safety margin in case ping fluctuates
    TweenSpeedMul = 1.5,
    TweenMaxSpeed = 0,          -- absolute speed cap studs/s  0 = unlimited
                                -- if WalkSpeed is very high and you get killed set a numeric cap to limit it
    TweenClimb = 6,             -- maximum climb up/down: 6 studs per segment
    TweenRollbackLimit = 3,     -- number of consecutive knockbacks before switching to walk

    -- Humtween mode settings (default mode)
    -- Speed in studs/s: 0 = calculate from actual WalkSpeed * HumTweenSpeedMul (safer; tied to actual stats)
    --                    enter a fixed number e.g. 450 = forces a constant speed (more aggressive and riskier)
    HumTweenSpeed = 0,
    HumTweenSpeedMul = 2.0,     -- multiplier of actual WalkSpeed (2x = measured limit that survived in this game)
    HumTweenMaxSpeed = 0,       -- absolute speed cap in studs/s; 0 = unlimited
    HumTweenStep = 18,          -- segment length (can be longer than the old tween mode because it does not anchor)
    HumTweenClimb = 8,          -- maximum climb up/down: 8 studs per segment
    HumTweenGround = true,      -- raycast to follow the ground on every segment (off = moves straight through the air; riskier)
    HumTweenHover = 3.2,        -- hover height above the ground, in studs
    HumTweenRecloneEvery = 0,   -- clone a new Humanoid every N segments (0 = 0 = clone only once per trip)
    HumTweenRollbackLimit = 3,  -- number of consecutive knockbacks before switching to MoveFallback

    -- Used only by MoveMode = "warp"
    Step = 50,
    Gap = 0.07,
    GroundSnap = true,
    HopTimeout = 300,

    ----------------------------------------------------------------
    -- Stealing cycle
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    -- Midpoint (visit before collecting eggs each time)
    ----------------------------------------------------------------
    -- Leaving base and heading straight for an egg cuts diagonally across the area
    -- can make the tween hit obstacles or enter guard territory too early
    -- Visiting the midpoint before heading to the egg = makes the route consistent and predictable
    -- Use a Vector3 or {x, y, z} as well · false = off (use the original direct route)
    MidPoint = { 547, 71, -362 },
    MidPointTol = 12,           -- consider the midpoint reached within this distance; do not revisit
    MidPointHome = false,       -- true = also visit the midpoint on the way back to base

    -- true  = steal using the same remote called by the in-game button (faster; no need to hold for 1.2 seconds)
    -- false = use only the original ProximityPrompt button
    -- the character still walks to the egg first because the server likely checks distance
    StealViaRemote = true,

    ChainGrab = 5,              -- eggs to steal per trip before returning to base
    GrabTimeout = 6,            -- wait for status "carrying" maximum wait in seconds
    ClaimTimeout = 14,           -- wait for status "delivered to base" maximum wait in seconds
    LoopDelay = 0.5,            -- delay between cycles
    RetryGrab = 2,              -- number of retries if stealing fails

    ----------------------------------------------------------------
    -- Base tasks
    ----------------------------------------------------------------
    AutoStart = true,
    AutoPlace = true,           -- place stolen eggs in the pen
    AutoHatch = true,           -- hatch eggs whose timer has finished
    AutoEquip = true,           -- equip hatched pets into the pen
    AutoSell = true,            -- sell the lowest earners when the pen is full
    AutoClaimOffline = true,    -- claim offline earnings when joining
    TendEvery = 3,              -- perform base tasks every N stealing cycles

    ----------------------------------------------------------------
    -- Upgrades (cost in-game currency)
    ----------------------------------------------------------------
    AutoUpgrade = true,         -- master switch for all upgrades
    UpgradeEvery = 5,           -- attempt upgrades every N cycles

    -- Upgrade the treadmill = to gain Speed faster = and access better areas (best value)
    -- Lv1 x2 · Lv2 x5 · Lv3 x12 · Lv4 x30 · Lv5 x80 · Lv6 x100
    -- Lv7 $75B x200 · Lv8 $2T x500 · Lv9 $50T x1000 · Lv10 $1000T x2000
    UpgradeTreadmill = true,
    MaxTreadmillPrice = 0,      -- maximum price per upgrade  0 = unlimited (only upgrade if you have enough money)

    -- Upgrade the pen = to place more pets  very expensive, so disabled
    UpgradePen = false,
    MaxPenPrice = 0,

    ----------------------------------------------------------------
    -- Selling policy
    ----------------------------------------------------------------
    -- Never sell pets earning at least this much
    --   Suffixes are supported: "10M" · "20b" · "9.9t" · 10000000 · "1,500,000"
    --   k = thousand · m = million · b = billion · t = trillion · q = quadrillion
    --   0 = ignore price sell based only on ranking (lowest earner is sold first)
    KeepAbove = 0,
    KeepExtra = 0,              -- number of pen slots to leave empty
    SellBackpack = true,        -- also sell backpack pets worse than the last pet in the pen

    -- do not collect eggs earning below this value  use the same format as KeepAbove
    -- 0 = calculate automatically (1% the best pet currently owned)
    MinEggRate = 0,

    -- true  = always collect the highest earner first even if it is farther away  <<< default
    -- false = collect the closest one first (faster cycles, but lower-value eggs)
    PreferBest = true,

    ----------------------------------------------------------------
    -- Treadmill (Speed)
    ----------------------------------------------------------------
    RideTreadmill = true,       -- use the treadmill when Speed is too low for the next area
    TreadmillSeconds = 20,      -- seconds to use the treadmill each time

    -- required speed multiplier over the first area guard before starting to steal
    -- new account with WalkSpeed 16 = exactly matches the Forest guard going out now will get you caught and killed
    -- 1.15 = require 15% more speed first (a few seconds on the treadmill should be enough)
    MinSpeedToSteal = 1.15,

    -- true = always collect eggs first if any are available in accessible areas  (prioritize collecting eggs)
    --        use the treadmill only when no eggs are available
    -- The easiest area (Forest) is always accessible because the guard starts asleep and wakes slowly, giving you a chance to grab an egg
    CollectFirst = true,
    TreadmillEvery = 10,        -- use the treadmill every N cycles (0 = only when Speed is insufficient)
    SpeedTarget = 0,            -- increase Speed until this target, then stop using the treadmill (0 = automatically)

    ----------------------------------------------------------------
    -- Area reset cycle (night / walls closed)
    ----------------------------------------------------------------
    HandleReset = true,         -- return to base when the countdown signal is heard
    ResetHoldFor = 8,           -- seconds to wait at base
    ResetWaitMax = 90,          -- maximum seconds to wait for eggs to respawn

    ----------------------------------------------------------------
    -- Other settings
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    -- One-click preset  (overrides DEFAULTS, then _G.EggConfig can override it)
    ----------------------------------------------------------------
    -- "safe"     = normal walking only; never touches CFrame  slowest safest
    -- "balanced" = humtween 2x + everything automated            <<< default
    -- "fast"     = aggressive humtween (constant 450 studs/s), collect 8 eggs at a time, risk of being kicked
    -- nil        = no preset; use values directly from the file
    Preset = "balanced",

    ShowUI = true,              -- status panel (center of the screen)
    UIButtons = true,           -- Pause / Mode / Stop buttons on the panel (click directly; no typing needed)
    UIDraggable = true,         -- panel can be dragged
    UIPosX = 0.5,               -- 0 = far left · 0.5 = center · 1 = far right
    UIPosY = 0.5,               -- 0 = top · 0.5 = center · 1 = bottom
    StatusTextSize = 15,
    Verbose = true,             -- log to console
    AntiAFK = true,
    AntiKick = true,            -- intercept client-side Kick calls (cannot stop server-side BAC; use walk instead)
    PerfMode = false,           -- reduce graphics
    FpsBoost = false,           -- setfpscap
    FpsCap = 30,
    SurviveTeleport = true,     -- continue running after server teleport (SourceUrl must be set)
    SourceUrl = nil,            -- e.g. "https://raw.githubusercontent.com/.../steal_an_egg.lua"
}

local PRESETS = {
    safe = {
        MoveMode = "walk", MoveFallback = "walk",
        ChainGrab = 3, RespectGuardSpeed = true, SpeedSafety = 1.0,
    },
    balanced = {
        MoveMode = "humtween", MoveFallback = "walk",
        HumTweenSpeed = 0, HumTweenSpeedMul = 2.0, HumTweenStep = 18,
        ChainGrab = 5, RespectGuardSpeed = true, SpeedSafety = 0.85,
    },
    fast = {
        MoveMode = "humtween", MoveFallback = "humtween",
        HumTweenSpeed = 450, HumTweenStep = 28, HumTweenClimb = 14,
        ChainGrab = 8, RespectGuardSpeed = true, SpeedSafety = 0.7,
    },
}

local CFG = {}
for k, v in pairs(DEFAULTS) do CFG[k] = v end
-- Override order:  DEFAULTS  ->  PRESETS[Preset]  ->  _G.EggConfig (user config always takes priority)
do
    local want = (_G.EggConfig and _G.EggConfig.Preset) or DEFAULTS.Preset
    local pre = want and PRESETS[tostring(want):lower()]
    if pre then for k, v in pairs(pre) do CFG[k] = v end end
    CFG.Preset = want
end
for k, v in pairs(_G.EggConfig or {}) do CFG[k] = v end
_G.EggConfig = CFG

--=====================================================================
--  SERVICES / STATE
--=====================================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting          = game:GetService("Lighting")
local TweenService      = game:GetService("TweenService")
local StarterGui        = game:GetService("StarterGui")

local LP = Players.LocalPlayer

-- stop the previous instance if run again
if _G.__EGG_RUNNING then
    pcall(function() _G.EggStop() end)
    task.wait(0.4)
end
_G.__EGG_RUNNING = true

-- S = all state (kept in one table to avoid exceeding 200 locals in the main chunk)
local S = {
    alive      = true,
    paused     = not CFG.AutoStart,
    conns      = {},
    threads    = {},
    status     = "starting",
    loops      = 0,
    stolen     = 0,
    hatched    = 0,
    sold       = 0,
    placed     = 0,
    failed     = 0,
    upgrades   = 0,
    lastUpgrade = -99,
    tiers      = nil,
    easiestGuard = nil,
    startClock = os.clock(),
    carrying   = nil,          -- record for the egg being carried
    carryMul   = 1,
    resetting  = false,
    resetUntil = 0,
    lastTread  = 0,
    plot       = nil,
    pen        = nil,
    origin     = nil,
    tread      = nil,
    ui         = nil,
    controlsObj  = nil,
    controlsHeld = false,
    -- humtween: cache the original Humanoid stats before replacing it with a clone
    humLocked  = false,        -- whether WalkSpeed is currently forced to 0
    humCache   = nil,          -- { Character = c, WalkSpeed = .., JumpPower = .., ... }
    realWalk   = nil,          -- actual WalkSpeed (UI/logic must read this, not 0)
    humTween   = nil,          -- currently playing Tween
    netRoot    = nil,          -- remote storage (Packages.Networking)
    netCache   = nil,          -- old name -> instance
}

local function track(c) S.conns[#S.conns + 1] = c return c end
local function spawnLoop(fn)
    local t = task.spawn(function()
        while S.alive do
            local ok, err = pcall(fn)
            if not ok and CFG.Verbose then warn("[Egg] loop error: " .. tostring(err)) end
            task.wait(0.2)
        end
    end)
    S.threads[#S.threads + 1] = t
    return t
end

local function log(...)
    if not CFG.Verbose then return end
    local parts = {}
    for _, v in ipairs({ ... }) do parts[#parts + 1] = tostring(v) end
    print("[Egg] " .. table.concat(parts, " "))
end

--=====================================================================
--  UTIL
--=====================================================================
local U = {}

-- "10M" / "1,500,000" / 1e7  ->  number
function U.parseAmount(v)
    if type(v) == "number" then return v end
    if type(v) ~= "string" then return 0 end
    local s = v:gsub(",", ""):gsub("%s", "")
    local num, suf = s:match("^([%d%.]+)([%a]*)$")
    if not num then return tonumber(s) or 0 end
    local mult = ({
        k = 1e3, m = 1e6, b = 1e9, t = 1e12, q = 1e15,
        qa = 1e15, qi = 1e18, s = 1e21,
    })[suf:lower()] or 1
    return (tonumber(num) or 0) * mult
end

function U.short(n)
    n = tonumber(n) or 0
    local units = { { 1e15, "Q" }, { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }
    for _, u in ipairs(units) do
        if n >= u[1] then return string.format("%.2f%s", n / u[1], u[2]) end
    end
    return string.format("%.0f", n)
end

function U.now() return os.clock() end

-- call RemoteFunction without hanging indefinitely
--=====================================================================
--  NETWORK LAYER
--  Updated 2026-08-31 (PlaceVersion 447): the game renamed the whole set of items
--    * ReplicatedStorage.Network  ->  ReplicatedStorage.Packages.Networking
--      (the new object is a ModuleScript, not a Folder, but FindFirstChild still works)
--    * Remote names changed from "Category: RequestThing"
--      to "RF/Category/Action" (RemoteFunction) and "RE/Category/Action" (RemoteEvent)
--    * Categories were renamed: Plots->Homestead · Eggs->EggWorld
--      ActiveAssets->PenRoster · OfflineAssets->AwayEarnings · ClientCharacter->RigSync
--    * Two endpoints changed from RemoteFunction to RemoteEvent (no return value anymore)
--      -> U.invoke/U.fire supports both types, so call sites do not need to change
--
--  the rest of the code still uses the old names; this table translates them
--  if the game reverts or an older server is used, the resolver also checks the old names
--=====================================================================
local NET = {
    ["Plots: RequestState"]                  = "RF/Homestead/AskState",
    ["Plots: RequestBaseUpgrade"]            = "RE/Homestead/AskBaseTierRaise",
    ["Eggs: RequestAreaEggSnapshot"]         = "RF/EggWorld/AskFieldEggSnapshot",
    ["Eggs: RequestRuntimeSnapshot"]         = "RF/EggWorld/AskLiveSnapshot",
    ["Eggs: RequestAreaEggCarry"]            = "RF/EggWorld/AskFieldEggCarry",
    ["Eggs: RequestPlaceEgg"]                = "RF/EggWorld/AskPlaceEgg",
    ["Eggs: RequestHatchEgg"]                = "RF/EggWorld/AskHatch",
    ["Eggs: RequestCompleteHatchEgg"]        = "RF/EggWorld/AskFinishHatch",
    ["ActiveAssets: RequestRuntimeSnapshot"] = "RF/PenRoster/AskLiveSnapshot",
    ["ActiveAssets: RequestEquipLimit"]      = "RF/PenRoster/AskWearLimit",
    ["ActiveAssets: RequestEquip"]           = "RF/PenRoster/AskWear",
    ["ActiveAssets: RequestSell"]            = "RF/PenRoster/AskSale",
    ["OfflineAssets: GetSummary"]            = "RF/AwayEarnings/FetchSummary",
    ["OfflineAssets: Redeem"]                = "RF/AwayEarnings/AskCollect",
    ["Treadmills: RequestUpgrade"]           = "RF/Treadmill/AskTierRaise",
    ["ClientCharacter: RequestCharacterReset"] = "RE/RigSync/AskRigWipe",
}

-- remote storage  try the new location first, then fall back to the old one
function U.netRoot()
    if S.netRoot and S.netRoot.Parent then return S.netRoot end
    local pkg = ReplicatedStorage:FindFirstChild("Packages")
    local root = pkg and pkg:FindFirstChild("Networking")
    if not root then root = ReplicatedStorage:FindFirstChild("Network") end   -- older version
    S.netRoot = root
    return root
end

-- convert old name to the actual instance  (cache it so it does not need to be searched each time)
function U.remote(name)
    S.netCache = S.netCache or {}
    local hit = S.netCache[name]
    if hit and hit.Parent then return hit end

    local root = U.netRoot()
    if not root then return nil end

    -- 1) new name from the mapping table  2) the supplied name directly (in case a new name is already supplied or an old server is used)
    local found = (NET[name] and root:FindFirstChild(NET[name])) or root:FindFirstChild(name)

    -- 3) not found yet: the game may have switched this endpoint between RF/RE; try the other type
    if not found and NET[name] then
        local alt = NET[name]:gsub("^RF/", "RE/"):gsub("^RE/", "RF/")
        found = root:FindFirstChild(alt)
    end

    S.netCache[name] = found
    if not found and CFG.Verbose then
        warn("[Egg] Remote not found: " .. tostring(name) .. " -> " .. tostring(NET[name]))
    end
    return found
end

function U.invoke(name, timeout, ...)
    local remote = U.remote(name)
    if not remote then return false, "no remote " .. name end
    -- Endpoint changed to RemoteEvent in the game: fire only; no return value
    if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
        local args0 = table.pack(...)
        pcall(function() remote:FireServer(table.unpack(args0, 1, args0.n)) end)
        return true, nil
    end
    local args = table.pack(...)
    local box = { done = false }
    task.spawn(function()
        local res = table.pack(pcall(function()
            return remote:InvokeServer(table.unpack(args, 1, args.n))
        end))
        box.done = true
        box.ok = res[1]
        box.v1, box.v2, box.v3 = res[2], res[3], res[4]
    end)
    local t0 = os.clock()
    while not box.done and os.clock() - t0 < (timeout or 8) do task.wait(0.05) end
    if not box.done then return false, "timeout" end
    if not box.ok then return false, tostring(box.v1) end
    return true, box.v1, box.v2, box.v3
end

function U.fire(name, ...)
    local remote = U.remote(name)
    if not remote then return end
    local args = table.pack(...)
    -- In case the endpoint is still a RemoteFunction (FireServer would error)
    if remote:IsA("RemoteFunction") then
        task.spawn(function()
            pcall(function() remote:InvokeServer(table.unpack(args, 1, args.n)) end)
        end)
        return
    end
    pcall(function() remote:FireServer(table.unpack(args, 1, args.n)) end)
end

function U.char()
    local c = LP.Character
    if not c or not c.Parent then return nil end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return nil end
    return c, hrp, hum
end

-- During humtween, WalkSpeed is set to 0; other logic must not read it for area selection, treadmill, or UI
-- read 0 otherwise it thinks we are too slow to enter any area -> return the cached actual value instead
-- midpoint from config  accepts both Vector3 and {x,y,z}  returns nil when disabled
function U.midPoint()
    local v = CFG.MidPoint
    if not v or v == false then return nil end
    if typeof(v) == "Vector3" then return v end
    if type(v) == "table" then
        local x, y, z = tonumber(v[1] or v.X or v.x), tonumber(v[2] or v.Y or v.y), tonumber(v[3] or v.Z or v.z)
        if x and y and z then return Vector3.new(x, y, z) end
    end
    return nil
end

function U.walkSpeed()
    if S.humLocked and S.realWalk and S.realWalk > 0 then return S.realWalk end
    local _, _, hum = U.char()
    return hum and hum.WalkSpeed or 16
end

--=====================================================================
--  GAME BINDINGS  (directory + remotes)
--=====================================================================
-- Updated 2026-08-31 (PlaceVersion 447): all data modules moved
--    ReplicatedStorage.Directory.*            ->  ReplicatedStorage.Data.*
--    ReplicatedStorage.Library.Modules.*      ->  ReplicatedStorage.Shared.Modules.*
--    ReplicatedStorage.Library.Client.EggCmds -> ReplicatedStorage.Client.EggState (method names changed too)
-- Important pitfall: ReplicatedStorage.Assets / .Mutations visible at the top level are
--    "folder of models" not a data module  requiring it will not return the data
local G = {}
do
    -- Try paths in order and use the first one found (supports old servers / reverted versions)
    local function tryPaths(paths, field)
        for _, path in ipairs(paths) do
            local node = ReplicatedStorage
            for seg in path:gmatch("[^%.]+") do
                node = node and node:FindFirstChild(seg)
            end
            if node and node:IsA("ModuleScript") then
                local ok, mod = pcall(require, node)
                if ok and type(mod) == "table" then
                    local v = field and mod[field] or mod
                    if type(v) == "table" then return v, path end
                end
            end
        end
        return nil
    end

    local path
    G.Assets, path = tryPaths({ "Data.Assets", "Directory.Assets" }, "Directory")
    G.Assets = G.Assets or {}
    G.Areas  = tryPaths({ "Data.Areas",  "Directory.Areas"  }, "Directory") or {}
    G.Guards = tryPaths({ "Data.Guards", "Directory.Guards" }, "Directory") or {}
    G.Mutations = tryPaths({ "Shared.Modules.Mutations", "Library.Modules.Mutations" })
    G.EggCmds   = tryPaths({ "Client.EggState", "Library.Client.EggCmds" })
    -- Treadmill: Directory is keyed by the config _id (e.g. "DemonicTreadmill")
    -- The current level is stored in the save data, not on the plot sign
    G.Tread     = tryPaths({ "Data.Treadmills", "Directory.Treadmills" })
    G.Save      = tryPaths({ "Shared.Save", "Library.Modules.Save" })

    if next(G.Assets) == nil then
        warn("[Egg] Could not read the Assets table - all eggs will be valued at 0 (the game may have updated again)")
    end
    if next(G.Guards) == nil then
        warn("[Egg] Could not read the Guards table - no area will be considered safe to enter")
    end
end

local EXP = 1.85 -- exponent for Scale in the earnings formula (verified against live values)

local function mutationMulti(muts)
    if not muts or next(muts) == nil then return 1 end   -- empty = do not call (to prevent error spam)
    -- v447: GetTotalMutationsEarningMulti was removed the new name is EarningsFor
    -- (accepts the same input and returns the same value: {"Golden","Silver"} = 2.7 · {} = 1)
    if G.Mutations then
        local fn = G.Mutations.EarningsFor or G.Mutations.GetTotalMutationsEarningMulti
        if fn then
            local ok, m = pcall(fn, muts)
            if ok and type(m) == "number" and m > 0 then return m end
        end
    end
    -- fallback: approximately 2.5x per mutation
    local n = 0
    for _ in pairs(muts) do n = n + 1 end
    return 2.5 ^ n
end

-- Value of one egg = earnings per second of the pet that will hatch
local function eggValue(rec)
    local def = G.Assets[rec.AssetCategory]
    if not def then return 0 end
    local base = def.EarningRate or 0
    local scale = rec.AssetScale or rec.Scale or 1
    return base * (scale ^ EXP) * mutationMulti(rec.Mutations)
end

local function eggWeight(rec)
    local def = G.Assets[rec.AssetCategory]
    return (def and def.Egg and def.Egg.WeightKg) or 1
end

local function growthTime(cat)
    local def = G.Assets[cat]
    return (def and def.Egg and def.Egg.GrowthTime) or 30
end

local function guardSpeed(areaId)
    local g = G.Guards[areaId]
    return (g and g.WalkSpeed) or math.huge
end

--=====================================================================
--  PLOT  (find your plot / pen / reference point / treadmill)
--=====================================================================
local function resolvePlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end

    local found
    -- Primary method: ask the server which slot belongs to us
    local ok, state = U.invoke("Plots: RequestState", 6)
    if ok and type(state) == "table" and type(state.OwnersBySlot) == "table" then
        for slot, owner in pairs(state.OwnersBySlot) do
            if owner == LP.UserId then
                found = plots:FindFirstChild(tostring(slot))
                break
            end
        end
    end
    -- Fallback: read the name on the sign
    if not found then
        for _, p in ipairs(plots:GetChildren()) do
            local sign = p:FindFirstChild("PlotSign")
            if sign then
                for _, d in ipairs(sign:GetDescendants()) do
                    if d:IsA("TextLabel") and d.Text == LP.Name then found = p break end
                end
            end
            if found then break end
        end
    end
    if not found then return false end

    S.plot   = found
    S.origin = found:FindFirstChild("CenterPoint")
    local tu = found:FindFirstChild("ToUpdate")
    S.pen    = tu and tu:FindFirstChild("PetArea")
    S.tread  = found:FindFirstChild("TreadmillBottom")
    if not S.origin then S.origin = S.pen end
    return S.pen ~= nil and S.origin ~= nil
end

local function homePoint()
    if S.pen then return S.pen.Position + Vector3.new(0, 4, 0) end
    if S.origin then return S.origin.Position + Vector3.new(0, 4, 0) end
    local _, hrp = U.char()
    return hrp and hrp.Position or Vector3.new(0, 50, 0)
end

--=====================================================================
--  MOVEMENT
--    tween = move continuously in short segments while following the ground  <<< default
--    walk  = normal movement with MoveTo (safest)
--    warp  = teleporting by position; the server detects it and kills the character. Do not use
--=====================================================================
local M = {}

-- find the ground beneath the point return nil if not found (to avoid accidentally placing the character over a drop)
function M.groundY(pos)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character }
    local hit = workspace:Raycast(pos + Vector3.new(0, 50, 0), Vector3.new(0, -400, 0), params)
    return hit and (hit.Position.Y + 3.2) or nil
end

-- return the character to normal physics
function M.unlock()
    local _, hrp = U.char()
    if hrp and hrp.Anchored then
        hrp.Anchored = false
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
    if S.humLocked then M.humRestore() end
end

-- ===== TWEEN MOVER =====
-- split the route into short segments (TweenStep) each segment:
--   1. raycast for the ground at the segment endpoint -> the character will not float or sink into the ground
--   2. anchor the character and tween CFrame linearly
--   3. unanchor and clear velocity
-- because movement is continuous and incremental, the server should not see it as a position jump
-- if repeatedly knocked back = automatically switch back to normal walking
function M.tweenTo(target, tol)
    tol = tol or CFG.ArriveTol
    M.grabControls()
    local deadline = os.clock() + CFG.MoveTimeout
    local rollbacks, stalls = 0, 0

    while os.clock() < deadline do
        if not S.alive then M.unlock() return false end
        local _, hrp, hum = U.char()
        if not hrp or not hum or hum.Health <= 0 then M.unlock() return false end

        local delta = target - hrp.Position
        local flat = Vector3.new(delta.X, 0, delta.Z)
        if flat.Magnitude <= tol then M.unlock() return true end

        local step = math.min(CFG.TweenStep, flat.Magnitude)
        local dir = flat.Unit
        local nextPos = hrp.Position + dir * step
        local gy = M.groundY(nextPos)
        if gy then
            -- maximum climb up/down TweenClimb per segment prevents falling into pits or clipping through mountains
            local dy = math.clamp(gy - hrp.Position.Y, -CFG.TweenClimb, CFG.TweenClimb)
            nextPos = Vector3.new(nextPos.X, hrp.Position.Y + dy, nextPos.Z)
        end

        local speed = math.max(8, U.walkSpeed() * CFG.TweenSpeedMul)
        local capAbs = tonumber(CFG.TweenMaxSpeed) or 0
        if capAbs > 0 then speed = math.min(speed, capAbs) end
        local dur = math.max(0.03, step / speed)
        local from = hrp.Position

        hrp.Anchored = true
        local tw = TweenService:Create(
            hrp,
            TweenInfo.new(dur, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
            { CFrame = CFrame.new(nextPos, nextPos + dir) }
        )
        local done = false
        tw.Completed:Once(function() done = true end)
        tw:Play()
        local twEnd = os.clock() + dur + 0.4
        while not done and os.clock() < twEnd and S.alive do task.wait() end
        pcall(function() tw:Cancel() end)
        hrp.Anchored = false
        hrp.AssemblyLinearVelocity = Vector3.zero

        local moved = (hrp.Position - from).Magnitude
        if moved < step * 0.4 then
            rollbacks = rollbacks + 1
            stalls = stalls + 1
            if rollbacks >= CFG.TweenRollbackLimit then
                warn("[Egg] Tween was knocked back by the server - permanently switching to walk mode")
                CFG.MoveMode = "walk"
                M.unlock()
                return M.walkTo(target, tol)
            end
            -- Stuck against a wall: jump and move sideways
            if stalls % 3 == 0 then
                pcall(function() hum.Jump = true end)
                task.wait(0.15)
            end
        else
            rollbacks = 0
            stalls = 0
        end
        task.wait()
    end
    M.unlock()
    return false
end


-- ===== HUMANOID-SWAP TWEEN MOVER  (MoveMode = "humtween")  <<< default =====
-- Unlike the old "tween" mode, this method never anchors the character - anchoring is what
-- caused the old mode to be kicked by BAC (Error 267) because the server sees the part anchored while its position moves
-- This method instead:
--   1. clone the current Humanoid and discard the old one
--      -> break connections, states, and detection hooks attached to the old Humanoid
--      -> restore the Animator otherwise animations disappear and it is obvious
--      -> BreakJointsOnDeath = false prevent the character from breaking apart if killed mid-trip
--   2. WalkSpeed = 0 while moving -> the character will not walk against the tween
--      (actual value is cached in S.realWalk then U.walkSpeed() reads from there instead)
--   3. Tween HumanoidRootPart CFrame linearly + clear Assembly velocity
--      every segment -> no accumulated velocity, avoids the "excess speed" check and helps prevent death on landing
-- movement still uses short ground-following segments because this game still checks for position jumps
local HUM_PROPS = { "WalkSpeed", "JumpPower", "JumpHeight", "AutoRotate", "PlatformStand" }

-- Replace the Humanoid with a fresh clone + set WalkSpeed to 0; return the new Humanoid
function M.humSwap()
    local char, hrp, hum = U.char()
    if not char or not hrp or not hum then return nil end

    -- Cache the real stats before changing them (only at the start of the trip)
    if not S.humLocked or not S.humCache or S.humCache.Character ~= char then
        S.humCache = { Character = char }
        for _, prop in ipairs(HUM_PROPS) do
            pcall(function() S.humCache[prop] = hum[prop] end)
        end
        S.realWalk = S.humCache.WalkSpeed or hum.WalkSpeed
    end

    local clone
    local ok = pcall(function()
        hum.Archivable = true
        clone = hum:Clone()
        clone.BreakJointsOnDeath = false
        hum:Destroy()
        clone.Parent = char
        clone.WalkSpeed = 0
        if not clone:FindFirstChildOfClass("Animator") then
            local anim = Instance.new("Animator")
            anim.Parent = clone
        end
        -- Prevent fall damage as in guardCharacter (this Humanoid was just created and has not been configured yet)
        clone:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        clone:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end)
    if not ok or not clone or not clone.Parent then
        warn("[Egg] humSwap failed - switch permanently to mode " .. M.fallbackMode())
        S.humLocked = false
        return nil
    end

    hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
    S.humLocked = true
    return clone
end

-- restore the character’s real stats  must be called whenever movement ends otherwise the player cannot move
function M.humRestore()
    if S.humTween then
        pcall(function() S.humTween:Cancel() end)
        S.humTween = nil
    end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        -- WalkSpeed: restore the original value only if it is still 0 because we set it
        -- If the game changes the value during the trip (for example, speed is reduced when carrying a heavy egg
        -- or a treadmill buff is applied), do not overwrite it or we may run faster than the server allows and get caught
        local cached = (S.humCache and S.humCache.Character == char) and S.humCache or nil
        if hum.WalkSpeed == 0 then
            local want = (cached and cached.WalkSpeed) or S.realWalk
            if want and want > 0 then pcall(function() hum.WalkSpeed = want end) end
        end
        if cached then
            for _, prop in ipairs(HUM_PROPS) do
                if prop ~= "WalkSpeed" and cached[prop] ~= nil then
                    pcall(function() hum[prop] = cached[prop] end)
                end
            end
        end
    end
    if hrp then
        hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
    end
    S.humLocked = false
end

-- fallback mode when detected  never return "humtween" or it will loop forever
-- (The "fast" preset sets MoveFallback = "humtween"; handle that case here)
function M.fallbackMode()
    local f = tostring(CFG.MoveFallback or "walk"):lower()
    if f == "humtween" or f == "warp" then return "walk" end
    return f
end

-- speed used for tweening  studs/s
function M.humSpeed()
    local flat = tonumber(CFG.HumTweenSpeed) or 0
    local speed
    if flat > 0 then
        speed = flat
    else
        speed = math.max(8, U.walkSpeed() * (tonumber(CFG.HumTweenSpeedMul) or 2))
    end
    local cap = tonumber(CFG.HumTweenMaxSpeed) or 0
    if cap > 0 then speed = math.min(speed, cap) end
    return speed
end

-- move one segment to the specified CFrame  return true if the tween completes
function M.humLeg(targetCF, speed)
    local _, hrp = U.char()
    if not hrp then return false end

    hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity = Vector3.zero, Vector3.zero

    local dist = (targetCF.Position - hrp.Position).Magnitude
    local dur = math.max(0.03, dist / math.max(1, speed))
    local tw = TweenService:Create(
        hrp,
        TweenInfo.new(dur, Enum.EasingStyle.Linear),
        { CFrame = targetCF }
    )
    S.humTween = tw

    local done, state = false, nil
    tw.Completed:Once(function(st) done, state = true, st end)
    tw:Play()

    local deadline = os.clock() + dur + 0.4
    while not done and os.clock() < deadline and S.alive do task.wait() end
    if S.humTween == tw then S.humTween = nil end
    if not done then pcall(function() tw:Cancel() end) end

    -- finish by setting CFrame exactly to prevent small errors from accumulating
    if state == Enum.PlaybackState.Completed and hrp.Parent then
        hrp.CFrame = targetCF
    end
    hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
    return done
end

function M.humTweenTo(target, tol)
    tol = tol or CFG.ArriveTol
    M.grabControls()

    local deadline = os.clock() + CFG.MoveTimeout
    local rollbacks, legs = 0, 0
    local reclone = math.max(0, tonumber(CFG.HumTweenRecloneEvery) or 0)

    if not M.humSwap() then
        CFG.MoveMode = M.fallbackMode()
        return M.goTo(target, tol)
    end

    while os.clock() < deadline do
        if not S.alive then M.humRestore() return false end
        local _, hrp, hum = U.char()
        if not hrp or not hum or hum.Health <= 0 then M.humRestore() return false end

        local delta = target - hrp.Position
        local flat = Vector3.new(delta.X, 0, delta.Z)
        if flat.Magnitude <= tol then M.humRestore() return true end

        -- Humanoid was replaced or lost its lock (for example, after respawning) -> replace it again
        if hum.WalkSpeed > 0 and S.humLocked then
            if not M.humSwap() then
                CFG.MoveMode = M.fallbackMode()
                M.humRestore()
                return M.goTo(target, tol)
            end
        end

        local step = math.min(CFG.HumTweenStep, flat.Magnitude)
        local dir = flat.Magnitude > 0.05 and flat.Unit or hrp.CFrame.LookVector
        local nextPos = hrp.Position + dir * step

        if CFG.HumTweenGround then
            local gy = M.groundY(nextPos)
            if gy then
                gy = gy - 3.2 + (tonumber(CFG.HumTweenHover) or 3.2)
                local dy = math.clamp(gy - hrp.Position.Y, -CFG.HumTweenClimb, CFG.HumTweenClimb)
                nextPos = Vector3.new(nextPos.X, hrp.Position.Y + dy, nextPos.Z)
            end
        end

        local from = hrp.Position
        M.humLeg(CFrame.new(nextPos, nextPos + dir), M.humSpeed())
        legs = legs + 1

        -- periodically clone a new one if configured (detection hooks attached to the Humanoid cannot reattach in time)
        if reclone > 0 and legs % reclone == 0 then M.humSwap() end

        local moved = ((hrp.Parent and hrp.Position or from) - from).Magnitude
        if moved < step * 0.4 then
            rollbacks = rollbacks + 1
            if rollbacks >= (CFG.HumTweenRollbackLimit or 3) then
                warn("[Egg] humtween was knocked back - permanently switching to mode " .. M.fallbackMode())
                CFG.MoveMode = M.fallbackMode()
                M.humRestore()
                return M.goTo(target, tol)
            end
        else
            rollbacks = 0
        end
        task.wait()
    end

    M.humRestore()
    return false
end

-- warp in segments verify movement in every segment reduce the distance if knocked back
function M.warpTo(target, tol)
    tol = tol or CFG.ArriveTol
    local step = CFG.Step
    local stuck = 0
    for _ = 1, CFG.HopTimeout do
        if not S.alive then return false end
        local _, hrp, hum = U.char()
        if not hrp then task.wait(0.3) return false end

        local delta = target - hrp.Position
        if delta.Magnitude <= tol then return true end

        local hop = delta.Magnitude > step and delta.Unit * step or delta
        local from = hrp.Position
        local dest = from + hop
        if CFG.GroundSnap and math.abs(hop.Y) < step * 0.5 then
            dest = Vector3.new(dest.X, M.groundY(dest), dest.Z)
        end

        local flat = Vector3.new(delta.X, 0, delta.Z)
        if flat.Magnitude > 0.05 then
            hrp.CFrame = CFrame.new(dest, dest + flat.Unit)
        else
            hrp.CFrame = CFrame.new(dest) * (hrp.CFrame - hrp.CFrame.Position)
        end
        -- Do not accumulate falling velocity, or the character may die on landing (this game does not respawn after death)
        hrp.AssemblyLinearVelocity = Vector3.zero
        task.wait(CFG.Gap)

        local moved = (hrp.Position - from).Magnitude
        if moved < hop.Magnitude * 0.35 then
            stuck = stuck + 1
            step = math.max(12, step - 8)          -- server knocked the character back -> reduce step size
            if stuck > 12 then
                -- move upward and try again (to avoid getting stuck on walls)
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 8, 0)
                task.wait(0.15)
                stuck = 0
                step = CFG.Step
            end
        else
            stuck = 0
            if step < CFG.Step then step = math.min(CFG.Step, step + 4) end
        end
    end
    return false
end

-- ControlModule control: disable player input first otherwise it sends
-- Humanoid:Move(0,0,0) every frame and cancels MoveTo (movement is limited to ~4 studs/s)
function M.controls()
    if S.controlsObj then return S.controlsObj end
    local ok, pm = pcall(function() return require(LP.PlayerScripts.PlayerModule) end)
    if not ok then return nil end
    local ok2, c = pcall(function() return pm:GetControls() end)
    if ok2 then S.controlsObj = c end
    return S.controlsObj
end

function M.grabControls()
    local c = M.controls()
    if c and not S.controlsHeld then
        pcall(function() c:Disable() end)
        S.controlsHeld = true
    end
end

function M.releaseControls()
    local c = M.controls()
    if c and S.controlsHeld then
        pcall(function() c:Enable() end)
        S.controlsHeld = false
    end
end

-- move directly toward the destination (used by pathfinding for each waypoint)
-- return "stuck" if pushing against a wall without moving
function M.stepTo(point, tol, budget)
    local t0 = os.clock()
    local lastPos, stallAt = nil, os.clock()
    while os.clock() - t0 < (budget or 8) do
        if not S.alive then return false, "dead" end
        local _, hrp, hum = U.char()
        if not hrp then return false, "nochar" end

        local flat = Vector3.new(point.X, hrp.Position.Y, point.Z)
        if (flat - hrp.Position).Magnitude <= (tol or CFG.ArriveTol) then return true end
        hum:MoveTo(flat)

        -- no movement = blocked by something try jumping over it first if still blocked, report as stuck
        if lastPos and (hrp.Position - lastPos).Magnitude < 1 then
            if os.clock() - stallAt > 1.0 then
                pcall(function() hum.Jump = true end)
                stallAt = os.clock()
                if os.clock() - t0 > 3 then return false, "stuck" end
            end
        else
            stallAt = os.clock()
        end
        lastPos = hrp.Position
        task.wait(0.1)
    end
    return false, "timeout"
end

-- calculate a path around obstacles using PathfindingService
function M.computePath(target)
    local _, hrp = U.char()
    if not hrp then return nil end
    local PS = game:GetService("PathfindingService")
    local ok, path = pcall(function()
        return PS:CreatePath({
            AgentRadius = 3,
            AgentHeight = 6,
            AgentCanJump = true,
            AgentCanClimb = false,
            WaypointSpacing = 8,
        })
    end)
    if not ok or not path then return nil end
    local ok2 = pcall(function() path:ComputeAsync(hrp.Position, target) end)
    if not ok2 or path.Status ~= Enum.PathStatus.Success then return nil end
    local wps = path:GetWaypoints()
    if #wps < 2 then return nil end
    return wps
end

-- normal walking at the character’s actual speed (safer; no knockback or death)
-- try walking straight first use pathfinding to detour only if a wall blocks the way
function M.walkTo(target, tol)
    tol = tol or CFG.ArriveTol
    M.grabControls()
    local deadline = os.clock() + CFG.MoveTimeout

    while os.clock() < deadline do
        if not S.alive then return false end
        local _, hrp = U.char()
        if not hrp then return false end
        if (Vector3.new(target.X, hrp.Position.Y, target.Z) - hrp.Position).Magnitude <= tol then
            return true
        end

        -- 1) try going straight first much faster when the path is clear
        local ok, why = M.stepTo(target, tol, math.min(10, deadline - os.clock()))
        if ok then return true end
        if why == "dead" or why == "nochar" then return false end

        -- 2) if straight movement fails, a wall is blocking the way use pathfinding to detour
        if not CFG.Pathfind then return false end
        local wps = M.computePath(target)
        if not wps then
            -- no path found: back up randomly and try again next cycle
            local _, h2 = U.char()
            if h2 then
                local side = h2.CFrame.RightVector * (math.random(0, 1) == 0 and 14 or -14)
                M.stepTo(h2.Position + side, 4, 2.5)
            end
        else
            for i = 2, #wps do
                if not S.alive or os.clock() >= deadline then break end
                local wp = wps[i]
                local _, h3, hum3 = U.char()
                if not h3 then return false end
                if wp.Action == Enum.PathWaypointAction.Jump then
                    pcall(function() hum3.Jump = true end)
                end
                local reached, reason = M.stepTo(wp.Position, 5, 6)
                if not reached then
                    if reason == "dead" or reason == "nochar" then return false end
                    break -- path became invalid; recalculate next cycle
                end
            end
        end
    end
    return false
end

function M.goTo(target, tol)
    local mode = CFG.MoveMode
    if mode == "warp" then return M.warpTo(target, tol) end   -- dangerous
    if mode == "walk" then return M.walkTo(target, tol) end
    if mode == "tween" then return M.tweenTo(target, tol) end -- anchored version (already kicked by BAC)
    return M.humTweenTo(target, tol)                          -- humtween = default
end

-- visit the midpoint first (skip if already nearby)  return true if no stop is needed or the stop succeeds
-- This belongs on M rather than U because it calls M.goTo, while local M is declared after the U block
function M.viaMid(label)
    local mid = U.midPoint()
    if not mid then return true end
    local _, hrp = U.char()
    local tol = tonumber(CFG.MidPointTol) or 12
    if hrp and (hrp.Position - mid).Magnitude <= tol then return true end
    S.status = "-> middle" .. (label and (" (" .. label .. ")") or "")
    return M.goTo(mid, tol)
end

function M.goHome()
    if CFG.MidPointHome then M.viaMid("home") end
    local ok = M.goTo(homePoint(), 6)
    task.wait(CFG.WarpSettle)
    return ok
end

--=====================================================================
--  AREA EGGS (snapshot / ranking / target selection)
--=====================================================================
local A = {}

function A.snapshot()
    local ok, snap = U.invoke("Eggs: RequestAreaEggSnapshot", 8)
    if not ok or type(snap) ~= "table" then return {} end
    return snap.Records or {}
end

function A.areaAllowed(areaId)
    local want = CFG.Area
    if type(want) == "table" then
        for _, a in ipairs(want) do if a == areaId then return true end end
        return false
    end
    if type(want) == "string" and want ~= "ALL" and want ~= "" then
        return want == areaId
    end
    return true
end

-- slowest guard in the game (= starting area)
function A.easiestGuard()
    if S.easiestGuard then return S.easiestGuard end
    local best
    for id in pairs(G.Guards) do
        local g = guardSpeed(id)
        if g < math.huge and (not best or g < best) then best = g end
    end
    S.easiestGuard = best or 16
    return S.easiestGuard
end

-- whether you can outrun the guard (including the slowdown while carrying an egg)
function A.areaSafe(areaId, carryMul)
    if not CFG.RespectGuardSpeed then return true end
    local g = guardSpeed(areaId)
    if g == math.huge then return false end

    -- The easiest areaalways accessible
    -- New account WalkSpeed 16 = exactly matches the Forest guard strictly speaking, you would qualify for no areas
    -- but the guard starts asleep and wakes slowly (RunBackWakeDelayRequired) giving time to grab an egg and run
    if g <= A.easiestGuard() then return true end

    local mine = U.walkSpeed() * (carryMul or 1)
    return mine >= g * CFG.SpeedSafety
end

-- minimum value threshold for eggs worth collecting
function A.minRate(ownedBest)
    local m = U.parseAmount(CFG.MinEggRate)
    if m > 0 then return m end
    return (ownedBest or 0) * 0.01
end

-- Always return a list of collectible eggs sorted from highest earner to lowest
-- the most valuable is always collected first even if farther away
-- (if values tie, choose the closer one)
function A.candidates(ownedBest)
    local list = {}
    local floor = A.minRate(ownedBest)
    local _, hrp = U.char()
    local me = hrp and hrp.Position or Vector3.zero

    for _, rec in pairs(A.snapshot()) do
        if rec.State == "Slot" and A.areaAllowed(rec.AreaId) then
            local mul = math.clamp(1 - 0.04 * eggWeight(rec), 0.25, 1)
            if A.areaSafe(rec.AreaId, mul) then
                local val = eggValue(rec)
                if val >= floor then
                    list[#list + 1] = {
                        rec = rec,
                        value = val,
                        carryMul = mul,
                        dist = (rec.BottomCFrame.Position - me).Magnitude,
                    }
                end
            end
        end
    end

    if CFG.PreferBest == false then
        -- speed-focused mode: choose the nearest one first
        table.sort(list, function(a, b) return a.dist < b.dist end)
    else
        table.sort(list, function(a, b)
            if a.value ~= b.value then return a.value > b.value end
            return a.dist < b.dist
        end)
    end
    return list
end

--=====================================================================
--  STEAL  (press CarryAreaEgg -> carry it back to base)
--=====================================================================
local promptCache = { list = {}, at = 0 }

local function refreshPrompts()
    if os.clock() - promptCache.at < 3 and #promptCache.list > 0 then return promptCache.list end
    local list = {}
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Name == "CarryAreaEgg" then
            local p = d.Parent
            if p and p:IsA("BasePart") then list[#list + 1] = { prompt = d, part = p } end
        end
    end
    promptCache.list, promptCache.at = list, os.clock()
    return list
end

local function promptNear(pos, maxDist)
    local best, bd
    for _, e in ipairs(refreshPrompts()) do
        if e.prompt.Parent then
            local d = (e.part.Position - pos).Magnitude
            if (not bd or d < bd) then best, bd = e.prompt, d end
        end
    end
    if best and bd and bd <= (maxDist or 14) then return best, bd end
    return nil, bd
end

-- steal one egg: move there -> press the button -> confirm it is being carried
local function stealEgg(cand)
    local rec = cand.rec
    local eggPos = rec.BottomCFrame.Position

    -- visit the midpoint before heading to the egg
    M.viaMid(rec.AreaId)
    if not S.alive then return false end

    S.status = "steal " .. tostring(rec.AssetCategory) .. " @ " .. tostring(rec.AreaId)
    if not M.goTo(eggPos + Vector3.new(0, 3, 0), 4) then
        S.failed = S.failed + 1
        return false
    end
    task.wait(CFG.WarpSettle)

    for attempt = 1, math.max(1, CFG.RetryGrab) do
        if not S.alive then return false end

        -- Primary method: fire the same remote used by the in-game button
        -- derived from StarterPlayerScripts.Game.AreaEggs -> bindPrompt.Triggered:
        --     EggState.CarryFieldEgg(rec.Uid, slotKey)
        --       = AskFieldEggCarry:InvokeServer{ Uid = ..., FirstAreaSlotKey = ... }
        -- Better than using the button because Prompt.Enabled is handled only on the client (the server cannot see it)
        -- Also avoids waiting for a 1.2-second hold; FirstAreaSlotKey is used only for eggs in the first area
        -- normal eggs do not use it -> send nil
        local carried = false
        if CFG.StealViaRemote ~= false then
            local ok, res, why = U.invoke("Eggs: RequestAreaEggCarry", 6, { Uid = rec.Uid })
            carried = ok and res and true or false
            if ok and not res and CFG.Verbose and attempt == 1 then
                log("carry remote refused:", tostring(why))
            end
        end

        -- Fallback: press the original button (in case the remote signature changes again)
        if not carried then
            promptCache.at = 0
            local prompt = promptNear(eggPos, 16)
            if prompt then
                pcall(function() fireproximityprompt(prompt, 1) end)
            end
        end
        local t0 = os.clock()
        while os.clock() - t0 < CFG.GrabTimeout do
            if S.carrying then
                S.stolen = S.stolen + 1
                S.carryMul = S.carrying.SpeedMultiplier or cand.carryMul or 1
                log("grabbed", S.carrying.AssetCategory, "(" .. U.short(cand.value) .. "/s)")
                return true
            end
            task.wait(0.1)
        end
        -- still not triggered: move a little closer and retry
        M.goTo(eggPos + Vector3.new(0, 2, 0), 2)
        task.wait(0.3)
    end
    S.failed = S.failed + 1
    return false
end

-- carry back to base -> when entering the pen, the server automatically converts the egg into a Tool
local function carryHome()
    S.status = "carry home"
    M.goTo(homePoint(), 6)

    -- the server collects the egg upon reaching the pen; wait first
    local t0 = os.clock()
    while os.clock() - t0 < CFG.ClaimTimeout do
        if not S.carrying then return true end
        task.wait(0.2)
        -- not inside yet: walk around the pen in case the trigger did not activate (starts after waiting 2 seconds)
        if os.clock() - t0 > 2 then
            M.goTo(homePoint() + Vector3.new(math.random(-6, 6), 0, math.random(-6, 6)), 4)
        end
    end
    return not S.carrying
end

--=====================================================================
--  BASE WORK  (place eggs / hatch / equip pets / sell)
--=====================================================================
local B = {}

function B.myEggRecords()
    local out = {}
    local ok, snap = U.invoke("Eggs: RequestRuntimeSnapshot", 8)
    if not ok or type(snap) ~= "table" then return out end
    for _, entry in pairs(snap) do
        if type(entry) == "table" and entry.OwnerUserId == LP.UserId then
            for uid, rec in pairs(entry.Records or {}) do out[uid] = rec end
        end
    end
    return out
end

function B.myPets()
    local out, count = {}, 0
    local ok, snap = U.invoke("ActiveAssets: RequestRuntimeSnapshot", 8)
    if not ok or type(snap) ~= "table" then return out, 0 end
    for _, entry in pairs(snap) do
        if type(entry) == "table" and entry.OwnerUserId == LP.UserId then
            for uid, rec in pairs(entry.Records or {}) do
                out[#out + 1] = { uid = uid, mps = rec.MoneyPerSecond or 0, data = rec.ItemData or {} }
                count = count + 1
            end
        end
    end
    table.sort(out, function(a, b) return a.mps > b.mps end)
    return out, count
end

function B.equipLimit()
    local ok, n = U.invoke("ActiveAssets: RequestEquipLimit", 6)
    if ok and type(n) == "number" then return n end
    return 13
end

-- egg or pet Tools in the backpack/hand
function B.tools(itemType)
    local out = {}
    local function scan(container)
        if not container then return end
        for _, c in ipairs(container:GetChildren()) do
            if c:IsA("Tool") and c:GetAttribute("ItemType") == itemType then
                out[#out + 1] = c
            end
        end
    end
    scan(LP:FindFirstChild("Backpack"))
    scan(LP.Character)
    return out
end

-- find an empty pen slot for an egg
function B.freeSpot(taken)
    if not S.pen or not S.origin then return nil end
    local size = S.pen.Size
    local mx = math.max(4, size.X / 2 - 5)
    local mz = math.max(4, size.Z / 2 - 5)
    for _ = 1, 60 do
        local dx = math.random(-math.floor(mx), math.floor(mx))
        local dz = math.random(-math.floor(mz), math.floor(mz))
        local world = S.pen.CFrame * CFrame.new(dx, size.Y / 2 + 1, dz)
        local clear = true
        for _, p in ipairs(taken) do
            if (p - world.Position).Magnitude < 6 then clear = false break end
        end
        if clear then return world end
    end
    return S.pen.CFrame * CFrame.new(math.random(-10, 10), size.Y / 2 + 1, math.random(-10, 10))
end

function B.placeEggs()
    if not CFG.AutoPlace then return end
    if not S.pen or not S.origin then return end

    -- claimed eggs are stored as records, not Tools in the backpack
    -- (they become Tools only when RequestEquipTool is called - placing does not require holding it)
    -- a record that has not been placed yet = has no Placement field
    local pending, taken = {}, {}
    for uid, rec in pairs(B.myEggRecords()) do
        if rec.Placement then
            if rec.Placement.LocalCFrame then
                taken[#taken + 1] = (S.origin.CFrame * rec.Placement.LocalCFrame).Position
            end
        else
            pending[#pending + 1] = { uid = uid, rec = rec }
        end
    end
    if #pending == 0 then return end

    for _, item in ipairs(pending) do
        if not S.alive then return end
        local world = B.freeSpot(taken)
        if world then
            local localCF = S.origin.CFrame:ToObjectSpace(world)
            local ok, res, reason = U.invoke("Eggs: RequestPlaceEgg", 8, { Uid = item.uid, LocalCFrame = localCF })
            if ok and res then
                S.placed = S.placed + 1
                taken[#taken + 1] = world.Position
                log("placed", item.rec.AssetCategory)
            elseif CFG.Verbose then
                log("place failed", item.rec.AssetCategory, tostring(reason or res))
            end
            task.wait(0.15)
        end
    end
end

function B.hatchReady()
    if not CFG.AutoHatch then return end
    local now = workspace:GetServerTimeNow()
    for uid, rec in pairs(B.myEggRecords()) do
        if not S.alive then return end
        if rec.Placement then
            local ready
            -- v447: EggCmds.IsLocalEggReady -> EggState.IsReadyToHatch
            if G.EggCmds then
                local fn = G.EggCmds.IsReadyToHatch or G.EggCmds.IsLocalEggReady
                if fn then
                    local ok, r = pcall(fn, uid)
                    if ok then ready = r end
                end
            end
            if ready == nil then
                local need = growthTime(rec.AssetCategory) / math.max(0.01, rec.GrowthSpeedMultiplier or 1)
                ready = (now - (rec.Placement.PlacedAt or now)) >= need
            end
            if ready then
                local ok, res = U.invoke("Eggs: RequestHatchEgg", 8, uid)
                if ok and res then
                    task.wait(0.9)
                    local ok2, res2, _, petUid = U.invoke("Eggs: RequestCompleteHatchEgg", 8, uid)
                    if ok2 and res2 then
                        S.hatched = S.hatched + 1
                        log("hatched", rec.AssetCategory, petUid and ("-> " .. tostring(petUid):sub(1, 8)) or "")
                    end
                end
                task.wait(0.2)
            end
        end
    end
end

-- value of pets still in the backpack (not placed in the pen yet)
function B.bagPetValue(tool)
    local cat = tool:GetAttribute("Category")
    local def = G.Assets[cat]
    if not def then return 0 end
    local scale = tonumber(tool:GetAttribute("Scale")) or 1
    -- the Mutations attribute is a string, e.g. "Golden,Silver" (empty = none)
    -- must be split into an array of names
    -- (ExtractMutationsFromString returns a mutation object, which GetTotalMutationsEarningMulti cannot consume)
    local muts = {}
    for name in tostring(tool:GetAttribute("Mutations") or ""):gmatch("[^,%s]+") do
        muts[#muts + 1] = name
    end
    return (def.EarningRate or 0) * (scale ^ EXP) * mutationMulti(muts)
end

-- place pets in the pen and sell the worst one when full
function B.equipAndSell()
    local bag = B.tools("Asset")
    if #bag == 0 and not CFG.AutoSell then return end

    local pets, count = B.myPets()
    local limit = B.equipLimit() - math.max(0, CFG.KeepExtra)
    local keepAbove = U.parseAmount(CFG.KeepAbove)

    -- sort backpack pets: best first
    table.sort(bag, function(a, b) return B.bagPetValue(a) > B.bagPetValue(b) end)

    for _, tool in ipairs(bag) do
        if not S.alive then return end
        local uid = tool:GetAttribute("UID")
        if not uid then continue end
        local val = B.bagPetValue(tool)

        if count < limit then
            if CFG.AutoEquip then
                local ok, res = U.invoke("ActiveAssets: RequestEquip", 8, uid)
                if ok and res then
                    count = count + 1
                    table.insert(pets, { uid = uid, mps = val, data = {} })
                    table.sort(pets, function(a, b) return a.mps > b.mps end)
                end
                task.wait(0.12)
            end
        elseif CFG.AutoSell then
            -- pen is full: is the new pet better than the last pet in the pen
            local worst = pets[#pets]
            if worst and val > worst.mps and (keepAbove <= 0 or worst.mps < keepAbove) then
                local ok, res = U.invoke("ActiveAssets: RequestSell", 8, worst.uid)
                if ok and res then
                    S.sold = S.sold + 1
                    table.remove(pets, #pets)
                    count = count - 1
                    log("sold worst", U.short(worst.mps) .. "/s  <-  " .. U.short(val) .. "/s")
                    task.wait(0.12)
                    local ok2, res2 = U.invoke("ActiveAssets: RequestEquip", 8, uid)
                    if ok2 and res2 then
                        count = count + 1
                        table.insert(pets, { uid = uid, mps = val, data = {} })
                        table.sort(pets, function(a, b) return a.mps > b.mps end)
                    end
                end
            elseif CFG.SellBackpack and worst and val <= worst.mps and (keepAbove <= 0 or val < keepAbove) then
                -- the new pet is worse than every pet in the pen -> sell it
                local ok, res = U.invoke("ActiveAssets: RequestSell", 8, uid)
                if ok and res then
                    S.sold = S.sold + 1
                    log("sold bag pet", U.short(val) .. "/s")
                end
            end
            task.wait(0.12)
        end
    end
end

function B.claimOffline()
    if not CFG.AutoClaimOffline then return end
    local ok, sum = U.invoke("OfflineAssets: GetSummary", 6)
    if ok and type(sum) == "table" and (sum.ClaimableAmount or 0) > 0 then
        U.invoke("OfflineAssets: Redeem", 8)
        log("claimed offline", U.short(sum.ClaimableAmount))
    end
end

-- current cash (read from GUI because leaderstats only contains Money/s)
function B.cash()
    local pg = LP:FindFirstChild("PlayerGui")
    local money = pg and pg:FindFirstChild("Money")
    if not money then return 0 end
    for _, d in ipairs(money:GetDescendants()) do
        if d:IsA("TextLabel") and d.Name == "Money" then
            return U.parseAmount((d.Text or ""):gsub("%$", ""))
        end
    end
    return 0
end

-- treadmills sorted by price: index matches the "Level" shown on the sign
-- Lv1 Treadmill x2 · Lv2 Sci-Fi x5 · Lv3 Flame x12 · Lv4 Celebrity x30
-- Lv5 Golden x80 · Lv6 The Freeze x100 · Lv7 Lucky Block x200
-- Lv8 Hacker x500 · Lv9 Demonic x1000 · Lv10 Angelic x2000
function B.treadmillTiers()
    if S.tiers then return S.tiers end
    if not G.Tread then return {} end
    local TD = G.Tread.Directory or G.Tread
    local list = {}
    for id, cfg in pairs(TD) do
        -- v447: AskTierRaise expects the config "_id" (e.g. "DemonicTreadmill") not the treadmill instance ID
        list[#list + 1] = {
            id    = cfg._id or id,
            price = cfg.Price or 0,
            mult  = cfg.SpeedMultiplier or 0,
            level = cfg.UpgradeLevel,
        }
    end
    table.sort(list, function(a, b) return a.price < b.price end)
    S.tiers = list
    return list
end

-- current treadmill level: read from save data first (most accurate) then fall back to the sign on the plot
function B.treadLevel()
    if G.Save and G.Save.Get then
        local ok, save = pcall(G.Save.Get)
        if ok and type(save) == "table" and tonumber(save.TreadmillUpgradeLevel) then
            return tonumber(save.TreadmillUpgradeLevel)
        end
    end
    return padLevel(S.plot and S.plot:FindFirstChild("TreadmillUpgrade"))
end

-- read the current level from the upgrade stand sign ("Level 6 > Level 7")
local function padLevel(model)
    if not model then return nil end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("TextLabel") then
            local cur, nxt = tostring(d.Text):match("Level%s+(%d+)%s*>%s*Level%s+(%d+)")
            if cur then return tonumber(cur), tonumber(nxt) end
        end
    end
    return nil
end

function B.upgradeTreadmill()
    if not (CFG.AutoUpgrade and CFG.UpgradeTreadmill) then return end
    local cur = B.treadLevel()
    local tiers = B.treadmillTiers()
    if #tiers == 0 then return end

    -- the game selects the target using GetByUpgradeLevel(level + 1) -> use the same method
    local target
    if cur and G.Tread and G.Tread.GetByUpgradeLevel then
        local ok, cfg = pcall(G.Tread.GetByUpgradeLevel, cur + 1)
        if ok and type(cfg) == "table" and cfg._id then
            target = { id = cfg._id, price = cfg.Price or 0, mult = cfg.SpeedMultiplier or 0 }
        end
    end
    -- Fallback: iterate from cheapest to most expensive the next one after the current level
    if not target then target = tiers[(cur and (cur + 1)) or 2] end
    if not target then return end          -- already at the maximum level

    local cap = U.parseAmount(CFG.MaxTreadmillPrice)
    if cap > 0 and target.price > cap then return end
    local cash = B.cash()
    if cash > 0 and target.price > cash then return end

    local ok, res, reason = U.invoke("Treadmills: RequestUpgrade", 8, target.id)
    if ok and res then
        S.upgrades = S.upgrades + 1
        log(("upgraded treadmill -> %s (x%s) for $%s"):format(target.id, tostring(target.mult), U.short(target.price)))
    elseif CFG.Verbose and reason then
        log("treadmill upgrade:", tostring(reason))
    end
end

function B.upgradePen()
    if not (CFG.AutoUpgrade and CFG.UpgradePen) then return end
    local pad = S.plot and S.plot:FindFirstChild("PlotUpgrade")
    local cur = padLevel(pad)
    -- read the price from the sign do not send the request if funds are insufficient
    local cost
    if pad then
        for _, d in ipairs(pad:GetDescendants()) do
            if d:IsA("TextLabel") then
                local c = tostring(d.Text):match("^%$([%d%.,]+[kKmMbBtTqQ]?)$")
                if c then
                    local v = U.parseAmount(c)
                    if v and (not cost or v > cost) then cost = v end
                end
            end
        end
    end
    local cap = U.parseAmount(CFG.MaxPenPrice)
    if cap > 0 and cost and cost > cap then return end
    if cost and cost > B.cash() then return end

    U.fire("Plots: RequestBaseUpgrade")
    task.wait(0.5)
    local after = padLevel(pad)
    if cur and after and after > cur then
        S.upgrades = S.upgrades + 1
        log(("upgraded pen -> Level %d for $%s"):format(after, U.short(cost or 0)))
    end
end

function B.upgrade()
    if not CFG.AutoUpgrade then return end
    if (S.loops - (S.lastUpgrade or -99)) < math.max(1, CFG.UpgradeEvery) then return end
    S.lastUpgrade = S.loops
    B.upgradeTreadmill()
    B.upgradePen()
end

--=====================================================================
--  TREADMILL  (stand on the treadmill to increase Speed)
--=====================================================================
local function speedStat()
    local ls = LP:FindFirstChild("leaderstats")
    local sp = ls and ls:FindFirstChild("Speed")
    return sp and (tonumber(sp.Value) or 0) or 0
end

-- next inaccessible area required WalkSpeed
local function nextAreaNeed()
    local mine = U.walkSpeed()
    local best
    for id in pairs(G.Guards) do
        if A.areaAllowed(id) then
            local need = guardSpeed(id)
            if need > mine and (not best or need < best) then best = need end
        end
    end
    return best
end

local function rideTreadmill(seconds)
    if not S.tread then return end
    S.status = "treadmill"
    local pos = S.tread.Position + Vector3.new(0, 4, 0)
    M.goTo(pos, 5)
    local t0 = os.clock()
    while S.alive and os.clock() - t0 < seconds do
        local _, hrp = U.char()
        if hrp and (hrp.Position - pos).Magnitude > 8 then M.goTo(pos, 4) end
        task.wait(0.5)
    end
    S.lastTread = S.loops
end

-- A new account with WalkSpeed 16 exactly matches the Forest guard -> cannot outrun it and may be caught/killed
-- increase Speed until faster than the first area guard then go steal eggs
-- (WalkSpeed grows very slowly compared with the Speed stat ~ Speed^0.165 but rises quickly at first
--  Speed 10 -> WalkSpeed 16, Speed ~23 -> WalkSpeed ~18 (only a few seconds on the treadmill are needed)
local function tooSlowToSteal()
    if not CFG.RespectGuardSpeed then return false end
    return U.walkSpeed() < A.easiestGuard() * CFG.MinSpeedToSteal
end

local function treadmillIfNeeded()
    if not CFG.RideTreadmill or not S.tread then return end
    local target = U.parseAmount(CFG.SpeedTarget)
    if target > 0 and speedStat() >= target then return end

    local need = nextAreaNeed()
    local due = CFG.TreadmillEvery > 0 and (S.loops - S.lastTread) >= CFG.TreadmillEvery
    if need or due then
        rideTreadmill(CFG.TreadmillSeconds)
    end
end

--=====================================================================
--  EVENT WIRING  (egg-carry status / area reset cycle)
--=====================================================================
local function wireEvents()
    local net = ReplicatedStorage:FindFirstChild("Network")
    if not net then return end

    local carry = net:FindFirstChild("Eggs: AreaEggCarryState")
    if carry then
        track(carry.OnClientEvent:Connect(function(state)
            if type(state) == "table" and state.IsCarrying then
                S.carrying = state
                S.carryMul = state.SpeedMultiplier or 1
            else
                S.carrying = nil
                S.carryMul = 1
            end
        end))
    end

    local removed = net:FindFirstChild("Eggs: AreaEggRemoved")
    if removed then
        track(removed.OnClientEvent:Connect(function()
            promptCache.at = 0
        end))
    end

    local countdown = net:FindFirstChild("Eggs: AreaEggResetStartCountdown")
    if countdown then
        track(countdown.OnClientEvent:Connect(function(info)
            if not CFG.HandleReset then return end
            local secs = 3
            if type(info) == "table" then
                secs = tonumber(info.Seconds or info.Duration or info.Countdown) or 3
            elseif type(info) == "number" then
                secs = info
            end
            S.resetting = true
            S.resetUntil = os.clock() + secs + CFG.ResetHoldFor
            log("area reset incoming - retreating home")
        end))
    end

    -- character respawned -> reset carrying status
    track(LP.CharacterAdded:Connect(function()
        S.carrying = nil
        S.carryMul = 1
        task.wait(1.5)
        pcall(resolvePlot)
    end))
end

-- during the area reset: return to base and wait for eggs to respawn
local function handleReset()
    if not S.resetting then return false end
    S.status = "area reset - holding"
    M.goHome()
    while S.alive and os.clock() < S.resetUntil do task.wait(0.5) end

    -- wait until an egg with Slot status appears again
    local t0 = os.clock()
    while S.alive and os.clock() - t0 < CFG.ResetWaitMax do
        local n = 0
        for _, rec in pairs(A.snapshot()) do
            if rec.State == "Slot" then n = n + 1 end
        end
        if n >= 5 then break end
        task.wait(2)
    end
    S.resetting = false
    promptCache.at = 0
    log("area reset done - resuming")
    return true
end

--=====================================================================
--  UI  (status panel in the screen corner)
--=====================================================================
local function buildUI()
    if not CFG.ShowUI then return end
    -- remove the old panel first to prevent duplicate GUIs when the script is run again
    pcall(function()
        for _, g in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if g.Name == "EggFarmStatus" then g:Destroy() end
        end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui")
        if pg then
            for _, g in ipairs(pg:GetChildren()) do
                if g.Name == "EggFarmStatus" then g:Destroy() end
            end
        end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "EggFarmStatus"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

    -- place in the center of the screen (position can be adjusted with CFG.UIPosX / UIPosY  0.5 = center)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, CFG.UIButtons and 194 or 158)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(CFG.UIPosX or 0.5, 0, CFG.UIPosY or 0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, CFG.UIButtons and -50 or -16)
    label.Position = UDim2.new(0, 8, 0, 8)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.TextSize = CFG.StatusTextSize
    label.TextColor3 = Color3.fromRGB(235, 235, 245)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Text = "Egg Farm starting..."
    label.Parent = frame

    -- ===== Buttons: click to run; no console commands needed =====
    local btnPause, btnMode
    if CFG.UIButtons then
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -16, 0, 30)
        row.Position = UDim2.new(0, 8, 1, -38)
        row.BackgroundTransparency = 1
        row.Parent = frame

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.Padding = UDim.new(0, 6)
        layout.Parent = row

        local function mkBtn(text, w, color, fn)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(w, -4, 1, 0)
            b.BackgroundColor3 = color
            b.BorderSizePixel = 0
            b.AutoButtonColor = true
            b.Font = Enum.Font.GothamBold
            b.TextSize = 13
            b.TextColor3 = Color3.fromRGB(245, 245, 250)
            b.Text = text
            b.Parent = row
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            track(b.MouseButton1Click:Connect(function() pcall(fn, b) end))
            return b
        end

        btnPause = mkBtn(S.paused and "START" or "PAUSE", 0.34, Color3.fromRGB(38, 110, 62), function(b)
            S.paused = not S.paused
            b.Text = S.paused and "START" or "PAUSE"
            b.BackgroundColor3 = S.paused and Color3.fromRGB(38, 110, 62) or Color3.fromRGB(126, 96, 24)
            log(S.paused and "paused" or "resumed")
        end)

        btnMode = mkBtn("MODE: " .. tostring(CFG.MoveMode), 0.42, Color3.fromRGB(40, 62, 120), function(b)
            local order = { "humtween", "walk", "tween" }
            local i = 1
            for n, m in ipairs(order) do if m == CFG.MoveMode then i = n break end end
            CFG.MoveMode = order[(i % #order) + 1]
            pcall(function() M.humRestore() end)
            b.Text = "MODE: " .. CFG.MoveMode
            log("move mode ->", CFG.MoveMode)
        end)

        mkBtn("STOP", 0.24, Color3.fromRGB(130, 40, 44), function()
            _G.EggStop()
        end)
    end

    -- ===== drag the panel to move it =====
    if CFG.UIDraggable then
        local UIS = game:GetService("UserInputService")
        local dragging, dragStart, startPos
        track(frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging, dragStart, startPos = true, input.Position, frame.Position
            end
        end))
        track(UIS.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement
                and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local d = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end))
        track(UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
    end

    S.ui = { gui = gui, frame = frame, label = label, btnPause = btnPause, btnMode = btnMode }
end

local function updateUI()
    if not S.ui then return end
    local mins = (os.clock() - S.startClock) / 60
    local ls = LP:FindFirstChild("leaderstats")
    local mps = ls and ls:FindFirstChild("Money/s")
    S.ui.label.Text = table.concat({
        (S.paused and "[PAUSED] " or "[RUN] ") .. S.status,
        string.format("stolen %d   hatched %d   sold %d", S.stolen, S.hatched, S.sold),
        string.format("placed %d   failed %d   upg %d", S.placed, S.failed, S.upgrades),
        string.format("speed %s   walk %.0f", U.short(speedStat()), U.walkSpeed()),
        string.format("$/s %s   cash %s",
            U.short(U.parseAmount(tostring(mps and mps.Value or 0):gsub("%$", ""))), U.short(B.cash())),
        string.format("mode %s%s   uptime %.1f min",
            tostring(CFG.MoveMode), S.humLocked and "*" or "", mins),
        "F2 pause  F3 mode  F4 hide",
    }, "\n")

    -- buttons may be triggered by hotkeys or other code keep the button text synchronized with the actual state
    if S.ui.btnPause then
        S.ui.btnPause.Text = S.paused and "START" or "PAUSE"
        S.ui.btnPause.BackgroundColor3 = S.paused
            and Color3.fromRGB(38, 110, 62) or Color3.fromRGB(126, 96, 24)
    end
    if S.ui.btnMode then S.ui.btnMode.Text = "MODE: " .. tostring(CFG.MoveMode) end
end

--=====================================================================
--  QoL  (anti-afk / perf / hotkey)
--=====================================================================
-- Anti-kick: intercept :Kick() calls made on the client only
-- **Cannot stop server-side kicks (e.g. BAC-2513 / Error 267)**
-- the real solution is MoveMode = "walk" to avoid being detected by the server in the first place
local function installAntiKick()
    if not CFG.AntiKick then return end
    local g = getgenv()
    if g.__egg_antikick then return end
    local ok = pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local m = getnamecallmethod()
            if m == "Kick" and typeof(self) == "Instance" and self:IsA("Player") then
                warn("[Egg] blocked client-side Kick: " .. tostring((...)):sub(1, 60))
                return nil
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
    g.__egg_antikick = ok
    log("anti-kick", ok and "installed (client-side only)" or "FAILED")
end

local function setupQoL()
    installAntiKick()

    if CFG.AntiAFK then
        local ok, vu = pcall(function() return game:GetService("VirtualUser") end)
        if ok and vu then
            track(LP.Idled:Connect(function()
                pcall(function()
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new(0, 0))
                end)
            end))
        end
    end

    if CFG.FpsBoost then pcall(function() setfpscap(CFG.FpsCap) end) end

    if CFG.PerfMode then
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 1e6
            for _, d in ipairs(Lighting:GetChildren()) do
                if d:IsA("PostEffect") then d.Enabled = false end
            end
        end)
    end

    local UIS = game:GetService("UserInputService")
    track(UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.F2 then
            S.paused = not S.paused
            log(S.paused and "paused" or "resumed")
        elseif input.KeyCode == Enum.KeyCode.F3 then
            _G.EggMode()
        elseif input.KeyCode == Enum.KeyCode.F4 then
            if S.ui and S.ui.frame then S.ui.frame.Visible = not S.ui.frame.Visible end
        end
    end))
end

--=====================================================================
--  SAFETY  (Death prevention - this game does not respawn you after death; leave and rejoin)
--=====================================================================
local function guardCharacter(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    pcall(function()
        -- disable states that cause fall damage
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end)
end

local function isDead()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health <= 0
end

-- attempt to respawn: send the reset remote and wait for CharacterAdded
local function reviveIfDead()
    if not isDead() then return true end

    -- died while using humtween = too aggressive; reduce speed automatically to avoid dying again
    if CFG.MoveMode == "humtween" then
        pcall(function() M.humRestore() end)
        if (tonumber(CFG.HumTweenSpeed) or 0) > 0 then
            -- fixed speed -> halve it below 120, stop using fixed speed
            CFG.HumTweenSpeed = math.floor(CFG.HumTweenSpeed / 2)
            if CFG.HumTweenSpeed < 120 then CFG.HumTweenSpeed = 0 end
            warn(("[Egg] Died during humtween - reducing HumTweenSpeed to %d (0 = tied to WalkSpeed)")
                :format(CFG.HumTweenSpeed))
        elseif (CFG.HumTweenSpeedMul or 2) > 1 then
            CFG.HumTweenSpeedMul = math.max(1, (CFG.HumTweenSpeedMul or 2) - 0.5)
            warn(("[Egg] Died during humtween - reducing HumTweenSpeedMul to %.1f")
                :format(CFG.HumTweenSpeedMul))
        else
            CFG.MoveMode = M.fallbackMode()
            warn("[Egg] died even with humtween at 1x - switch permanently to mode " .. CFG.MoveMode .. " permanently")
        end
    elseif CFG.MoveMode == "tween" then
        if (CFG.TweenSpeedMul or 1) > 1 then
            CFG.TweenSpeedMul = math.max(1, (CFG.TweenSpeedMul or 1) - 0.5)
            warn(("[Egg] Died during tween - reducing TweenSpeedMul to %.1f"):format(CFG.TweenSpeedMul))
        else
            CFG.MoveMode = "walk"
            warn("[Egg] Died even with tween at 1x - permanently switching to walk mode")
        end
    end
    pcall(function() M.unlock() end)

    S.status = "dead - trying to respawn"
    warn("[Egg] character died - requesting respawn (if it does not respawn within 30 seconds, leave and rejoin)")
    -- v447: RE/RigSync/AskRigWipe does not mean "request respawn"
    -- the game fires it from Humanoid.Died to notify that the character died and includes the character Model
    -- Spamming it will not help respawn and may look suspicious to the server -> do not fire it
    -- in this game, after death you must leave and rejoin  only wait in case CharacterAutoLoads works
    local t0 = os.clock()
    while S.alive and os.clock() - t0 < 30 do
        task.wait(0.5)
        if not isDead() then
            guardCharacter(LP.Character)
            log("respawned")
            return true
        end
    end
    warn("[Egg] did not respawn - you must leave and rejoin manually")
    return false
end

--=====================================================================
--  MAIN LOOP
--=====================================================================
local function tendBase()
    S.status = "base work"
    M.goHome()
    B.placeEggs()
    B.hatchReady()
    B.equipAndSell()
    B.upgrade()
end

local function cycle()
    S.loops = S.loops + 1

    if handleReset() then return end

    -- 1) First check whether eggs are available to collect <<< prioritize collecting eggs first
    local pets = B.myPets()
    local ownedBest = pets[1] and pets[1].mps or 0
    local list = A.candidates(ownedBest)

    -- no eggs are available in accessible areas
    if #list == 0 then
        -- if too slow to access better areas then increase Speed
        -- (the easiest area is always accessible if this point is reached, eggs there are gone or already collected)
        if CFG.CollectFirst and tooSlowToSteal() then
            S.status = string.format("waiting for eggs / too slow (walk %.0f) - train", U.walkSpeed())
        else
            S.status = "no eggs available - waiting"
        end
        tendBase()
        if CFG.RideTreadmill and S.tread and tooSlowToSteal() then
            rideTreadmill(CFG.TreadmillSeconds)
        else
            task.wait(3)
        end
        return
    end

    if CFG.Verbose then
        local top = {}
        for i = 1, math.min(3, #list) do
            top[#top + 1] = string.format("%s %s/s", list[i].rec.AssetCategory, U.short(list[i].value))
        end
        log(("%d eggs worth taking | best: %s"):format(#list, table.concat(top, " > ")))
    end

    -- collect one egg at a time and refresh the list each time
    -- (eggs in the old list may have been taken by someone else - to avoid making an unnecessary trip)
    local grabbed, tried = 0, {}
    while grabbed < math.max(1, CFG.ChainGrab) do
        if not S.alive or S.paused or S.resetting then break end

        local cand
        for _, c in ipairs(list) do
            if not tried[c.rec.Uid] then cand = c break end
        end
        if not cand then break end
        tried[cand.rec.Uid] = true

        if stealEgg(cand) then
            if carryHome() then
                grabbed = grabbed + 1
            else
                log("claim timed out - dropping to base work")
                break
            end
        end

        if grabbed < math.max(1, CFG.ChainGrab) then
            list = A.candidates(ownedBest)
            if #list == 0 then break end
        end
        task.wait(0.1)
    end

    -- 2) Base tasks
    if grabbed > 0 or (S.loops % math.max(1, CFG.TendEvery) == 0) then
        tendBase()
    end

    -- 3) increase Speed
    treadmillIfNeeded()

    task.wait(CFG.LoopDelay)
end

--=====================================================================
--  BOOT
--=====================================================================
function _G.EggStop()
    S.alive = false
    _G.__EGG_RUNNING = false
    pcall(function() M.humRestore() end)        -- restore actual WalkSpeed, or the player cannot move
    pcall(function() M.releaseControls() end)   -- restore control to the player
    pcall(function() M.unlock() end)            -- never leave the character anchored
    for _, c in ipairs(S.conns) do pcall(function() c:Disconnect() end) end
    S.conns = {}
    if S.ui and S.ui.gui then pcall(function() S.ui.gui:Destroy() end) end
    print("[Egg] stopped")
end

function _G.EggPause(v)
    if v == nil then S.paused = not S.paused else S.paused = v and true or false end
    return S.paused
end

-- start/resume  (START button on the panel calls this)
function _G.EggStart()
    S.paused = false
    return true
end

-- Toggle movement mode; if no value is provided, cycle to the next mode; provide a name to set it directly
function _G.EggMode(mode)
    local order = { "humtween", "walk", "tween" }
    if mode then
        local want = tostring(mode):lower()
        -- Invalid mode name silently falls back to humtween in goTo, which is not what the user intended
        if want ~= "humtween" and want ~= "walk" and want ~= "tween" and want ~= "warp" then
            warn('[Egg] Unknown mode "' .. want .. '" - Available modes: humtween / walk / tween / warp')
            return CFG.MoveMode
        end
        CFG.MoveMode = want
    else
        local i = 1
        for n, m in ipairs(order) do if m == CFG.MoveMode then i = n break end end
        CFG.MoveMode = order[(i % #order) + 1]
    end
    pcall(function() M.humRestore() end)
    log("move mode ->", CFG.MoveMode)
    return CFG.MoveMode
end

-- edit config live while running  e.g. _G.EggSet{ ChainGrab = 8, HumTweenSpeed = 450 }
function _G.EggSet(tbl)
    for k, v in pairs(tbl or {}) do CFG[k] = v end
    return CFG
end

-- Move the character to the desired point using the same mover as the farming routine (for testing/manual use)
function _G.EggGoTo(pos, tol)
    if typeof(pos) == "CFrame" then pos = pos.Position end
    return M.goTo(pos, tol or 5)
end

-- immediately restore character state (if the script gets stuck and movement stops working)
function _G.EggRelease()
    pcall(function() M.humRestore() end)
    pcall(function() M.unlock() end)
    pcall(function() M.releaseControls() end)
    return true
end

local function boot()
    repeat task.wait() until game:IsLoaded()
    task.wait(1)

    buildUI()
    setupQoL()
    wireEvents()

    guardCharacter(LP.Character)
    track(LP.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        guardCharacter(c)
    end))

    -- wait until your own plot is found (the slot number changes after a server transfer)
    local t0 = os.clock()
    while S.alive and not resolvePlot() and os.clock() - t0 < 45 do
        S.status = "waiting for plot"
        updateUI()
        task.wait(1)
    end
    if not S.plot then
        warn("[Egg] Could not find your own plot - stopping")
        _G.EggStop()
        return
    end
    log("plot", S.plot.Name, "| pen", tostring(S.pen and S.pen.Position))

    B.claimOffline()

    -- clean up leftovers from the previous session
    tendBase()

    -- restart itself after a server transfer
    if CFG.SurviveTeleport and CFG.SourceUrl then
        pcall(function()
            queue_on_teleport(([[
                _G.EggConfig = game:GetService("HttpService"):JSONDecode(%q)
                loadstring(game:HttpGet(%q))()
            ]]):format(game:GetService("HttpService"):JSONEncode({
                Area = CFG.Area, ChainGrab = CFG.ChainGrab, KeepAbove = tostring(CFG.KeepAbove),
                MinEggRate = tostring(CFG.MinEggRate), AutoSell = CFG.AutoSell, AutoHatch = CFG.AutoHatch,
            }), CFG.SourceUrl))
        end)
    end

    -- UI loop
    spawnLoop(function()
        updateUI()
        task.wait(0.35)
    end)

    -- main loop
    spawnLoop(function()
        if S.paused then
            S.status = "paused"
            task.wait(0.5)
            return
        end
        if isDead() then
            if not reviveIfDead() then
                S.status = "dead - rejoin needed"
                task.wait(5)
            end
            return
        end
        if not U.char() then
            S.status = "waiting for character"
            task.wait(1)
            return
        end
        if not S.plot or not S.plot.Parent then
            resolvePlot()
            task.wait(1)
            return
        end
        cycle()
    end)

    log(("started | preset %s | mode %s | F2 pause  F3 mode  F4 hide")
        :format(tostring(CFG.Preset), tostring(CFG.MoveMode)))
    log("commands: _G.EggStart() _G.EggPause() _G.EggMode() _G.EggSet{} _G.EggRelease() _G.EggStop()")
end

task.spawn(boot)
