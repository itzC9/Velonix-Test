loadstring(game:HttpGet("https://raw.githubusercontent.com/ug32-C9/Velonix-UI-Library/refs/heads/main/Main3.lua"))()

local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")

local dashActive = false
local dashConnection

local comboActive = false
local comboConnection

local espRunning = false
local espObjects = {}
local connections = {}

function createESP()
	if espRunning then return end
	espRunning = true

	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local Camera = workspace.CurrentCamera
	local LocalPlayer = Players.LocalPlayer

	local function createEsp(player)
		if player == LocalPlayer or espObjects[player] then return end

		local espData = {
			box = Drawing.new("Square"),
			line = Drawing.new("Line"),
			text = Drawing.new("Text"),
			healthText = Drawing.new("Text")
		}

		espData.box.Thickness = 1
		espData.box.Filled = false
		espData.box.Color = Color3.fromRGB(0, 255, 0)
		espData.box.Visible = false

		espData.line.Thickness = 1
		espData.line.Color = Color3.fromRGB(0, 255, 0)
		espData.line.Visible = false

		espData.text.Size = 16
		espData.text.Center = true
		espData.text.Outline = true
		espData.text.OutlineColor = Color3.new(0, 0, 0)
		espData.text.Color = Color3.fromRGB(255, 255, 255)
		espData.text.Visible = false
		espData.text.Font = 2

		espData.healthText.Size = 14
		espData.healthText.Center = true
		espData.healthText.Outline = true
		espData.healthText.OutlineColor = Color3.new(0, 0, 0)
		espData.healthText.Color = Color3.fromRGB(255, 255, 255)
		espData.healthText.Visible = false
		espData.healthText.Font = 2

		espObjects[player] = espData
	end

	local function updateEsp()
		local Camera = workspace.CurrentCamera
		for player, esp in pairs(espObjects) do
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local humanoid = char and char:FindFirstChildOfClass("Humanoid")

			if hrp and humanoid and humanoid.Health > 0 then
				local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				if onScreen then
					local w, h = 50, 80
					local pos = Vector2.new(screenPos.X, screenPos.Y)

					esp.box.Size = Vector2.new(w, h)
					esp.box.Position = pos - Vector2.new(w / 2, h / 2)
					esp.box.Visible = true

					esp.line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
					esp.line.To = pos
					esp.line.Visible = true

					esp.text.Text = player.Name
					esp.text.Position = pos - Vector2.new(0, h / 2 + 15)
					esp.text.Visible = true

					esp.healthText.Text = string.format("%d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
					esp.healthText.Position = pos + Vector2.new(0, h / 2 + 5)
					esp.healthText.Visible = true

					local hpRatio = humanoid.Health / humanoid.MaxHealth
					local color = Color3.new(1 - hpRatio, hpRatio, 0)
					esp.box.Color = color
					esp.line.Color = color
				else
					esp.box.Visible = false
					esp.line.Visible = false
					esp.text.Visible = false
					esp.healthText.Visible = false
				end
			else
				esp.box.Visible = false
				esp.line.Visible = false
				esp.text.Visible = false
				esp.healthText.Visible = false
			end
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		createEsp(player)
	end

	table.insert(connections, Players.PlayerAdded:Connect(createEsp))
	table.insert(connections, Players.PlayerRemoving:Connect(function(player)
		local esp = espObjects[player]
		if esp then
			for _, v in pairs(esp) do
				if v.Remove then v:Remove() end
			end
			espObjects[player] = nil
		end
	end))

	table.insert(connections, RunService.RenderStepped:Connect(updateEsp))

	table.insert(connections, Players.LocalPlayer.CharacterAdded:Connect(function()
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			createEsp(player)
		end
	end))
end

function removeESP()
	if not espRunning then return end
	espRunning = false

	-- Disconnect all connections
	for _, conn in ipairs(connections) do
		if conn and conn.Disconnect then
			pcall(function() conn:Disconnect() end)
		end
	end
	table.clear(connections)

	-- Remove all drawing objects
	for _, esp in pairs(espObjects) do
		for _, v in pairs(esp) do
			if v and v.Remove then
				pcall(function() v:Remove() end)
			end
		end
	end
	table.clear(espObjects)
end

function AutoCombo()
    comboActive = true
    comboConnection = game:GetService("RunService").Heartbeat:Connect(function()
        local target = getClosestTarget()
        if target and comboActive then
            local distance = (target.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance <= 15 then
                mouse1press()
                wait(0.1)
                mouse1release()
            end
        end
    end)
end

function AutoComboOFF()
    comboActive = false
    if comboConnection then comboConnection:Disconnect() end
end

function antideathON()
    dashActive = true
    dashConnection = game:GetService("RunService").Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")

        if humanoid and humanoid.Health > 0 then
            local percent = humanoid.Health / humanoid.MaxHealth
            if percent <= 0.2 then
                -- Dash Key: Q
                keypress(Enum.KeyCode.Q)
                wait(0.1)
                keyrelease(Enum.KeyCode.Q)
            end
        end
    end)
end

function antideathOFF()
    dashActive = false
    if dashConnection then dashConnection:Disconnect() end
end

function AutoBlockOn()
    if autoBlockActive then return end
    autoBlockActive = true

    blockConnection = RunService.Heartbeat:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local enemyHRP = player.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if enemyHRP and myHRP then
                    local distance = (enemyHRP.Position - myHRP.Position).Magnitude
                    if distance <= 12 then
                        keypress(Enum.KeyCode.F)
                        wait(0.2)
                        keyrelease(Enum.KeyCode.F)
                    end
                end
            end
        end
    end)
end

function AutoBlockOff()
    autoBlockActive = false
    if blockConnection then blockConnection:Disconnect() blockConnection = nil end
end

createWindow("Velonix-TSB", 28)
addLogo(121332021347640)

createTab("Home", 1)
createLabel("Credits:", "Founder: itzC9", 1)
createLabel("Scripter: GoodgamerYT", 1)

createTab("Player", 2)
createToggle("Auto-Combo", 2, false, function(s)
    if s then
        AutoCombo()
    else
        AutoComboOFF()
    end
end)
createToggle("Auto Block", 2, false, function(s)
    if s then
        AutoBlockOn()
    else
        AutoBlockOff()
    end
end)
createToggle("Anti-Death", 2, false, function(s)
    if s then
        antideathON()
    else
        antideathOFF()
    end
end)
createTab("Visual", 3)
createToggle("ESP", 3, false, function(s)
    if s then
        createESP()
    else
        removeESP()
    end
end)

-- Settings
createSettingButton("Anti-Lag", function()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Texture") or v:IsA("Decal") then
			v.Transparency = 1
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") then
			v.Enabled = false
		elseif v:IsA("MeshPart") then
			v.Material = Enum.Material.Plastic
		end
	end
end)

createSettingButton("Boost FPS", function()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	game:GetService("Lighting").GlobalShadows = false
	game:GetService("Lighting").FogEnd = 100000
	game:GetService("Lighting").Brightness = 1
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Material = Enum.Material.SmoothPlastic
			obj.Reflectance = 0
		end
	end
end)

createSettingButton("Low-Grahics", function()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	local lighting = game:GetService("Lighting")
	lighting.GlobalShadows = false
	lighting.FogStart = 0
	lighting.FogEnd = 9e9
	lighting.Brightness = 0

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Material = Enum.Material.SmoothPlastic
			obj.Reflectance = 0
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") then
			obj.Enabled = false
		elseif obj:IsA("Texture") or obj:IsA("Decal") then
			obj:Destroy()
		end
	end

	if workspace:FindFirstChildOfClass("Terrain") then
		workspace.Terrain.WaterWaveSize = 0
		workspace.Terrain.WaterWaveSpeed = 0
		workspace.Terrain.WaterReflectance = 0
		workspace.Terrain.WaterTransparency = 0
	end
end)

createNotify("Velonix Universal","Made By GoodGamer & itzC9")