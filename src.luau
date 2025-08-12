local menuMaker = loadstring(game:HttpGet("https://raw.githubusercontent.com/semzev/MenuMakerLuau/refs/heads/main/src.luau"))()
local player : Player = game.Players.LocalPlayer	
local character : Model = player.Character or player.CharacterAdded:Wait()
local humanoid : Humanoid = character:WaitForChild("Humanoid")
local camera : Camera = game.Workspace.CurrentCamera

local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")

local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Exponential)

local gravityNormal = workspace.Gravity

local partTransparency = 0.4

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

local function getNumber(input)
	input = tostring(tonumber(input))
	if input == nil or input == "" or input == "nil" then return nil end
	return input
end

local oldPos = nil
local function heartbeatFly(leaveState : boolean)
	if not leaveState then humanoid:ChangeState(0) end
	local currentCF = character.PrimaryPart.CFrame
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
	
	local lerped = oldPos:Lerp(add * (humanoid.WalkSpeed / 15), 0.08)
	currentCF += lerped-- 
	primary.CFrame = CFrame.lookAt(
		currentCF.Position,
		currentCF.Position + (game.Workspace.CurrentCamera.CFrame.LookVector * 2)
	)
	oldPos = lerped
end

local cachedParts = {}
local function addDestroyability(obj)
	local clickDetec = Instance.new("ClickDetector", obj)
	local con
	con = clickDetec.MouseClick:Connect(function()
		menuMaker:Notify({Title = "Destroy?", Description = "Click again to confirm.", Duration = 0.8})
		
		local con2
		con2 = clickDetec.MouseClick:Once(function()
			con:Disconnect()
			con2:Disconnect()
			obj:Destroy()
			return
		end)
		
		task.delay(5, function()
			if con2 then con2:Disconnect(); con2 = nil end
			return
		end)
	end)
	table.insert(cachedParts, {obj, con})
	return
end

local debugVizualize = false
local pixelStep = 10
local function getObjectsInFrame(frame : GuiObject, specific : any?)
	local objects = {}

	local frameSizeX = frame.AbsoluteSize.X
	local frameSizeY = frame.AbsoluteSize.Y
	
	local frameStartX = frame.AbsolutePosition.X - (frameSizeX/2) + frameSizeX/2
	local frameEndX = frame.AbsolutePosition.X + (frameSizeX/2) + frameSizeX/2
	local frameStartY = frame.AbsolutePosition.Y - (frameSizeY/2)  + frameSizeY/2
	local frameEndY = frame.AbsolutePosition.Y + (frameSizeY/2) + frameSizeY/2
	
	local params = RaycastParams.new()
	params:AddToFilter(character)

	for x = frameStartX, frameEndX, pixelStep do
		for y = frameStartY, frameEndY, pixelStep do
			local ray = camera:ScreenPointToRay(x,y)
			local cast = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
			table.insert(objects, cast)
		end
	end
	
	if debugVizualize then
		if player.PlayerGui:FindFirstChild("FrameAnalyzerDebugGui") then player.PlayerGui["FrameAnalyzerDebugGui"]:Destroy() end
		local gui = Instance.new("ScreenGui", player.PlayerGui)
		gui.Name = "FrameAnalyzerDebugGui"
		for x = frameStartX, frameEndX, pixelStep do
			for y = frameStartY, frameEndY, pixelStep do
				local f = Instance.new("Frame",gui)
				f.Position = UDim2.new(0,x,0,y); f.Size = UDim2.new(0,1,0,1)
			end
		end	
	end
	
	if specific == "Character" then
		local filteredObjects = {}
		for i, v in objects do
			if v.Instance.Parent:FindFirstChildWhichIsA("Humanoid") then
				if filteredObjects[v.Instance.Parent] then continue end
				filteredObjects[v.Instance.Parent] = v.Distance
			end
		end
		return filteredObjects
	end
	
	return objects
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
local localCategorty = menu:CreateCategory("Local", 3)
local combatCategory = menu:CreateCategory("Combat", 4)
local worldCategory = menu:CreateCategory("Misc", 5)
local settingsCategory = menu:CreateCategory("Settings", 100)

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
		humanoid.PlatformStand = false
	end,
	
	function()
		oldPos = nil
		humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		workspace.Gravity = gravityNormal
		if flyCon then flyCon:Disconnect(); flyCon = nil end
	end
)

playerCategory:CreateToggleOption("AirSwim", Enum.KeyCode.V, 3,
	function()
	
		airSwimCon = runService.RenderStepped:Connect(function()
			humanoid:ChangeState(4)
			humanoid.WalkSpeed = 100
		end)
		
		humanoid.PlatformStand = false
	end,
	
	function()
		if airSwimCon then airSwimCon:Disconnect(); airSwimCon = nil end
		humanoid:ChangeState(Enum.HumanoidStateType.Landed)
		humanoid.WalkSpeed = 16
	end
)

local infJumpCon
table.insert(connections, infJumpCon)
playerCategory:CreateToggleOption("InfJump", Enum.KeyCode.U, 4,
	function()
		local humanoid = humanoid
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
		humanoid.WalkSpeed = input
	end,
	
	function()
		humanoid.WalkSpeed = 16
	end
)

playerCategory:CreateInputOption("JumpHack", Enum.KeyCode.J, "enter height", 6,
	function(input)
		if input == nil or input == "" then return end
		input = tonumber(input)
		if type(input) == "nil" then return end
		humanoid.JumpHeight = input
	end,

	function()
		humanoid.JumpHeight = 7.2
	end
)

local iceSize = Vector3.new(5,1,5)
local offset = Vector3.new(0,2.7,0)
local icePathCon
table.insert(connections, icePathCon)
playerCategory:CreateToggleOption("Ice Path", Enum.KeyCode.K, 7,
	function()
		local elapsed = 0
		icePathCon = runService.Heartbeat:Connect(function(dt)
			elapsed += dt
			if elapsed < 0.03 then return end
			elapsed = 0
			local ice = Instance.new("Part", workspace)
			ice.Anchored = true
			ice.Size = iceSize
			ice.CFrame = character.PrimaryPart.CFrame
			ice.Position = Vector3.new(ice.Position.X,(character.PrimaryPart.Position.Y - offset.Y) - 0.8, ice.Position.Z)
			ice.BrickColor = BrickColor.new("Pastel Blue")
			ice.Transparency = partTransparency
			
			task.delay(1, function()
				tweenService:Create(ice, TweenInfo.new(1, Enum.EasingStyle.Linear), {Transparency = 1}):Play()
				task.delay(1, function()
					ice:Destroy()
				end)
			end)
			
		end)
	end,
	function()
		if icePathCon then icePathCon:Disconnect(); icePathCon = nil end
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
			humanoid.Sit = true
			character.PrimaryPart.Velocity = Vector3.new(0,0,0)
		end)

		local con
		con = humanoid.Jumping:Connect(function(isJumping)
			if isJumping then
				runServiceCon:Disconnect()
				runServiceCon = nil
				humanoid.Sit = false
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
				humanoid:MoveTo(targetedCharacter.PrimaryPart.Position)
			else
				humanoid:MoveTo(character.PrimaryPart.Position)
			end
		end)
	end,
	
	function()
		if followConnection then
			humanoid:MoveTo(character.PrimaryPart.Position)
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
				workspace.Gravity = 0
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
			workspace.Gravity = gravityNormal
			humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
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
			humanoid:MoveTo(character.PrimaryPart.Position)
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
			humanoid:MoveTo(character.PrimaryPart.Position)
			bugCon:Disconnect()
			bugCon = nil
		end
	end
)

-- Combat category

local aimLockCon
local gui
local range = 30
table.insert(connections, aimLockCon)
combatCategory:CreateInputOption("AimLock", Enum.KeyCode.C, "enter range", 1,
	function(input)
		local range = getNumber(input)
		if range == nil then return end
		
		local mouse = player:GetMouse()
		local fixedRange = range * 10
		
		gui = Instance.new("ScreenGui", player.PlayerGui)
		
		local frame = Instance.new("ImageLabel", gui) --1270305386
		frame.AnchorPoint = Vector2.new(0.5,0.5)
		frame.Position = UDim2.new(0.5,0,0.5,0)
		frame.Size = UDim2.new(0,fixedRange,0,fixedRange)
		frame.BackgroundTransparency = 1
		frame.Image = "rbxassetid://1270305379"
		
		local lockedBodyPart = nil
		aimLockCon = runService.RenderStepped:Connect(function(dt)
			if userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				if lockedBodyPart == nil then
					local charactersInFrame = getObjectsInFrame(frame, "Character")
					if charactersInFrame == {} then return end

					local closest = {nil, 0}
					for i, v in charactersInFrame do
						if v > closest[2] then
							if i:FindFirstChildWhichIsA("Humanoid").Health > 0 then
								closest = {i, v}
							end
						end
					end

					if closest == {nil, 0} or closest[1] == nil then return end

					lockedBodyPart = closest[1]:FindFirstChild("Head") or closest[1].PrimaryPart
					if lockedBodyPart == nil then return end
				end
				if lockedBodyPart.Parent.Humanoid.Health <= 0 then lockedBodyPart = nil return end
				if lockedBodyPart == nil then return end
				
				camera.CFrame = CFrame.lookAt(camera.CFrame.Position, lockedBodyPart.Position)
			else
				lockedBodyPart = nil
			end	
		end)
	end,
	function()
		if aimLockCon then aimLockCon:Disconnect(); aimLockCon = nil end
		if gui then gui:Destroy(); gui = nil end
	end
)

-- local category

localCategorty:CreateToggleOption("Btools", nil, 1, 
	function()
		for i = 1, 4 do
			local Tool = Instance.new("HopperBin", player:FindFirstChildOfClass("Backpack"))
			Tool.BinType = i
			Tool.Name = tostring(Tool.BinType)
		end
	end
)

local size = Vector3.new(5,1,2)
localCategorty:CreateInputOption("Spawn staircase", nil, 'enter height', 2,
	function(input)
		input = tostring(tonumber(input))
		if input == nil or input == "" or input == "nil" then return end
		
		local startPos
		local model
		local function createPart (i)
			local newStep = Instance.new("Part", model)
			newStep.Transparency = partTransparency
			newStep.Anchored = false
			newStep.Size = size
			newStep.Position = startPos + Vector3.new(0, (size.Y + i) - 1, (size.Z / 2) * i )
			return newStep
		end
		
		local height = input
		local direction = character.PrimaryPart.CFrame.LookVector
		model = Instance.new("Model", workspace)
		startPos = character.PrimaryPart.Position + Vector3.new(0,-2.5,0)
		
		local startPart = createPart(0)
		startPart.Anchored = true
		model.PrimaryPart = startPart
		
		for i = 1, height - 1 do
			local part = createPart(i)
			local weld = Instance.new("WeldConstraint", startPart)
			weld.Part0 = startPart
			weld.Part1 = part
		end
		
		model.PrimaryPart.CFrame = CFrame.lookAt(startPos, startPos - direction)
		addDestroyability(model)
	end
)

localCategorty:CreateInputOption("Spawn ladder", nil, "enter height", 3,
	function(input)
		local height = getNumber(input)
		if height == nil then return end
		local startPos = character.PrimaryPart.Position
		local direction = character.PrimaryPart.CFrame.LookVector.Unit

		local ladderPos = startPos + direction * 3 + Vector3.new(0, height/2 - 2.5, 0)

		local ladder = Instance.new("TrussPart")
		ladder.Size = Vector3.new(2, height, 2)
		ladder.Transparency = partTransparency
		ladder.Anchored = true
		ladder.Parent = workspace
		ladder.Position = ladderPos

		ladder.CFrame = CFrame.new(ladderPos, ladderPos + direction)
		addDestroyability(ladder)
	end
)

local platformSize = Vector3.new(8,1,8)
localCategorty:CreateToggleOption("Spawn platform", nil, 4,
	function(input)
		local height = getNumber(input)
		local platform = Instance.new("Part", workspace)
		platform.Anchored = true
		platform.Transparency = partTransparency
		platform.Size = platformSize
		
		platform.Position = character.PrimaryPart.Position + Vector3.new(0,-3,0)
		addDestroyability(platform)
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
local detachStep = 1
settingsCategory:CreateToggleOption("Detach Menu", Enum.KeyCode.Delete, 100, 
	function()
		if detachStep == 1 then
			menuMaker:Notify({Title = "Detach?", Description = "Click again to confirm.", Duration = 0.8})
			detachStep = 2
			task.delay(5, function()
				detachStep = 1
			end)
		elseif detachStep == 2 then
			detachStep = 1
			for _,v in connections  do
				if v then v:Disconnect(); v = nil end
			end
			menuMaker:Notify({Title = menuData.Title.." detached", Description = "Thanks for using!"})
			menu:Destroy()
			menu = nil
		end
		
	end
)

local destroyStep = 1
settingsCategory:CreateToggleOption("Destroy all parts", nil, 99, 
	function()
		if destroyStep == 1 then
			menuMaker:Notify({Title = "Destroy all parts?", Description = "Click again to confirm.", Duration = 0.8})
			destroyStep = 2
			task.delay(5, function()
				destroyStep = 1
			end)
		elseif destroyStep == 2 then
			destroyStep = 1
			for _, v in cachedParts do
				if v[2] then v[2]:Disconnect() end
				if v[1] then v[1]:Destroy() end
			end
		end
	end
)


local con
local function setupPlayerDeathConnection()
	con = humanoid.Died:Connect(function()
		for _,v in connections do
			if v ~= nil then v:Disconnect(); v = nil end
		end
		con:Disconnect()
		character = player.CharacterAdded:Wait()
		humanoid = character:FindFirstChildWhichIsA("Humanoid")
		camera = game.Workspace.CurrentCamera
		setupPlayerDeathConnection()
	end)
end

setupPlayerDeathConnection()
