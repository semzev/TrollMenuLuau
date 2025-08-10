local menuMaker = loadstring(game:HttpGet("https://raw.githubusercontent.com/semzev/MenuMakerLuau/refs/heads/main/src.luau"))()
local player = game.Players.LocalPlayer	
local character = player.Character or player.CharacterAdded:Wait()

local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")

local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Exponential)

local gravityNormal = workspace.Gravity

local function getCharacter(name)
	local lwr = string.lower
	name = lwr(name)
	
	for _, v in game.Players:GetPlayers() do
		if name == lwr(v.Name) then return v.Character end
		if name == lwr(v.DisplayName) then return v.Character end
		if not v.Character:FindFirstChild("Head") then warn("No head found.") return end
	end

	for _, v in game.Workspace:GetChildren() do
		if lwr(name) ~= lwr(v.Name) then continue end
		if not v:IsA("Model") and not v:FindFirstChildWhichIsA("Humanoid") then continue end
		if not v:FindFirstChild("Head") then warn("No head found.") return end
		return v
	end
	return nil
end

local oldPos = nil
local function heartbeatFly(leaveState : boolean)
	if not leaveState then character.Humanoid:ChangeState(0) end
	local currentCF = character.PrimaryPart.CFram
	local primary = character.PrimaryPart
	local add = Vector3.zero
	
	if userInputService:IsKeyDown(Enum.KeyCode.W) then add += primary.CFrame.LookVector end
	if userInputService:IsKeyDown(Enum.KeyCode.A) then add -= primary.CFrame.RightVector end
	if userInputService:IsKeyDown(Enum.KeyCode.S) then add -= primary.CFrame.LookVector end
	if userInputService:IsKeyDown(Enum.KeyCode.D) then add += primary.CFrame.RightVector end
	if userInputService:IsKeyDown(Enum.KeyCode.Space) then add += primary.CFrame.UpVector end
	if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then add -= primary.CFrame.UpVector end

	primary.AssemblyLinearVelocity = Vector3.new(0,0,0)
	primary.AssemblyAngularVelocity = Vector3.new(0,0,0)
	
	if oldPos == nil then
		oldPos = add
	end
	
	local lerped = oldPos:Lerp(add * (character.Humanoid.WalkSpeed / 15), 0.08)
	currentCF += lerped-- 
	primary.CFrame = CFrame.lookAt(
		currentCF.Position,
		currentCF.Position + (game.Workspace.CurrentCamera.CFrame.LookVector * 2)
	)
	oldPos = lerped
end


-- Menu
local menuData = {
	Title = "Mod Menu",
	BackgroundColor = Color3.new(0.4, 0.4, 0.4),
	PrimaryColor = Color3.new(0.513725, 0, 0),
	SecondaryColor = Color3.new(0.698039, 0, 0),
	SelectedColor = Color3.new(0.886275, 0, 0),
	HoverColor = Color3.new(0,0,0),
	FontColor = Color3.new(0,0,0),
	Font = Enum.Font.Ubuntu,
	RoundCorners = false
}

local connections = {}

local menu = menuMaker.newMenu(menuData)

menuMaker:Notify({Title = menuData.Title.." attached", Description = "Thanks for using!"})

local playerCategory = menu:CreateCategory("Character", 1)
local trollCategory = menu:CreateInputCategory("Troll", 2, "Targeted player:", "enter player")
local worldCategory = menu:CreateCategory("Misc", 3)
local settingsCategory = menu:CreateCategory("Settings", 4)

-- Player Category
local noClipCon
table.insert(connections, noClipCon)
playerCategory:CreateToggleOption("NoClip", Enum.KeyCode.E, 1,
	function()
		noClipCon = runService.RenderStepped:Connect(function()
			for _, v in character:GetChildren() do
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
			end
		end)
	end, 
	
	function()
		noClipCon:Disconnect()
		local upperTorso = character.UpperTorso or character.Torso
		local lowerTorso = character.LowerTorso or character.Torso
		local primaryPart = character.PrimaryPart or character.HumanoidRootPart
		upperTorso.CanCollide = true
		lowerTorso.CanCollide = true
		primaryPart.CanCollide = true
	end
)

local flyCon
table.insert(connections, flyCon)
playerCategory:CreateToggleOption("Fly", Enum.KeyCode.F, 2,
	function()
		workspace.Gravity = 0
		flyCon = runService.Heartbeat:Connect(function()
			heartbeatFly()
		end)
		character.Humanoid.PlatformStand = false
	end,
	
	function()
		oldPos = nil
		character.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		workspace.Gravity = gravityNormal
		if flyCon then flyCon:Disconnect(); flyCon = nil end
	end
)

playerCategory:CreateToggleOption("AirSwim", Enum.KeyCode.V, 3,
	function()
	
		airSwimCon = runService.RenderStepped:Connect(function()
			character.Humanoid:ChangeState(4)
			character.Humanoid.WalkSpeed = 100
		end)
		
		character.Humanoid.PlatformStand = false
	end,
	
	function()
		if airSwimCon then airSwimCon:Disconnect(); airSwimCon = nil end
		character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
		character.Humanoid.WalkSpeed = 16
	end
)

local infJumpCon
table.insert(connections, infJumpCon)
playerCategory:CreateToggleOption("InfJump", Enum.KeyCode.U, 4,
	function()
		local humanoid = character.Humanoid
		local elapsed = 0
		infJumpCon = userInputService.JumpRequest:Connect(function()
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end)
	end,
	function()
		if infJumpCon then infJumpCon:Disconnect(); infJumpCon = nil end
	end
)

playerCategory:CreateInputOption("SpeedHack", Enum.KeyCode.X, "enter speed", 5,
	function(input)
		if input == nil or input == "" then return end
		input = tonumber(input)
		if type(input) == "nil" then return end
		character.Humanoid.WalkSpeed = input
	end,
	
	function()
		character.Humanoid.WalkSpeed = 16
	end
)

playerCategory:CreateInputOption("JumpHack", Enum.KeyCode.J, "enter height", 6,
	function(input)
		if input == nil or input == "" then return end
		input = tonumber(input)
		if type(input) == "nil" then return end
		character.Humanoid.JumpHeight = input
	end,

	function()
		character.Humanoid.JumpHeight = 7.2
	end
)


-- Troll Category
trollCategory:CreateInputOption("Sit on player", nil, "enter player", 1,
	function(input)
		if input == nil or input == "" then return end
		local targetedCharacter = getCharacter(input)
		if targetedCharacter == nil then return end

		local runServiceCon
		runServiceCon = runService.Heartbeat:Connect(function()
			character.PrimaryPart.CFrame = targetedCharacter.Head.CFrame + Vector3.new(0,2,0)
			character.Humanoid.Sit = true
			character.PrimaryPart.Velocity = Vector3.new(0,0,0)
		end)

		local con
		con = character.Humanoid.Jumping:Connect(function(isJumping)
			if isJumping then
				runServiceCon:Disconnect()
				runServiceCon = nil
				character.Humanoid.Sit = false
				con:Disconnect()
				con = nil
				return
			end
		end)
	end
)

trollCategory:CreateInputOption("Tp to player", nil, "enter player", 2,
	function(input)
		if input == nil or input == "" then return end
		local targetedCharacter = getCharacter(input)
		if targetedCharacter == nil then return end
		
		character.PrimaryPart.CFrame = targetedCharacter.PrimaryPart.CFrame
	end
)

local followConnection
table.insert(connections, followConnection)
trollCategory:CreateInputOption("Auto follow player", nil, "enter player", 3,
	function(input)
		if input == nil or input == "" then return end
		local targetedCharacter = getCharacter(input)
		if targetedCharacter == nil then return end
		
		followConnection = runService.Heartbeat:Connect(function()  
			local distance = (targetedCharacter.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude
			if distance > 3 then
				character.Humanoid:MoveTo(targetedCharacter.PrimaryPart.Position)
			else
				character.Humanoid:MoveTo(character.PrimaryPart.Position)
			end
		end)
	end,
	
	function()
		if followConnection then
			character.Humanoid:MoveTo(character.PrimaryPart.Position)
			followConnection:Disconnect()
			followConnection = nil
		end
	end
)

local helicopterCon
local state = true
table.insert(connections, helicopterCon)
trollCategory:CreateInputOption("Helicopter on player", nil, "enter player", 4,
	function(input)
		if input == nil or input == "" then return end
		local targetedCharacter = getCharacter(input)
		if targetedCharacter == nil then return end
		
		local rotationIndx = 0
		local function startAnimation()
			helicopterCon = runService.Heartbeat:Connect(function()
				rotationIndx += 3
				if rotationIndx > 360 then rotationIndx = 0 end
				character.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
				local rotation = CFrame.Angles(math.rad(270), 0, math.rad(rotationIndx))
				character.PrimaryPart.CFrame = CFrame.new(targetedCharacter.PrimaryPart.Position + Vector3.new(0,6,0)) * rotation
			end)
		end
		state = true
		task.spawn(function()
			while state do
				startAnimation()
				task.wait(1.5)
				if helicopterCon then helicopterCon:Disconnect() end
				task.wait(0.1)
			end
		end)
	end,
	
	function()
		if helicopterCon then
			state = false
			helicopterCon:Disconnect()
			helicopterCon = nil
			character.PrimaryPart.CFrame += Vector3.new(0,4,0)
		end
	end
)

local rotateAboveCon
table.insert(connections, rotateAboveCon)
trollCategory:CreateInputOption("Spin on player", nil, "enter player", 5,
	function(input)
		if input == nil or input == "" then return end
		local targetedCharacter = getCharacter(input)
		if targetedCharacter == nil then return end

		local rotationIndx = 0
		rotateAboveCon = runService.Heartbeat:Connect(function()
			rotationIndx += 2
			if rotationIndx > 360 then rotationIndx = 0 end
			local rotation = CFrame.Angles(0, math.rad(rotationIndx), 0)
			character.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
			character.PrimaryPart.CFrame = CFrame.new(targetedCharacter.PrimaryPart.Position + Vector3.new(0,5,0)) * rotation
		end)
	end,
	function()
		if rotateAboveCon then
			rotateAboveCon:Disconnect()
			rotateAboveCon = nil
			character.PrimaryPart.CFrame += Vector3.new(0,4,0)
		end
	end
)

local faceCon
table.insert(connections, faceCon)
trollCategory:CreateInputOption("Look at player", nil, "enter player", 6,
	function(input)
		if input == nil or input == "" then return end
		local targetedCharacter = getCharacter(input)
		if targetedCharacter == nil then return end

		faceCon = runService.Heartbeat:Connect(function()
			character.PrimaryPart.CFrame = CFrame.lookAt(character.PrimaryPart.Position, targetedCharacter.PrimaryPart.Position)
		end)
	end,

	function()
		if faceCon then
			character.Humanoid:MoveTo(character.PrimaryPart.Position)
			faceCon:Disconnect()
			faceCon = nil
		end
	end
)

local bugCon
table.insert(connections, bugCon)
trollCategory:CreateInputOption("Bug around player", nil, "enter player", 7,
	function(input)
		if input == nil or input == "" then return end
		local targetedCharacter = getCharacter(input)
		if targetedCharacter == nil then return end

		bugCon = runService.Heartbeat:Connect(function()
			character.PrimaryPart.CFrame = CFrame.lookAt(character.Head.Position, targetedCharacter.Head.Position)
		end)
	end,

	function()
		if bugCon then
			character.Humanoid:MoveTo(character.PrimaryPart.Position)
			bugCon:Disconnect()
			bugCon = nil
		end
	end
)


-- Misc Category
worldCategory:CreateToggleOption("ESP", Enum.KeyCode.N, 1, 
	function()
		for _, v in game.Players:GetPlayers() do
			if v == player then continue end
			local espColor = Color3.new(0.64, 0, 0)
			
			local esp = Instance.new("Highlight", v.Character)
			esp.Name = "123Esp"
			esp.FillColor = espColor
			esp.FillTransparency = 1
			esp.OutlineTransparency = 1
			
			local nameTag = Instance.new("BillboardGui", v.Character.Head)
			local textLabel = Instance.new("TextLabel", nameTag)
			
			nameTag.Size = UDim2.new(4,0,1,0)
			nameTag.StudsOffset = Vector3.new(0,2.2,0)
			nameTag.AlwaysOnTop = true
			nameTag.Name = "123NameTagCool"
			
			textLabel.Text = v.Name
			textLabel.BackgroundTransparency = 1
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.AnchorPoint = Vector2.new(0.5,0.5)
			textLabel.Position = UDim2.new(0.5,0,0,0)
			textLabel.Size = UDim2.new(1,0,1,0)
			textLabel.Transparency = 0.2
			textLabel.BackgroundColor3 = espColor
			textLabel.TextTransparency = 1
			textLabel.TextColor3 = Color3.new(255,255,255)
			textLabel.Font = Enum.Font.Ubuntu
			textLabel.TextSize = 16
			
			tweenService:Create(esp, tweenInfo, {OutlineTransparency = 0, FillTransparency = 0.5}):Play()
			tweenService:Create(textLabel, tweenInfo, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
		end
	end,
	function()
		for _, v in game.Workspace:GetDescendants() do
			if v.Name == "123Esp" then v:Destroy() end
			if v.Name == "123NameTagCool" then v:Destroy() end
		end
	end
	
) 

worldCategory:CreateToggleOption("Tracers", Enum.KeyCode.T, 2,
	function()
		print("Fix tracers.")
		for _, v in workspace:GetChildren() do
			if not v:IsA("Model") then continue end
			local beam = Instance.new("Beam", character)
			local a1 = Instance.new("Attachment", character.PrimaryPart) --.Character
			local a2 = Instance.new("Attachment", v.PrimaryPart)
			a1.Name, a2.Name = "123Att", "123Att"
			beam.ZOffset = 1
			beam.Name = "123Tracer"
			beam.Attachment0 = a1
			beam.Attachment1 = a2
			beam.Width0 = 0.1
			beam.Width1 = 0.1
			beam.FaceCamera = true
			beam.Transparency = NumberSequence.new(0)
			beam.Color = ColorSequence.new(Color3.new(1,0,0))
		end
	end,
	
	function()
		for _, v in character:GetChildren() do
			if v.Name == "123Tracer" then
				if v then v:Destroy() end
			end
		end
	end
)

worldCategory:CreateToggleOption("Btools", nil, 3, 
	function()
		for i = 1, 4 do
			local Tool = Instance.new("HopperBin")
			Tool.BinType = i
			Tool.Name = tostring(i)
			Tool.Parent = player:FindFirstChildOfClass("Backpack")
		end
	end
)

worldCategory:CreateToggleOption("Infinite Yield", nil, 4, 
	function()
		local success, err = pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
		end)
	end
)

worldCategory:CreateToggleOption("f3x tools", nil, 4, 
	function()
		local success, err = pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/f3x.lua"))()
		end)
	end
)

worldCategory:CreateToggleOption("SystemBrokenHub", nil, 5, 
	function()
		local success, err = pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/H20CalibreYT/SystemBroken/main/script"))()
		end)
	end
)

worldCategory:CreateToggleOption("Sky hub", nil, 6, 
	function()
		local success, err = pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub/refs/heads/main/FE%20Trolling%20GUI.luau"))()
		end)
	end
)

-- Settings Category
settingsCategory:CreateToggleOption("Detach Menu", Enum.KeyCode.Delete, 100, 
	function()
		for _,v in connections  do
			if v then v:Disconnect(); v = nil end
		end
		menuMaker:Notify({Title = menuData.Title.." detached", Description = "Thanks for using!"})
		menu:Destroy()
		menu = nil
	end
)


local con
local function setupPlayerDeathConnection()
	con = character.Humanoid.Died:Connect(function()
		for _,v in connections do
			if v then v:Disconnect(); v = nil end
		end
		con:Disconnect()
		character = player.CharacterAdded:Wait()
		setupPlayerDeathConnection()
	end)
end

setupPlayerDeathConnection()
