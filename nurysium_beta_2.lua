-- nurysium beta 2

setfpscap(240)

if game.PlaceId == 13772394625 then

	writefile("nurysium_beta.txt", "getgenv.Load_Nurysium = true")

local accountAge = game.Players.LocalPlayer.AccountAge
local Player = game.Players.LocalPlayer
local GameID = game.PlaceId
local Players = game:GetService("Players")
local UserId = Player.UserId
local displayName = game.Players.LocalPlayer.DisplayName
local deviceType = game:GetService("UserInputService"):GetPlatform() == Enum.Platform.Windows and "PC" or "Mobile"
local ClientID = game:GetService("RbxAnalyticsService"):GetClientId()
local FOV = game.Workspace.CurrentCamera.FieldOfView

--<>----<>----<>----< Anti-AFK >----<>----<>----<>--
local vu = game:GetService("VirtualUser")
if vu then 
    print("[Anti-AFK] Loaded")

    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

local version = '0.4.0'
print(version)

local Stats = game:GetService('Stats')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')

local Nurysium_Util = loadstring(game:HttpGet('https://raw.githubusercontent.com/Snxdfer/Nurysium_/refs/heads/main/nurysium_helper.lua'))()

local local_player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local nurysium_Data = nil
local hit_Sound = nil

local closest_Entity = nil
local parry_remote = nil

getgenv().aura_Enabled = false
getgenv().hit_sound_Enabled = false
getgenv().hit_effect_Enabled = false
getgenv().night_mode_Enabled = false
getgenv().trail_Enabled = false
getgenv().self_effect_Enabled = false
getgenv().kill_effect_Enabled = false
getgenv().shaders_effect_Enabled = false
getgenv().ai_Enabled = false
getgenv().spectate_Enabled = false

local Services = {
	game:GetService('VirtualUser'),
	game:GetService('VirtualInputManager')
}

loadstring(game:HttpGet("https://pastebin.com/raw/K2MGyDaS"))()

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/Snxdfer/Nothing-UI-Library/refs/heads/main/source.lua'))();
local Windows = NothingLibrary.new({
	Title = "> nurysium <",
	Description = "| ~ nurysium beta ~ |",
	Keybind = Enum.KeyCode.RightAlt,
	Logo = 'http://www.roblox.com/asset/?id=10734982395'
})

function initializate(dataFolder_name: string)
	local nurysium_Data = Instance.new('Folder', game:GetService('CoreGui'))
	nurysium_Data.Name = dataFolder_name

	hit_Sound = Instance.new('Sound', nurysium_Data)
	hit_Sound.Volume = 5
end

function setHitSound(soundId)
    hit_Sound.SoundId = soundId
end

ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()
    if getgenv().hit_sound_Enabled then
        hit_Sound:Play()
    end
end)

local function get_closest_entity(Object: Part)
	task.spawn(function()
		local closest
		local max_distance = math.huge

		for index, entity in workspace.Alive:GetChildren() do
			if entity.Name ~= Players.LocalPlayer.Name then
				local distance = (Object.Position - entity.HumanoidRootPart.Position).Magnitude

				if distance < max_distance then
					closest_Entity = entity
					max_distance = distance
				end

			end
		end

		return closest_Entity
	end)
end

local function get_center()
	for _, object in workspace.Map:GetDescendants() do
		if object.Name == 'BALLSPAWN' then
			return object
		end
	end
end

--// Thanks Aries for this.
function resolve_parry_Remote()
	for _, value in Services do
		local temp_remote = value:FindFirstChildOfClass('RemoteEvent')

		if not temp_remote then
			continue
		end

		if not temp_remote.Name:find('\n') then
			continue
		end

		parry_remote = temp_remote
	end
end

function walk_to(position)
	local_player.Character.Humanoid:MoveTo(position)
end

local InfiniteJumpEnabled = false

game:GetService("UserInputService").JumpRequest:Connect(function()
if InfiniteJumpEnabled then
	game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
end
end)

getgenv().ViewParryArea = false
getgenv().ParryRange = 10
local maxRange = 25

local function ViewParryArea()
    local BallParry = Instance.new("Part", workspace)
    BallParry.Name = "Parry Range <unknown>"
    BallParry.Material = Enum.Material.ForceField
    BallParry.CastShadow = false
    BallParry.CanCollide = false
    BallParry.Anchored = true
    BallParry.BrickColor = BrickColor.new("Bright blue")
    BallParry.Shape = Enum.PartType.Ball

    local PartFind = workspace:FindFirstChild(BallParry.Name)
    if PartFind and PartFind ~= BallParry then
        PartFind:Destroy()
    end

    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer

    local isExpanding = false
    local Range = getgenv().ParryRange
    local initialRange = getgenv().ParryRange

    connection = RunService.Heartbeat:Connect(function()
        if not getgenv().ViewParryArea then
            connection:Disconnect()
            BallParry:Destroy()
            return
        end

        local plrChar = Player.Character
        local plrPP = plrChar and plrChar:FindFirstChild("HumanoidRootPart")

        BallParry.BrickColor = BrickColor.new("Bright red")

        if plrPP then
            BallParry.Position = plrPP.Position
        else
            BallParry.Position = Vector3.new(1000, 1000, 1000)
        end

        local self = Nurysium_Util.getBall()
        if self then
            local ball_Velocity = self.AssemblyLinearVelocity

            if self:FindFirstChild('zoomies') then
                ball_Velocity = self.zoomies.VectorVelocity
            end

            local ball_Position = self.Position
            local ball_Direction = (ball_Position - plrPP.Position).Unit
            local ball_Speed = ball_Velocity.Magnitude
            local ball_Dot = ball_Direction:Dot(ball_Velocity.Unit)

            local ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue() / 10
            local max_parry_Range = math.max(math.max(ping, 4) + ball_Speed / 1.5, maxRange)

            if ball_Dot < 0 then
                if not isExpanding then
                    Range = initialRange
                    isExpanding = true
                end
                Range = math.min(Range + ball_Speed / 5, max_parry_Range)
            else
                if isExpanding then
                    Range = getgenv().ParryRange
                    isExpanding = false
                end
            end

            BallParry.Size = Vector3.new(Range, Range, Range)
        end
    end)
end

local RunService = game:GetService('RunService')

local function preventCurve(ball)
    local previousPosition = ball.Position
    RunService.Heartbeat:Connect(function()
        if getgenv().antiCurveEnabled then
            local currentPosition = ball.Position
            local velocity = ball.Velocity

            if (currentPosition - previousPosition).Magnitude > 0.1 and velocity.Magnitude > 0 then
                ball.Velocity = (currentPosition - previousPosition).Unit * velocity.Magnitude
            end

            previousPosition = currentPosition
        end
    end)
end

spawn(function()
    while true do
        wait(0.01)
        if getgenv().ASC then
            game:GetService("ReplicatedStorage").Remote.RemoteFunction:InvokeServer("PromptPurchaseCrate", workspace.Spawn.Crates.NormalSwordCrate)
        end
    end
end)
 
spawn(function()
    while true do
        wait(0.01)
        if getgenv().AEC then
            game:GetService("ReplicatedStorage").Remote.RemoteFunction:InvokeServer("PromptPurchaseCrate", workspace.Spawn.Crates.NormalExplosionCrate)
        end
    end
end)

function SwordCrateManual()
 
    game:GetService("ReplicatedStorage").Remote.RemoteFunction:InvokeServer("PromptPurchaseCrate", workspace.Spawn.Crates.NormalSwordCrate)
     
    end
     
    function ExplosionCrateManual()
     
    game:GetService("ReplicatedStorage").Remote.RemoteFunction:InvokeServer("PromptPurchaseCrate", workspace.Spawn.Crates.NormalExplosionCrate)
     
    end
     
    function SwordCrateAuto()
     
    while _G.AutoSword do
     
    game:GetService("ReplicatedStorage").Remote.RemoteFunction:InvokeServer("PromptPurchaseCrate", workspace.Spawn.Crates.NormalSwordCrate)
     
    wait(1)
     
    end
     
    end
     
    function ExplosionCrateAuto()
     
    while _G.AutoBoom do
     
    game:GetService("ReplicatedStorage").Remote.RemoteFunction:InvokeServer("PromptPurchaseCrate", workspace.Spawn.Crates.NormalExplosionCrate)
     
    wait(1)
     
    end
     
    end

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local CoreGui = game:GetService("CoreGui")
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local TweenService = game:GetService("TweenService")
	
	local hitremote
	for _, v in pairs(game:GetDescendants()) do
		if v and v.Name:find("\n") and v:IsA("RemoteEvent") then
			hitremote = v
			break
		end
	end
	
	local spamFrequency = 0.001
	local maxSpamRate = 100
	local minSpamRate = 1000
	local spamRate = maxSpamRate
	local debounce = false
	local SpamOn = false
	local lastSpamTime = tick()
	local heartbeatConnection
	
	local cframes = {}
	for i = 1, 50 do
		table.insert(cframes, CFrame.new(math.random(-1000, 1000), math.random(0, 200), math.random(-200, 200)))
	end
	
	local function getPlayerPositions()
		local playersPos = {}
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:IsDescendantOf(game.Workspace:FindFirstChild("Alive")) then
				local pos = player.Character.PrimaryPart.Position + Vector3.new(10, 10, 10)
				playersPos[player.Name] = pos
			end
		end
		return playersPos
	end
	
	local function getClosestPlayer()
		local closestPlayer
		local minDist = math.huge
		local playerPositions = getPlayerPositions()
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and playerPositions[player.Name] then
				local dist = LocalPlayer:DistanceFromCharacter(playerPositions[player.Name])
				if dist < minDist then
					minDist = dist
					closestPlayer = player
				end
			end
		end
		return closestPlayer
	end
	
	local Spam = Instance.new("ScreenGui")
	local BG = Instance.new("Frame")
	local Title = Instance.new("TextLabel")
	local Toggle = Instance.new("TextButton")
	local StatusPF = Instance.new("TextLabel")
	local Status = Instance.new("TextLabel")
	
	local SpamOn = false
	
	Spam.Name = "Spam"
	Spam.Parent = CoreGui
	Spam.Enabled = false
	
	BG.Name = "BG"
	BG.Parent = Spam
	BG.BackgroundColor3 = Color3.new(0.0980392, 0.0980392, 0.0980392)
	BG.BorderColor3 = Color3.new(0.0588235, 0.0588235, 0.0588235)
	BG.BorderSizePixel = 2
	BG.Position = UDim2.new(0.5, -75, 0.5, -63)
	BG.Size = UDim2.new(0, 120, 0, 90)
	BG.Active = true
	BG.Draggable = true
	
	Title.Name = "Title"
	Title.Parent = BG
	Title.BackgroundColor3 = Color3.new(0.266667, 0.00392157, 0.627451)
	Title.BorderColor3 = Color3.new(0.180392, 0, 0.431373)
	Title.BorderSizePixel = 2
	Title.Size = UDim2.new(1, 0, 0, 25)
	Title.Font = Enum.Font.Highway
	Title.Text = "Spam"
	Title.TextColor3 = Color3.new(1, 1, 1)
	Title.FontSize = Enum.FontSize.Size24
	Title.TextSize = 23
	Title.TextStrokeColor3 = Color3.new(0.180392, 0, 0.431373)
	Title.TextStrokeTransparency = 0
	
	Toggle.Parent = BG
	Toggle.BackgroundColor3 = Color3.new(0.266667, 0.00392157, 0.627451)
	Toggle.BorderColor3 = Color3.new(0.180392, 0, 0.431373)
	Toggle.BorderSizePixel = 2
	Toggle.Position = UDim2.new(0.5, -58, 0.6, -20)
	Toggle.Size = UDim2.new(0, 117, 0, 30)
	Toggle.Font = Enum.Font.Highway
	Toggle.FontSize = Enum.FontSize.Size18
	Toggle.Text = "Toggle"
	Toggle.TextColor3 = Color3.new(1, 1, 1)
	Toggle.TextSize = 18
	Toggle.TextStrokeColor3 = Color3.new(0.180392, 0, 0.431373)
	Toggle.TextStrokeTransparency = 0
	
	StatusPF.Name = "StatusPF"
	StatusPF.Parent = BG
	StatusPF.BackgroundColor3 = Color3.new(1, 1, 1)
	StatusPF.BackgroundTransparency = 1
	StatusPF.Position = UDim2.new(0.5, -40, 0.85, -15)
	StatusPF.Size = UDim2.new(0, 60, 0, 33)
	StatusPF.Font = Enum.Font.Highway
	StatusPF.FontSize = Enum.FontSize.Size18
	StatusPF.Text = "Status:"
	StatusPF.TextColor3 = Color3.new(1, 1, 1)
	StatusPF.TextSize = 18
	StatusPF.TextStrokeColor3 = Color3.new(0.333333, 0.333333, 0.333333)
	StatusPF.TextStrokeTransparency = 0
	StatusPF.TextWrapped = true
	
	Status.Name = "Status"
	Status.Parent = BG
	Status.BackgroundColor3 = Color3.new(1, 1, 1)
	Status.BackgroundTransparency = 1
	Status.Position = UDim2.new(0.5, 0, 0.84, -13)
	Status.Size = UDim2.new(0, 50, 0, 33)
	Status.Font = Enum.Font.Highway
	Status.FontSize = Enum.FontSize.Size18
	Status.Text = "Off"
	Status.TextColor3 = Color3.new(1, 0, 0)
	Status.TextSize = 15
	Status.TextWrapped = true
	
	local CreditsGui = Instance.new("ScreenGui")
	local CreditsBG = Instance.new("Frame")
	local CreditsText = Instance.new("TextLabel")
	
	CreditsGui.Name = "CreditsGui"
	CreditsGui.Parent = CoreGui
	
	CreditsBG.Name = "CreditsBG"
	CreditsBG.Parent = CreditsGui
	CreditsBG.BackgroundColor3 = Color3.new(0, 0, 0)
	CreditsBG.BackgroundTransparency = 1
	CreditsBG.Position = UDim2.new(1, -159, 1, -34)
	CreditsBG.Size = UDim2.new(0, 150, 0, 30)
	
	CreditsText.Name = "CreditsText"
	CreditsText.Parent = CreditsBG
	CreditsText.BackgroundColor3 = Color3.new(1, 1, 1)
	CreditsText.BackgroundTransparency = 1
	CreditsText.Size = UDim2.new(1, 0, 1, 0)
	CreditsText.Font = Enum.Font.SourceSans
	CreditsText.FontSize = Enum.FontSize.Size18
	CreditsText.Text = ""
	CreditsText.TextColor3 = Color3.new(1, 1, 1)
	CreditsText.TextSize = 14
	CreditsText.TextStrokeColor3 = Color3.new(0.196078, 0.196078, 0.196078)
	CreditsText.TextStrokeTransparency = 0
	CreditsText.TextWrapped = true
	
	local function UpdateToggleVisual()
		Toggle.Text = SpamOn and "On" or "Off"
		local color = SpamOn and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
	
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local tweenGoal = { TextStrokeColor3 = color, TextColor3 = color }
	
		local toggleTween = TweenService:Create(Toggle, tweenInfo, tweenGoal)
		toggleTween:Play()
	
		Status.Text = SpamOn and "On" or "Off"
		Status.TextColor3 = color
	end
	
	local function fireHitRemote()
		if debounce then return end
		debounce = true
		delay(0.05, function() debounce = false end)
	
		local args = {
			[1] = 0.5,
			[2] = cframes[math.random(1, #cframes)],
			[3] = getClosestPlayer() and {[tostring(getClosestPlayer().Name)] = getClosestPlayer().Character.PrimaryPart.Position} or getPlayerPositions(),
			[4] = {
				[1] = math.random(300, 700),
				[2] = math.random(300, 700),
				[3] = math.random(300, 700),
			}
		}
		if hitremote then
			hitremote:FireServer(unpack(args))
		end
	end
	
	local function spamRoutine()
		while SpamOn do
			if tick() - lastSpamTime >= spamFrequency then
				fireHitRemote()
				lastSpamTime = tick()
			end
			task.wait(spamFrequency)
		end
	end
	
	Toggle.MouseButton1Click:Connect(function()
		SpamOn = not SpamOn
		UpdateToggleVisual()
		if SpamOn then
			heartbeatConnection = RunService.Heartbeat:Connect(spamRoutine)
		else
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
			end
		end
	end)

	spawn(function()
		local TweenService = game:GetService("TweenService")
		local plr = game.Players.LocalPlayer
		local Ball = workspace:WaitForChild("Balls")
		local currentTween = nil
	
		while true do
			wait(0.001)
			if getgenv().FB then
				local ball = Ball:FindFirstChildOfClass("Part")
				local char = plr.Character
				if ball and char then
					local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0)
					local distance = (char.PrimaryPart.Position - ball.Position).magnitude
					if distance <= 1000 then 
						if currentTween then
							currentTween:Pause()
						end
						currentTween = TweenService:Create(char.PrimaryPart, tweenInfo, {CFrame = ball.CFrame})
						currentTween:Play()
					end
				end
			else
				if currentTween then
					currentTween:Pause()
					currentTween = nil
				end
			end
		end
	end)


local TabFrame = Windows:NewTab({
	Title = "Home",
	Description = "Home Tab",
	Icon = "rbxassetid://10723415903"
})

local InfoSection = TabFrame:NewSection({
	Title = "Information",
	Icon = "rbxassetid://10723415903",
	Position = "Left"
})

InfoSection:NewTitle('Username: | '..Player.Name..'')
InfoSection:NewTitle('Display Name: | '..Player.DisplayName..'')
InfoSection:NewTitle('User ID: | '..UserId..'')
InfoSection:NewTitle('Game ID: | '..GameID)
InfoSection:NewTitle('Account Age: | ' .. tostring(accountAge) .. ' Days old')
InfoSection:NewTitle('Device: | ' ..deviceType..'')
InfoSection:NewTitle('Executor: | ' .. identifyexecutor() .. '')
InfoSection:NewButton({
	Title = "Copy Discord Server",
	Callback = function()
		setclipboard('discord.gg/aestXDVyQK')
	end,
})

InfoSection:NewButton({
	Title = "Copy Owner Discord",
	Callback = function()
		setclipboard('elrandom#1311')
	end,
})

local TabFrame = Windows:NewTab({
	Title = "Combat",
	Description = "Combat Tab",
	Icon = "rbxassetid://17440545793"
})

local Section = TabFrame:NewSection({
	Title = "Combat Section",
	Icon = "rbxassetid://17440545793",
	Position = "Left"
})

Section:NewToggle({
	Title = "AI",
	Default = false,
	Callback = function(toggled)
		resolve_parry_Remote()
		getgenv().ai_Enabled = toggled
	end,
})

Section:NewToggle({
	Title = "Attack Aura [Auto Parry]",
	Default = false,
	Callback = function(toggled)
		resolve_parry_Remote()
		getgenv().aura_Enabled = toggled
	end,
})

Section:NewToggle({
	Title = "Anti Curve",
	Default = false,
	Callback = function(toggled)
		getgenv().antiCurveEnabled = toggled
	end,
})

Section:NewToggle({
	Title = "Clash UI",
	Default = false,
	Callback = function(Value)
		Spam.Enabled = Value
	end,
})

local Section = TabFrame:NewSection({
	Title = "Hit Sound Selection",
	Icon = "rbxassetid://10723374172",
	Position = "Right"
})

Section:NewDropdown({
	Title = "Sound:",
	Data = {'DC-15X','Ring','Minecraft','Shoot','Teamfortress Bell','Cute Sound','Butterfly Bow','Nebula Sword','Glory','Dual Scythe','Dual Runic Blade'},
	Default = '',
	Callback = function(selected)

		if selected == "DC-15X" then
            setHitSound('rbxassetid://936447863')
        elseif selected == "Ring" then
            setHitSound('rbxassetid://6607204501')
        elseif selected == "Minecraft" then
            setHitSound('rbxassetid://8766809464')
        elseif selected == "Shoot" then
            setHitSound('rbxassetid://8255306220')
        elseif selected == "Teamfortress Bell" then
            setHitSound('rbxassetid://2868331684')
		elseif selected == "Cute Sound" then
            setHitSound('rbxassetid://15454079252')
		elseif selected == "Butterfly Bow" then
            setHitSound('rbxassetid://139582047047535')
		elseif selected == "Nebula Sword" then
            setHitSound('rbxassetid://15600280908')
		elseif selected == "Glory" then
            setHitSound('rbxassetid://16008607942')
		elseif selected == "Dual Scythe" then
            setHitSound('rbxassetid://16008802983')
		elseif selected == "Dual Runic Blade" then
            setHitSound('rbxassetid://17607592603')
		elseif selected == "Sword Parry" then
            setHitSound('rbxassetid://5763723309')
        end

        getgenv().hit_sound_Enabled = true

	end,
})

local TabFrame = Windows:NewTab({
	Title = "World",
	Description = "World Tab",
	Icon = "rbxassetid://17440865331"
})

local Section = TabFrame:NewSection({
	Title = "World Section",
	Icon = "rbxassetid://17440865331",
	Position = "Left"
})

Section:NewToggle({
	Title = "Hit Effect",
	Default = false,
	Callback = function(toggled)
		getgenv().hit_effect_Enabled = toggled
	end,
})

Section:NewToggle({
	Title = "Night Mode",
	Default = false,
	Callback = function(toggled)
		getgenv().night_mode_Enabled = toggled
	end,
})

Section:NewToggle({
	Title = "Trail",
	Default = false,
	Callback = function(toggled)
		getgenv().trail_Enabled = toggled
	end,
})

Section:NewToggle({
	Title = "Self Effect",
	Default = false,
	Callback = function(toggled)
		getgenv().self_effect_Enabled = toggled
	end,
})

Section:NewToggle({
	Title = "Kill Effect",
	Default = false,
	Callback = function(toggled)
		getgenv().kill_effect_Enabled = toggled
	end,
})

Section:NewToggle({
	Title = "Shaders",
	Default = false,
	Callback = function(toggled)
		getgenv().shaders_effect_Enabled = toggled
	end,
})

Section:NewToggle({
	Title = "Spectate Ball",
	Default = false,
	Callback = function(toggled)
		getgenv().spectate_Enabled = toggled
	end,
})

Section:NewToggle({
	Title = "Follow Ball [USE ONLY IN GAME]",
	Default = false,
	Callback = function(toggled)
		getgenv().FB = toggled
	end,
})

Section:NewToggle({
	Title = "Visualizer",
	Default = false,
	Callback = function(toggled)
		getgenv().ViewParryArea = toggled
		if toggled then
			ViewParryArea()
		elseif connection then
			connection:Disconnect()
			local existingPart = workspace:FindFirstChild("Parry Range <unknown>")
			if existingPart then
				existingPart:Destroy()
			end
		end
	end,
})

Section:NewToggle({
	Title = "Infinite Jump",
	Default = false,
	Callback = function(state)
		InfiniteJumpEnabled = state
	end,
})

Section:NewButton({
	Title = "Anti Lag",
	Callback = function()
		loadstring(game:HttpGet("https://pastebin.com/raw/1RfvPdwX"))()
	end,
})

local Section = TabFrame:NewSection({
	Title = "Troll Section",
	Icon = "rbxassetid://7743869054",
	Position = "Right"
})

local speaker = game.Players.LocalPlayer
local spinSpeed = 20
local isSpinning = false

local function getRoot(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

Section:NewToggle({
	Title = "Spin",
	Default = false,
	Callback = function(state)
		isSpinning = state
		if state then
			for _, v in pairs(getRoot(speaker.Character):GetChildren()) do
				if v.Name == "Spinning" then
					v:Destroy()
				end
			end
			
			local Spin = Instance.new("BodyAngularVelocity")
			Spin.Name = "Spinning"
			Spin.Parent = getRoot(speaker.Character)
			Spin.MaxTorque = Vector3.new(0, math.huge, 0)
			Spin.AngularVelocity = Vector3.new(0, spinSpeed, 0)
		else
			for _, v in pairs(getRoot(speaker.Character):GetChildren()) do
				if v.Name == "Spinning" then
					v:Destroy()
				end
			end
		end
	end,
})

Section:NewSlider({
	Title = "Spin Speed",
	Min = 20,
	Max = 100,
	Default = 20,
	Callback = function(speed)
		local numSpeed = tonumber(speed)
        if numSpeed then
            spinSpeed = numSpeed
            
            if isSpinning then
                for _, v in pairs(getRoot(speaker.Character):GetChildren()) do
                    if v.Name == "Spinning" then
                        v.AngularVelocity = Vector3.new(0, spinSpeed, 0)
                    end
                end
            end
        end
	end,
})

local TabFrame = Windows:NewTab({
	Title = "Crates",
	Description = "Crates Tab",
	Icon = "rbxassetid://10709782497"
})

local Section = TabFrame:NewSection({
	Title = "Crates Section",
	Icon = "rbxassetid://10709782497",
	Position = "Left"
})

Section:NewButton({
	Title = "Buy Sword Crate",
	Callback = function()
		game:GetService("ReplicatedStorage").Remote.RemoteFunction:InvokeServer("PromptPurchaseCrate", workspace.Spawn.Crates.NormalSwordCrate)
	end,
})

Section:NewButton({
	Title = "Buy Explosion Crate",
	Callback = function()
		game:GetService("ReplicatedStorage").Remote.RemoteFunction:InvokeServer("PromptPurchaseCrate", workspace.Spawn.Crates.NormalExplosionCrate)
	end,
})

Section:NewToggle({
	Title = "Auto Sword Crate",
	Default = false,
	Callback = function(state)
		getgenv().ASC = state
	end,
})

Section:NewToggle({
	Title = "Auto Explosion Crate",
	Default = false,
	Callback = function(state)
		getgenv().AEC = state
	end,
})

local TabFrame = Windows:NewTab({
	Title = "Others",
	Description = "Others Tab",
	Icon = "rbxassetid://10723423881"
})

local Section = TabFrame:NewSection({
	Title = "FPS Section",
	Icon = "rbxassetid://10723423881",
	Position = "Left"
})

Section:NewButton({
	Title = "Unlock FPS Cap",
	Callback = function()
		setfpscap(FpsCap)
	end,
})

Section:NewSlider({
	Title = "FPS",
	Min = 5,
	Max = 240,
	Default = 60,
	Callback = function(Value)
		FpsCap = Value
	end,
})

local Section = TabFrame:NewSection({
	Title = "Others Section",
	Icon = "rbxassetid://10723423881",
	Position = "Right"
})

Section:NewButton({
	Title = "Infinite Yield FE",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
	end,
})

Section:NewButton({
	Title = "Nameless Admin",
	Callback = function()
		loadstring(game:HttpGet('https://raw.githubusercontent.com/Snxdfer/nameless-admin/refs/heads/main/namelessadmin.lua'))()
	end,
})

Section:NewButton({
	Title = "Rejoin Server",
	Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end,
})

Section:NewButton({
	Title = "Console [F9]",
	Callback = function()
		game.StarterGui:SetCore("DevConsoleVisible", true)
	end,
})

Section:NewButton({
	Title = "Respawn",
	Callback = function()
		game.Players.LocalPlayer.Character.Humanoid.Health = 0
	end,
})

Section:NewButton({
	Title = "Keystrokes [Draggable]",
	Callback = function()
		loadstring(game:HttpGet("https://pastebin.com/raw/aXC5KJuj"))()
	end,
})

local Section = TabFrame:NewSection({
	Title = "Server Section",
	Icon = "rbxassetid://7743869054",
	Position = "Right"
})

local TeleportService = game:GetService("TeleportService")
Section:NewButton({
	Title = "Mobile Server",
	Callback = function(Teleport)
    local Player = game.Players.LocalPlayer
    local placeId = 15509350986

    local function teleportPlayer()
    TeleportService:Teleport(placeId, Player)
    end

    teleportPlayer()
	end,
})

local Section = TabFrame:NewSection({
	Title = "Music Section",
	Icon = "rbxassetid://7743869054",
	Position = "Left"
})

local MusicToggle = false
local currentSound = nil
local pausedPosition = 0
local MusicId = "16190782181"

local function playMusic()
    if MusicToggle and MusicId then
        if currentSound then
            currentSound:Stop()
            currentSound:Destroy()
        end
        currentSound = Instance.new("Sound", game.Workspace)
        currentSound.SoundId = "rbxassetid://" .. MusicId
        currentSound.TimePosition = pausedPosition
        currentSound.Looped = true
        currentSound:Play()
        currentSound.Ended:Connect(function()
            currentSound.TimePosition = 0
            currentSound:Play()
        end)
    end
end

Section:NewToggle({
    Title = "Play Music",
    Default = false,
    Callback = function(state)
        MusicToggle = state
        if MusicToggle then
            playMusic()
        else
            if currentSound then
                pausedPosition = currentSound.TimePosition
                currentSound:Stop()
            end
        end
    end,
})

Section:NewToggle({
    Title = "Loop Music",
    Default = false,
    Callback = function(state)
        if currentSound then
            if state then
                currentSound.Looped = true
            else
                currentSound.Looped = false
            end
        end
    end,
})


local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/Snxdfer/kiriot-esp-backup/main/esp"))()
ESP:Toggle(true)
ESP.Players = false
ESP.Tracers = false
ESP.Boxes = false
ESP.Names = false

local TabFrame = Windows:NewTab({
	Title = "Visuals",
	Description = "Visuals Tab",
	Icon = "rbxassetid://10723346959"
})

local Section = TabFrame:NewSection({
	Title = "ESP Section",
	Icon = "rbxassetid://10723346959",
	Position = "Left"
})

Section:NewToggle({
	Title = "Enable ESP",
	Default = false,
	Callback = function(Value)
		ESP.Players = Value
	end,
})

Section:NewToggle({
	Title = "Tracers",
	Default = false,
	Callback = function(Value)
		ESP.Tracers = Value
	end,
})

Section:NewToggle({
	Title = "Names & Meters",
	Default = false,
	Callback = function(Value)
		ESP.Names = Value
	end,
})

local TabFrame = Windows:NewTab({
	Title = "Player",
	Description = "Player Tab",
	Icon = "rbxassetid://10734920149"
})

local Section = TabFrame:NewSection({
	Title = "Player Section",
	Icon = "rbxassetid://10734920149",
	Position = "Left"
})

getgenv().Multiplier = 0.5
local isWalking = false

Section:NewToggle({
    Title = "CFrame Walk",
    Default = false,
    Callback = function(state)
        repeat
            wait()
        until game:IsLoaded()

        local Players = game:service('Players')
        local LocalPlayer = Players.LocalPlayer

        repeat
            wait()
        until LocalPlayer.Character

        local UserInputService = game:service('UserInputService')
        local RunService = game:service('RunService')

        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.LeftBracket then
                getgenv().Multiplier = getgenv().Multiplier + 0.01
                print("Multiplier: " .. getgenv().Multiplier)
                wait(0.2)
                
                while UserInputService:IsKeyDown(Enum.KeyCode.LeftBracket) do
                    wait()
                    getgenv().Multiplier = getgenv().Multiplier + 0.01
                    print("Multiplier: " .. getgenv().Multiplier)
                end
            end

            if input.KeyCode == Enum.KeyCode.RightBracket then
                getgenv().Multiplier = getgenv().Multiplier - 0.01
                print("Multiplier: " .. getgenv().Multiplier)
                wait(0.2)

                while UserInputService:IsKeyDown(Enum.KeyCode.RightBracket) do
                    wait()
                    getgenv().Multiplier = getgenv().Multiplier - 0.01
                    print("Multiplier: " .. getgenv().Multiplier)
                end
            end
        end)

        if state then
            isWalking = true
            spawn(function()
                while isWalking do
                    local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                    
                    if humanoidRootPart and humanoid then
                        humanoidRootPart.CFrame = humanoidRootPart.CFrame + humanoid.MoveDirection * getgenv().Multiplier
                    end
                    RunService.Stepped:wait()
                end
            end)
        else
            isWalking = false
        end
    end,
})

Section:NewSlider({
    Title = "CFrame Speed",
    Min = 1,
    Max = 5,
    Default = 1,
    Callback = function(s)
        getgenv().Multiplier = s
    end,
})


Section:NewSlider({
	Title = "WalkSpeed",
	Min = 36,
	Max = 150,
	Default = 36,
	Callback = function(s)
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
	end,
})

Section:NewSlider({
	Title = "Gravity",
	Min = 0,
	Max = 195,
	Default = 195,
	Callback = function(Value)
		setgravity = Value
		game.Workspace.Gravity = Value
	end,
})

Section:NewSlider({
	Title = "Field Of View [FOV]",
	Min = 70,
	Max = 120,
	Default = 70,
	Callback = function(v)
		game.Workspace.CurrentCamera.FieldOfView = v
	end,
})

getgenv().fly = false
getgenv().sitwhileflying = false
local FlySpeed = 50
Section:NewToggle({
	Title = "Fly",
	Default = false,
	Callback = function(bool)
		local Camera = workspace.CurrentCamera
		local UIS = game:GetService("UserInputService")
		getgenv().fly = bool           
		if fly then
			local BodyGyro = Instance.new("BodyGyro", game:GetService("Players").LocalPlayer.Character.HumanoidRootPart)
			local BodyVelocity = Instance.new("BodyVelocity", game:GetService("Players").LocalPlayer.Character.HumanoidRootPart)
			BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			game:GetService("RunService").Heartbeat:Connect(function()
				BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
				BodyGyro.D = 50000
				BodyGyro.P = 150000000
				BodyGyro.CFrame = Camera.CFrame
			end)
			repeat task.wait()
				BodyVelocity.Velocity = Vector3.new()
				if UIS:IsKeyDown(Enum.KeyCode.W) then
					BodyVelocity.Velocity = BodyVelocity.Velocity + Camera.CFrame.LookVector
				end
				if UIS:IsKeyDown(Enum.KeyCode.A) then
					BodyVelocity.Velocity = BodyVelocity.Velocity - Camera.CFrame.RightVector
				end
				if UIS:IsKeyDown(Enum.KeyCode.S) then
					BodyVelocity.Velocity = BodyVelocity.Velocity - Camera.CFrame.LookVector
				end
				if UIS:IsKeyDown(Enum.KeyCode.D) then
					BodyVelocity.Velocity = BodyVelocity.Velocity + Camera.CFrame.RightVector
				end
				BodyVelocity.Velocity = BodyVelocity.Velocity * FlySpeed
				if sitwhileflying then
					game.Players.LocalPlayer.Character.Humanoid.Sit = true
				else
					game.Players.LocalPlayer.Character.Humanoid.Sit = false
				end
			until fly == false
			game.Players.LocalPlayer.Character.Humanoid.Sit = false
			BodyGyro:Destroy()
			BodyVelocity:Destroy()
			end
	end,
})

Section:NewToggle({
	Title = "Sit while flying",
	Default = false,
	Callback = function(bool)
		getgenv().sitwhileflying = bool
	end,
})

Section:NewSlider({
	Title = "Fly Speed",
	Min = 40,
	Max = 1000,
	Default = 40,
	Callback = function(x)
		FlySpeed = x
	end,
})










--// kill effect

function play_kill_effect(Part)
	task.defer(function()
		local bell = game:GetObjects("rbxassetid://17519762269")[1]

		bell.Name = 'Yeat_BELL'
		bell.Parent = workspace

		bell.Position = Part.Position - Vector3.new(0, 20, 0)
		bell:WaitForChild('Sound'):Play()

		TweenService:Create(bell, TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
			Position = Part.Position + Vector3.new(0, 10, 0)
		}):Play()

		task.delay(5, function()
			TweenService:Create(bell, TweenInfo.new(1.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
				Position = Part.Position + Vector3.new(0, 100, 0)
			}):Play()
		end)

		task.delay(6, function()
			bell:Destroy()
		end)
	end)
end

task.defer(function()
	workspace.Alive.ChildRemoved:Connect(function(child)
		if not workspace.Dead:FindFirstChild(child.Name) and child ~= local_player.Character and #workspace.Alive:GetChildren() > 1 then
			return
		end

		if getgenv().kill_effect_Enabled then
			play_kill_effect(child.HumanoidRootPart)
		end
	end)
end)

--// self effect

task.defer(function()
	game:GetService("RunService").Heartbeat:Connect(function()

		if not local_player.Character then
			return
		end

		if getgenv().self_effect_Enabled then
			local effect = game:GetObjects("rbxassetid://17519530107")[1]

			effect.Name = 'nurysium_efx'

			if local_player.Character.PrimaryPart:FindFirstChild('nurysium_efx') then
				return
			end

			effect.Parent = local_player.Character.PrimaryPart
		else

			if local_player.Character.PrimaryPart:FindFirstChild('nurysium_efx') then
				local_player.Character.PrimaryPart['nurysium_efx']:Destroy()
			end
		end

	end)
end)

--// trail

task.defer(function()
	game:GetService("RunService").Heartbeat:Connect(function()

		if not local_player.Character then
			return
		end

		if getgenv().trail_Enabled then
			local trail = game:GetObjects("rbxassetid://17483658369")[1]

			trail.Name = 'nurysium_fx'

			if local_player.Character.PrimaryPart:FindFirstChild('nurysium_fx') then
				return
			end

			local Attachment0 = Instance.new("Attachment", local_player.Character.PrimaryPart)
			local Attachment1 = Instance.new("Attachment", local_player.Character.PrimaryPart)

			Attachment0.Position = Vector3.new(0, -2.411, 0)
			Attachment1.Position = Vector3.new(0, 2.504, 0)

			trail.Parent = local_player.Character.PrimaryPart
			trail.Attachment0 = Attachment0
			trail.Attachment1 = Attachment1
		else

			if local_player.Character.PrimaryPart:FindFirstChild('nurysium_fx') then
				local_player.Character.PrimaryPart['nurysium_fx']:Destroy()
			end
		end

	end)
end)

--// night mode

task.defer(function()
	while task.wait(1) do
		if getgenv().night_mode_Enabled then
			TweenService:Create(game:GetService("Lighting"), TweenInfo.new(3), {ClockTime = 1.9}):Play()
		else
			TweenService:Create(game:GetService("Lighting"), TweenInfo.new(3), {ClockTime = 13.5}):Play()
		end
	end
end)

--// spectate ball
task.defer(function()
    RunService.RenderStepped:Connect(function()
        if getgenv().spectate_Enabled then

            local self = Nurysium_Util.getBall()

            if not self then
                return
            end

            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(workspace.CurrentCamera.CFrame.Position, self.Position), 1.5)
        end
    end)
end)

--// shaders

task.defer(function()
	while task.wait(1) do
		if getgenv().shaders_effect_Enabled then
			TweenService:Create(game:GetService("Lighting").Bloom, TweenInfo.new(4), {
				Size = 100,
				Intensity = 2.1
			}):Play()
		else
			TweenService:Create(game:GetService("Lighting").Bloom, TweenInfo.new(3), {
				Size = 3,
				Intensity = 1
			}):Play()
		end
	end
end)

ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()
	if getgenv().hit_sound_Enabled then
		hit_Sound:Play()
	end

	if getgenv().hit_effect_Enabled then
		local hit_effect = game:GetObjects("rbxassetid://17407244385")[1]

		hit_effect.Parent = Nurysium_Util.getBall()
		hit_effect:Emit(3)

		task.delay(5, function()
			hit_effect:Destroy()
		end)

	end
end)

--// aura

local aura = {
	can_parry = true,
	is_spamming = false,

	parry_Range = 0,
	spam_Range = 0,  
	hit_Count = 0,

	hit_Time = tick(),
	last_target = nil
}

--// AI

task.defer(function()
    game:GetService("RunService").Heartbeat:Connect(function()
        if getgenv().ai_Enabled and workspace.Alive:FindFirstChild(local_player.Character.Name) then
            local self = Nurysium_Util.getBall()

            if not self or not closest_Entity then
                return
            end

            if not closest_Entity:FindFirstChild('HumanoidRootPart') then
                walk_to(local_player.Character.HumanoidRootPart.Position + Vector3.new(math.sin(tick()) * math.random(35, 50), 0, math.cos(tick()) * math.random(35, 50)))
                return
            end

            local ball_Position = self.Position
            local ball_Speed = self.AssemblyLinearVelocity.Magnitude
            local ball_Distance = local_player:DistanceFromCharacter(ball_Position)

            local player_Position = local_player.Character.PrimaryPart.Position

            local target_Position = closest_Entity.HumanoidRootPart.Position
            local target_Distance = local_player:DistanceFromCharacter(target_Position)
            local target_LookVector = closest_Entity.HumanoidRootPart.CFrame.LookVector

            local resolved_Position = Vector3.zero

            local target_Humanoid = closest_Entity:FindFirstChildOfClass("Humanoid")
            if target_Humanoid and target_Humanoid:GetState() == Enum.HumanoidStateType.Jumping and local_player.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                local_player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end

            if (ball_Position - player_Position):Dot(local_player.Character.PrimaryPart.CFrame.LookVector) < -0.2 and tick() % 4 <= 2 then
                return
            end

            if tick() % 4 <= 2 then
                if target_Distance > 10 then
                    resolved_Position = target_Position + (player_Position - target_Position).Unit * 8
                else
                    resolved_Position = target_Position + (player_Position - target_Position).Unit * 25
                end
            else
                resolved_Position = target_Position - target_LookVector * (math.random(8.5, 13.5) + (ball_Distance / math.random(8, 20)))
            end

            if (player_Position - target_Position).Magnitude < 8 then
                resolved_Position = target_Position + (player_Position - target_Position).Unit * 35
            end

            if ball_Distance < 8 then
                resolved_Position = player_Position + (player_Position - ball_Position).Unit * 10
            end

            if aura.is_spamming then
                resolved_Position = player_Position + (ball_Position - player_Position).Unit * 10
            end

            walk_to(resolved_Position + Vector3.new(math.sin(tick()) * 10, 0, math.cos(tick()) * 10))
        end
    end)
end)


ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function()
	aura.hit_Count += 1

	task.delay(0.185, function()
		aura.hit_Count -= 1
	end)
end)


task.spawn(function()
	RunService.PreRender:Connect(function()
		if not getgenv().aura_Enabled then
			return
		end

		if closest_Entity then
			if workspace.Alive:FindFirstChild(closest_Entity.Name) then
				if aura.is_spamming then
					if local_player:DistanceFromCharacter(closest_Entity.HumanoidRootPart.Position) <= aura.spam_Range then   
						parry_remote:FireServer(
							0.5,
							CFrame.new(camera.CFrame.Position, Vector3.zero),
							{[closest_Entity.Name] = closest_Entity.HumanoidRootPart.Position},
							{closest_Entity.HumanoidRootPart.Position.X, closest_Entity.HumanoidRootPart.Position.Y},
							false
						)
					end
				end
			end
		end
	end)

	RunService.PreRender:Connect(function()
		if not getgenv().aura_Enabled then
			return
		end

		workspace:WaitForChild("Balls").ChildRemoved:Once(function(child)
			aura.hit_Count = 0
			aura.is_spamming = false
			aura.can_parry = true
			aura.last_target = nil
		end)

		local ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue() / 10
		local self = Nurysium_Util.getBall()

		if not self then
			return
		end

		self:GetAttributeChangedSignal('target'):Once(function()
			aura.can_parry = true
		end)

		self:GetAttributeChangedSignal('from'):Once(function()
			aura.last_target = workspace.Alive:FindFirstChild(self:GetAttribute('from'))
		end)

		if self:GetAttribute('target') ~= local_player.Name or not aura.can_parry then
			return
		end

		get_closest_entity(local_player.Character.PrimaryPart)

		local player_Position = local_player.Character.PrimaryPart.Position
		local player_Velocity = local_player.Character.HumanoidRootPart.AssemblyLinearVelocity
		local player_isMoving = player_Velocity.Magnitude > 0

		local ball_Position = self.Position
		local ball_Velocity = self.AssemblyLinearVelocity

		if self:FindFirstChild('zoomies') then
			ball_Velocity = self.zoomies.VectorVelocity
		end

		local ball_Direction = (local_player.Character.PrimaryPart.Position - ball_Position).Unit
		local ball_Distance = local_player:DistanceFromCharacter(ball_Position)
		local ball_Dot = ball_Direction:Dot(ball_Velocity.Unit)
		local ball_Speed = ball_Velocity.Magnitude
		local ball_speed_Limited = math.min(ball_Speed / 1000, 0.1)

		local target_Position = closest_Entity.HumanoidRootPart.Position
		local target_Distance = local_player:DistanceFromCharacter(target_Position)
		local target_distance_Limited = math.min(target_Distance / 10000, 0.1)
		local target_Direction = (local_player.Character.PrimaryPart.Position - closest_Entity.HumanoidRootPart.Position).Unit
		local target_Velocity = closest_Entity.HumanoidRootPart.AssemblyLinearVelocity
		local target_isMoving = target_Velocity.Magnitude > 0
		local target_Dot = target_isMoving and math.max(target_Direction:Dot(target_Velocity.Unit), 0)

		aura.spam_Range = math.max(ping / 10, 10.5) + ball_Speed / 6.15
		aura.parry_Range = math.max(math.max(ping, 3.5) + ball_Speed / 3.25, 9.5)

		if target_isMoving then
            aura.is_spamming = (aura.hit_Count > 1 or (target_Distance < 11 and ball_Distance < 10)) and ball_Dot > -0.25
        else
            aura.is_spamming = (aura.hit_Count > 1 or (target_Distance < 11.5 and ball_Distance < 10))
        end

		if ball_Distance <= aura.parry_Range and ball_Dot > -0.1 then
			parry_remote:FireServer(
				0.5,
				CFrame.new(camera.CFrame.Position, Vector3.new(math.random(-1000, 1000), math.random(0, 1000), math.random(100, 1000))),
				{[closest_Entity.Name] = target_Position},
				{target_Position.X, target_Position.Y},
				false
			)

			aura.can_parry = false
			aura.hit_Time = tick()
			aura.hit_Count += 1

			task.delay(0.2, function()
				aura.hit_Count -= 1
			end)
		end

		task.spawn(function()
			repeat
				RunService.PreRender:Wait()
			until (tick() - aura.hit_Time) >= 1
			    aura.can_parry = true
		end)
	end)
end)



initializate('nurysium_temp')

end
