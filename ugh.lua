local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local CONFIG = {
	AgentRadius = 2,
	AgentHeight = 5,
	AgentCanJump = true,
	AgentCanClimb = true,
	WaypointSpacing = 3,

	BLineUpdateRate = 0.05,
	RepathDelay = 0.10,
	ScanRange = 300,
	WaypointTimeout = 2.5,

	TeleportBehindDistance = 15,
}

local enabled = false
local cancelled = false

local selectedTarget = nil
local selectedRoot = nil
local selectedHighlight = nil

local currentCategory = "Players"
local mode = "Path"
local searchText = ""

local controllerThread = nil
local targetButtons = {}

local gui = Instance.new("ScreenGui")
gui.Name = "StandalonePathfinder"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 400, 0, 570)
mainFrame.Position = UDim2.new(0, 40, 0.5, -285)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(65, 65, 65)
mainStroke.Thickness = 1
mainStroke.Parent = mainFrame

local dragBar = Instance.new("Frame")
dragBar.Name = "DragBar"
dragBar.Size = UDim2.new(1, 0, 0, 42)
dragBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
dragBar.BorderSizePixel = 0
dragBar.Parent = mainFrame

local dragCorner = Instance.new("UICorner")
dragCorner.CornerRadius = UDim.new(0, 10)
dragCorner.Parent = dragBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = " "
title.TextColor3 = Color3.fromRGB(235, 235, 235)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = dragBar

local dragging = false
local dragStart
local startPosition

dragBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPosition = mainFrame.Position
	end
end)

dragBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	local delta = input.Position - dragStart

	mainFrame.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end)

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1, -20, 0, 25)
targetLabel.Position = UDim2.new(0, 10, 0, 52)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "Target: None"
targetLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
targetLabel.Font = Enum.Font.Gotham
targetLabel.TextSize = 12
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 22)
statusLabel.Position = UDim2.new(0, 10, 0, 76)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

local function createButton(text, position, size)
	local button = Instance.new("TextButton")

	button.Size = size or UDim2.new(0, 110, 0, 32)
	button.Position = position

	button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	button.BorderSizePixel = 0

	button.Text = text
	button.TextColor3 = Color3.fromRGB(235, 235, 235)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 11

	button.AutoButtonColor = true
	button.Parent = mainFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	return button
end

local scanButton = createButton("SCAN NEAREST", UDim2.new(0, 10, 0, 105), UDim2.new(0, 120, 0, 32))

local followButton = createButton("FOLLOW", UDim2.new(0, 140, 0, 105), UDim2.new(0, 120, 0, 32))

local stopButton = createButton("STOP", UDim2.new(0, 270, 0, 105), UDim2.new(0, 120, 0, 32))

local playersTab = createButton("PLAYERS", UDim2.new(0, 10, 0, 145), UDim2.new(0, 185, 0, 32))

local npcsTab = createButton("NPCS", UDim2.new(0, 205, 0, 145), UDim2.new(0, 185, 0, 32))

local searchBox = Instance.new("TextBox")

searchBox.Name = "Search"
searchBox.Size = UDim2.new(1, -20, 0, 32)
searchBox.Position = UDim2.new(0, 10, 0, 185)

searchBox.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
searchBox.BorderSizePixel = 0

searchBox.ClearTextOnFocus = false
searchBox.PlaceholderText = "Search players / NPCs..."
searchBox.PlaceholderColor3 = Color3.fromRGB(105, 105, 105)

searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(230, 230, 230)

searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 12
searchBox.TextXAlignment = Enum.TextXAlignment.Left

searchBox.Parent = mainFrame

local searchPadding = Instance.new("UIPadding")
searchPadding.PaddingLeft = UDim.new(0, 10)
searchPadding.Parent = searchBox

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 6)
searchCorner.Parent = searchBox

local targetList = Instance.new("ScrollingFrame")

targetList.Name = "TargetList"
targetList.Size = UDim2.new(1, -20, 0, 185)
targetList.Position = UDim2.new(0, 10, 0, 225)

targetList.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
targetList.BorderSizePixel = 0

targetList.ScrollBarThickness = 5
targetList.CanvasSize = UDim2.new(0, 0, 0, 0)
targetList.AutomaticCanvasSize = Enum.AutomaticSize.Y

targetList.Parent = mainFrame

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 7)
listCorner.Parent = targetList

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = targetList

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 5)
listPadding.PaddingBottom = UDim.new(0, 5)
listPadding.PaddingLeft = UDim.new(0, 5)
listPadding.PaddingRight = UDim.new(0, 5)
listPadding.Parent = targetList

local refreshButton = createButton("REFRESH", UDim2.new(0, 10, 0, 420), UDim2.new(0, 185, 0, 32))

local modeButton = createButton("MODE: PATH", UDim2.new(0, 205, 0, 420), UDim2.new(0, 185, 0, 32))

local teleportButton = createButton("TELEPORT BEHIND 15", UDim2.new(0, 10, 0, 462), UDim2.new(1, -20, 0, 38))

local function getRoot(model)
	if not model or not model:IsA("Model") then
		return nil
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then
		return nil
	end

	if humanoid.Health <= 0 then
		return nil
	end

	return root
end

local function getLocalRoot()
	local character = LocalPlayer.Character

	if not character then
		return nil
	end

	return getRoot(character)
end

local function getDistance(root)
	local localRoot = getLocalRoot()

	if not localRoot or not root then
		return math.huge
	end

	return (localRoot.Position - root.Position).Magnitude
end

local function clearHighlight()
	if selectedHighlight then
		selectedHighlight:Destroy()
		selectedHighlight = nil
	end
end

local function highlightTarget(model)
	clearHighlight()

	if not model then
		return
	end

	local highlight = Instance.new("Highlight")

	highlight.Name = "PathfinderTargetHighlight"
	highlight.Adornee = model

	highlight.FillColor = Color3.fromRGB(170, 0, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 60, 60)

	highlight.FillTransparency = 0.65
	highlight.OutlineTransparency = 0

	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

	highlight.Parent = model

	selectedHighlight = highlight
end

local function matchesSearch(data)
	if searchText == "" then
		return true
	end

	local query = string.lower(searchText)

	local displayName = string.lower(data.DisplayName or "")
	local username = string.lower(data.Username or "")
	local name = string.lower(data.Name or "")

	return string.find(displayName, query, 1, true)
		or string.find(username, query, 1, true)
		or string.find(name, query, 1, true)
end

local function getPlayerTargets()
	local targets = {}

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local character = player.Character
			local root = getRoot(character)

			if root then
				table.insert(targets, {
					Name = player.DisplayName,
					DisplayName = player.DisplayName,
					Username = player.Name,
					FullName = player.DisplayName .. "  @" .. player.Name,

					Model = character,
					Root = root,

					Type = "Player",
					Player = player,
				})
			end
		end
	end

	return targets
end

local function getNPCTargets()
	local targets = {}
	local seen = {}

	for _, object in ipairs(workspace:GetDescendants()) do
		if object:IsA("Humanoid") then
			local model = object.Parent

			if model and model:IsA("Model") and not seen[model] and not Players:GetPlayerFromCharacter(model) then
				local root = getRoot(model)

				if root then
					seen[model] = true

					table.insert(targets, {
						Name = model.Name,
						DisplayName = model.Name,
						Username = "",
						FullName = model.Name,

						Model = model,
						Root = root,

						Type = "NPC",
					})
				end
			end
		end
	end

	return targets
end

local function getTargets()
	local targets

	if currentCategory == "Players" then
		targets = getPlayerTargets()
	else
		targets = getNPCTargets()
	end

	local filtered = {}

	for _, data in ipairs(targets) do
		if matchesSearch(data) then
			table.insert(filtered, data)
		end
	end

	return filtered
end

local function selectTarget(data)
	if not data then
		return
	end

	selectedTarget = data.Model
	selectedRoot = data.Root

	targetLabel.Text = "Target: " .. data.FullName
	statusLabel.Text = "Selected " .. data.Type

	highlightTarget(selectedTarget)

	for _, button in ipairs(targetButtons) do
		button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	end
end

local function refreshTargets()
	for _, button in ipairs(targetButtons) do
		button:Destroy()
	end

	table.clear(targetButtons)

	local targets = getTargets()

	table.sort(targets, function(a, b)
		return getDistance(a.Root) < getDistance(b.Root)
	end)

	for index, data in ipairs(targets) do
		local distance = getDistance(data.Root)

		local button = Instance.new("TextButton")

		button.Size = UDim2.new(1, -10, 0, 36)
		button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

		button.BorderSizePixel = 0

		button.TextColor3 = Color3.fromRGB(220, 220, 220)
		button.Font = Enum.Font.Gotham
		button.TextSize = 11

		if data.Type == "Player" then
			button.Text = string.format("%s  @%s    [%.1f]", data.DisplayName, data.Username, distance)
		else
			button.Text = string.format("%s    [NPC]    [%.1f]", data.Name, distance)
		end

		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Parent = targetList
		button.LayoutOrder = index

		local padding = Instance.new("UIPadding")
		padding.PaddingLeft = UDim.new(0, 9)
		padding.Parent = button

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 5)
		corner.Parent = button

		table.insert(targetButtons, button)

		button.MouseButton1Click:Connect(function()
			selectTarget(data)

			button.BackgroundColor3 = Color3.fromRGB(55, 25, 25)
		end)
	end

	statusLabel.Text = string.format("%d %s found", #targets, string.lower(currentCategory))
end

local function scanNearest()
	local targets = getTargets()

	local nearest = nil
	local nearestDistance = CONFIG.ScanRange

	for _, data in ipairs(targets) do
		local distance = getDistance(data.Root)

		if distance < nearestDistance then
			nearestDistance = distance
			nearest = data
		end
	end

	if nearest then
		selectTarget(nearest)

		statusLabel.Text = string.format("Nearest: %.1f studs", nearestDistance)
	else
		selectedTarget = nil
		selectedRoot = nil

		clearHighlight()

		targetLabel.Text = "Target: None"
		statusLabel.Text = "No target in range"
	end
end

local function stopMovement()
	cancelled = true
	enabled = false

	local character = LocalPlayer.Character

	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	local root = character and character:FindFirstChild("HumanoidRootPart")

	if humanoid and root then
		humanoid:MoveTo(root.Position)
	end

	statusLabel.Text = "Stopped"
end

local function runPathfinder()
	cancelled = false
	enabled = true

	while enabled and not cancelled do
		local character = LocalPlayer.Character

		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		local root = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoid or not root then
			task.wait(0.2)
			continue
		end

		local targetRoot = selectedRoot

		if not targetRoot or not targetRoot.Parent or not getRoot(targetRoot.Parent) then
			statusLabel.Text = "Target lost"
			task.wait(0.25)
			continue
		end

		local distance = (root.Position - targetRoot.Position).Magnitude

		targetLabel.Text = string.format("Target: %s  [%.1f]", targetRoot.Parent.Name, distance)

		statusLabel.Text = "Following • PATH"

		local path = PathfindingService:CreatePath({
			AgentRadius = CONFIG.AgentRadius,
			AgentHeight = CONFIG.AgentHeight,
			AgentCanJump = CONFIG.AgentCanJump,
			AgentCanClimb = CONFIG.AgentCanClimb,
			WaypointSpacing = CONFIG.WaypointSpacing,
		})

		local success = pcall(function()
			path:ComputeAsync(root.Position, targetRoot.Position)
		end)

		if not success or path.Status ~= Enum.PathStatus.Success then
			statusLabel.Text = "Repathing..."
			task.wait(CONFIG.RepathDelay)
			continue
		end

		local waypoints = path:GetWaypoints()

		local blocked = false

		local blockedConnection = path.Blocked:Connect(function()
			blocked = true
		end)

		for _, waypoint in ipairs(waypoints) do
			if cancelled or not enabled then
				break
			end

			if blocked then
				break
			end

			if not selectedRoot or not selectedRoot.Parent then
				break
			end

			if waypoint.Action == Enum.PathWaypointAction.Jump then
				humanoid.Jump = true
			end

			humanoid:MoveTo(waypoint.Position)

			local reached = false

			local moveConnection = humanoid.MoveToFinished:Connect(function()
				reached = true
			end)

			local startTime = os.clock()

			while
				not reached
				and not cancelled
				and enabled
				and not blocked
				and (os.clock() - startTime) < CONFIG.WaypointTimeout
			do
				task.wait(0.05)
			end

			moveConnection:Disconnect()

			if blocked then
				break
			end
		end

		blockedConnection:Disconnect()

		task.wait(CONFIG.RepathDelay)
	end
end

local function runBLine()
	cancelled = false
	enabled = true

	while enabled and not cancelled do
		local character = LocalPlayer.Character

		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		local root = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoid or not root then
			task.wait(0.2)
			continue
		end

		local targetRoot = selectedRoot

		if not targetRoot or not targetRoot.Parent or not getRoot(targetRoot.Parent) then
			statusLabel.Text = "Target lost"
			task.wait(0.25)
			continue
		end

		local distance = (root.Position - targetRoot.Position).Magnitude

		targetLabel.Text = string.format("Target: %s  [%.1f]", targetRoot.Parent.Name, distance)

		statusLabel.Text = "Following • B-LINE"

		humanoid:MoveTo(targetRoot.Position)

		task.wait(CONFIG.BLineUpdateRate)
	end
end

local function startFollowing()
	if not selectedTarget or not selectedRoot then
		statusLabel.Text = "Select a target first"
		return
	end

	cancelled = true
	enabled = false

	task.wait()

	cancelled = false
	enabled = true

	if mode == "B-Line" then
		controllerThread = task.spawn(runBLine)
	else
		controllerThread = task.spawn(runPathfinder)
	end
end

local function teleportBehind()
	if not selectedTarget or not selectedRoot then
		statusLabel.Text = "Select a target first"
		return
	end

	if not selectedRoot.Parent then
		statusLabel.Text = "Target unavailable"
		return
	end

	local character = LocalPlayer.Character

	if not character then
		statusLabel.Text = "Character unavailable"
		return
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")

	if not hrp then
		statusLabel.Text = "HumanoidRootPart unavailable"
		return
	end

	local targetRoot = selectedRoot

	local distance = CONFIG.TeleportBehindDistance

	local destination = targetRoot.Position - targetRoot.CFrame.LookVector * distance

	hrp.CFrame = CFrame.lookAt(destination, targetRoot.Position)

	statusLabel.Text = string.format("Teleported %.0f studs behind", distance)
end

scanButton.MouseButton1Click:Connect(function()
	scanNearest()
end)

followButton.MouseButton1Click:Connect(function()
	startFollowing()
end)

stopButton.MouseButton1Click:Connect(function()
	stopMovement()
end)

teleportButton.MouseButton1Click:Connect(function()
	teleportBehind()
end)

refreshButton.MouseButton1Click:Connect(function()
	refreshTargets()
end)

playersTab.MouseButton1Click:Connect(function()
	currentCategory = "Players"

	playersTab.BackgroundColor3 = Color3.fromRGB(55, 25, 25)

	npcsTab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

	refreshTargets()
end)

npcsTab.MouseButton1Click:Connect(function()
	currentCategory = "NPCs"

	npcsTab.BackgroundColor3 = Color3.fromRGB(55, 25, 25)

	playersTab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

	refreshTargets()
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	searchText = searchBox.Text

	refreshTargets()
end)

modeButton.MouseButton1Click:Connect(function()
	local wasFollowing = enabled

	cancelled = true
	enabled = false

	task.wait()

	if mode == "Path" then
		mode = "B-Line"
		modeButton.Text = "MODE: B-LINE"
	else
		mode = "Path"
		modeButton.Text = "MODE: PATH"
	end

	if wasFollowing and selectedTarget and selectedRoot then
		cancelled = false
		enabled = true

		if mode == "B-Line" then
			controllerThread = task.spawn(runBLine)
		else
			controllerThread = task.spawn(runPathfinder)
		end
	else
		statusLabel.Text = "Mode: " .. mode
	end
end)

task.spawn(function()
	while gui.Parent do
		if selectedRoot and selectedRoot.Parent then
			local localRoot = getLocalRoot()

			if localRoot then
				local distance = (localRoot.Position - selectedRoot.Position).Magnitude

				local model = selectedRoot.Parent
				local player = Players:GetPlayerFromCharacter(model)

				if player then
					targetLabel.Text =
						string.format("Target: %s  @%s  [%.1f]", player.DisplayName, player.Name, distance)
				else
					targetLabel.Text = string.format("Target: %s  [%.1f]", model.Name, distance)
				end
			end
		end

		task.wait(0.1)
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	cancelled = true
	enabled = false

	targetLabel.Text = "Target: " .. (selectedTarget and selectedTarget.Name or "None")

	statusLabel.Text = "Waiting for character..."

	task.wait(1)

	if selectedTarget and selectedRoot then
		cancelled = false
		enabled = true

		if mode == "B-Line" then
			controllerThread = task.spawn(runBLine)
		else
			controllerThread = task.spawn(runPathfinder)
		end

		statusLabel.Text = "Following • " .. string.upper(mode)
	else
		statusLabel.Text = "Ready"
	end

	refreshTargets()
end)
