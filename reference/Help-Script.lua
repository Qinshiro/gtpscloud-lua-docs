-- Dynamic Server Commands Help Menu
-- /help, /?  -> one button per role, each opens the list of commands that role can use.
-- Commands shown here are the ones registered with registerLuaCommand (read through getRoles()).
print("(Loaded) Server Commands Help Menu (Dynamic)")

-- ======== CONFIGURATION ========
-- Local on purpose: other scripts overwrite the global `Roles`, which would break this script
local ROLE = {
    NONE = 0,
    VIP = 1,
    SUPER_VIP = 2,
    MODERATOR = 3,
    ADMIN = 4,
    COMMUNITY_MANAGER = 5,
    CREATOR = 6,
    GOD = 7,
    DEVELOPER = 51,
}

local DIALOG_ICON = 20616
local DEFAULT_COLOR = "`0"

-- Icon item ID and description per role shown at the top of the role's command list.
-- The same text can be pasted into the item's Description field in the item editor.
local ROLE_INFO = {
    [ROLE.NONE] = {description = "Commands every player can use."}, -- no icon: the header is drawn without one
    [ROLE.VIP] = {icon = 25018, description = "Commands unlocked for VIP members, on top of the default commands."},
    [ROLE.SUPER_VIP] = {icon = 25016, description = "Extra commands for Super VIP members, plus everything VIP can use."},
    [ROLE.MODERATOR] = {icon = 25014, description = "Moderation commands to keep the server safe and friendly. Use them fairly."},
    [ROLE.ADMIN] = {icon = 25012, description = "Administration commands for managing players and worlds."},
    [ROLE.COMMUNITY_MANAGER] = {icon = 25010, description = "Commands for managing the community, events and announcements."},
    [ROLE.CREATOR] = {icon = 25008, description = "Creator commands for building and managing server content."},
    [ROLE.GOD] = {icon = 25006, description = "High-level commands with almost full control of the server."},
    [ROLE.DEVELOPER] = {icon = 25004, description = "Full access commands for developing, maintaining and managing the server."},
}

-- Name color per role ID (only color codes already used by the default scripts)
local ROLE_COLORS = {
    [ROLE.DEVELOPER] = "`3",
    [ROLE.GOD] = "`$",
    [ROLE.CREATOR] = "`#",
    [ROLE.COMMUNITY_MANAGER] = "`2",
    [ROLE.ADMIN] = "`4",
    [ROLE.MODERATOR] = "`5",
    [ROLE.SUPER_VIP] = "`8",
    [ROLE.VIP] = "`6",
}

-- ======== COMMANDS ========
registerLuaCommand({
    command = "help",
    roleRequired = ROLE.NONE,
    description = "Shows the server commands menu."
})

registerLuaCommand({
    command = "?",
    roleRequired = ROLE.NONE,
    description = "Shows the server commands menu."
})

-- ======== HELPERS ========
local warned = false

-- Removes characters that could break a dialog line
local function clean(text)
    return (tostring(text):gsub("[`|%c]", ""))
end

local function roleColor(roleID)
    return ROLE_COLORS[roleID] or DEFAULT_COLOR
end

-- Roles that are not in ROLE_INFO (custom roles) get DIALOG_ICON and a generic description
local function roleInfo(roleID)
    return ROLE_INFO[roleID] or {icon = DIALOG_ICON, description = "Commands of this role."}
end

-- Copy of getRoles(), highest role ID first (Developer on top, Default at the bottom).
-- It is a copy so sorting never touches the server's own list.
local function getSortedRoles()
    local list = {}
    for _, role in pairs(getRoles()) do
        if type(role.roleID) == "number" then
            list[#list + 1] = role
        end
    end
    table.sort(list, function(a, b) return a.roleID > b.roleID end)
    return list
end

-- Plain sorted copy of the command names of a role
local function getCommandNames(role)
    local names = {}
    if type(role.allowCommands) == "table" then
        for _, name in pairs(role.allowCommands) do
            if type(name) == "string" then
                names[#names + 1] = name
            end
        end
    end
    table.sort(names)
    return names
end

local function roleTitle(role)
    if role.roleID == ROLE.NONE then
        return "Default Role"
    end
    return "@" .. clean(role.roleName or "Unknown")
end

local function sendDialog(player, lines, dialogName)
    lines[#lines + 1] = "end_dialog|" .. dialogName .. "|||"
    lines[#lines + 1] = "add_quick_exit|"
    player:onDialogRequest(table.concat(lines, "\n"))
end

-- ======== DIALOGS ========
-- Main menu: one button per role that has commands
local function openHelpMain(player)
    local lines = {
        "set_default_color|`o",
        "add_label_with_icon|big|`wServer Commands``|left|" .. DIALOG_ICON .. "|",
        "add_smalltext|Click a category below to see the list of commands.|left|",
        "add_spacer|small|",
    }

    local shown = 0
    local hasField = false
    for _, role in ipairs(getSortedRoles()) do
        if type(role.allowCommands) == "table" then hasField = true end
        local count = #getCommandNames(role)
        if count > 0 then
            shown = shown + 1
            lines[#lines + 1] = "add_button|help_cat_" .. role.roleID .. "|" ..
                roleColor(role.roleID) .. roleTitle(role) .. " (" .. count .. ")``|no_flags|0|0|"
        end
    end

    if shown == 0 then
        lines[#lines + 1] = "add_smalltext|`4No commands are registered yet.``|left|"
        -- allowCommands is not described in the API files, so tell the owner once if it is missing
        if not hasField and not warned then
            warned = true
            print("[Help] getRoles() returned no 'allowCommands' field. Check the role fields on this server build.")
        end
    end

    sendDialog(player, lines, "help_main")
end

-- Command list of one role, then the commands of every lower role (nearest role first),
-- each lower role under its own heading
local function openHelpSub(player, roleID)
    local roles = getSortedRoles() -- highest role ID first
    local target
    for _, role in ipairs(roles) do
        if role.roleID == roleID then
            target = role
            break
        end
    end
    if not target then return end

    local info = roleInfo(roleID)
    local title = roleColor(roleID) .. roleTitle(target) .. " Commands``"
    local lines = {
        "set_default_color|`o",
        -- A role without an icon (Default) gets a plain big label instead
        info.icon and ("add_label_with_icon|big|" .. title .. "|left|" .. info.icon .. "|")
            or ("add_label|big|" .. title .. "|left|"),
        "add_smalltext|" .. clean(info.description) .. "|left|",
        "add_spacer|small|",
    }

    -- A command is only listed once: the first section that has it keeps it
    local seen = {}
    local function newNames(role)
        local fresh = {}
        for _, name in ipairs(getCommandNames(role)) do
            if not seen[name] then
                seen[name] = true
                fresh[#fresh + 1] = "/" .. clean(name)
            end
        end
        return fresh
    end

    -- 1) The selected role
    local own = newNames(target)
    if #own > 0 then
        lines[#lines + 1] = "add_textbox|`w" .. table.concat(own, ", ") .. "``|left|"
    else
        lines[#lines + 1] = "add_smalltext|`4No commands found.``|left|"
    end

    -- 2) Every lower role, each with its own heading (the spacer is the border between sections)
    for _, role in ipairs(roles) do
        if role.roleID < roleID then
            local names = newNames(role)
            if #names > 0 then
                lines[#lines + 1] = "add_spacer|small|"
                lines[#lines + 1] = "add_textbox|" .. roleColor(role.roleID) .. roleTitle(role) ..
                    " (" .. #names .. ")``|left|"
                lines[#lines + 1] = "add_textbox|`w" .. table.concat(names, ", ") .. "``|left|"
            end
        end
    end

    lines[#lines + 1] = "add_spacer|small|"
    lines[#lines + 1] = "add_button|help_back|Back|no_flags|0|0|"
    sendDialog(player, lines, "help_sub")
end

-- ======== CALLBACKS ========
onPlayerCommandCallback(function(world, player, fullCommand)
    local command = fullCommand:match("^(%S+)")
    if not command then return false end
    command = command:lower()

    if command == "help" or command == "?" then
        openHelpMain(player)
        return true
    end
    return false
end)

onPlayerDialogCallback(function(world, player, data)
    local dialogName = data["dialog_name"] or ""
    local clicked = data["buttonClicked"] or ""

    if dialogName == "help_main" then
        local roleID = tonumber(clicked:match("^help_cat_(%d+)$"))
        if roleID then
            openHelpSub(player, roleID)
        end
        return true
    end

    if dialogName == "help_sub" then
        if clicked == "help_back" then
            openHelpMain(player)
        end
        return true
    end

    return false
end)