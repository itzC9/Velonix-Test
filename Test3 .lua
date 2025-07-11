loadstring(game:HttpGet("https://raw.githubusercontent.com/itzC9/Velonix-UI-Library/refs/heads/main/Main3.lua"))()

local espRunning = false
local espObjects = {}
local connections = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local assistConnection = nil

local fovEnabled = false
local fovSize = 100
local fovCircle = nil

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
	
	for _, conn in ipairs(connections) do
		if conn and conn.Disconnect then
			pcall(function() conn:Disconnect() end)
		end
	end
	table.clear(connections)
    
	for _, esp in pairs(espObjects) do
		for _, v in pairs(esp) do
			if v and v.Remove then
				pcall(function() v:Remove() end)
			end
		end
	end
	table.clear(espObjects)
end

function getClosestTarget()
    local closest = nil
    local minDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                if fovEnabled then
                    if dist <= fovSize and dist < minDist then
                        minDist = dist
                        closest = hrp
                    end
                else
                    if dist < minDist then
                        minDist = dist
                        closest = hrp
                    end
                end
            end
        end
    end

    return closest
end

function AssistOn()
    if assistConnection then return end

    assistConnection = RunService.RenderStepped:Connect(function()
        local target = getClosestTarget()
        if target then
            local direction = (target.Position - Camera.CFrame.Position).Unit
            local newCF = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
            Camera.CFrame = newCF
        end
    end)
end

function AssistOff()
    if assistConnection then
        assistConnection:Disconnect()
        assistConnection = nil
    end
end

function fovON()
    fovEnabled = true
    if fovCircle then return end

    fovCircle = Drawing.new("Circle")
    fovCircle.Radius = fovSize
    fovCircle.Thickness = 2
    fovCircle.Filled = false
    fovCircle.Visible = true
    fovCircle.Color = Color3.fromRGB(255, 255, 255)

    RunService:BindToRenderStep("FOVFollow", Enum.RenderPriority.Camera.Value + 1, function()
        fovCircle.Position = UserInputService:GetMouseLocation()
    end)
end

function fovOFF()
    fovEnabled = false
    if fovCircle then
        fovCircle:Remove()
        fovCircle = nil
    end
    RunService:UnbindFromRenderStep("FOVFollow")
end

createWindow("Velonix-Universal", 28)
addLogo(12345678)

createTab("Home", 1)
createLabel("Credits:", "Founder: itzC9\nScripter: GoodgamerYT", 1)
createButton("Unknown Button", 1, function()
    print("Button Clicked!")
end)
createTab("Player", 2)
createToggle("Aimbot", 2, false, function(s)
    if s then
        AssistOn()
    else
        AssistOff()
    end
end)
createTab("Visuals", 3)
createToggle("ESP", 3, false, function(s)
    if s then
        createESP()
    else
        removeESP()
    end
end)
createTab("Other", 4)
createToggle("FOV", 4, false, function(s)
    if s then
        fovON()
    else
        fovOFF()
    end
end)

createTextBox(4, "FOV Size", function(text)
    local num = tonumber(text)
    if num then
        fovSize = num
        if fovCircle then
            fovCircle.Radius = fovSize
        end
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