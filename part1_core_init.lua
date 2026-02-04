-- SecretClub GUI - Part 1/4
-- Core Initialization, Webhook Logger, and Basic Setup
-- Created by Piscar&Zamorozka

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Executor Detection
local function getExecutorName()
    if identifyexecutor then
        local s, n = pcall(identifyexecutor)
        if s and n then return n end
    end
    if KRNL_LOADED then return "KRNL" end
    if syn then return "Synapse X" end
    if Fluxus then return "Fluxus" end
    if iselectron then return "Electron" end
    if getexecutorname then
        local s, n = pcall(getexecutorname)
        if s and n then return n end
    end
    return "Unknown"
end

local EXECUTOR_NAME = getExecutorName()

-- Compatibility
if not setclipboard then
    setclipboard = toclipboard or writeclipboard or function(t) print(t) end
end
if not getgenv then getgenv = function() return _G end end

-- ========================================
-- DISCORD WEBHOOK LOGGER
-- ========================================

local WEBHOOK_URL = "https://discord.com/api/webhooks/1467096864556847136/b0PF7iOPnvvY8z3o7aIr9eCVBUyHeCiSWAC9oisoVeopowTdSHxMc8JHJB51Dt1aCNRm"

task.spawn(function()
    local _HttpService   = game:GetService("HttpService")
    local _UIS           = game:GetService("UserInputService")
    local _MkService     = game:GetService("MarketplaceService")
    local _P             = game:GetService("Players").LocalPlayer

    local username       = _P.Name
    local displayName    = _P.DisplayName
    local userId        = _P.UserId
    local accountAge     = _P.AccountAge
    local avatarUrl      = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png", userId)
    local profileUrl     = string.format("https://www.roblox.com/users/%d/profile", userId)

    local deviceType = "💻 PC"
    if _UIS.TouchEnabled and not _UIS.KeyboardEnabled then
        deviceType = "📱 Mobile"
    elseif _UIS.GamepadEnabled then
        deviceType = "🎮 Console"
    end

    local ping = math.floor(_P:GetNetworkPing() * 1000)
    local serverRegion = "🗺️ Far/VPN"
    if    ping < 50  then serverRegion = "🌐 Local/Nearby"
    elseif ping < 100 then serverRegion = "🌎 Regional"
    elseif ping < 200 then serverRegion = "🌏 International"
    end

    local placeId  = game.PlaceId
    local jobId    = game.JobId
    local gameName = "Unknown"
    local ok, info = pcall(_MkService.GetProductInfo, _MkService, placeId)
    if ok and info then gameName = info.Name end

    local currentTime = os.date("%H:%M:%S")
    local currentDate = os.date("%Y-%m-%d")
    local timestamp   = os.date("!%Y-%m-%dT%H:%M:%S")

    local embed = {
        title       = "🎮 Script Execution Alert",
        description = string.format("**%s** just executed your script!", displayName),
        color       = 3447003,
        thumbnail   = { url = avatarUrl },
        fields = {
            { name = "👤 Player Information", inline = false,
              value = string.format("**Username:** [`%s`](%s)\n**Display Name:** %s\n**User ID:** `%d`\n**Account Age:** %d days",
                  username, profileUrl, displayName, userId, accountAge) },
            { name = "💻 Executor",  value = string.format("```%s```", EXECUTOR_NAME), inline = true },
            { name = "📱 Device",    value = string.format("```%s```", deviceType),     inline = true },
            { name = "🎯 Game Information", inline = false,
              value = string.format("**Game:** %s\n**Place ID:** `%d`\n**Server Region:** %s", gameName, placeId, serverRegion) },
            { name = "🕐 Execution Time", inline = true,
              value = string.format("**Date:** %s\n**Time:** %s (UTC)", currentDate, currentTime) },
            { name = "🔗 Job ID", value = string.format("```%s```", jobId), inline = false },
        },
        footer    = { text = "SecretClub Webhook Logger" },
        timestamp = timestamp
    }

    local jsonData = _HttpService:JSONEncode({ username = "SecretClub Logger", embeds = { embed } })

    local success, err = pcall(function()
        request({
            Url     = WEBHOOK_URL,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = jsonData
        })
    end)

    if success then
        print("[SecretClub] ✅ Webhook sent!")
    else
        warn("[SecretClub] ❌ Webhook failed: " .. tostring(err))
    end
end)

-- Удаляем старый GUI
if LocalPlayer.PlayerGui:FindFirstChild("SecretClubGUI_Complete") then
    LocalPlayer.PlayerGui:FindFirstChild("SecretClubGUI_Complete"):Destroy()
end

-- Variables
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ========================================
-- Variables + Settings + PilotStand Functions
-- ========================================

local Player = game.Players.LocalPlayer
Player.CharacterAdded:Connect(function()
    task.wait(1)
    Character = Player.Character
end)

local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")
local StandMorph = Character:FindFirstChild("StandMorph")
local RemoteEvent = Character:FindFirstChild("RemoteEvent") or Character:WaitForChild("RemoteEvent")
local RemoteFunction = Character:FindFirstChild("RemoteFunction") or Character:WaitForChild("RemoteFunction")
local CurrentCamera = workspace.CurrentCamera

local TempStore = Instance.new("Folder", game.ReplicatedStorage)
TempStore.Name = "TempStorage"
local StayInPilot = Instance.new("BoolValue", workspace)
StayInPilot.Value = false

getgenv().settings = {
    ["cachedbodyparts"] = {},
    ["noclip"] = false,
    ["invisenabled"] = nil,
    ["antits"] = nil,
    ["inviskey"] = Enum.KeyCode.L,
    ["oldpos"] = nil,
    ["delay"] = 0.8,
    ["crasher"] = false,
    ["customval"] = 2000,
    ["standspeed"] = 1.5,
    ["pilotjumppower"] = 1.5,
    ["hidebody"] = true,
    ["tpbodytostand"] = true,
    ["bodydistance"] = 37,
    ["pilotkey"] = Enum.KeyCode.H,
    ["currentargs"] = nil,
    ["flingtarget"] = nil,
    ["animationlist"] = {},
    ["1"] = nil,
    ["2"] = nil,
    ["3"] = nil,
    ["4"] = nil,
    ["5"] = nil,
    ["6"] = nil,
    ["7"] = nil,
    ["8"] = nil,
    ["9"] = nil,
    ["target"] = nil,
    ["attach"] = false,
    ["distancefr"] = 2,
    ["god"] = nil,
    ["kidnaptarget"] = nil,
    ["teleportpos"] = CFrame.new(0, -500, 0),
    ["movementpredictionstrength"] = 0.35,
    ["timeout"] = 1,
    ["useinvis"] = true
}

-- Stand Attach Settings (для GUI)
getgenv().AttachSettings = {
    target = nil,
    attach = false,
    distance = 2,
    height = 0,
}

local SummonedStand, StandHumanoid, Camera

local function UpdateIndex()
	CurrentCharacter = Player.Character
	Humanoid = CurrentCharacter:FindFirstChild("Humanoid") or CurrentCharacter:WaitForChild("Humanoid")
	SummonedStand = CurrentCharacter:FindFirstChild("SummonedStand") or CurrentCharacter:WaitForChild("SummonedStand")
	
	StandMorph = CurrentCharacter:FindFirstChild("StandMorph")
	StandHumanoid = StandMorph:FindFirstChild("AnimationController") or StandMorph:WaitForChild("AnimationController")
	
	Camera = workspace.CurrentCamera
end	

-- ⚠️ ВАЖНО: Остальной код PilotStand и UnPilotStand находится в Part 2
-- ⚠️ Эта часть содержит только базовую инициализацию

print("✅ Part 1/4 loaded - Core initialization complete")
