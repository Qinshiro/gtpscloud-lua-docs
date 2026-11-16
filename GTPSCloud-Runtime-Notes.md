# GTPSCloud Runtime Notes

## Evidence and Scope

The owner confirmed runtime behavior using private project code and the public [Find](reference/Find-Script.lua) and [Help](reference/Help-Script.lua) references. Private administrative implementations are intentionally excluded from this repository. The exact server build was not supplied.

These are user-confirmed observations, not independent live-server tests of every branch. Read [In-Game Patterns](GTPSCloud-Ingame-Patterns.md) for the public command and dialog examples.

## Project Calling Conventions

- Use `os.time()` for Unix time. Do not use `os.date`.
- Use `timer.setTimeout(seconds, callback)` and `timer.clear(timerID)`.
- Access Discord through static `DiscordBot.method(...)` calls.
- Use colon calls for event and player instance methods, such as `event:getChannelID()` and `player:getCleanName()`.
- In-game dialog callbacks receive `(world, player, data)`. Read `data["dialog_name"]` and `data["buttonClicked"]`.
- The public Find/Help scripts use true for handled command/dialog events and false for unrelated ones. Do not generalize that pattern into cancellation semantics for other callbacks.

These conventions take precedence over conflicting class-signature examples for this project. HTTP, SQLite, file, directory, bitwise, and repeating-timer bindings remain unconfirmed by the supplied runtime evidence.

## Sandbox Compatibility

The owner reports that `pcall` is unavailable. The optional `tryCall` helper in AGENTS.md falls back to a direct call; exceptions still propagate. A leading true does not establish that an API operation succeeded. Preserve documented error returns and validate inputs.

Use timestamps for cooldowns. Discord timestamp markup can provide a date label without a local date-formatting library. Do not assume the server timezone or the format of `getTodaysDate()`.

## Public Examples

- [Discord ping](examples/discord-ping.lua): simple channel-filtered response.
- [Delayed ping](examples/discord-delayed-ping.lua): one-shot timeout with a stable channel ID.
- [In-game dialog](examples/ingame-dialog.lua): command and submitted dialog routing.

These standalone examples are learning adaptations checked with local syntax tooling and mocks. They have not been executed against the owner's live server. No private administrative command implementation is included.
