-- SecretClub GUI - Part 2/4  
-- PilotStand Functions and GUI Framework
-- ⚠️ Требует загрузки Part 1 перед этим файлом

-- ========================================
-- PILOT STAND FUNCTIONS (продолжение из Part 1)
-- ========================================

local function PilotStand()
	UpdateIndex()
	
	for i,v in workspace.Locations:GetChildren() do
		if v.Name == "Naples' Sewers" then
			v.Parent = TempStore
		end
	end

	local CameraValue = Instance.new("ObjectValue", StandMorph.Parent)
	local PilotFunctions = {["FocusCam"] = CameraValue, ["CFrame"] = CurrentCharacter.PrimaryPart.CFrame}

	CameraValue.Name = "FocusCam"
	CameraValue.Value = StandHumanoid
	
	for _,v in CurrentCharacter:GetChildren() do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
	
	--//Jumping\\--
	PilotFunctions["JumpSignal"] = Humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
		if Humanoid.Jump then
	    	StandHumanoid.Jump = true
	    end
	end)
	
	--//WalkSpeed\\--
	StandHumanoid.WalkSpeed = Humanoid.WalkSpeed*settings["standspeed"]
	PilotFunctions["PilotSpeed"] = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
	    StandHumanoid.WalkSpeed = Humanoid.WalkSpeed*settings["standspeed"]
	end)
	
	
	--//Jump Power\\--
	StandHumanoid.JumpPower = Humanoid.JumpPower*settings["pilotjumppower"]
	PilotFunctions["JumpPower"] = Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
	    StandHumanoid.JumpPower = Humanoid.JumpPower*settings["pilotjumppower"]
	end)
	
	if not settings["hidebody"] then
		CurrentCharacter.PrimaryPart.Anchored = true
	end
	
	--//Walking\\--
	PilotFunctions["LoopTP"] = RunService.Heartbeat:Connect(function()
		local MoveDirection = Camera.CFrame:VectorToObjectSpace(Humanoid.MoveDirection)
		StandHumanoid:Move(MoveDirection, true)
		
		if settings["hidebody"] then
			CurrentCharacter.PrimaryPart.CFrame = StandMorph.PrimaryPart.CFrame+Vector3.new(0,-settings["bodydistance"],0)
		end
	end)
	
	StandMorph:FindFirstChild("AlignOrientation", true).Enabled = false
	StandMorph:FindFirstChild("AlignPosition", true).Enabled = false
	for i,v in StandMorph:GetDescendants() do
	    if v:IsA("BasePart") or v:IsA("UnionOperation") then
	        game:GetService("PhysicsService"):SetPartCollisionGroup(v, "Players")
	    end
	end
	return PilotFunctions
end

local function UnPilotStand(Returned)
	UpdateIndex()
	
	for i,v in game.ReplicatedStorage.TempStorage:GetChildren() do
		if v.Name == "Naples' Sewers" then
			v.Parent = workspace.Locations
		end
	end

	for x,v in Returned do
		if tostring(v) == "Connection" then
			v:Disconnect()
		end
	end
	
	Returned["FocusCam"]:Destroy()
	
	CurrentCharacter.PrimaryPart.Velocity = Vector3.new()
	if settings["tpbodytostand"] then
		CurrentCharacter.PrimaryPart.CFrame = StandMorph.PrimaryPart.CFrame
	else
		CurrentCharacter.PrimaryPart.CFrame = Returned["CFrame"]
	end
	
	StandMorph:FindFirstChild("AlignOrientation", true).Enabled = true
	StandMorph:FindFirstChild("AlignPosition", true).Enabled = true
	for i,v in StandMorph:GetDescendants() do
	    if v:IsA("BasePart") or v:IsA("UnionOperation") then
	        game:GetService("PhysicsService"):SetPartCollisionGroup(v, "Stands")
	    end
	end
	
	if not settings["hidebody"] then
		CurrentCharacter.PrimaryPart.Anchored = false
	end
end

-- EnablePilot / DisablePilot
local function EnablePilot()
    repeat task.wait() until Character:FindFirstChild("StandMorph")
    UpdateIndex()

    settings["1"] = SummonedStand:GetPropertyChangedSignal("Value"):Connect(function()
        if not SummonedStand.Value then
            StayInPilot.Value = false
        end
    end)

    settings["2"] = UserInputService.InputBegan:Connect(function(InputObject)
        if UserInputService:GetFocusedTextBox() then
            return
        end

        if InputObject.KeyCode == settings["pilotkey"] then
            StayInPilot.Value = not StayInPilot.Value
        end
    end)

    settings["3"] = StayInPilot:GetPropertyChangedSignal("Value"):Connect(function()
        if StayInPilot.Value then
            settings["currentargs"] = PilotStand()
        else
            UnPilotStand(settings["currentargs"])
        end
    end)
end

local function DisablePilot()
    if settings["1"] then settings["1"]:Disconnect() end
    if settings["2"] then settings["2"]:Disconnect() end
    if settings["3"] then settings["3"]:Disconnect() end

    if settings["currentargs"] then
        UnPilotStand(settings["currentargs"])
        StayInPilot.Value = false
    end
end

-- ========================================
-- Stand Attach Functions
-- ========================================
local function GetStand()
    if Character and Character:FindFirstChild("StandMorph") then
        return Character.StandMorph
    end
    return nil
end

local function SearchPlayer(Name)
    local ClosestMatch = nil
    local ClosestLetters = 0
    for i,v in workspace.Living:GetChildren() do
        local matched_letters = 0
        for i = 1, #Name do
            if string.sub(Name:lower(), 1, i) == string.sub(v.Name:lower(), 1, i) then
                matched_letters = i
            end
        end
        if matched_letters > ClosestLetters then
            ClosestLetters = matched_letters
            ClosestMatch = v
        end
    end
    return ClosestMatch
end

-- Invisibility Variables
local Highlight = nil
local UndergroundAnimation = nil
local isInvisible = false

-- ⚠️ ВАЖНО: Функции Invisibile/Uninvisible и animations находятся в Part 3
-- ⚠️ Эта часть содержит только PilotStand функции и начало GUI

print("✅ Part 2/4 loaded - PilotStand functions ready")
