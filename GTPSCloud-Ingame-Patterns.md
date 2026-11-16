# GTPSCloud In-Game Patterns

## Source and Evidence

The user confirmed that both supplied scripts run normally on their server:

- [Find-Script.lua](reference/Find-Script.lua): item search, paginated dialogs, inventory grants, role restrictions, and persistent restrictions.
- [Help-Script.lua](reference/Help-Script.lua): dynamic command help built from role metadata.

The Find and Help reference copies preserve the supplied Lua source text, with line endings normalized for publication; see [Source Notes](SOURCE-NOTES.md). These notes describe code patterns in user-confirmed working scripts. They do not claim that every branch has been independently tested or that other GTPSCloud builds use the same behavior.

## In-Game Command Input

Both scripts register commands with a slash-free name:

```lua
registerLuaCommand({
    command = "learnmenu",
    roleRequired = 0,
    description = "Open the example menu."
})
```

The player types `/learnmenu`. The callback receives `(world, player, fullCommand)`; the working scripts match command names without the leading slash. Find parses the remaining arguments from the same string:

```lua
local function splitCommand(fullCommand)
    local command, arguments = fullCommand:match("^(%S+)%s*(.*)")
    if not command then return nil, "" end
    return command:lower(), arguments
end
```

For the input `find World Lock`, this produces `find` and `World Lock`. Spaces inside the search term remain part of the argument string. This parser does not add quote or escape handling.

Both working scripts return `true` for commands they handle and `false` for unrelated commands. Follow this established handled/unhandled pattern for this project's command and dialog callbacks. It does not establish cancellation behavior for unrelated callbacks such as chat, movement, or item events.

## Dialog Callback Payload: Important Reference Correction

The collected API page names the third argument `dialogName`. Both working scripts instead receive a field table:

```lua
onPlayerDialogCallback(function(world, player, data)
    local dialogName = data["dialog_name"] or ""
    local clicked = data["buttonClicked"] or ""
    if dialogName ~= "learn_menu" then return false end
    if clicked == "learn_close" then
        return true
    end
    return true
end)
```

Use the table form on this project. Do not compare the third argument itself to a dialog-name string.

| Field | Pattern in the working scripts |
| --- | --- |
| `data["dialog_name"]` | Name passed to `end_dialog` |
| `data["buttonClicked"]` | Button identifier from the submitted dialog |
| `data["find_search_term"]` | Text input with that identifier |
| `data["pick_" .. itemID]` | Checkbox value compared with the string `"1"` |
| `data["amt_" .. itemID]` | Amount text converted with `tonumber` and validated |

Do not treat the string `"0"` as false in Lua. Checkbox selection in Find is an explicit equality comparison with `"1"`.

## Dialog Construction

Both scripts build pipe-delimited lines and call `player:onDialogRequest(dialogText)` without supplying a delay or callback argument.

Help builds lines without trailing newlines and joins them with `table.concat(lines, "\n")`. Find includes newlines in its lines and uses `table.concat(lines)`. Use one convention consistently rather than accidentally adding or removing line separators.

Working directives include:

- `set_default_color`
- `add_label` and `add_label_with_icon`
- `add_smalltext` and `add_textbox`
- `add_button|button_id|Label|no_flags|0|0|`
- `add_text_input`
- `add_checkicon` and `add_custom_break` in Find
- `end_dialog|dialog_name|||`
- `add_quick_exit|`

Copy the exact field layout from the relevant working source. These examples do not document every dialog directive. The Find source keeps the final `add_checkicon` field empty to avoid an additional number drawn on the icon.

Clean inserted labels/search text to avoid breaking pipe-delimited dialog lines. The working scripts remove backticks, pipes, and control characters with `gsub("[`|%c]", "")`. This changes formatting intentionally; it is a project pattern rather than a universal escaping function.

## Role Metadata Exposed by getRoles

Help reads these fields from entries returned by `getRoles()`:

| Field | Usage in Help |
| --- | --- |
| `role.roleID` | Numeric ID, used to sort and select roles |
| `role.roleName` | Role display name |
| `role.allowCommands` | Table of command-name strings |

The local API reference only gives a broad collection type. The working scripts supply additional project evidence for the fields above.

```lua
local function roleCommandNames(role)
    local names = {}
    if type(role.allowCommands) ~= "table" then return names end
    for _, name in pairs(role.allowCommands) do
        if type(name) == "string" then names[#names + 1] = name end
    end
    table.sort(names)
    return names
end
```

Help copies the roles collection before sorting and keeps command-name lists separate from the server's own data. It groups lower numeric role IDs below the selected role and deduplicates displayed command names. That is the supplied project's presentation policy, not proof that arbitrary role IDs always encode privilege order.

Displaying a role's commands is not authorization to execute those commands. Role IDs and icon IDs in these scripts are project configuration. Keep them local rather than introducing a shared global `Roles` table that another script can overwrite.

## Find Search and Item Enumeration

- Enumerates IDs from `0` to `getItemsCount() - 1`, reads `getItem(id)`, and skips missing items/names.
- Normalizes names and uses literal `string.find` searches, avoiding Lua-pattern interpretation of the search term.
- A normal search matches substrings. Prefixing with `@` selects whole normalized words.
- Builds the name cache on the first search. There is no explicit item-reload invalidation in the source; add a deliberate invalidation strategy if adapting it to changing item definitions.
- Hides odd item IDs as seeds unless the term contains `seed`. This is the source's item convention; do not treat it as a guaranteed rule for every custom item set.
- Clamps pagination and stores the IDs actually rendered on the current page.

## Sessions, Restrictions, and Grants

Find stores transient state under `sessions[player:getUserID()]`, including rendered page IDs, selection queues, and validated amounts. Its disconnect callback clears that player's session:

```lua
local sessions = {}

onPlayerDisconnectCallback(function(player)
    sessions[player:getUserID()] = nil
end)
```

When adapting this pattern, use the same session table as the rest of the feature; the isolated snippet does not create a session by itself.

The working script treats submitted dialog fields as client input. It checks role permissions again on submission, considers only server-recorded page IDs, validates amounts, and rechecks item restrictions before granting. Reuse those checks rather than trusting a dialog to enforce access.

Its grant expression is:

```lua
local function addWithBackpackFallback(player, itemID, amount)
    return player:changeItem(itemID, amount, 0)
        or player:changeItem(itemID, amount, 1)
end
```

The third argument is numeric in this working script: `0` first, then `1` for the backpack fallback. `or` short-circuits; the second call runs only when the first result is falsy. Preserve this project pattern without inventing additional failure codes or transaction guarantees. Apply authorization and input validation before calling this helper.

Persistent restrictions use `saveDataToServer`/`loadDataFromServer`. Item-ID keys are converted to strings, and loaded role values are normalized with `tonumber`. Keep transient UI sessions separate from persistent configuration.

## Minimal Standalone Adaptation

[ingame-dialog.lua](examples/ingame-dialog.lua) demonstrates command registration, slash-free command matching, dialog construction, submitted field-table routing, and handled/unhandled returns. It does not search or grant items. The adaptation is locally mock-tested, not yet run on the user's server.
