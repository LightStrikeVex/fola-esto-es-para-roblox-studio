local webhookUrl = "https://discord.com/api/webhooks/1293650802459676694/hL-I2dHVGxGLfCblBiMGZWgGtMm8lc275BqhDgcyrDV4QYzXRPWFfLSMZbw-ZipZwPaf"
local groupId = 16476025

local PlayerTracker = {}
PlayerTracker.__index = PlayerTracker

function PlayerTracker:new(userId)
    local self = setmetatable({}, PlayerTracker)
    self.userId = userId
    self.entryTime = os.time()
    self.exitTime = nil
    return self
end

function PlayerTracker:setExitTime()
    self.exitTime = os.time()
end

function PlayerTracker:getTimeElapsed()
    return self.exitTime - self.entryTime
end

function PlayerTracker:getMinutesElapsed()
    return math.floor(self:getTimeElapsed() / 60)
end

function formatGMTTime(timestamp)
    return os.date("%H:%M", timestamp)
end

function getPlayerAvatarUrl(userId)
    local Players = game:GetService("Players")
    local playerThumbnail, thumbnailType, thumbnailStatus = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    return playerThumbnail
end

function sendWebhookMessage(player, minutesElapsed, entryTimeFormatted, exitTimeFormatted)
    if player:IsInGroup(groupId) then
        local avatarUrl = getPlayerAvatarUrl(player.UserId)

        local message = {
            content = "Time elapsed on site: **" .. minutesElapsed .. "** minutes.\nRecorded timestamps: *" .. entryTimeFormatted .. "* to *" .. exitTimeFormatted .. "* GMT.",
            username = player.Name,
            avatar_url = avatarUrl
        }

        local httpService = game:GetService("HttpService")

        local success, err = pcall(function()
            httpService:PostAsync(webhookUrl, httpService:JSONEncode(message), Enum.HttpContentType.ApplicationJson)
        end)

        if not success then
            warn("Error sending webhook message: " .. err)
        end
    end
end

local playerData = {}

game.Players.PlayerAdded:Connect(function(player)
    playerData[player.UserId] = PlayerTracker:new(player.UserId)
end)

game.Players.PlayerRemoving:Connect(function(player)
    if playerData[player.UserId] then
        playerData[player.UserId]:setExitTime()

        local timeElapsed = playerData[player.UserId]:getTimeElapsed()
        local minutesElapsed = playerData[player.UserId]:getMinutesElapsed()

        local entryTimeFormatted = formatGMTTime(playerData[player.UserId].entryTime)
        local exitTimeFormatted = formatGMTTime(playerData[player.UserId].exitTime)

        sendWebhookMessage(player, minutesElapsed, entryTimeFormatted, exitTimeFormatted)

        playerData[player.UserId] = nil
    end
end)
