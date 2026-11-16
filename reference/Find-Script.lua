-- Advanced Item Finder (with restricted items filter and seed filter)
-- /find <Name>, /f <Name>          Search every item whose name contains <Name> (lock = Lock, Block, Padlock...)
-- /find @<Name>, /f @<Name>        Whole word only (@lock = World Lock, Small Lock... but not Block or Padlock)
--                                  @lock can also be limited to a list of lock item IDs, see CONFIG.LOCK_SEARCH_MODE
--                                  Tick the ones you want and press Take
-- /findblock                       Open the blacklist menu (add / remove restricted items per role)
print("(Loaded) Advanced Item Finder for GrowSoft")

-- ======== CONFIGURATION ========
-- Local on purpose: other scripts overwrite the global `Roles`, which would break role checks here
local ROLE = {
    MODERATOR = 3,
    DEVELOPER = 51,
}

-- Every role ID, highest first (used to find a player's highest role)
local ROLE_IDS = {51, 7, 6, 5, 4, 3, 2, 1}

local ROLE_NAMES = {
    [51] = "Developer",
    [7] = "God",
    [6] = "Creator",
    [5] = "Community Manager",
    [4] = "Admin",
    [3] = "Moderator",
    [2] = "Super VIP",
    [1] = "VIP",
}

local CONFIG = {
    FIND_MIN_ROLE = ROLE.MODERATOR,
    FINDBLOCK_MIN_ROLE = ROLE.DEVELOPER,
    MENU_MAX_ROLE = 7,      -- highest role shown in the /findblock menu (7 = God; Developer owns the server)
    -- What "@lock" matches:
    --   "name"  = every item with the whole word "lock" in its name (World Lock, Small Lock...)
    --   "items" = only the item IDs listed in LOCK_ITEM_IDS below
    LOCK_SEARCH_MODE = "name",
    LOCK_KEYWORD = "lock",  -- the word after @ that triggers the lock search
    LOCK_ITEM_IDS = {242, 1796, 7188}, -- World Lock, Diamond Lock, Blue Gem Lock (add your other locks here)
    COLUMNS = 8,            -- icons per row (the in-game dialog fits 8 per row)
    ROWS = 5,               -- rows per page (8 x 5 = 40 items per page)
    MAX_AMOUNT = 200,       -- most you can take of one item
    DEFAULT_AMOUNT = 1,
    MAX_TICKED = 20,        -- most items that can be taken in one go (keeps the amount dialog small)
    MAX_SEARCH_LENGTH = 30,
    DIALOG_ICON = 6016,
    STORAGE_KEY = "find_cmd_blacklist",
}

local ITEMS_PER_PAGE = CONFIG.COLUMNS * CONFIG.ROWS

-- ======== STATE ========
-- pcall is not available on every server build, so fall back to a plain call
local function tryCall(fn, ...)
    if pcall then return pcall(fn, ...) end
    return true, fn(...)
end

-- blacklist[tostring(itemID)] = minimum role ID
local blacklist = {}
local loaded = loadDataFromServer(CONFIG.STORAGE_KEY)
if type(loaded) == "table" then
    for key, value in pairs(loaded) do
        local roleID = tonumber(value)
        if roleID and roleID > 0 then blacklist[tostring(key)] = roleID end
    end
end

-- sessions[userID] = {
--   find = {term, results, page, pageIDs, queue, amounts},   -- /find
--   add  = {term, results, page, pageIDs},                   -- findblock "Add Items" search
--   fbRole, remPage, remPageIDs, remQueue                    -- findblock role list / removal
-- }
local sessions = {}
local nameCache = nil -- built on the first search

-- ======== HELPERS ========
local function getHighestRole(player)
    for _, roleID in ipairs(ROLE_IDS) do
        if player:hasRole(roleID) then return roleID end
    end
    return 0
end

local function canSee(playerRole, itemID)
    return playerRole >= (blacklist[tostring(itemID)] or 0)
end

local function saveBlacklist()
    saveDataToServer(CONFIG.STORAGE_KEY, blacklist)
end

-- Removes characters that could break or inject into a dialog, then trims and limits the length
local function sanitize(text)
    text = tostring(text or ""):gsub("[`|%c]", ""):match("^%s*(.-)%s*$")
    return text:sub(1, CONFIG.MAX_SEARCH_LENGTH)
end

-- "Angel's Wings" -> " angel s wings " (lowercase, letters and digits only, one space between words)
local function normalize(text)
    local clean = tostring(text or ""):lower():gsub("[^%w]+", " ")
    return " " .. clean:match("^%s*(.-)%s*$") .. " "
end

local function cleanName(item)
    return (tostring(item:getName()):gsub("[`|%c]", ""))
end

local function getValidItem(itemID)
    if not itemID or itemID ~= math.floor(itemID) then return nil end
    if itemID < 0 or itemID >= getItemsCount() then return nil end
    return getItem(itemID)
end

local function getNameCache()
    if nameCache then return nameCache end
    nameCache = {}
    for id = 0, getItemsCount() - 1 do
        local item = getItem(id)
        local name = item and item:getName()
        if name and name ~= "" then
            -- Seeds have odd IDs (same rule Buy.lua uses when it skips seeds)
            nameCache[#nameCache + 1] = {id = id, key = normalize(name), isSeed = (id % 2 == 1)}
        end
    end
    return nameCache
end

local function newSession()
    return {
        find = {term = "", results = {}, page = 1, pageIDs = {}, queue = nil, amounts = {}},
        add = {term = "", results = {}, page = 1, pageIDs = {}},
        fbRole = nil,
        remPage = 1,
        remPageIDs = {},   -- own items drawn on the current page (these can be removed)
        fbView = nil,      -- higher role whose item list is open (view only)
        viewPage = 1,      -- page of that view-only list
        remQueue = nil,
    }
end

local function getSession(player)
    local userID = player:getUserID()
    local session = sessions[userID]
    if not session then
        session = newSession()
        sessions[userID] = session
    end
    return session
end

-- Search by name. Seeds are hidden unless the search itself contains "seed".
--   lock  -> every item whose name contains "lock" (Lock, Block, Padlock, World Lock...)
--   @lock -> whole words only (World Lock, Small Lock; not Block or Padlock).
--            With CONFIG.LOCK_SEARCH_MODE = "items" it shows only the IDs in CONFIG.LOCK_ITEM_IDS instead.
-- `accept(itemID)` decides which items may appear.
local function searchItems(rawTerm, accept)
    local term = sanitize(rawTerm)
    local results = {}

    local exact = (term:sub(1, 1) == "@")
    local needle = normalize(exact and term:sub(2) or term) -- " lock "
    local plain = needle:sub(2, -2)                          -- "lock"
    if plain == "" then return term, results end

    -- "@lock" in "items" mode: only the locks listed in the config
    if exact and CONFIG.LOCK_SEARCH_MODE == "items" and plain == CONFIG.LOCK_KEYWORD:lower() then
        for _, itemID in ipairs(CONFIG.LOCK_ITEM_IDS) do
            if getValidItem(itemID) and accept(itemID) then
                results[#results + 1] = itemID
            end
        end
        return term, results
    end

    local wantsSeed = (plain:find("seed", 1, true) ~= nil)
    for _, entry in ipairs(getNameCache()) do
        if wantsSeed or not entry.isSeed then
            local matches
            if exact then
                matches = (entry.key:find(needle, 1, true) ~= nil) -- needle is " lock ", so whole words only
            else
                matches = (entry.key:find(plain, 1, true) ~= nil)
            end
            if matches and accept(entry.id) then
                results[#results + 1] = entry.id
            end
        end
    end
    return term, results
end

local function pageBounds(total, page)
    local totalPages = math.max(1, math.ceil(total / ITEMS_PER_PAGE))
    page = math.max(1, math.min(page, totalPages))
    local first = (page - 1) * ITEMS_PER_PAGE + 1
    local last = math.min(first + ITEMS_PER_PAGE - 1, total)
    return page, totalPages, first, last
end

-- Same button style as the built-in scripts. These advance the dialog layout, so nothing overlaps
local function button(name, label)
    return "add_button|" .. name .. "|" .. label .. "|no_flags|0|0|\n"
end

-- Adds ids[first..last] as a grid of tick icons and returns the IDs that were drawn.
-- tagFn(itemID) may return extra text for the icon label (for example the item's real role).
local function addItemGrid(dialog, ids, first, last, prefix, tagFn)
    local drawn = {}
    local column = 0
    for n = first, last do
        local itemID = ids[n]
        local item = getItem(itemID)
        if item then
            drawn[#drawn + 1] = itemID
            -- Last field stays empty: any value there is drawn as a number on the icon
            dialog[#dialog + 1] = "add_checkicon|" .. prefix .. itemID .. "|" .. cleanName(item) ..
                " (" .. itemID .. ")" .. (tagFn and tagFn(itemID) or "") .. "||" .. itemID .. "||\n"
            column = column + 1
            if column % CONFIG.COLUMNS == 0 then
                dialog[#dialog + 1] = "add_custom_break|\n"
            end
        end
    end
    if column % CONFIG.COLUMNS ~= 0 then
        dialog[#dialog + 1] = "add_custom_break|\n"
    end
    return drawn
end

local function finishDialog(player, dialog, name)
    dialog[#dialog + 1] = "end_dialog|" .. name .. "|||\n"
    dialog[#dialog + 1] = "add_quick_exit|"
    player:onDialogRequest(table.concat(dialog))
end

-- ======== /find DIALOGS ========
local function openFindDialog(player)
    local session = getSession(player)
    local find = session.find

    local total = #find.results
    local page, totalPages, first, last = pageBounds(total, find.page)
    find.page = page
    find.pageIDs = {}
    find.queue = nil

    local dialog = {
        "set_default_color|`o\n",
        "add_label_with_icon|big|`wItem Finder``|left|" .. CONFIG.DIALOG_ICON .. "|\n",
        "add_spacer|small|\n",
        "add_text_input|find_search_term|Search:|" .. find.term .. "|" .. CONFIG.MAX_SEARCH_LENGTH .. "|\n",
        button("find_btn_search", "Search"),
        "add_spacer|small|\n",
    }

    if find.term == "" then
        dialog[#dialog + 1] = "add_smalltext|Type part of an item name and press Search (`wlock`` finds every item with lock in its name). Start with `w@`` for whole words only (`w@lock`` finds only locks, not Block). Seeds are hidden unless you include the word `wseed``.|left|\n"
    elseif total == 0 then
        dialog[#dialog + 1] = "add_smalltext|`4No items found for \"" .. find.term ..
            "\", or you lack permission to see them.``|left|\n"
    else
        dialog[#dialog + 1] = "add_smalltext|Results for `w\"" .. find.term .. "\"`` (`2" .. total ..
            "``) - Page `w" .. page .. "/" .. totalPages ..
            "``. Tick the items you want, then press `wTake``. You set the amount for each item next.|left|\n"
        dialog[#dialog + 1] = "add_spacer|small|\n"
        find.pageIDs = addItemGrid(dialog, find.results, first, last, "pick_")

        dialog[#dialog + 1] = "add_spacer|small|\n"
        if page > 1 then dialog[#dialog + 1] = button("find_btn_prev", "Previous Page") end
        if page < totalPages then dialog[#dialog + 1] = button("find_btn_next", "Next Page") end
        dialog[#dialog + 1] = button("find_btn_take", "Take")
    end

    dialog[#dialog + 1] = button("find_btn_close", "Cancel")
    finishDialog(player, dialog, "dialog_find_main")
end

-- One row per ticked item (icon, name, amount)
local function openTakeDialog(player)
    local session = sessions[player:getUserID()]
    if not session or not session.find.queue then return end
    local find = session.find

    local dialog = {
        "set_default_color|`o\n",
        "add_label_with_icon|big|`wTake Items``|left|" .. CONFIG.DIALOG_ICON .. "|\n",
        "add_smalltext|Enter the amount for each item (0 to " .. CONFIG.MAX_AMOUNT .. "). Use 0 to skip an item.|left|\n",
        "add_spacer|small|\n",
    }
    for _, itemID in ipairs(find.queue) do
        local item = getItem(itemID)
        dialog[#dialog + 1] = "add_label_with_icon|small|`w" .. cleanName(item) .. "``|left|" .. itemID .. "|\n"
        dialog[#dialog + 1] = "add_text_input|amt_" .. itemID .. "|Amount:|" ..
            (find.amounts[itemID] or tostring(CONFIG.DEFAULT_AMOUNT)) .. "|3|\n"
        dialog[#dialog + 1] = "add_spacer|small|\n"
    end

    dialog[#dialog + 1] = button("find_take_confirm", "Confirm")
    dialog[#dialog + 1] = button("find_take_back", "Back")
    dialog[#dialog + 1] = button("find_take_cancel", "Cancel")
    finishDialog(player, dialog, "dialog_find_take")
end

-- ======== /findblock DIALOGS ========
-- Items restricted to exactly this role (the only ones that can be removed from its list)
local function getOwnItems(roleID)
    local ids = {}
    for itemIDStr, blockedRole in pairs(blacklist) do
        if blockedRole == roleID then
            local itemID = tonumber(itemIDStr)
            if itemID then ids[#ids + 1] = itemID end
        end
    end
    table.sort(ids) -- pairs() has no fixed order, so sort to keep the list stable
    return ids
end

-- Roles above `roleID` that have restricted items (nearest role first) and their item counts
local function getHigherRolesWithItems(roleID)
    local counts = {}
    for _, blockedRole in pairs(blacklist) do
        if blockedRole > roleID then counts[blockedRole] = (counts[blockedRole] or 0) + 1 end
    end
    local roles = {}
    for blockedRole in pairs(counts) do roles[#roles + 1] = blockedRole end
    table.sort(roles)
    return roles, counts
end

local function isKnownRole(roleID)
    return roleID ~= nil and roleID > 0 and (ROLE_NAMES[roleID] ~= nil or #getOwnItems(roleID) > 0)
end

local function roleLabel(roleID)
    return ROLE_NAMES[roleID] or ("Role " .. roleID)
end

-- Level 1: one button per role
local function openFindblockMainDialog(player)
    local ownCounts = {}
    for _, blockedRole in pairs(blacklist) do
        ownCounts[blockedRole] = (ownCounts[blockedRole] or 0) + 1
    end

    local dialog = {
        "set_default_color|`o\n",
        "add_label_with_icon|big|`wItem Blacklisted on Find``|left|" .. CONFIG.DIALOG_ICON .. "|\n",
        "add_smalltext|Select a role to manage its restricted items:|left|\n",
        "add_spacer|small|\n",
    }

    local function roleButton(roleID)
        return button("findblock_btn_role_" .. roleID,
            roleLabel(roleID) .. " (" .. roleID .. "): " .. (ownCounts[roleID] or 0) .. " Items")
    end

    local shown = {}
    for _, roleID in ipairs(ROLE_IDS) do
        -- Roles above MENU_MAX_ROLE are hidden, unless items are restricted to exactly that role
        local inRange = roleID >= CONFIG.FIND_MIN_ROLE and roleID <= CONFIG.MENU_MAX_ROLE
        if inRange or (ownCounts[roleID] or 0) > 0 then
            shown[roleID] = true
            dialog[#dialog + 1] = roleButton(roleID)
        end
    end

    -- Restrictions saved with a role ID that is no longer in ROLE_IDS stay reachable
    local extra = {}
    for roleID in pairs(ownCounts) do
        if not shown[roleID] then extra[#extra + 1] = roleID end
    end
    table.sort(extra)
    for _, roleID in ipairs(extra) do
        dialog[#dialog + 1] = roleButton(roleID)
    end

    dialog[#dialog + 1] = "add_custom_break|\n"
    dialog[#dialog + 1] = "add_spacer|small|\n"
    dialog[#dialog + 1] = button("find_btn_close", "Close")
    finishDialog(player, dialog, "dialog_findblock_main")
end

-- Level 2: the chosen role's own items (icons, editable), then a button for every higher role
local function openFindblockRoleMenu(player, roleID)
    local session = getSession(player)
    session.fbRole = roleID
    session.fbView = nil
    session.remPageIDs = {}

    local own = getOwnItems(roleID)
    local page, totalPages, first, last = pageBounds(#own, session.remPage)
    session.remPage = page

    local dialog = {
        "set_default_color|`o\n",
        "add_label_with_icon|big|`w" .. roleLabel(roleID) .. " Restrictions``|left|" .. CONFIG.DIALOG_ICON .. "|\n",
        "add_smalltext|Items only `w" .. roleLabel(roleID) .. "`` and above can see: `2" .. #own .. "``|left|\n",
        "add_spacer|small|\n",
    }

    if #own == 0 then
        dialog[#dialog + 1] = "add_smalltext|`4No items are restricted to this role.``|left|\n"
        dialog[#dialog + 1] = "add_smalltext|Press `wAdd Items`` to add new restrictions.|left|\n"
    else
        dialog[#dialog + 1] = "add_smalltext|Page `w" .. page .. "/" .. totalPages ..
            "``. Tick items and press `wRemove Selected``, or add new items.|left|\n"
        dialog[#dialog + 1] = "add_spacer|small|\n"
        session.remPageIDs = addItemGrid(dialog, own, first, last, "fbrem_")
        dialog[#dialog + 1] = "add_spacer|small|\n"
        if page > 1 then dialog[#dialog + 1] = button("findblock_btn_prev", "Previous Page") end
        if page < totalPages then dialog[#dialog + 1] = button("findblock_btn_next", "Next Page") end
    end

    -- Higher roles that have items: view only
    local higher, counts = getHigherRolesWithItems(roleID)
    if #higher > 0 then
        dialog[#dialog + 1] = "add_spacer|small|\n"
        dialog[#dialog + 1] = "add_smalltext|Items restricted to higher roles are hidden from `w" .. roleLabel(roleID) ..
            "`` too. Open a list below (view only):|left|\n"
        for _, higherRole in ipairs(higher) do
            dialog[#dialog + 1] = button("findblock_view_" .. higherRole,
                roleLabel(higherRole) .. " (" .. higherRole .. "): " .. counts[higherRole] .. " Items")
        end
    end

    dialog[#dialog + 1] = "add_spacer|small|\n"
    dialog[#dialog + 1] = button("findblock_btn_add", "Add Items")
    if #own > 0 then dialog[#dialog + 1] = button("findblock_btn_rem", "Remove Selected") end
    dialog[#dialog + 1] = button("findblock_btn_back", "Back")
    dialog[#dialog + 1] = button("find_btn_close", "Close")
    finishDialog(player, dialog, "dialog_findblock_role")
end

-- Level 3: the item list of a higher role, view only (nothing here can be changed)
local function openFindblockViewDialog(player, viewRole)
    local session = getSession(player)
    session.fbView = viewRole

    local ids = getOwnItems(viewRole)
    local total = #ids
    local page, totalPages, first, last = pageBounds(total, session.viewPage)
    session.viewPage = page

    local dialog = {
        "set_default_color|`o\n",
        "add_label_with_icon|big|`w" .. roleLabel(viewRole) .. " Restrictions``|left|" .. CONFIG.DIALOG_ICON .. "|\n",
        "add_smalltext|`wView only``: items only `w" .. roleLabel(viewRole) ..
            "`` and above can see (`2" .. total .. "``). They can only be changed from the `w" ..
            roleLabel(viewRole) .. "`` menu.|left|\n",
        "add_spacer|small|\n",
    }

    if total == 0 then
        dialog[#dialog + 1] = "add_smalltext|`4No items are restricted to this role.``|left|\n"
    else
        dialog[#dialog + 1] = "add_smalltext|Page `w" .. page .. "/" .. totalPages .. "``.|left|\n"
        dialog[#dialog + 1] = "add_spacer|small|\n"
        addItemGrid(dialog, ids, first, last, "fbview_")
    end

    dialog[#dialog + 1] = "add_spacer|small|\n"
    if page > 1 then dialog[#dialog + 1] = button("findblock_btn_prev", "Previous Page") end
    if page < totalPages then dialog[#dialog + 1] = button("findblock_btn_next", "Next Page") end
    dialog[#dialog + 1] = button("findblock_btn_back", "Back")
    dialog[#dialog + 1] = button("find_btn_close", "Close")
    finishDialog(player, dialog, "dialog_findblock_list")
end

local function openFindblockRemConfirm(player, session)
    local queue = session.remQueue
    local dialog = {
        "set_default_color|`o\n",
        "add_label_with_icon|big|`wRemove Restriction``|left|" .. CONFIG.DIALOG_ICON .. "|\n",
        "add_smalltext|Are you sure you want to remove the restriction for these `w" .. #queue .. "`` item(s)?|left|\n",
        "add_spacer|small|\n",
    }

    local names = {}
    for i = 1, math.min(#queue, 10) do
        local item = getItem(queue[i])
        names[#names + 1] = "- " .. (item and cleanName(item) or "Unknown")
    end
    dialog[#dialog + 1] = "add_textbox|`w" .. table.concat(names, "\n") .. "``|left|\n"
    if #queue > 10 then
        dialog[#dialog + 1] = "add_smalltext|... and " .. (#queue - 10) .. " more.|left|\n"
    end

    dialog[#dialog + 1] = "add_custom_break|\n"
    dialog[#dialog + 1] = "add_spacer|small|\n"
    dialog[#dialog + 1] = button("fb_rem_yes", "Yes")
    dialog[#dialog + 1] = button("fb_rem_no", "No")
    finishDialog(player, dialog, "dialog_findblock_rem_conf")
end

-- Search for items to restrict (items that are already restricted are left out)
local function openFindblockAddDialog(player)
    local session = getSession(player)
    local add = session.add

    local total = #add.results
    local page, totalPages, first, last = pageBounds(total, add.page)
    add.page = page
    add.pageIDs = {}

    local dialog = {
        "set_default_color|`o\n",
        "add_label_with_icon|big|`wAdd Restricted Items``|left|" .. CONFIG.DIALOG_ICON .. "|\n",
        "add_smalltext|Restricting to: `w" .. roleLabel(session.fbRole or 0) .. "`` and above.|left|\n",
        "add_spacer|small|\n",
        "add_text_input|fb_search_term|Search:|" .. add.term .. "|" .. CONFIG.MAX_SEARCH_LENGTH .. "|\n",
        button("fb_add_btn_search", "Search"),
        "add_spacer|small|\n",
    }

    if add.term == "" then
        dialog[#dialog + 1] = "add_smalltext|Type part of an item name and press Search (`wlock`` finds every item with lock in its name). Start with `w@`` for whole words only (`w@lock`` finds only locks, not Block). Seeds are hidden unless you include the word `wseed``.|left|\n"
    elseif total == 0 then
        dialog[#dialog + 1] = "add_smalltext|`4No unrestricted items found for \"" .. add.term .. "\".``|left|\n"
    else
        dialog[#dialog + 1] = "add_smalltext|Results for `w\"" .. add.term .. "\"`` (`2" .. total ..
            "``) - Page `w" .. page .. "/" .. totalPages ..
            "``. Tick the items you want to restrict, then press `wAdd Selected``.|left|\n"
        dialog[#dialog + 1] = "add_spacer|small|\n"
        add.pageIDs = addItemGrid(dialog, add.results, first, last, "fbpick_")

        dialog[#dialog + 1] = "add_spacer|small|\n"
        if page > 1 then dialog[#dialog + 1] = button("fb_add_btn_prev", "Previous Page") end
        if page < totalPages then dialog[#dialog + 1] = button("fb_add_btn_next", "Next Page") end
        dialog[#dialog + 1] = button("fb_add_btn_confirm", "Add Selected")
    end

    dialog[#dialog + 1] = button("fb_add_btn_close", "Cancel")
    finishDialog(player, dialog, "dialog_findblock_add")
end

-- ======== TAKE ========
local function startTake(player, session, data)
    local find = session.find
    local playerRole = getHighestRole(player)
    local ticked = {}
    for _, itemID in ipairs(find.pageIDs) do
        if data["pick_" .. itemID] == "1" and getValidItem(itemID) and canSee(playerRole, itemID) then
            ticked[#ticked + 1] = itemID
        end
    end

    if #ticked == 0 then
        player:onConsoleMessage("`4Tick at least one item first.``")
        openFindDialog(player)
        return
    end
    if #ticked > CONFIG.MAX_TICKED then
        player:onConsoleMessage("`4You can take at most " .. CONFIG.MAX_TICKED .. " different items at once.``")
        openFindDialog(player)
        return
    end

    find.queue = ticked
    find.amounts = {}
    openTakeDialog(player)
end

local function confirmTake(player, session, data)
    local find = session.find
    local entries, problems = {}, {}
    for _, itemID in ipairs(find.queue) do
        local typed = tostring(data["amt_" .. itemID] or "")
        -- Only a short run of digits is ever put back into the dialog
        find.amounts[itemID] = typed:match("^%d%d?%d?$") and typed or tostring(CONFIG.DEFAULT_AMOUNT)

        local amount = tonumber(typed)
        if not amount or amount ~= math.floor(amount) or amount < 0 or amount > CONFIG.MAX_AMOUNT then
            problems[#problems + 1] = getItem(itemID):getName()
        elseif amount > 0 then
            entries[#entries + 1] = {id = itemID, amount = amount}
        end
    end

    if #problems > 0 then
        player:onConsoleMessage("`4Invalid amount for: `w" .. table.concat(problems, ", ") ..
            "`4. Use a whole number from 0 to " .. CONFIG.MAX_AMOUNT .. ".``")
        openTakeDialog(player)
        return
    end
    if #entries == 0 then
        player:onConsoleMessage("`4Every amount is 0, so there is nothing to take.``")
        openTakeDialog(player)
        return
    end

    -- Dialog data comes from the client, so the role and blacklist are checked again for every item
    local playerRole = getHighestRole(player)
    local given, failed = {}, 0
    for _, entry in ipairs(entries) do
        local item = getValidItem(entry.id)
        -- Same pattern as Buy.lua: try the inventory first, then the backpack
        if item and canSee(playerRole, entry.id) and
            (player:changeItem(entry.id, entry.amount, 0) or player:changeItem(entry.id, entry.amount, 1)) then
            given[#given + 1] = entry.amount .. " " .. item:getName()
        else
            failed = failed + 1
        end
    end

    if #given > 0 then
        local shown = {}
        for i = 1, math.min(#given, 5) do shown[i] = given[i] end
        local more = #given > 5 and (" and " .. (#given - 5) .. " more") or ""
        player:onConsoleMessage("`2Took: `w" .. table.concat(shown, ", ") .. more .. "`2.``")
    end
    if failed > 0 then
        player:onConsoleMessage("`4" .. failed .. " item(s) could not be added (no space or no permission).``")
    end
    sessions[player:getUserID()] = nil
end

-- ======== COMMANDS ========
registerLuaCommand({
    command = "find",
    roleRequired = CONFIG.FIND_MIN_ROLE,
    description = "Search and take items. Use @name to match whole words only."
})

registerLuaCommand({
    command = "f",
    roleRequired = CONFIG.FIND_MIN_ROLE,
    description = "Alias for /find."
})

registerLuaCommand({
    command = "findblock",
    roleRequired = CONFIG.FINDBLOCK_MIN_ROLE,
    description = "Open the menu to restrict items in /find to a minimum role."
})

-- Tells the player why nothing happened instead of failing silently
local function denyAccess(player, minRole)
    player:onConsoleMessage("`4You don't have permission to use this. Required: `w" ..
        roleLabel(minRole) .. "`4 or above.``")
end

local function handleCommand(player, fullCommand)
    local command, args = fullCommand:match("^(%S+)%s*(.*)")
    if not command then return false end
    command = command:lower()

    if command == "find" or command == "f" then
        if not player:hasRole(CONFIG.FIND_MIN_ROLE) then
            denyAccess(player, CONFIG.FIND_MIN_ROLE)
            return true
        end
        local find = getSession(player).find
        if args:match("%S") then
            local playerRole = getHighestRole(player)
            find.term, find.results = searchItems(args, function(itemID)
                return canSee(playerRole, itemID)
            end)
            find.page = 1
        end
        openFindDialog(player)
        return true
    end

    if command == "findblock" then
        if not player:hasRole(CONFIG.FINDBLOCK_MIN_ROLE) then
            denyAccess(player, CONFIG.FINDBLOCK_MIN_ROLE)
            return true
        end

        openFindblockMainDialog(player)
        return true
    end

    return false
end

onPlayerCommandCallback(function(world, player, fullCommand)
    local ok, handled = tryCall(handleCommand, player, fullCommand)
    if not ok then
        print("[ItemFinder] Command error: " .. tostring(handled))
        return false
    end
    return handled == true
end)

-- ======== DIALOG HANDLING ========
local FIND_DIALOGS = {
    dialog_find_main = true,
    dialog_find_take = true,
}

local FINDBLOCK_DIALOGS = {
    dialog_findblock_main = true,
    dialog_findblock_role = true,
    dialog_findblock_list = true,
    dialog_findblock_rem_conf = true,
    dialog_findblock_add = true,
}

-- Back to the selected role's menu, or to the main menu if no role is selected
local function backToFindblock(player, session)
    if session.fbRole then
        openFindblockRoleMenu(player, session.fbRole)
    else
        openFindblockMainDialog(player)
    end
end

local function handleFindMain(player, session, clicked, data)
    local find = session.find
    if clicked == "find_btn_search" then
        local playerRole = getHighestRole(player)
        find.term, find.results = searchItems(data["find_search_term"], function(itemID)
            return canSee(playerRole, itemID)
        end)
        find.page = 1
        openFindDialog(player)
    elseif clicked == "find_btn_prev" then
        find.page = find.page - 1
        openFindDialog(player)
    elseif clicked == "find_btn_next" then
        find.page = find.page + 1
        openFindDialog(player)
    elseif clicked == "find_btn_take" then
        startTake(player, session, data)
    end
end

local function handleFindTake(player, session, clicked, data)
    if not session.find.queue then return end
    if clicked == "find_take_confirm" then
        confirmTake(player, session, data)
    elseif clicked == "find_take_back" then
        openFindDialog(player)
    elseif clicked == "find_take_cancel" then
        sessions[player:getUserID()] = nil
    end
end

local function handleFindblockMain(player, session, clicked)
    local roleID = tonumber(clicked:match("^findblock_btn_role_(%d+)$"))
    if roleID and isKnownRole(roleID) then
        session.remPage = 1
        openFindblockRoleMenu(player, roleID)
    end
end

-- Level 2: the selected role's own items (editable) and the buttons for higher roles
local function handleFindblockRoleMenu(player, session, clicked, data)
    if clicked == "findblock_btn_back" then
        session.fbRole = nil
        session.fbView = nil
        openFindblockMainDialog(player)
        return
    end
    if not session.fbRole then return end

    if clicked == "findblock_btn_prev" then
        session.remPage = session.remPage - 1
        openFindblockRoleMenu(player, session.fbRole)
    elseif clicked == "findblock_btn_next" then
        session.remPage = session.remPage + 1
        openFindblockRoleMenu(player, session.fbRole)
    elseif clicked == "findblock_btn_add" then
        session.add = {term = "", results = {}, page = 1, pageIDs = {}}
        openFindblockAddDialog(player)
    elseif clicked == "findblock_btn_rem" then
        -- Only items restricted to exactly this role can be removed
        local ticked = {}
        for _, itemID in ipairs(session.remPageIDs) do
            if data["fbrem_" .. itemID] == "1" and blacklist[tostring(itemID)] == session.fbRole then
                ticked[#ticked + 1] = itemID
            end
        end
        if #ticked > 0 then
            session.remQueue = ticked
            openFindblockRemConfirm(player, session)
        else
            player:onConsoleMessage("`4Tick at least one item to remove first.``")
            openFindblockRoleMenu(player, session.fbRole)
        end
    else
        local viewRole = tonumber(clicked:match("^findblock_view_(%d+)$"))
        -- Only a higher role that really has items can be opened
        if viewRole and viewRole > session.fbRole and #getOwnItems(viewRole) > 0 then
            session.viewPage = 1
            openFindblockViewDialog(player, viewRole)
        end
    end
end

-- Level 3: a higher role's list, view only
local function handleFindblockView(player, session, clicked)
    if clicked == "findblock_btn_back" then
        if session.fbRole then
            openFindblockRoleMenu(player, session.fbRole)
        else
            openFindblockMainDialog(player)
        end
        return
    end
    if not session.fbView then return end

    if clicked == "findblock_btn_prev" then
        session.viewPage = session.viewPage - 1
        openFindblockViewDialog(player, session.fbView)
    elseif clicked == "findblock_btn_next" then
        session.viewPage = session.viewPage + 1
        openFindblockViewDialog(player, session.fbView)
    end
end

local function handleFindblockRemConfirm(player, session, clicked)
    if clicked == "fb_rem_yes" then
        if session.remQueue then
            local count = 0
            for _, itemID in ipairs(session.remQueue) do
                if blacklist[tostring(itemID)] == session.fbRole then
                    blacklist[tostring(itemID)] = nil
                    count = count + 1
                end
            end
            saveBlacklist()
            player:onConsoleMessage("`2Removed restriction for " .. count .. " item(s).``")
        end
        session.remQueue = nil
        backToFindblock(player, session)
    elseif clicked == "fb_rem_no" then
        session.remQueue = nil
        backToFindblock(player, session)
    end
end

local function handleFindblockAdd(player, session, clicked, data)
    local add = session.add
    if clicked == "fb_add_btn_search" then
        add.term, add.results = searchItems(data["fb_search_term"], function(itemID)
            return blacklist[tostring(itemID)] == nil
        end)
        add.page = 1
        openFindblockAddDialog(player)
    elseif clicked == "fb_add_btn_prev" then
        add.page = add.page - 1
        openFindblockAddDialog(player)
    elseif clicked == "fb_add_btn_next" then
        add.page = add.page + 1
        openFindblockAddDialog(player)
    elseif clicked == "fb_add_btn_confirm" then
        if not isKnownRole(session.fbRole) then return end
        local added = 0
        for _, itemID in ipairs(add.pageIDs) do
            if data["fbpick_" .. itemID] == "1" and getValidItem(itemID)
                and blacklist[tostring(itemID)] == nil then
                blacklist[tostring(itemID)] = session.fbRole
                added = added + 1
            end
        end
        if added > 0 then
            saveBlacklist()
            player:onConsoleMessage("`2Added " .. added .. " item(s) to the restriction list.``")
            openFindblockRoleMenu(player, session.fbRole)
        else
            player:onConsoleMessage("`4Tick at least one item first.``")
            openFindblockAddDialog(player)
        end
    elseif clicked == "fb_add_btn_close" then
        backToFindblock(player, session)
    end
end

local function handleDialog(player, data)
    local dialogName = data["dialog_name"] or ""
    local isFind = FIND_DIALOGS[dialogName]
    local isFindblock = FINDBLOCK_DIALOGS[dialogName]
    if not isFind and not isFindblock then return false end

    -- Dialog packets can be forged, so never trust that only allowed players opened these
    local minRole = isFindblock and CONFIG.FINDBLOCK_MIN_ROLE or CONFIG.FIND_MIN_ROLE
    if not player:hasRole(minRole) then
        sessions[player:getUserID()] = nil
        denyAccess(player, minRole)
        return true
    end

    local clicked = data["buttonClicked"] or ""
    local userID = player:getUserID()

    if clicked == "find_btn_close" then
        sessions[userID] = nil
        return true
    end

    if isFindblock then
        local session = getSession(player)
        if dialogName == "dialog_findblock_main" then
            handleFindblockMain(player, session, clicked)
        elseif dialogName == "dialog_findblock_role" then
            handleFindblockRoleMenu(player, session, clicked, data)
        elseif dialogName == "dialog_findblock_list" then
            handleFindblockView(player, session, clicked)
        elseif dialogName == "dialog_findblock_rem_conf" then
            handleFindblockRemConfirm(player, session, clicked)
        elseif dialogName == "dialog_findblock_add" then
            handleFindblockAdd(player, session, clicked, data)
        end
        return true
    end

    -- /find dialogs only work while a session exists (it is created by /find)
    local session = sessions[userID]
    if not session then return true end

    if dialogName == "dialog_find_main" then
        handleFindMain(player, session, clicked, data)
    elseif dialogName == "dialog_find_take" then
        handleFindTake(player, session, clicked, data)
    end
    return true
end

onPlayerDialogCallback(function(world, player, data)
    local ok, handled = tryCall(handleDialog, player, data)
    if not ok then
        print("[ItemFinder] Dialog error: " .. tostring(handled))
        return false
    end
    return handled == true
end)

onPlayerDisconnectCallback(function(player)
    sessions[player:getUserID()] = nil
end)