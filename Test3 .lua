loadstring(game:HttpGet("https://raw.githubusercontent.com/itzC9/Velonix-UI-Library/refs/heads/main/Main3.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Aimbot & Auto Block Variables
local aimAssistActive = false
local autoBlockActive = false
local aimConnection = nil
local blockConnection = nil

-- FOV Settings
local fovEnabled = false
local fovSize = 100
local fovCircle = nil

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

function getClosestTarget()
    local closest = nil
    local minDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if (not fovEnabled or dist <= fovSize) and dist < minDist then
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
    if aimAssistActive then return end
    aimAssistActive = true

    aimConnection = RunService.RenderStepped:Connect(function()
        local target = getClosestTarget()
        if target then
            local direction = (target.Position - Camera.CFrame.Position).Unit
            local smoothed = Camera.CFrame.Position + direction * 10
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, smoothed)
        end
    end)
end

function AssistOff()
    aimAssistActive = false
    if aimConnection then aimConnection:Disconnect() aimConnection = nil end
end

-- UI Setup
createWindow("Velonix Universal", 28)
addLogo(121332021347640)

createTab("Player", 1)
createToggle("Aim Assist", 1, false, function(s)
    if s then AssistOn() else AssistOff() end
end)

createTab("FOV", 2)
createToggle("FOV Circle", 2, false, function(s)
    if s then fovON() else fovOFF() end
end)

createTextBox(2, "FOV Radius", function(t)
    local val = tonumber(t)
    if val then
        fovSize = val
        if fovCircle then fovCircle.Radius = val end
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

createNotify("Velonix Universal", "Made By GoodGamer & itzC9")