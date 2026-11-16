# GTPSCloud Lua Development Instructions

## Purpose

Use these instructions when generating, reviewing, or modifying Lua scripts for GTPSCloud. Produce simple, readable code that follows the documented API and the capabilities of the target server build.

## Language

- Write generated code comments, documentation, explanations inside project files, and configuration guidance in English.
- Use descriptive English names for new variables and helper functions. Preserve official API names and existing identifiers.
- Use English for new user-facing strings unless the user requests another language or the project already defines localized text.
- Reply in the user's preferred language unless they request English responses. The English requirement applies to project content by default.
- Do not translate, rename, or alter API identifiers, signatures, or parameter order.

## Read the Local References First

1. Read the relevant sections of [GTPSCloud-API.md](GTPSCloud-API.md) for the API contract.
2. Read the matching recipes and entries in [GTPSCloud-API-Examples.md](GTPSCloud-API-Examples.md) for usage patterns.
3. Read [GTPSCloud-Runtime-Notes.md](GTPSCloud-Runtime-Notes.md), [GTPSCloud-Ingame-Patterns.md](GTPSCloud-Ingame-Patterns.md), and the user-confirmed scripts in `reference/` for target-build behavior.
4. Consult the [official documentation](https://dash.gtps.cloud/docs) when local material is incomplete or needs updating.

The local reference was collected on November 16, 2026. Examples are learning material, not proof that a binding works on every build. Confirmed target-build behavior and explicit user corrections take precedence over incompatible examples. Record relevant discrepancies rather than silently treating conflicting signatures as equivalent.

The user confirmed that the supplied admin script runs normally. For this project, follow its `os.time()`, `timer.setTimeout(...)`, `timer.clear(...)`, and global static `DiscordBot.method(...)` conventions. Keep event/player instance methods as colon calls. Earlier generated class-signature examples do not override this evidence. Do not assume the script proves unrelated HTTP, database, file, bitwise, or interval bindings.

Search for the exact method or callback name. Read its description, parameter order, return values, and surrounding context before using it. Do not infer capabilities from a similarly named Growtopia API, bot framework, or standard Lua library.

## Sandbox Compatibility

- Treat `pcall` and `os.date` as unavailable on the user's target build.
- Do not depend on `xpcall`, `io`, `os.execute`, `os.remove`, `os.rename`, `package`, `debug`, LuaSocket, or external modules unless the target build explicitly confirms availability.
- Do not install or import a replacement standard library as a workaround for missing sandbox features.
- Use documented GTPSCloud file, directory, HTTP, timer, and database APIs for those operations.
- Avoid assuming a particular Lua version or newer language features merely because local syntax checks support them. Follow the target build and existing project style.
- Do not assume JSON encode/decode functions, HTTP servers, environment-variable access, or filesystem paths exist without documentation or project evidence.

## Optional tryCall Helper

Use this compatibility helper only when an optional wrapper is useful:

```lua
-- pcall may be missing on some builds.
local function tryCall(fn, ...)
    if pcall then return pcall(fn, ...) end
    return true, fn(...)
end
```

Its behavior is precise:

- When `pcall` exists, it returns the protected-call status followed by the function's results or error.
- When `pcall` is absent, it calls `fn` directly. An exception still propagates and may terminate the current execution.
- The fallback's leading `true` does not prove that the underlying API operation succeeded.
- If `fn` returns `false`, the wrapper returns `true, false`. If it returns `nil, errorMessage`, the wrapper returns `true, nil, errorMessage`.
- Preserve multiple return values. Do not replace this helper with a wrapper that silently discards results or fabricates success.

Do not use this helper as the error boundary for an operation that requires guaranteed exception recovery. Prefer input checks and documented error returns. If an API can throw and has no documented recovery mechanism, state that limitation.

## Objects, Methods, and Bindings

- Obtain `player`, `world`, `tile`, and Discord event objects from documented callbacks or getters.
- Treat class names in signatures as types, not the currently active instance. Call `player:getName()` on an actual Player object.
- Check nullable or unavailable objects before accessing their methods.
- Use documented constructors only. The working script accesses DiscordBot directly as a global API table. Do not invent a DiscordBot constructor, a global bot getter, or an object factory.
- Keep instance receivers and parameter order explicit. In Lua, `object:method(value)` passes `object` as the first argument; `object.method(value)` does not.
- The reference has conflicting utility notation: class pages use colon calls, while Utilities includes dot calls and alternate names such as `db.open`/`LuaDB` versus `sqlite:open`/`SqliteDB`.
- Follow a binding confirmed on the target build. Without confirmation, follow the relevant class-page signature and identify the assumption. Do not automatically retry a write using another notation.
- Do not guess item IDs, role IDs, flags, packet layouts, event IDs, resource paths, or config fields. Accept them as inputs or use values supported by the reference and project configuration.
- Do not treat a `void` return as a documented success flag.

## Time and Scheduling

- Never use `os.date` for timestamps or formatting.
- The os reference documents Unix time in seconds and writes `os:time()`, but this project's working script uses `os.time()`. Use the confirmed dot form here.
- Use `getTodaysDate()` when a server-provided date label is sufficient. Do not claim its format or timezone is guaranteed.
- Use numeric timestamps for cooldowns and expiration comparisons.
- Timer delays are in seconds. Do not silently pass millisecond values.
- Do not assume other delay or coordinate fields use the same units. Check each method separately.
- Use timers rather than busy loops or blocking waits.
- Keep recurring callbacks lightweight, retain timer IDs, and clear intervals when finished.
- Consider reload behavior and cleanup for in-memory cooldowns and per-player state.

## Callbacks and Commands

- Copy callback argument names and order from the reference.
- Register each intended handler once during script initialization. Do not register it repeatedly from a tick or another frequently called callback.
- Find and Help use `true` for handled command/dialog events and `false` for unrelated ones. Follow this project pattern for those callbacks; do not generalize it into cancellation semantics for all events.
- On this project, `onPlayerDialogCallback` receives `(world, player, data)`, where `data` is a field table with `dialog_name`, `buttonClicked`, and submitted input values. The collected reference's third-argument name `dialogName` does not describe the working payload correctly.
- The working in-game scripts parse slash-free command names and their arguments from `fullCommand`. Do not copy Discord prefix parsing into in-game callbacks.
- `getRoles()` entries expose `roleID`, `roleName`, and `allowCommands` in the working Help script. Copy collections before sorting; displayed role categories do not authorize command execution.
- Revalidate roles, selections, and amounts on dialog submission. Keep session state per user ID and clear it on disconnect when no longer needed.
- Register custom commands through `registerLuaCommand` with documented configuration fields.
- Match the command representation used by the target build. Do not assume the presence or absence of a slash or arguments without evidence.
- Validate command input before changing state. Apply the intended role or ownership restrictions to administrative actions.
- Avoid sending chat messages, logging every event, or saving persistent data on every tick unless the feature specifically requires it.
- Snapshot stable IDs or values when retaining information after a callback; do not assume referenced game objects remain valid indefinitely.

## HTTP

- Run documented asynchronous HTTP operations inside a coroutine.
- Follow the selected binding's argument order. The class reference documents `http:get(url, headers)` and `http:post(url, headers, postData)`; the Utilities page lists a different POST form.
- Preserve both response body and status code. A status of `-1` indicates a transport failure in the class reference; HTTP error statuses also need handling.
- A successful initial `coroutine.resume` does not mean the request has completed or that later execution cannot fail.
- Respect the documented one-call-per-50-ms-per-thread limit and the restriction on local/private IP destinations.
- Do not assume an available JSON library. Use plain text or a confirmed encoder when appropriate.

## Files and Persistent Data

- Use the documented `file` and `dir` bindings with paths inside the server's `localStorage` scope.
- Remember that `file:write` replaces file content and `dir:delete` recursively removes a directory.
- Check existence where appropriate, but do not claim it prevents every I/O exception.
- Use `saveDataToServer`/`loadDataFromServer` for documented table persistence and `saveStringToServer`/`loadStringFromServer` for strings.
- Namespace persistent keys by feature and include stable player IDs for per-player state.
- Handle missing data deliberately. Do not replace a valid `false` or zero value with a default because it is mistaken for absence.

## SQLite

- Use the database binding supported by the target build; do not assume `db` and `sqlite` are aliases.
- Check documented `(nil, errorMessage)` results when opening or querying a database.
- Close the database on success and on handled error paths.
- SELECT results contain rows whose values are strings according to the reference. Convert numeric values explicitly when needed.
- Do not invent prepared-statement or parameter-binding APIs. Avoid interpolating untrusted text into SQL; use a supported binding mechanism if one is confirmed.
- Do not assume ATTACH, DETACH, or extension loading is permitted.

## Discord and Rendering

- Use the appropriate event object for each Discord interaction. Reply signatures differ, especially for slash commands.
- Ignore bot-authored messages where needed to prevent reply loops.
- Preserve Discord IDs as strings and obtain bot credentials from the project's established configuration. Never embed real tokens in examples.
- Do not invent modal fields, component shapes, or flags. Follow the corresponding method description.
- Use documented Font, Texture, Sprite, and RenderTexture constructors and methods. Accept asset paths from project configuration rather than assuming assets exist.
- Call `display()` when required by the documented rendering pattern before exporting or using the rendered result.

## Implementation Style

- Prefer small local functions, clear names, and straightforward control flow.
- Keep examples focused on one behavior and state their required context.
- Use complete Lua statements rather than signature placeholders containing optional-parameter markers such as `b?`.
- Keep functions that change server or player state explicit; do not execute a catalog of examples at script load.
- Do not combine all snippets in the examples document into one script. Repeated names such as `example` are intentional independent demonstrations.
- Preserve existing project conventions and avoid unrelated refactors.
- When details are missing, complete the parts supported by evidence, identify the missing contract, and request only information needed to finish correctly.

## Verification and Delivery

1. Check every used API name, receiver, argument order, and return contract against the references and target-build evidence.
2. Check Lua syntax with available tooling compatible with the target build. Passing a local Lua 5.4 check alone does not establish GTPSCloud compatibility.
3. For behavior changes, verify relevant branches such as missing objects, missing data, cooldown boundaries, and documented error returns.
4. Test compatibility logic with `pcall` absent and without relying on `os.date`.
5. Use mocks when the live runtime is unavailable, and distinguish mock verification from execution against GTPSCloud.
6. Do not run mutations against a live server merely to verify syntax. Use an appropriate test context for changes to items, accounts, worlds, economy, or integration messages.
7. In the final handoff, link the changed files, summarize the behavior, state what was checked, and identify any remaining build-specific assumptions.

Never claim that code ran successfully on GTPSCloud unless it was actually tested there.

## Publication Boundary

Do not publish private Discord administrative scripts or derived administrative command implementations. Only the Find/Help source references and generic public learning examples are approved for inclusion. Additional uploaded files are not automatically approved for publication.
