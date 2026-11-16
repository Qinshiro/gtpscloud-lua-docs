# GTPSCloud Lua Learning Pack

API references, examples, and instructions for AI/Codex working on this GTPSCloud project.

## Give This Repository to an AI

Share this repository URL and include the following instruction:

> Read AGENTS.md first, then GTPSCloud-Runtime-Notes.md and GTPSCloud-Ingame-Patterns.md. Follow the user-confirmed script conventions when they differ from the API snapshot. Use the references and examples to build the requested GTPSCloud Lua feature. Do not assume pcall or os.date exists, and distinguish tested behavior from assumptions.

The learning pack contains a 33-section API snapshot, 784 minimal API-call examples, three standalone examples, and two public user-confirmed source scripts. Start with [llms.txt](llms.txt) for a compact AI-oriented index.

## Reading Order

1. [AGENTS.md](AGENTS.md): coding instructions and sandbox constraints.
2. [GTPSCloud-Runtime-Notes.md](GTPSCloud-Runtime-Notes.md): patterns from the user-confirmed working script.
3. [GTPSCloud-API.md](GTPSCloud-API.md): contracts collected from the official API documentation.
4. [GTPSCloud-API-Examples.md](GTPSCloud-API-Examples.md): practical recipes and minimal-call catalog.
5. [GTPSCloud-Ingame-Patterns.md](GTPSCloud-Ingame-Patterns.md): patterns from the user-confirmed [Find](reference/Find-Script.lua) and [Help](reference/Help-Script.lua) scripts, included as reference copies; see [Source Notes](SOURCE-NOTES.md).
6. [GTPSCloud-Additional-Reference.md](GTPSCloud-Additional-Reference.md): user-supplied audio filenames, IDs, colors, and time-formatting notes.

The earlier reference and examples include Indonesian explanatory text. New project guidance and standalone examples are written in English. API names are preserved exactly.

## Source Priority

Use explicit user corrections and confirmed target-build behavior first. The supplied working script uses `os.time()`, `timer.setTimeout(...)`, `timer.clear(...)`, and static `DiscordBot.method(...)` calls. Event/player instance methods use `:`.

Some collected signatures and generated examples use a different convention. Read the runtime notes before copying them. APIs not demonstrated by the working script remain documentation-based.

## Standalone Examples

| File | Command | Required configuration |
| --- | --- | --- |
| [discord-ping.lua](examples/discord-ping.lua) | `-learnping` | Discord channel ID |
| [discord-delayed-ping.lua](examples/discord-delayed-ping.lua) | `-learndelay` | Discord channel ID |
| [ingame-dialog.lua](examples/ingame-dialog.lua) | `/learnmenu` (in game) | No Discord configuration |

Each file is a separate example. Configure and load only those you need. Keep command names unique if other scripts are also running.

## Setup

1. Keep the Markdown files together so relative links resolve.
2. Replace configuration placeholders in the selected example with your Discord server's IDs. Keep IDs as strings.
3. Use your project's established GTPSCloud script-loading mechanism. The supplied material does not establish a dashboard installation procedure or upload directory.
4. Ensure the existing GTPSCloud Discord integration is connected and can access the configured channel.
5. Load the configured example once, then send its command in that channel.

For `ingame-dialog.lua`, load it using the same script mechanism and type `/learnmenu` in game. Click **Say Hello** to receive a console message. Discord configuration is not required for that example.

Unconfigured examples return before registering a handler. These examples use the existing global GTPSCloud DiscordBot integration, so no Discord token is embedded in the files.

## Verification Status

- The user confirmed the original admin, Find, and Help scripts run normally. No exact build number or per-command test results were supplied.
- The collected reference has 33 sections and 784 entries, including repeated or alternate utility entries.
- The earlier generated examples passed local Lua 5.4 syntax checks and selected mock behavior checks, which do not establish every GTPSCloud binding.
- New standalone examples are verified locally with mocks, without `pcall` or `os.date`. They have not been executed against the live server.

For future runtime observations, record the API form, inputs, result, build/version when known, and whether the evidence came from a live test, user confirmation, or a mock.
