-- Standalone example using the working admin script's dot-call binding.
local CHANNEL_ID = "REPLACE_WITH_CHANNEL_ID"
local COMMAND = "-learnping"

if CHANNEL_ID == "REPLACE_WITH_CHANNEL_ID" then
    print("[LearnPing] Configure CHANNEL_ID before loading this example.")
    return
end

onDiscordMessageCreateCallback(function(event)
    if not event or event:isBot() then return end
    if event:getChannelID() ~= CHANNEL_ID then return end
    if event:getContent() ~= COMMAND then return end
    DiscordBot.messageCreate(CHANNEL_ID, "Pong!", nil, 0, 0, nil)
end)
