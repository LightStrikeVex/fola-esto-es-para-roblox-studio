local httpService = game:GetService("HttpService")
local players = game:GetService("Players")

local webhookUrl = "https://discord.com/api/webhooks/1293744507283705908/eARUsX0s9NZFyW-7oQP8WWB48GpxTrusa_AITsgkDMf3xExHzZa7WZrHZZidMeYnMuwv"
local groupId = 16476025

local function sendToWebhook(username, message, iconUrl)
    local data = {
        ["username"] = username,
        ["content"] = message,
        ["avatar_url"] = iconUrl
    }
    
    local jsonData = httpService:JSONEncode(data)
    
    local success, errorMessage = pcall(function()
        httpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
    end)
    
    if not success then
        print("Error sending webhook request: " .. errorMessage)
    end
    
    wait(1)
end

local function convertToMinutes(seconds)
    return math.floor(seconds / 60)
end

players.PlayerAdded:Connect(function(player)
    if player:IsInGroup(groupId) then
        local joinTime = os.time()
        
        local thumbnailUrl = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. player.UserId .. "&size=420x420&format=Png&isCircular=false"
        local response = httpService:GetAsync(thumbnailUrl)
        local jsonData = httpService:JSONDecode(response)
        
        local imageUrl
        if jsonData and jsonData.data and jsonData.data[1] and jsonData.data[1].imageUrl then
            imageUrl = jsonData.data[1].imageUrl
        else
            imageUrl = "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-310966282D3529E36976BF6B07B1DC90-Png/420/420/AvatarHeadshot/Png/noFilter"
        end
        
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
                    
                    sendToWebhook(player.Name, message, imageUrl)
                end
            end
        end)
    end
end)
