local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PLACE_ID = game.PlaceId
local CURRENT_JOB = game.JobId
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local buySeedEvent = GameEvents:WaitForChild("BuySeedStock")
local plantSeedEvent = GameEvents:WaitForChild("Plant_RE")

local settings = {
	auto_buy_seeds = false,
	use_distance_check = false,
	collection_distance = 10,
	collect_nearest_fruit = false,
	debug_mode = false
}

local plant_position = nil
local is_auto_planting = false
local is_auto_collecting = false

local function get_player_farm()
	for _, farm in ipairs(workspace.Farm:GetChildren()) do
		local important_folder = farm:FindFirstChild("Important")
		if important_folder then
			local owner_value = important_folder:FindFirstChild("Data") and important_folder.Data:FindFirstChild("Owner")
			if owner_value and owner_value.Value == LocalPlayer.Name then
				return farm
			end
		end
	end
	return nil
end

local function buy_seed(seed_name)
	local seed_button = playerGui.Seed_Shop.Frame.ScrollingFrame:FindFirstChild(seed_name)
	if seed_button and seed_button.Main_Frame.Cost_Text.TextColor3 ~= Color3.fromRGB(255, 0, 0) then
		createNotify("Buy Seed", "Attempting to buy seed: " .. seed_name)
		buySeedEvent:FireServer(seed_name)
	end
end

local function equip_seed(seed_name)
	local character = LocalPlayer.Character
	if not character then 
		createNotify("Equip Error", "Character not found.")
		return false 
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then 
		createNotify("Equip Error", "Humanoid not found.")
		return false 
	end

	-- Try to equip from Backpack
	for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
		if item:GetAttribute("ITEM_TYPE") == "Seed" and item:GetAttribute("Seed") == seed_name then
			humanoid:EquipTool(item)
			task.wait()

			local equipped_tool = character:FindFirstChildOfClass("Tool")
			if equipped_tool and equipped_tool:GetAttribute("ITEM_TYPE") == "Seed" and equipped_tool:GetAttribute("Seed") == seed_name then
				return equipped_tool
			end
		end
	end

	-- Check if already equipped
	local equipped_tool = character:FindFirstChildOfClass("Tool")
	if equipped_tool and equipped_tool:GetAttribute("ITEM_TYPE") == "Seed" and equipped_tool:GetAttribute("Seed") == seed_name then
		return equipped_tool
	end

	createNotify("Equip Error", "Seed not found or failed to equip: " .. seed_name)
	return false
end

function auto_collect_fruits()
	while is_auto_collecting do
		local character = LocalPlayer.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		local farm = get_player_farm()

		if not (rootPart and farm and farm.Important and farm.Important.Plants_Physical) then
			createNotify("Collect Error", "Player or farm or plants not ready.")
			task.wait(0.5)
			continue
		end

		local plants_physical = farm.Important.Plants_Physical

		if settings.collect_nearest_fruit then
			local nearest_prompt = nil
			local min_distance = math.huge

			for _, plant in ipairs(plants_physical:GetChildren()) do
				for _, descendant in ipairs(plant:GetDescendants()) do
					if descendant:IsA("ProximityPrompt") and descendant.Enabled then
						local dist = (rootPart.Position - descendant.Parent.Position).Magnitude
						if (not settings.use_distance_check or dist <= settings.collection_distance) and dist < min_distance then
							min_distance = dist
							nearest_prompt = descendant
						end
					end
				end
			end

			if nearest_prompt then
				createNotify("Collecting Nearest", nearest_prompt.Parent.Name .. " at " .. tostring(min_distance))
				fireproximityprompt(nearest_prompt)
				task.wait(0.05)
			end
		else
			for _, plant in ipairs(plants_physical:GetChildren()) do
				for _, prompt in ipairs(plant:GetDescendants()) do
					if prompt:IsA("ProximityPrompt") and prompt.Enabled then
						local should_collect = true
						local dist = (rootPart.Position - prompt.Parent.Position).Magnitude
						if settings.use_distance_check and dist > settings.collection_distance then
							should_collect = false
						end

						if should_collect then
							createNotify("Collecting", prompt.Parent.Name .. " at " .. tostring(dist))
							fireproximityprompt(prompt)
							task.wait(0.05)
						end
					end
				end
			end
		end
		task.wait()
	end
end

function auto_plant_seeds(seed_name)
	while is_auto_planting do
		local tool = equip_seed(seed_name)

		if not tool and settings.auto_buy_seeds then
			buy_seed(seed_name)
			task.wait(0.2)
			tool = equip_seed(seed_name)
		end

		if tool and plant_position then
			local quantity = tool:GetAttribute("Quantity")
			if quantity and quantity > 0 then
				createNotify("Planting", "Seed: " .. seed_name .. " | Quantity: " .. quantity)
				plantSeedEvent:FireServer(plant_position, seed_name)
			else
				createNotify("Quantity Error", "No seed left: " .. seed_name)
			end
		else
			createNotify("Equip Error", "Tool or plant position is invalid. Seed: " .. seed_name)
		end

		task.wait(0.2)
	end
end

-- Initialize Plant Position
local farm = get_player_farm()
if farm and farm.Important and farm.Important.Plant_Locations then
	local part = farm.Important.Plant_Locations:FindFirstChildOfClass("Part")
	if part then
		plant_position = part.Position
	else
		plant_position = Vector3.new(0, 0, 0)
		createNotify("Plot", "Default plant location not found.")
	end
else
	plant_position = Vector3.new(0, 0, 0)
	createNotify("Plot Error", "Farm or Plant_Locations missing.")
end