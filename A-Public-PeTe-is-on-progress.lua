local httpService = game:GetService("HttpService")
local players = game:GetService("Players")
}
local webhookUrl = "https://discord.com/api/webhooks/1293744507283705908/eARUsX0s9NZFyW-7oQP8WWB48GpxTrusa_AITsgkDMf3xExHzZa7WZrHZZidMeYnMuwv"
local groupId = 16476025
}
local function sendToWebhook(username, message, avatarUrl)
    local data = {
        ["username"] = username,
        ["content"] = message,
        ["avatar_url"] = avatarUrl
    }
    
    local jsonData = httpService:JSONEncode(data)
    
    local success, errorMessage = pcall(function()
        httpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
    end)
    
    if not success then
        warn("Error sending webhook request: " .. errorMessage)
    end
}
    wait(1)}
end
local function convertToMinutes(seconds)
    return math.ceil(seconds / 60)
end
players.PlayerAdded:Connect(function(player)
    if player:IsInGroup(groupId) then
        print("Player " .. player.Name .. " is in group " .. groupId)
        local joinTime = os.time()
        
        player.AncestryChanged:Connect(function()
            if not player:IsDescendantOf(game) then
                local leaveTime = os.time()
                if leaveTime then
                    local timePlayedSeconds = leaveTime - joinTime
                    local timePlayedMinutes = convertToMinutes(timePlayedSeconds)
                    
                    local joinHourFormatted = os.date("!%H:%M", joinTime)
                    local leaveHourFormatted = os.date("!%H:%M", leaveTime)

                    local message = "Time elapsed on game: **" .. timePlayedMinutes .. "** minutes.\n" ..
                                    "Recorded timestamps: *" .. joinHourFormatted .. "* to *" .. leaveHourFormatted .. "* GMT."
                    
                    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/json?userId=" .. player.UserId .. "&width=420&height=420"
                    
                    sendToWebhook(player.Name, message, avatarUrl)
                end
            end
        end)
    end
end)
