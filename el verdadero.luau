local httpService = game:GetService("HttpService")
local players = game:GetService("Players")

local webhookUrl = "https://hooks.hyra.io/webhooks/1293744507283705908/eARUsX0s9NZFyW-7oQP8WWB48GpxTrusa_AITsgkDMf3xExHzZa7WZrHZZidMeYnMuwv"
local groupId = 16476025

local function sendToWebhook(username: string, message: string, profilePictureUrl: string)
    local data = {
        ["username"] = username,
        ["content"] = message,
        ["avatar_url"] = profilePictureUrl
    }
    
    local jsonData = httpService:JSONEncode(data)
    
    local success, errorMessage = pcall(function()
        local response = httpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
        if response.StatusCode ~= 200 then
            warn("Error sending webhook request: " .. response.StatusMessage)
        end
    end)
    
    if not success then
        warn("Error sending webhook request: " .. errorMessage)
    end
    
    wait(1)
end

local function convertToMinutes(seconds: number): number
    return math.ceil(seconds / 60)
end

local function getUserProfilePicture(userId: number): string
    local url = "https://users.roblox.com/v1/users/" .. userId
    local response = httpService:GetAsync(url)
    local data = httpService:JSONDecode(response)

    if data and data.thumbnailUrl then
        return data.thumbnailUrl
    else
        warn("Error obtaining profile picture: " .. tostring(data))
        return "https://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&Format=Png&username=" .. userId
    end
end

players.PlayerAdded:Connect(function(player: Player)
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
                    
                    local profilePictureUrl = getUserProfilePicture(player.UserId)
                    sendToWebhook(player.Name, message, profilePictureUrl)
                end
            end
        end)
    end
end)
