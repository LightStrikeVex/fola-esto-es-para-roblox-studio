local webhookUrl = "https://discord.com/api/webhooks/1291955749802741812/U1pc46iFRLhoDbx94YNz2f9S_H_yqK8qlxTTFx_JL9uMpRW7zntnHYExYhRmvOxUEfOK"
local groupId = 16476025
local playerData = {}

local function formatGMTTime(timestamp)
  return os.date("%H:%M", timestamp)
end

local function sendWebhookMessage(player, minutesElapsed, entryTimeFormatted, exitTimeFormatted)
  if player:IsInGroup(groupId) then
    local message = "Time elapsed on game: **" .. minutesElapsed .. "** minutes.\nRecorded timestamps: *" .. entryTimeFormatted .. "* to *" .. exitTimeFormatted .. "* GMT."

    local httpRequest = game:GetService("HttpService"):RequestAsync({
      Url = webhookUrl,
      Method = "POST",
      Headers = {
        ["Content-Type"] = "application/json"
      },
      Body = HttpService:JSONEncode({
        content = message,
        username = player.Name,
        avatar_url = player.Thumbnail.Url
      })
    })

    if httpRequest.Success then
      print("Webhook message sent successfully!")
    else
      warn("Error sending webhook message:", httpRequest.StatusCode, httpRequest.StatusMessage)
    end
  end
end

game.Players.PlayerAdded:Connect(function(player)
  -- Initialize player data
  playerData[player.UserId] = {
    entryTime = os.time(),
    exitTime = nil
  }
end)

game.Players.PlayerRemoving:Connect(function(player)
  if playerData[player.UserId] then
    playerData[player.UserId].exitTime = os.time()

    local timeElapsed = playerData[player.UserId].exitTime - playerData[player.UserId].entryTime
    local minutesElapsed = math.floor(timeElapsed / 60)

    local entryTimeFormatted = formatGMTTime(playerData[player.UserId].entryTime)
    local exitTimeFormatted = formatGMTTime(playerData[player.UserId].exitTime)

    sendWebhookMessage(player, minutesElapsed, entryTimeFormatted, exitTimeFormatted)

    playerData[player.UserId] = nil
  end
end)
