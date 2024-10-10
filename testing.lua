local httpService = game:GetService("HttpService")
local players = game:GetService("Players")

local webhookUrl = "https://hooks.hyra.io/webhooks/1293744507283705908/eARUsX0s9NZFyW-7oQP8WWB48GpxTrusa_AITsgkDMf3xExHzZa7WZrHZZidMeYnMuwv"

local groupId = 16476025

local function sendToWebhook(username, message)
    local data = {
        ["username"] = username,
        ["content"] = message
    }
    
    local jsonData = httpService:JSONEncode(data)
    
    httpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
end

local function convertToMinutes(seconds)
    return math.ceil(seconds / 60)
end

players.PlayerAdded:Connect(function(player)
    if player:IsInGroup(groupId) then
        local joinTime = os.time()
        local joinTimestamp = os.date("!*t", joinTime)

        player.AncestryChanged:Connect(function()
            if not player:IsDescendantOf(game) then
                local leaveTime = os.time()
                local timePlayedSeconds = leaveTime - joinTime
                local timePlayedMinutes = convertToMinutes(timePlayedSeconds)
                
                local joinHourFormatted = string.format("%02d:%02d", joinTimestamp.hour, joinTimestamp.min)
                local leaveHourFormatted = os.date("!%H:%M", leaveTime) -- Formato de la hora de salida (GMT)

                local message = "Time elapsed on game: **" .. timePlayedMinutes .. "** minutes.\n" ..
                                "Recorded timestamps: *" .. joinHourFormatted .. "* to *" .. leaveHourFormatted .. "* GMT."
                
                sendToWebhook(player.Name, message)
            end
        end)
    end
end)
