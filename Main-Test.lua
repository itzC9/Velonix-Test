-- Velonix Simple UI Loader with Drag and Close
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VelonixLoader"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 250)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Roblox classic drag
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title label
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "Velonix Script Loader"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Button container
local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(1, -40, 1, -60)
buttonFrame.Position = UDim2.new(0, 20, 0, 50)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = mainFrame

-- Button creator utility
local function createButton(text, yOrder, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.Position = UDim2.new(0, 0, 0, (yOrder - 1) * 50)
	btn.Text = text
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.BorderSizePixel = 0
	btn.Parent = buttonFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(callback)
end

-- Buttons with script load
createButton("🌱 Grow a Garden", 1, function()
	loadstring(game:HttpGet("https://github.com/itzC9/Velonix-Test/raw/refs/heads/main/Test1.lua"))()
	screenGui:Destroy()
end)

createButton("⚔️ The Strongest Battleground", 2, function()
	loadstring(game:HttpGet("https://github.com/itzC9/Velonix-Test/raw/refs/heads/main/Test2.lua"))()
	screenGui:Destroy()
end)

createButton("🧠 Steal a Brainrot (Coming Soon)", 3, function()
	print("Coming Soon")
	screenGui:Destroy()
end)

createButton("🌐 Universal Script", 3, function()
	loadstring(game:HttpGet("https://github.com/itzC9/Velonix-Test/raw/refs/heads/main/Test3.lua"))()
	screenGui:Destroy()
end)