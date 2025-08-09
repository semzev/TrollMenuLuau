local menuMaker = require(game.ReplicatedStorage.MenuMaker)
local player = game.Players.LocalPlayer	
local character = player.Character or player.CharacterAdded:Wait()

local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Exponential)

local data = {
	"Mod Menu",
	Color3.new(0.4, 0.4, 0.4),
	Color3.new(0.513725, 0, 0),
	Color3.new(0.698039, 0, 0),
	Color3.new(0.886275, 0, 0),
	Color3.new(0,0,0),
	Enum.Font.Ubuntu
}

local menu = menuMaker.newMenu(data)

local playerCategory = menu:CreateCategory("Character", 1)
local trollCategory = menu:CreateInputCategory("Troll", 2, "Targeted player:", "enter player")
local worldCategory = menu:CreateCategory("Misc", 3)

-- Player Category
local noClipCon
playerCategory:CreateToggleOption("NoClip", Enum.KeyCode.E, 1,
	function()
		local elapsed = 0
		noClipCon = runService.RenderStepped:Connect(function(dt)
			elapsed += dt
			if elapsed > 0.5 then
				elapsed = 0
				for _, v in character:GetChildren() do
					if v:IsA("BasePart") then
						v.CanCollide = false
					end
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

playerCategory:CreateToggleOption("Invisibility", Enum.KeyCode.I, 2,
	function()
		for _, v in character:GetChildren()  do
			if v:IsA("BasePart") then
				v.Transparency = 1
			end
		end
	end,

	function()
		for _, v in character:GetChildren()  do
			if v:IsA("BasePart") then
				if v == character.PrimaryPart then continue end
				v.Transparency = 0
			end
		end
	end
)


playerCategory:CreateInputOption("SpeedHack", Enum.KeyCode.X, "enter speed", 3,
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

playerCategory:CreateInputOption("JumpHack", Enum.KeyCode.J, "enter height", 4,
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
		local targetedCharacter = game.Players:FindFirstChild(input) or game.Workspace:FindFirstChild(input)
		if targetedCharacter:IsA("Player") then targetedCharacter = targetedCharacter.Character end

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
				con:Disconnect()
				con = nil
				return
			end
		end)
	end
)

local followConnection
trollCategory:CreateInputOption("Auto follow player", nil, "enter player", 2,
	function(input)
		if input == nil or input == "" then return end
		local targetedCharacter = game.Players:FindFirstChild(input) or game.Workspace:FindFirstChild(input)
		if targetedCharacter:IsA("Player") then targetedCharacter = targetedCharacter.Character end
		if not targetedCharacter then return end
		
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
trollCategory:CreateInputOption("Helicopter on player", nil, "enter player", 3,
	function(input)
		if input == nil or input == "" then return end
		local targetedCharacter = game.Players:FindFirstChild(input) or game.Workspace:FindFirstChild(input)
		if targetedCharacter:IsA("Player") then targetedCharacter = targetedCharacter.Character end
		if not targetedCharacter then return end
		
		local rotationIndx = 0
		helicopterCon = runService.Heartbeat:Connect(function()
			rotationIndx += 3
			if rotationIndx > 360 then rotationIndx = 0 end
			local rotation = CFrame.Angles(math.rad(270), 0, math.rad(rotationIndx))
			character.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
			character.PrimaryPart.CFrame = CFrame.new(targetedCharacter.PrimaryPart.Position + Vector3.new(0,5,0)) * rotation
		end)
	end,
	function()
		if helicopterCon then
			helicopterCon:Disconnect()
			helicopterCon = nil
			character.PrimaryPart.CFrame += Vector3.new(0,4,0)
		end
	end
)

local rotateAboveCon
trollCategory:CreateInputOption("Spin on player", nil, "enter player", 4,
	function(input)
		if input == nil or input == "" then return end
		local targetedCharacter = game.Players:FindFirstChild(input) or game.Workspace:FindFirstChild(input)
		if targetedCharacter:IsA("Player") then targetedCharacter = targetedCharacter.Character end
		if not targetedCharacter then return end

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
trollCategory:CreateInputOption("Look at player", nil, "enter player", 5,
	function(input)
		if input == nil or input == "" then return end
		local targetedCharacter = game.Players:FindFirstChild(input) or game.Workspace:FindFirstChild(input)
		if targetedCharacter:IsA("Player") then targetedCharacter = targetedCharacter.Character end
		if not targetedCharacter then return end

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
trollCategory:CreateInputOption("Bug around player", nil, "enter player", 6,
	function(input)
		if input == nil or input == "" then return end
		local targetedCharacter = game.Players:FindFirstChild(input) or game.Workspace:FindFirstChild(input)
		if targetedCharacter:IsA("Player") then targetedCharacter = targetedCharacter.Character end
		if not targetedCharacter then return end

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

-- World Category
worldCategory:CreateToggleOption("ESP", Enum.KeyCode.V, 1, 
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
		for _, v in game.Players:GetPlayers() do
			if v == player then continue end
			if v.Character:FindFirstChild("123Esp") then
				
				tweenService:Create(v.Character["123Esp"], tweenInfo, {OutlineTransparency = 1, FillTransparency = 1}):Play()
				
				task.delay(0.3,function()
					if v.Character:FindFirstChild("123Esp") then v.Character:FindFirstChild("123Esp"):Destroy() end
				end)
			end
			if v.Character.Head:FindFirstChild("123NameTagCool") then
				
				local tag =  v.Character.Head:FindFirstChild("123NameTagCool")
				
				tweenService:Create(tag.TextLabel, tweenInfo, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
				task.delay(0.3, function()
					if tag then tag:Destroy() end
				end)
			end
		end
	end
	
) 

local tracerCon
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

character.Humanoid.Died:Connect(function()
	local function safeDisconnect(connection)
		if connection then connection:Disconnect() end
	end

	safeDisconnect(noClipCon)
	safeDisconnect(bugCon)
	safeDisconnect(faceCon)
	safeDisconnect(rotateAboveCon)
	safeDisconnect(helicopterCon)
	safeDisconnect(followConnection)
	
	character = player.CharacterAdded:Wait()
end)
