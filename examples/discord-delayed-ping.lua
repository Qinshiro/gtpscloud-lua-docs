-- Retain stable values instead of the event object in a timer.
local CHANNEL_ID = "REPLACE_WITH_CHANNEL_ID"
local COMMAND = "-learndelay"
local DELAY_SECONDS = 2
local pending = false

if CHANNEL_ID == "REPLACE_WITH_CHANNEL_ID" then
    print("[LearnDelay] Configure CHANNEL_ID before loading this example.")
    return
end

onDiscordMessageCreateCallback(function(event)
    if not event or event:isBot() then return end
    if event:getChannelID() ~= CHANNEL_ID then return end
    if event:getContent() ~= COMMAND or pending then return end
    local channelID = event:getChannelID()
    pending = true
    timer.setTimeout(DELAY_SECONDS, function()
        pending = false
        DiscordBot.messageCreate(channelID, "Delayed pong!", nil, 0, 0, nil)
    end)
end)
