loadstring(game:HttpGet("https://raw.githubusercontent.com/itzC9/Velonix-UI-Library/refs/heads/main/Main3.lua"))()

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
local profit_data = {}
local last_profit_check = 0

-- Anti-AFK
local VirtualInputManager = game:GetService("VirtualInputManager")
local function antiAfk()
    local connection
    connection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualInputManager:SendKeyEvent(true, "W", false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "W", false, game)
    end)
    return connection
end
local antiAfkConnection = antiAfk()

-- Profit Calculator
local function calculate_profit()
    local current_time = os.time()
    if current_time - last_profit_check < 5 then
        return profit_data
    end
    last_profit_check = current_time
    
    local character = LocalPlayer.Character
    if not character then return profit_data end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return profit_data end
    
    local farm = get_player_farm()
    if not farm then return profit_data end
    
    local plants_physical = farm.Important.Plants_Physical
    if not plants_physical then return profit_data end
    
    local total_value = 0
    local plant_count = 0
    
    for _, plant in ipairs(plants_physical:GetChildren()) do
        for _, descendant in ipairs(plant:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and descendant.Enabled then
                local dist = (rootPart.Position - descendant.Parent.Position).Magnitude
                if not settings.use_distance_check or dist <= settings.collection_distance then
                    local fruit_value = descendant.Parent:GetAttribute("Value") or 0
                    total_value = total_value + fruit_value
                    plant_count = plant_count + 1
                end
            end
        end
    end
    
    profit_data = {
        total_value = total_value,
        plant_count = plant_count,
        last_updated = os.date("%X")
    }
    
    return profit_data
end

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

createWindow("Velonix-GaG", 28)
addLogo(121332021347640)

createTab("Home", 1)

-- HOME TAB
createLabel("Made By Velonix Team", 1)
createDivider(1)
createToggle("Auto Collect", 1, false, function(s)
    is_auto_collecting = s
    if s then
        task.spawn(auto_collect_fruits)
    end
end)
createDivider(1)
local selected_seed = "Carrot"
createTextBox(1, "Seed to Plant", function(t)
    selected_seed = t
end)
createDivider(1)
createToggle("Distance Check", 1, false, function(s)
    settings.use_distance_check = s
end)
createDivider(1)
createToggle("Debug Mode", 1, false, function(s)
    settings.debug_mode = s
end)

-- PLAYER TAB
createTab("Player", 2)
local seeds = {
    "Carrot", "Strawberry", "Blueberry", "Rose",
    "Orange Tulip", "Stonebite", "Tomato", "Daffodil"
}

local autoBuyStates = {}
local customSeedNames = {}

for _, seed in ipairs(seeds) do
    autoBuyStates[seed] = false
    customSeedNames[seed] = seed

    createToggle("Auto-Buy " .. seed, 2, false, function(s)
        autoBuyStates[seed] = s
        if s then
            ReplicatedStorage.GameEvents.BuySeedStock:FireServer(customSeedNames[seed])
        else
            createNotify("Auto-Buy:", seed .. " disabled.")
        end
    end)
end

-- PROFIT TAB
createTab("Profit", 3)
createButton("Calculate Profit", 3, function()
    local profit = calculate_profit()
    createNotify("Profit Calculator", 
        string.format("Total Value: $%d\nPlants Ready: %d\nLast Updated: %s", 
        profit.total_value or 0, 
        profit.plant_count or 0, 
        profit.last_updated or "Never"))
end)
createLabel("Click to calculate current farm profit", 3)
createTab("Credits", 4)
createTab("-- itzC9", 4)
createTab("-- GoodGamerYT", 4)
createTab("-- Velonix Studio", 4)
-- Settings
createSettingButton("Rejoin", function()
    TeleportService:TeleportToPlaceInstance(PLACE_ID, CURRENT_JOB, LocalPlayer)
end)

createSettingButton("Small-Server", function()
    local cursor = ""
    local found = false

    repeat
        local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100%s", PLACE_ID, (cursor ~= "" and "&cursor="..cursor or ""))
        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and response and response.data then
            for _, server in ipairs(response.data) do
                if server.playing < server.maxPlayers and server.id ~= CURRENT_JOB then
                    found = true
                    TeleportService:TeleportToPlaceInstance(PLACE_ID, server.id, LocalPlayer)
                    break
                end
            end
            cursor = response.nextPageCursor
        else
            break
        end

        task.wait(1)
    until found or not cursor
end)

createSettingButton("Discord", function()
    setclipboard("https://discord.gg/czwp9fWzkz")
end)

createNotify("Velonix Studio: ","Velonix Hub Successfully Loaded!")