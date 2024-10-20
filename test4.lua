local httpService = game:GetService("HttpService")
local players = game:GetService("Players")

local webhookUrl = "https://discord.com/api/webhooks/1293744507283705908/eARUsX0s9NZFyW-7oQP8WWB48GpxTrusa_AITsgkDMf3xExHzZa7WZrHZZidMeYnMuwv"
local groupId = 16476025

local playerTimePlayed = {}

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
    
    wait(1)
end

local function convertToMinutes(seconds)
    return math.floor(seconds / 60)
end

local function getPlayerThumbnail(player)
    local userId = player.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local content, isReady = players:GetUser ThumbnailAsync(userId, thumbType, thumbSize)
    
    return isReady and content or "rbxassetid://0"
end

players.PlayerAdded:Connect(function(player)
    if player:IsInGroup(groupId) then
        local joinTime = os.time()
        
        player.AncestryChanged:Connect(function()
            if not player:IsDescendantOf(game) then
                local leaveTime = os.time()
                if leaveTime then
                    local timePlayedSeconds = leaveTime - joinTime
                    local timePlayedMinutes = convertToMinutes(timePlayedSeconds)
                    
                    if playerTimePlayed[player.UserId] then
                        playerTimePlayed[player.UserId] = playerTimePlayed[player.UserId] + timePlayedMinutes
                    else
                        playerTimePlayed[player.UserId] = timePlayedMinutes
                    end
                    
                    local joinHourFormatted = os.date("!%H:%M", joinTime)
                    local leaveHourFormatted = os.date("!%H:%M", leaveTime)

                    local message = "Time elapsed on game: **" .. playerTimePlayed[player.UserId] .. "** minutes.\n" ..
                                    "Recorded timestamps: *" .. joinHourFormatted .. "* to *" .. leaveHourFormatted .. "* GMT."
                    
                    local avatarUrl = getPlayerThumbnail(player)
                    sendToWebhook(player.Name, message, avatarUrl)
                end
            end
        end)
    end
end)
