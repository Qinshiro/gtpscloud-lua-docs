-- Standalone adaptation of the user-confirmed Find and Help callback patterns.
local COMMAND = "learnmenu"
local DIALOG_NAME = "learn_menu"

local function openMenu(player)
    local lines = {
        "set_default_color|`o",
        "add_label|big|Example Menu|left|",
        "add_smalltext|Click the button to receive a console message.|left|",
        "add_button|learn_confirm|Say Hello|no_flags|0|0|",
        "end_dialog|" .. DIALOG_NAME .. "|||",
        "add_quick_exit|"
    }
    player:onDialogRequest(table.concat(lines, "\n"))
end

registerLuaCommand({
    command = COMMAND,
    roleRequired = 0,
    description = "Open the example menu."
})

onPlayerCommandCallback(function(world, player, fullCommand)
    local command = fullCommand:match("^(%S+)")
    if not command or command:lower() ~= COMMAND then return false end
    openMenu(player)
    return true
end)

onPlayerDialogCallback(function(world, player, data)
    if data["dialog_name"] ~= DIALOG_NAME then return false end
    if data["buttonClicked"] == "learn_confirm" then
        player:onConsoleMessage("Hello from the example menu!")
    end
    return true
end)
