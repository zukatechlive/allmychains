local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local COPY_LABEL = "[C]"
local COPIED_LABEL = "[✓]"
local FEEDBACK_DELAY = 0.3
local BUTTON_NAME = "__CopyBtn"
local DIM_ALPHA = 0.5
local RECONNECT_RATE = 1.5
local processed = {}
setmetatable(processed, { __mode = "k" })
local function resolvePath(root, ...)
	local current = root
	for _, name in ipairs({ ... }) do
		if not current then
			return nil
		end
		current = current:FindFirstChild(name)
	end
	return current
end
local function getClientLog()
	return resolvePath(CoreGui, "DevConsoleMaster", "DevConsoleWindow", "DevConsoleUI", "MainView", "ClientLog")
end
local function computeButtonPosition(label: TextLabel): UDim2
	local text = label.Text
	local fontSize = label.TextSize
	local font = label.Font
	local absWidth = label.AbsoluteSize.X
	if text:find("\n") then
		local lastLine = text:match("([^\n]*)$") or ""
		local size = TextService:GetTextSize(lastLine, fontSize, font, Vector2.new(absWidth, math.huge))
		return UDim2.new(0, size.X + 5, 1, -fontSize / 2)
	else
		local bounds = TextService:GetTextSize(text, fontSize, font, Vector2.new(absWidth, math.huge))
		return UDim2.new(0, bounds.X + 5, 0.5, 0)
	end
end
local function attachCopyButton(label: TextLabel)
	if processed[label] then
		return
	end
	if label:FindFirstChild(BUTTON_NAME) then
		return
	end
	processed[label] = true
	local btn = Instance.new("TextButton")
	btn.Name = BUTTON_NAME
	btn.Size = UDim2.new(0, 30, 0, 20)
	btn.BackgroundTransparency = 1
	btn.Text = COPY_LABEL
	btn.TextColor3 = label.TextColor3
	btn.Font = label.Font
	btn.TextSize = label.TextSize
	btn.TextTransparency = DIM_ALPHA
	btn.AnchorPoint = Vector2.new(0, 0.5)
	btn.Position = UDim2.new(0, 0, 0.5, 0)
	btn.Parent = label
	local posConn
	posConn = RunService.RenderStepped:Connect(function()
		if not btn.Parent then
			posConn:Disconnect()
			return
		end
		if label.TextBounds.X > 0 then
			btn.Position = computeButtonPosition(label)
			posConn:Disconnect()
		end
	end)
	btn.MouseEnter:Connect(function()
		btn.TextTransparency = 0
	end)
	btn.MouseLeave:Connect(function()
		btn.TextTransparency = DIM_ALPHA
	end)
	btn.MouseButton1Click:Connect(function()
		local ok, err = pcall(setclipboard, label.Text)
		if ok then
			btn.Text = COPIED_LABEL
			task.delay(FEEDBACK_DELAY, function()
				if btn and btn.Parent then
					btn.Text = COPY_LABEL
				end
			end)
		else
			btn.Text = "[!]"
			warn("[CopyBtn] setclipboard failed:", err)
			task.delay(FEEDBACK_DELAY, function()
				if btn and btn.Parent then
					btn.Text = COPY_LABEL
				end
			end)
		end
	end)
end
local function processContainer(container: Instance)
	for _, desc in ipairs(container:GetDescendants()) do
		if desc:IsA("TextLabel") then
			attachCopyButton(desc)
		end
	end
end
local wiredLogs = {}
setmetatable(wiredLogs, { __mode = "v" })
local function injectClientLog()
	local clientLog = getClientLog()
	if not clientLog then
		return
	end
	if wiredLogs[clientLog] then
		return
	end
	wiredLogs[clientLog] = true
	for _, child in ipairs(clientLog:GetChildren()) do
		if child:IsA("Frame") or child:IsA("ScrollingFrame") then
			processContainer(child)
		end
	end
	clientLog.ChildAdded:Connect(function(child)
		task.wait(0.1)
		if child and (child:IsA("Frame") or child:IsA("ScrollingFrame")) then
			processContainer(child)
		end
	end)
	clientLog.DescendantAdded:Connect(function(desc)
		if desc:IsA("TextLabel") then
			task.wait(0.05)
			attachCopyButton(desc)
		end
	end)
end
injectClientLog()
local elapsed = 0
RunService.Heartbeat:Connect(function(delta)
	elapsed += delta
	if elapsed >= RECONNECT_RATE then
		elapsed = 0
		injectClientLog()
	end
end)
