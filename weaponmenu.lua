local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera
local Mouse            = LocalPlayer:GetMouse()
local TOGGLE_KEY = Enum.KeyCode.RightControl
local LIVE_SYNC_RATE = 0.5
local UNDO_DEPTH = 10
pcall(function()
	local old = (gethui and gethui() or CoreGui):FindFirstChild("WE_v3")
	if old then
		old:Destroy()
	end
end)
local gui = Instance.new("ScreenGui")
gui.Name = "WE_v3"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.IgnoreGuiInset = true
gui.Parent = (gethui and gethui()) or CoreGui
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(375, 530)
Main.Position = UDim2.fromOffset(60, 60)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BackgroundTransparency = 0.5
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
local Border = Instance.new("Frame")
Border.Name = "Border"
Border.Size = UDim2.fromOffset(379, 534)
Border.Position = UDim2.fromOffset(58, 58)
Border.BackgroundColor3 = Color3.fromRGB(55, 55, 90)
Border.BorderSizePixel = 0
Border.BackgroundTransparency = 1
Border.ZIndex = Main.ZIndex - 1
Border.Parent = gui
Instance.new("UICorner", Border).CornerRadius = UDim.new(0, 7)
Main:GetPropertyChangedSignal("Position"):Connect(function()
	local ap = Main.AbsolutePosition
	Border.Position = UDim2.fromOffset(ap.X - 2, ap.Y - 2)
end)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 26)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 6)
local HFill = Instance.new("Frame", Header)
HFill.Size = UDim2.new(1, 0, 0, 6)
HFill.Position = UDim2.new(0, 0, 1, -6)
HFill.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
HFill.BorderSizePixel = 0
local TitleLbl = Instance.new("TextLabel", Header)
TitleLbl.Size = UDim2.new(1, -8, 1, 0)
TitleLbl.Position = UDim2.fromOffset(8, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "  direct weapon editor  v3"
TitleLbl.TextColor3 = Color3.fromRGB(210, 210, 255)
TitleLbl.TextSize = 12
TitleLbl.Font = Enum.Font.Code
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
local SrcBadge = Instance.new("TextLabel", Header)
SrcBadge.Size = UDim2.fromOffset(100, 14)
SrcBadge.Position = UDim2.new(1, -104, 0.5, -7)
SrcBadge.BackgroundColor3 = Color3.fromRGB(28, 28, 52)
SrcBadge.Text = ""
SrcBadge.TextColor3 = Color3.fromRGB(110, 130, 255)
SrcBadge.TextSize = 9
SrcBadge.Font = Enum.Font.Code
Instance.new("UICorner", SrcBadge).CornerRadius = UDim.new(0, 3)
local StatusLbl = Instance.new("TextLabel", Main)
StatusLbl.Size = UDim2.new(1, -10, 0, 14)
StatusLbl.Position = UDim2.fromOffset(5, 28)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "scanning..."
StatusLbl.TextColor3 = Color3.fromRGB(255, 150, 0)
StatusLbl.TextSize = 10
StatusLbl.Font = Enum.Font.Code
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
local function SetStatus(txt, r, g, b)
	StatusLbl.Text = txt
	StatusLbl.TextColor3 = Color3.fromRGB(r or 200, g or 200, b or 200)
end
local ToolBar = Instance.new("Frame", Main)
ToolBar.Size = UDim2.new(1, -10, 0, 20)
ToolBar.Position = UDim2.fromOffset(5, 44)
ToolBar.BackgroundColor3 = Color3.fromRGB(22, 22, 36)
ToolBar.BorderSizePixel = 0
Instance.new("UICorner", ToolBar).CornerRadius = UDim.new(0, 3)
local ToolNameLbl = Instance.new("TextLabel", ToolBar)
ToolNameLbl.Size = UDim2.new(1, -8, 1, 0)
ToolNameLbl.Position = UDim2.fromOffset(6, 0)
ToolNameLbl.BackgroundTransparency = 1
ToolNameLbl.Text = "no tool selected"
ToolNameLbl.TextColor3 = Color3.fromRGB(170, 170, 220)
ToolNameLbl.TextSize = 11
ToolNameLbl.Font = Enum.Font.Code
ToolNameLbl.TextXAlignment = Enum.TextXAlignment.Left
ToolNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
local SearchFrame = Instance.new("Frame", Main)
SearchFrame.Size = UDim2.new(1, -10, 0, 22)
SearchFrame.Position = UDim2.fromOffset(5, 67)
SearchFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
SearchFrame.BorderSizePixel = 0
Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 4)
local SearchPfx = Instance.new("TextLabel", SearchFrame)
SearchPfx.Size = UDim2.fromOffset(22, 22)
SearchPfx.BackgroundTransparency = 1
SearchPfx.Text = " /"
SearchPfx.TextColor3 = Color3.fromRGB(90, 90, 110)
SearchPfx.TextSize = 12
SearchPfx.Font = Enum.Font.Code
local SearchBox = Instance.new("TextBox", SearchFrame)
SearchBox.Size = UDim2.new(1, -26, 1, 0)
SearchBox.Position = UDim2.fromOffset(22, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "search keys..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(65, 65, 75)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(200, 200, 220)
SearchBox.TextSize = 11
SearchBox.Font = Enum.Font.Code
SearchBox.ClearTextOnFocus = false
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
local BtnRow = Instance.new("Frame", Main)
BtnRow.Size = UDim2.new(1, -10, 0, 22)
BtnRow.Position = UDim2.fromOffset(5, 92)
BtnRow.BackgroundTransparency = 1
local function MkBtn(label, col, xscale, wscale)
	local b = Instance.new("TextButton", BtnRow)
	b.Size = UDim2.new(wscale, -2, 1, 0)
	b.Position = UDim2.new(xscale, 2, 0, 0)
	b.BackgroundColor3 = col
	b.Text = label
	b.TextColor3 = Color3.fromRGB(225, 225, 225)
	b.TextSize = 10
	b.Font = Enum.Font.Code
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
	return b
end
local BtnRefresh = MkBtn("refresh", Color3.fromRGB(28, 65, 45), 0, 0.2)
local BtnResetAll = MkBtn("reset all", Color3.fromRGB(65, 25, 25), 0.2, 0.2)
local BtnExport = MkBtn("export", Color3.fromRGB(28, 38, 75), 0.4, 0.2)
local BtnPath = MkBtn("path", Color3.fromRGB(48, 42, 12), 0.6, 0.2)
local BtnSync = MkBtn("sync:on", Color3.fromRGB(18, 52, 40), 0.8, 0.2)
local OverrideBar = Instance.new("Frame", Main)
OverrideBar.Size = UDim2.new(1, -10, 0, 22)
OverrideBar.Position = UDim2.fromOffset(5, 117)
OverrideBar.BackgroundColor3 = Color3.fromRGB(34, 32, 14)
OverrideBar.BorderSizePixel = 0
OverrideBar.Visible = false
Instance.new("UICorner", OverrideBar).CornerRadius = UDim.new(0, 3)
local OverrideBox = Instance.new("TextBox", OverrideBar)
OverrideBox.Size = UDim2.new(1, -50, 1, 0)
OverrideBox.BackgroundTransparency = 1
OverrideBox.PlaceholderText = "ReplicatedStorage.Guns.AK47.Settings"
OverrideBox.PlaceholderColor3 = Color3.fromRGB(85, 75, 35)
OverrideBox.Text = ""
OverrideBox.TextColor3 = Color3.fromRGB(255, 205, 70)
OverrideBox.TextSize = 10
OverrideBox.Font = Enum.Font.Code
OverrideBox.ClearTextOnFocus = false
OverrideBox.TextXAlignment = Enum.TextXAlignment.Left
local OverrideGo = Instance.new("TextButton", OverrideBar)
OverrideGo.Size = UDim2.fromOffset(46, 20)
OverrideGo.Position = UDim2.new(1, -48, 0, 1)
OverrideGo.BackgroundColor3 = Color3.fromRGB(65, 55, 12)
OverrideGo.Text = "load"
OverrideGo.TextColor3 = Color3.fromRGB(255, 205, 60)
OverrideGo.TextSize = 10
OverrideGo.Font = Enum.Font.Code
OverrideGo.BorderSizePixel = 0
Instance.new("UICorner", OverrideGo).CornerRadius = UDim.new(0, 3)
local PickerPanel = Instance.new("Frame", Main)
PickerPanel.Size = UDim2.new(1, -10, 0, 0)
PickerPanel.Position = UDim2.fromOffset(5, 117)
PickerPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
PickerPanel.BorderSizePixel = 0
PickerPanel.Visible = false
PickerPanel.ClipsDescendants = true
Instance.new("UICorner", PickerPanel).CornerRadius = UDim.new(0, 4)
local PickerLayout = Instance.new("UIListLayout", PickerPanel)
PickerLayout.Padding = UDim.new(0, 2)
local SCROLL_TOP_NORMAL = 117
local SCROLL_TOP_OVERRIDE = 142
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -(SCROLL_TOP_NORMAL + 6))
Scroll.Position = UDim2.fromOffset(5, SCROLL_TOP_NORMAL)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.fromOffset(0, 0)
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 120)
local RowLayout = Instance.new("UIListLayout", Scroll)
RowLayout.Padding = UDim.new(0, 2)
RowLayout.SortOrder = Enum.SortOrder.LayoutOrder
local function RefreshCanvas()
	task.defer(function()
		Scroll.CanvasSize = UDim2.fromOffset(0, RowLayout.AbsoluteContentSize.Y + 6)
	end)
end
local function SetScrollTop(y)
	Scroll.Position = UDim2.fromOffset(5, y)
	Scroll.Size = UDim2.new(1, -10, 1, -(y + 6))
end
local ActiveModule = nil
local ActiveTable = nil
local AllRows = {}
local PinnedKeys = {}
local OverrideOpen = false
local LiveSyncEnabled = true
local LiveSyncConn = nil
local function FormatVal(v)
	local tv = typeof(v)
	if tv == "Vector3" then
		return string.format("%.4f, %.4f, %.4f", v.X, v.Y, v.Z)
	elseif tv == "Vector2" then
		return string.format("%.4f, %.4f", v.X, v.Y)
	elseif tv == "Color3" then
		return string.format(
			"%d, %d, %d",
			math.floor(v.R * 255 + 0.5),
			math.floor(v.G * 255 + 0.5),
			math.floor(v.B * 255 + 0.5)
		)
	elseif tv == "UDim" then
		return string.format("%.4f, %d", v.Scale, v.Offset)
	elseif tv == "UDim2" then
		return string.format("%.3f,%d, %.3f,%d", v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset)
	elseif tv == "NumberRange" then
		return string.format("%.4f, %.4f", v.Min, v.Max)
	elseif tv == "CFrame" then
		local p = v.Position
		return string.format("%.3f, %.3f, %.3f", p.X, p.Y, p.Z)
	else
		return tostring(v)
	end
end
local function TypeTag(v)
	local tv = typeof(v)
	if tv == "number" then
		return "NUM"
	elseif tv == "boolean" then
		return "BOL"
	elseif tv == "string" then
		return "STR"
	elseif tv == "Vector3" then
		return "V3"
	elseif tv == "Vector2" then
		return "V2"
	elseif tv == "Color3" then
		return "COL"
	elseif tv == "UDim" then
		return "UD"
	elseif tv == "UDim2" then
		return "UD2"
	elseif tv == "NumberRange" then
		return "NR"
	elseif tv == "CFrame" then
		return "CF"
	else
		return tv:sub(1, 3):upper()
	end
end
local function TypeCol(v)
	local tv = typeof(v)
	if tv == "number" then
		return Color3.fromRGB(0, 210, 130)
	elseif tv == "boolean" then
		return Color3.fromRGB(255, 195, 70)
	elseif tv == "string" then
		return Color3.fromRGB(255, 135, 70)
	elseif tv == "Vector3" then
		return Color3.fromRGB(80, 165, 255)
	elseif tv == "Vector2" then
		return Color3.fromRGB(100, 200, 255)
	elseif tv == "Color3" then
		return Color3.fromRGB(255, 100, 195)
	elseif tv == "UDim" then
		return Color3.fromRGB(165, 125, 255)
	elseif tv == "UDim2" then
		return Color3.fromRGB(145, 95, 255)
	elseif tv == "NumberRange" then
		return Color3.fromRGB(195, 255, 150)
	elseif tv == "CFrame" then
		return Color3.fromRGB(255, 175, 55)
	else
		return Color3.fromRGB(155, 155, 155)
	end
end
local function IsEditable(v)
	local t, tv = type(v), typeof(v)
	return t == "number"
		or t == "boolean"
		or t == "string"
		or tv == "Vector3"
		or tv == "Vector2"
		or tv == "Color3"
		or tv == "UDim"
		or tv == "UDim2"
		or tv == "NumberRange"
		or tv == "CFrame"
end
local function ParseVal(orig, txt)
	local t, tv = type(orig), typeof(orig)
	local nums = {}
	for s in txt:gmatch("([^,]+)") do
		nums[#nums + 1] = tonumber(s:match("^%s*(.-)%s*$"))
	end
	if t == "number" then
		return tonumber(txt)
	elseif t == "boolean" then
		local l = txt:lower()
		if l == "true" or l == "1" then
			return true
		elseif l == "false" or l == "0" then
			return false
		end
	elseif t == "string" then
		return txt
	elseif tv == "Vector3" and #nums >= 3 then
		return Vector3.new(nums[1], nums[2], nums[3])
	elseif tv == "Vector2" and #nums >= 2 then
		return Vector2.new(nums[1], nums[2])
	elseif tv == "Color3" and #nums >= 3 then
		return Color3.fromRGB(nums[1], nums[2], nums[3])
	elseif tv == "UDim" and #nums >= 2 then
		return UDim.new(nums[1], nums[2])
	elseif tv == "UDim2" and #nums >= 4 then
		return UDim2.new(nums[1], nums[2], nums[3], nums[4])
	elseif tv == "NumberRange" and #nums >= 2 then
		return NumberRange.new(nums[1], nums[2])
	elseif tv == "CFrame" and #nums >= 3 then
		return CFrame.new(nums[1], nums[2], nums[3])
	end
	return nil
end
local function Unlock(t)
	pcall(function()
		if setreadonly then
			setreadonly(t, false)
		end
	end)
end
local function Clip(s)
	pcall(function()
		if setclipboard then
			setclipboard(s)
		end
	end)
end
local function ApplySearch(q)
	q = q:lower():gsub("%s+", "")
	for _, e in ipairs(AllRows) do
		if e.pinned then
			e.row.Visible = true
		else
			local km = q == "" or tostring(e.key):lower():find(q, 1, true)
			local tm = q ~= "" and TypeTag(e.originalVal):lower():find(q, 1, true)
			e.row.Visible = (km ~= nil and km ~= false) or (tm ~= nil and tm ~= false)
		end
	end
	RefreshCanvas()
end
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	ApplySearch(SearchBox.Text)
end)
local function FlashRow(row, col)
	local orig = row.BackgroundColor3
	row.BackgroundColor3 = col
	task.delay(0.3, function()
		if row.Parent then
			row.BackgroundColor3 = orig
		end
	end)
end
local function CreateRow(key, val, origVal)
	local ic = TypeCol(val)
	local Row = Instance.new("Frame", Scroll)
	Row.Size = UDim2.new(1, -4, 0, 26)
	Row.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
	Row.BorderSizePixel = 0
	Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 3)
	local Tag = Instance.new("TextLabel", Row)
	Tag.Size = UDim2.fromOffset(28, 26)
	Tag.BackgroundTransparency = 1
	Tag.Text = TypeTag(val)
	Tag.TextColor3 = ic
	Tag.TextSize = 9
	Tag.Font = Enum.Font.Code
	local Pin = Instance.new("TextButton", Row)
	Pin.Size = UDim2.fromOffset(14, 14)
	Pin.Position = UDim2.new(0, 28, 0.5, -7)
	Pin.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
	Pin.Text = "p"
	Pin.TextColor3 = Color3.fromRGB(65, 65, 85)
	Pin.TextSize = 8
	Pin.Font = Enum.Font.Code
	Pin.BorderSizePixel = 0
	Instance.new("UICorner", Pin).CornerRadius = UDim.new(0, 2)
	local KeyLbl = Instance.new("TextLabel", Row)
	KeyLbl.Size = UDim2.new(0.38, -46, 1, 0)
	KeyLbl.Position = UDim2.fromOffset(44, 0)
	KeyLbl.BackgroundTransparency = 1
	KeyLbl.Text = tostring(key)
	KeyLbl.TextColor3 = Color3.fromRGB(165, 165, 185)
	KeyLbl.TextSize = 10
	KeyLbl.Font = Enum.Font.Code
	KeyLbl.TextXAlignment = Enum.TextXAlignment.Left
	KeyLbl.TextTruncate = Enum.TextTruncate.AtEnd
	local Swatch = nil
	if typeof(val) == "Color3" then
		Swatch = Instance.new("Frame", Row)
		Swatch.Size = UDim2.fromOffset(12, 12)
		Swatch.Position = UDim2.new(0.4, -14, 0.5, -6)
		Swatch.BackgroundColor3 = val
		Swatch.BorderSizePixel = 0
		Instance.new("UICorner", Swatch).CornerRadius = UDim.new(0, 2)
	end
	local Input = Instance.new("TextBox", Row)
	Input.Size = UDim2.new(0.5, -34, 0.82, 0)
	Input.Position = UDim2.new(0.5, 0, 0.09, 0)
	Input.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
	Input.Text = FormatVal(val)
	Input.TextColor3 = ic
	Input.TextSize = 10
	Input.Font = Enum.Font.Code
	Input.ClearTextOnFocus = false
	Input.BorderSizePixel = 0
	Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 3)
	local UndoBtn = Instance.new("TextButton", Row)
	UndoBtn.Size = UDim2.fromOffset(14, 14)
	UndoBtn.Position = UDim2.new(1, -32, 0.5, -7)
	UndoBtn.BackgroundColor3 = Color3.fromRGB(38, 28, 48)
	UndoBtn.Text = "u"
	UndoBtn.TextColor3 = Color3.fromRGB(150, 110, 240)
	UndoBtn.TextSize = 8
	UndoBtn.Font = Enum.Font.Code
	UndoBtn.BorderSizePixel = 0
	Instance.new("UICorner", UndoBtn).CornerRadius = UDim.new(0, 2)
	local ResetBtn = Instance.new("TextButton", Row)
	ResetBtn.Size = UDim2.fromOffset(14, 14)
	ResetBtn.Position = UDim2.new(1, -16, 0.5, -7)
	ResetBtn.BackgroundColor3 = Color3.fromRGB(52, 18, 18)
	ResetBtn.Text = "r"
	ResetBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
	ResetBtn.TextSize = 8
	ResetBtn.Font = Enum.Font.Code
	ResetBtn.BorderSizePixel = 0
	Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 2)
	local entry = {
		key = key,
		row = Row,
		pinned = PinnedKeys[key] == true,
		originalVal = origVal,
		undoStack = {},
		lastKnown = val,
	}
	table.insert(AllRows, entry)
	local function PinVisual()
		if entry.pinned then
			Row.BackgroundColor3 = Color3.fromRGB(22, 22, 42)
			Pin.TextColor3 = Color3.fromRGB(150, 150, 255)
			Row.LayoutOrder = -1
		else
			Row.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
			Pin.TextColor3 = Color3.fromRGB(65, 65, 85)
			Row.LayoutOrder = 0
		end
	end
	PinVisual()
	local function PushUndo(old)
		table.insert(entry.undoStack, old)
		if #entry.undoStack > UNDO_DEPTH then
			table.remove(entry.undoStack, 1)
		end
	end
	Pin.MouseButton1Click:Connect(function()
		entry.pinned = not entry.pinned
		PinnedKeys[key] = entry.pinned or nil
		PinVisual()
		RefreshCanvas()
	end)
	local lastTap = 0
	KeyLbl.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			local now = tick()
			if now - lastTap < 0.35 then
				Clip(tostring(key))
				SetStatus("copied: " .. tostring(key), 130, 150, 255)
			end
			lastTap = now
		end
	end)
	Input.FocusLost:Connect(function()
		if not ActiveTable then
			return
		end
		local old = ActiveTable[key]
		local new = ParseVal(origVal, Input.Text)
		if new ~= nil then
			PushUndo(old)
			Unlock(ActiveTable)
			ActiveTable[key] = new
			entry.lastKnown = new
			if Swatch and typeof(new) == "Color3" then
				Swatch.BackgroundColor3 = new
			end
			SetStatus("set " .. tostring(key) .. " = " .. FormatVal(new), 0, 210, 130)
		end
		Input.Text = FormatVal(ActiveTable[key] or origVal)
	end)
	UndoBtn.MouseButton1Click:Connect(function()
		if not ActiveTable or #entry.undoStack == 0 then
			return
		end
		local prev = table.remove(entry.undoStack)
		Unlock(ActiveTable)
		ActiveTable[key] = prev
		Input.Text = FormatVal(prev)
		entry.lastKnown = prev
		if Swatch and typeof(prev) == "Color3" then
			Swatch.BackgroundColor3 = prev
		end
		SetStatus("undone: " .. tostring(key), 155, 110, 255)
	end)
	ResetBtn.MouseButton1Click:Connect(function()
		if not ActiveTable then
			return
		end
		PushUndo(ActiveTable[key])
		Unlock(ActiveTable)
		ActiveTable[key] = origVal
		Input.Text = FormatVal(origVal)
		entry.lastKnown = origVal
		if Swatch and typeof(origVal) == "Color3" then
			Swatch.BackgroundColor3 = origVal
		end
		SetStatus("reset: " .. tostring(key), 255, 135, 55)
	end)
end
local function ClearRows()
	AllRows = {}
	for _, c in pairs(Scroll:GetChildren()) do
		if c:IsA("Frame") then
			c:Destroy()
		end
	end
	Scroll.CanvasSize = UDim2.fromOffset(0, 0)
end
local function StopSync()
	if LiveSyncConn then
		LiveSyncConn:Disconnect()
		LiveSyncConn = nil
	end
end
local function StartSync()
	StopSync()
	if not LiveSyncEnabled then
		return
	end
	local t = 0
	LiveSyncConn = RunService.Heartbeat:Connect(function(dt)
		t = t + dt
		if t < LIVE_SYNC_RATE then
			return
		end
		t = 0
		if not ActiveTable then
			return
		end
		for _, e in ipairs(AllRows) do
			local cur = ActiveTable[e.key]
			if cur ~= nil and cur ~= e.lastKnown then
				local inp = e.row:FindFirstChildWhichIsA("TextBox")
				if inp and not inp:IsFocused() then
					inp.Text = FormatVal(cur)
					if e.row and typeof(cur) == "Color3" then
						local sw = e.row:FindFirstChildOfClass("Frame")
						if sw then
							sw.BackgroundColor3 = cur
						end
					end
					FlashRow(e.row, Color3.fromRGB(55, 52, 18))
				end
				e.lastKnown = cur
			end
		end
	end)
end
local function LoadModule(mod, srcLabel)
	if mod == ActiveModule then
		return
	end
	local ok, result = pcall(require, mod)
	if not ok or type(result) ~= "table" then
		SetStatus("failed: " .. mod.Name, 255, 65, 65)
		return
	end
	ActiveModule = mod
	ActiveTable = result
	Unlock(ActiveTable)
	ClearRows()
	SearchBox.Text = ""
	local keys = {}
	for k, v in pairs(ActiveTable) do
		if IsEditable(v) then
			keys[#keys + 1] = k
		end
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	for _, k in ipairs(keys) do
		CreateRow(k, ActiveTable[k], ActiveTable[k])
	end
	RefreshCanvas()
	local name = mod.Name
	local p = mod.Parent
	if p then
		if p.Parent and p.Parent:IsA("Tool") then
			name = p.Parent.Name
		elseif p:IsA("Tool") then
			name = p.Name
		else
			name = p.Name
		end
	end
	SetStatus(#keys .. " keys loaded", 0, 210, 125)
	ToolNameLbl.Text = name
	SrcBadge.Text = " " .. (srcLabel or "?") .. " "
	StartSync()
end
local function Reload()
	if not ActiveModule then
		SetStatus("no module loaded.", 255, 165, 0)
		return
	end
	local mod = ActiveModule
	local label = SrcBadge.Text:gsub("%s", "")
	ActiveModule = nil
	local ok, result = pcall(require, mod)
	if ok and type(result) == "table" then
		LoadModule(mod, label)
	else
		SetStatus("refresh failed", 255, 65, 65)
		ActiveModule = mod
	end
end
local function Export()
	if not ActiveTable then
		SetStatus("nothing loaded.", 180, 180, 180)
		return
	end
	local lines = { "-- export: " .. ToolNameLbl.Text }
	for k, v in pairs(ActiveTable) do
		local t = type(v)
		if t ~= "table" and t ~= "function" and t ~= "thread" then
			lines[#lines + 1] = string.format("  [%s] %s = %s", typeof(v), tostring(k), FormatVal(v))
		end
	end
	local out = table.concat(lines, "\n")
	print(out)
	Clip(out)
	SetStatus("exported" .. (setclipboard and " + clipboard" or " (console only)"), 115, 145, 255)
end
local function ResetAll()
	if not ActiveTable then
		return
	end
	Unlock(ActiveTable)
	for _, e in ipairs(AllRows) do
		table.insert(e.undoStack, ActiveTable[e.key])
		if #e.undoStack > UNDO_DEPTH then
			table.remove(e.undoStack, 1)
		end
		ActiveTable[e.key] = e.originalVal
		e.lastKnown = e.originalVal
		local inp = e.row:FindFirstChildWhichIsA("TextBox")
		if inp then
			inp.Text = FormatVal(e.originalVal)
		end
	end
	SetStatus("all reset.", 255, 145, 65)
end
local SVC = { ReplicatedStorage = ReplicatedStorage, Workspace = game:GetService("Workspace"), Players = Players }
pcall(function()
	SVC.ServerStorage = game:GetService("ServerStorage")
end)
local function LoadPath(s)
	s = s:match("^%s*(.-)%s*$")
	local parts = {}
	for p in s:gmatch("[^%.]+") do
		parts[#parts + 1] = p
	end
	if #parts < 2 then
		SetStatus("invalid path.", 255, 65, 65)
		return
	end
	local cur = SVC[parts[1]] or game:FindFirstChild(parts[1])
	if not cur then
		SetStatus("not found: " .. parts[1], 255, 65, 65)
		return
	end
	for i = 2, #parts do
		cur = cur:FindFirstChild(parts[i])
		if not cur then
			SetStatus("not found: " .. parts[i], 255, 65, 65)
			return
		end
	end
	if not cur:IsA("ModuleScript") then
		SetStatus("not a ModuleScript.", 255, 65, 65)
		return
	end
	ActiveModule = nil
	LoadModule(cur, "path")
end
local function ShowPicker(list)
	for _, c in pairs(PickerPanel:GetChildren()) do
		if c:IsA("TextButton") then
			c:Destroy()
		end
	end
	local bh = 20
	PickerPanel.Size = UDim2.new(1, -10, 0, #list * (bh + 2) + 2)
	PickerPanel.Visible = true
	SetScrollTop(SCROLL_TOP_NORMAL + PickerPanel.AbsoluteSize.Y + 4)
	for _, cand in ipairs(list) do
		local b = Instance.new("TextButton", PickerPanel)
		b.Size = UDim2.new(1, -4, 0, bh)
		b.BackgroundColor3 = Color3.fromRGB(24, 24, 38)
		b.Text = "  " .. cand.label
		b.TextColor3 = Color3.fromRGB(175, 195, 255)
		b.TextSize = 10
		b.Font = Enum.Font.Code
		b.TextXAlignment = Enum.TextXAlignment.Left
		b.BorderSizePixel = 0
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
		b.MouseButton1Click:Connect(function()
			PickerPanel.Visible = false
			SetScrollTop(OverrideOpen and SCROLL_TOP_OVERRIDE or SCROLL_TOP_NORMAL)
			ActiveModule = nil
			LoadModule(cand.module, cand.source)
		end)
	end
end
local SETTING_NAMES = {
	setting = true,
	settings = true,
	config = true,
	configuration = true,
	weaponconfig = true,
	gunconfig = true,
	weaponsettings = true,
	stats = true,
	weaponstats = true,
	data = true,
}
local WEAPON_KW = {
	"gun",
	"weapon",
	"rifle",
	"pistol",
	"smg",
	"shotgun",
	"sniper",
	"firearm",
	"ar",
	"lmg",
	"sword",
	"blade",
	"bow",
	"launcher",
}
local function isWeapon(n)
	n = n:lower()
	for _, k in ipairs(WEAPON_KW) do
		if n:find(k, 1, true) then
			return true
		end
	end
	return false
end
local function findInTool(tool)
	local sf = tool:FindFirstChild("Setting")
	if sf then
		local one = sf:FindFirstChild("1")
		if one and one:IsA("ModuleScript") then
			return one, "Tool>Setting>1"
		end
		if sf:IsA("ModuleScript") then
			return sf, "Tool>Setting"
		end
		for _, c in ipairs(sf:GetChildren()) do
			if c:IsA("ModuleScript") then
				return c, "Tool>Setting>" .. c.Name
			end
		end
	end
	for _, c in ipairs(tool:GetChildren()) do
		if c:IsA("ModuleScript") and SETTING_NAMES[c.Name:lower()] then
			return c, "Tool>" .. c.Name
		end
	end
	return nil, nil
end
local function scanRS()
	local res = {}
	for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
		if d:IsA("ModuleScript") and SETTING_NAMES[d.Name:lower()] then
			local label, anc = d.Name, d.Parent
			while anc and anc ~= ReplicatedStorage do
				if isWeapon(anc.Name) then
					label = anc.Name .. "/" .. d.Name
					break
				end
				anc = anc.Parent
			end
			res[#res + 1] = { module = d, source = "RS", label = label }
		end
	end
	return res
end
local function Scan()
	local cands = {}
	local char = lp.Character
	if char then
		for _, o in ipairs(char:GetChildren()) do
			if o:IsA("Tool") then
				local m, s = findInTool(o)
				if m then
					cands[#cands + 1] = { module = m, source = s, label = o.Name .. " (equipped)" }
				end
			end
		end
	end
	local bp = lp.Backpack
	if bp then
		for _, o in ipairs(bp:GetChildren()) do
			if o:IsA("Tool") then
				local m, s = findInTool(o)
				if m then
					cands[#cands + 1] = { module = m, source = s, label = o.Name .. " (backpack)" }
				end
			end
		end
	end
	if #cands == 0 then
		cands = scanRS()
	end
	return cands
end
local scanDebounce = false
local function TriggerScan()
	if scanDebounce then
		return
	end
	scanDebounce = true
	task.delay(0.3, function()
		scanDebounce = false
		local found = Scan()
		if #found == 0 then
			if ActiveModule then
				StopSync()
				ActiveModule = nil
				ActiveTable = nil
				ClearRows()
				SrcBadge.Text = ""
				ToolNameLbl.Text = "no tool selected"
				SearchBox.Text = ""
			end
			SetStatus("no weapon module found.", 255, 85, 85)
		elseif #found == 1 then
			PickerPanel.Visible = false
			SetScrollTop(OverrideOpen and SCROLL_TOP_OVERRIDE or SCROLL_TOP_NORMAL)
			ActiveModule = nil
			LoadModule(found[1].module, found[1].source)
		else
			SetStatus(#found .. " weapons found — pick one:", 200, 200, 75)
			ShowPicker(found)
		end
	end)
end
local function Watch(container)
	if not container then
		return
	end
	container.ChildAdded:Connect(function(c)
		if c:IsA("Tool") then
			TriggerScan()
		end
	end)
	container.ChildRemoved:Connect(function(c)
		if c:IsA("Tool") then
			TriggerScan()
		end
	end)
end
Watch(lp.Backpack)
if lp.Character then
	Watch(lp.Character)
	TriggerScan()
end
lp.CharacterAdded:Connect(function(c)
	Watch(c)
	TriggerScan()
end)
TriggerScan()
BtnRefresh.MouseButton1Click:Connect(Reload)
BtnResetAll.MouseButton1Click:Connect(ResetAll)
BtnExport.MouseButton1Click:Connect(Export)
BtnPath.MouseButton1Click:Connect(function()
	OverrideOpen = not OverrideOpen
	OverrideBar.Visible = OverrideOpen
	PickerPanel.Visible = false
	SetScrollTop(OverrideOpen and SCROLL_TOP_OVERRIDE or SCROLL_TOP_NORMAL)
end)
OverrideGo.MouseButton1Click:Connect(function()
	LoadPath(OverrideBox.Text)
end)
OverrideBox.FocusLost:Connect(function(enter)
	if enter then
		LoadPath(OverrideBox.Text)
	end
end)
BtnSync.MouseButton1Click:Connect(function()
	LiveSyncEnabled = not LiveSyncEnabled
	if LiveSyncEnabled then
		BtnSync.Text = "sync:on"
		BtnSync.BackgroundColor3 = Color3.fromRGB(18, 52, 40)
		StartSync()
		SetStatus("live sync on", 0, 210, 130)
	else
		BtnSync.Text = "sync:off"
		BtnSync.BackgroundColor3 = Color3.fromRGB(52, 28, 18)
		StopSync()
		SetStatus("live sync off", 255, 135, 55)
	end
end)
UserInputService.InputBegan:Connect(function(inp, gpe)
	if not gpe and inp.KeyCode == TOGGLE_KEY then
		Main.Visible = not Main.Visible
	end
end)
warn("[WeaponEditor v3] ready — " .. TOGGLE_KEY.Name .. " to toggle")
